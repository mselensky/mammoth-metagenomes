#!/bin/bash
#SBATCH -A p30996
#SBATCH -p genhimem
#SBATCH -t 48:00:00
#SBATCH -n 4
#SBATCH --mem-per-cpu=60G
#SBATCH --job-name=gtdbtk-denovo_bacteria_MC-refined-mags
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out
#SBATCH --mail-user=mselensky@u.northwestern.edu \
#SBATCH --mail-type=END,FAIL

module purge all
module load gtdbtk
#module load singularity
#module load python-miniconda3
#source /home/$USER/.bashrc
#source activate /projects/p31618/software/gtdbtk-2.1.1

# user-defined variables
input_genomes=/projects/p30996/mammoth/metagenomes/refined_bins_50-10_compiled/
output_dir=/projects/p30996/mammoth/metagenomes/refined_bins_gtdbtk-denovo-wf
scratch=/scratch/${USER}/refined_bins_50-10_compiled

# move genomes to single scratch folder 
mkdir -p $scratch
cd $input_genomes
for i in */; do
  i=$(basename $i)
  cd $i
  for j in *.fasta; do
    cp ${j} ${scratch}/${j}
  done
  cd ..
done

# build denovo bacterial tree
# singularity exec -B ${GTDBTK_DATA_PATH}:/refdata -B ${scratch}:/data /projects/p31618/software/gtdbtk_latest.sif \
gtdbtk de_novo_wf \
  --genome_dir $scratch \
  --bacteria \
  --extension fasta \
  --outgroup_taxon p__Chloroflexota \
  --out_dir $output_dir \
  --cpus $SLURM_NTASKS

# remove temp genome fastas
rm $scratch/*.fasta
