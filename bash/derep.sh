#!/bin/bash

#SBATCH -A p30996
#SBATCH -p short
#SBATCH -t 04:00:00
#SBATCH -N 1
#SBATCH -n 12
#SBATCH --mem-per-cpu=8G
#SBATCH --job-name=derep-mammoth_reassembled_mags
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out

# list of samples from which to bin (not run):
# assemblies=${parent_dir}/assembled-spades
# for i in $(ls -df $assemblies/*/); do basename $i;done > samples
IFS=$'\n' read -d '' -r -a input_args < /home/mjs9560/scripts/mammoth-metagenomes/samples

module purge all
module load python-miniconda3
source activate /projects/p31618/software/drep
module load checkm

output_dir=/scratch/mjs9560/anvio-bins-frmttd2-manual_dereplicated_12Apr23
input_genomes=/scratch/mjs9560/anvio-bins-frmttd2-manual_reassembled_bins
tmp_genomes=/scratch/${USER}/reassembled_bins-mammoth
mkdir -p $tmp_genomes
for i in ${input_args[@]}; do
  cp ${input_genomes}/${i}/reassembled_bins/*.fasta $tmp_genomes
done

dRep dereplicate \
  ${output_dir} \
  -g ${tmp_genomes}/*.fasta \
  -l 10000 \
  -comp 50 \
  -con 10 \
  -p ${SLURM_NTASKS} &&
  rm -r $tmp_genomes
