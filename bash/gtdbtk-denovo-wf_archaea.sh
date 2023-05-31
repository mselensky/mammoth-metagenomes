#!/bin/bash
#SBATCH -A p30996
#SBATCH -p genhimem
#SBATCH -t 48:00:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --mem-per-cpu=60G
#SBATCH --job-name=gtdbtk-denovo_archaea_MC-dereplicated
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out
#SBATCH --mail-user=mselensky@u.northwestern.edu \
#SBATCH --mail-type=END,FAIL

module purge all
module load gtdbtk

# user-defined variables
input_genomes=/scratch/${USER}/anvio-bins-frmttd2-manual_dereplicated/dereplicated_genomes/
output_dir=/scratch/${USER}/dereplicated_bins_gtdbtk-denovo-wf_archaea
scratch=/scratch/${USER}/tmp-derep-arc-bins

# move genomes to single scratch folder 
mkdir -p $scratch
cp $input_genomes/*.fa $scratch
# for i in */; do
#   i=$(basename $i)
#   cd $i
#   for j in *.fa; do
#     cp ${j} ${scratch}/${j}
#   done
#   cd ..
# done

# build denovo bacterial tree
gtdbtk de_novo_wf \
  --genome_dir $scratch \
  --archaea \
  --extension fa \
  --outgroup_taxon p__Halobacteriota \
  --out_dir $output_dir \
  --cpus $SLURM_NTASKS

# remove temp genomes
rm -r $scratch/
