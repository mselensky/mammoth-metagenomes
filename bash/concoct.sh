#!/bin/bash
#SBATCH -A p30996
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --array=0-20
#SBATCH --mem=8G
#SBATCH --job-name=concoct_binning-mammoth
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%A_%a-%x.out

# note: this script assumes that reads we

# list of samples from which to bin (not run):
# for i in $(ls -df $parent_dir/*/); do basename $i;done > samples
IFS=$'\n' read -d '' -r -a input_args < /home/mjs9560/scripts/mammoth-metagenomes/samples
metagenome=${input_args[$SLURM_ARRAY_TASK_ID]}

#### user inputs ####
# define parent genome directory and trimmed reads folder
parent_dir=/projects/p30996/mammoth/metagenomes/metaWRAP-initial-bins
assemb_dir=${parent_dir}/${metagenome}/work_files
concoct_out=${parent_dir}/${metagenome}/concoct_bins
####             ####

# load concoct conda environment
module purge all
module load python-miniconda3
source activate /projects/p31618/software/concoct

# cut sequences
cut_up_fasta.py \
  ${assemb_dir}/assembly.fa \
  -c 10000 \
  -o 0 \
  --merge_last \
  -b ${assemb_dir}/contigs_10K.bed > ${assemb_dir}/contigs_10K.fa

concoct_coverage_table.py \
  ${assemb_dir}/contigs_10K.bed \
  ${assemb_dir}/${metagenome}.bam > ${assemb_dir}/concoct_coverage_table.tsv

concoct \
  --composition_file ${assemb_dir}/contigs_10K.fa \
  --coverage_file ${assemb_dir}/concoct_coverage_table.tsv \
  -b ${assemb_dir}/concoct_output \
  -t $SLURM_NTASKS

merge_cutup_clustering.py \
  ${assemb_dir}/concoct_output/clustering_gt*.csv > ${assemb_dir}/concoct_output/clustering_merged.csv

mkdir -p $concoct_out
extract_fasta_bins.py \
  ${assemb_dir}/assembly.fa \
  ${assemb_dir}/concoct_output/clustering_merged.csv \
  --output_path ${concoct_out}




