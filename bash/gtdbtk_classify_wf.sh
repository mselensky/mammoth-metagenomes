#!/bin/bash
#SBATCH -A p30996
#SBATCH -p short
#SBATCH -t 04:00:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --mem=0
#SBATCH --job-name=gtdbtk-classify
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out
#SBATCH --mail-user=mselensky@u.northwestern.edu \
#SBATCH --mail-type=END,FAIL

module purge all
module load gtdbtk

# user-defined variables
input_genomes=/scratch/${USER}/anvio-bins-frmttd2-manual_dereplicated_12Apr23/dereplicated_genomes
output_dir=/scratch/${USER}/dereplicated_bins_gtdbtk-classify_wf
scratch=/scratch/${USER}/tmp-bins-$SLURM_JOB_ID

# move genomes to single scratch folder 
mkdir -p $scratch
cp $input_genomes/*.fasta $scratch

gtdbtk classify_wf \
  --genome_dir $scratch \
  -x fasta \
  --out_dir $output_dir \
  --cpus $SLURM_NTASKS

# remove temp genomes
rm -r $scratch/
