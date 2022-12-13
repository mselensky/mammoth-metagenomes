#!/bin/bash

#SBATCH -A p31618
#SBATCH -p short
#SBATCH -t 01:00:00
#SBATCH --mem=1G
#SBATCH --ntasks-per-node=1
#SBATCH --job-name="assembly-spades-parent"
#SBATCH --output=slurm-out/mammoth-metagenomes/%x_%j.out

# this 'parent' job submits a 'child' job for every pair of reads you want to assemble into MAGs.
# in this way, we can allocate 1 CPU for every read pair. computation time for assembling a given
# pair of reads can range from a few minutes to around a day, depending on the input file. 

# you will only have to modify the input paths in this 'parent' job script -- do not alter the 
# 'child' script unless you want to change a specific SPAdes parameter.

# change directories to input data folder (trimmomatic output)
cd /projects/p31618/nu-seq/Osburn02_12.10.2021_metagenomes

# export paths as bash variables
export WORK_DR=`pwd`
export DATA_OUT=/projects/p30996/mammoth-metagenomes/assembled-spades
export DATA_IN=$WORK_DR/trimmomatic

# ensure output directory exists
mkdir -p $DATA_OUT

# submit an assembly job for each genome from trimmomatic output

printf "
Annotating genomes from $DATA_IN ...
"

cd $DATA_IN

for file in $(ls *_paired.fastq.gz -f | sed 's/_R[1-2]_paired.fastq.gz//' | sort -u)
do

  mkdir -p $DATA_OUT/${file}

  export INPUT_READS=${file}
  export PARENT_JOB=$SLURM_JOB_ID

  spades_job=$(sbatch \
  --account $SLURM_JOB_ACCOUNT \
  --partition normal \
  --time 48:00:00 \
  --mem=48G \
  --ntasks-per-node=4 \
  --job-name=SPAdes-${file} \
  --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out \
  /home/mjs9560/scripts/spades_child.sh \
  | sed 's/Submitted batch job //'
  )

printf "
 | [`date`] Submitted job $spades_job to assemble reads from ${file}."
  sleep 2

done
