#!/bin/bash
#SBATCH -A p30996
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem-per-cpu=48G
#SBATCH --array=0-20
#SBATCH --job-name=ribotagger-mammoth-no-eukarya
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%A_%a-%x.out
#SBATCH --mail-user=mselensky@u.northwestern.edu \
#SBATCH --mail-type=END,FAIL

# RiboTagger - extract 16S sequences from whole metagenome shotgun sequencing
# https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-016-1378-x#Sec2

module load perl
module load R/4.1.1

IFS=$'\n' read -d '' -r -a input_args < /home/mjs9560/scripts/mammoth-metagenomes/samples
metagenome=${input_args[$SLURM_ARRAY_TASK_ID]}

RIBO_PATH=/projects/p31618/software/ribotagger/ribotagger
SCRATCH=/scratch/${USER}/ribotagger-v4-mammoth/no_eukarya
TMP_READS=/scratch/${USER}/tmp_reads_${SLURM_ARRAY_JOB_ID}

mkdir -p $SCRATCH
mkdir -p $TMP_READS

cp /projects/p31618/nu-seq/Osburn02_12.10.2021_metagenomes/reads/${metagenome}*.fastq.gz $TMP_READS

perl ${RIBO_PATH}/ribotagger.pl \
  -in ${TMP_READS}/${metagenome}*R1_001.fastq.gz ${TMP_READS}/${metagenome}*R2_001.fastq.gz \
  -out $SCRATCH/${metagenome} \
  -region v4 \
  -no-eukaryota \
  -filetype fastq
