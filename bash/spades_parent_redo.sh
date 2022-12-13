#!/bin/bash

#SBATCH -A p31618
#SBATCH -p short
#SBATCH -t 01:00:00
#SBATCH --mem=1G
#SBATCH --ntasks-per-node=1
#SBATCH --job-name="assembly-spades-parent"
#SBATCH --output=/projects/p31618/nu-seq/Osburn02_12.10.2021_metagenomes/scripts/slurm-out/%x_%j.out

# this 'parent' job submits a 'child' job for every pair of reads you want to assemble into MAGs.
# in this way, we can allocate 1 CPU for every read pair. computation time for assembling a given
# pair of reads can range from a few minutes to around a day, depending on the input file. 

# you will only have to modify the input paths in this 'parent' job script -- do not alter the 
# 'child' script unless you want to change a specific SPAdes parameter.

# change directories to project folder
cd /projects/p31618/nu-seq/Osburn02_12.10.2021_metagenomes

# export paths as bash variables
export WORK_DR=`pwd`
export DATA_OUT=/projects/p30996/assembled-spades-mammoth
export DATA_IN=$WORK_DR/trimmomatic

# make a directory for the output
mkdir -p $DATA_OUT

# submit an assembly job for each genome from trimmomatic output

printf "
Annotating genomes from $DATA_IN ...
"

cd $DATA_IN

# metagenome jobs that previously failed:
# AW_RC_05_21_S5 BS_MC_01_21_S1 CX_GO_13_21_S3 EN_DV_02_21_S20 VD_CC_01_21_S18

for file in $(ls *_paired.fastq.gz -f | sed 's/_R[1-2]_paired.fastq.gz//' | sort -u | grep "AW_RC_05_21_S5\|BS_MC_01_21_S1\|CX_GO_13_21_S3\|EN_DV_02_21_S20\|VD_CC_01_21_S18")
do

  mkdir -p $DATA_OUT/${file}

  export INPUT_READS=${file}
  export PARENT_JOB=$SLURM_JOB_ID

  spades_job=$(sbatch \
  --account $SLURM_JOB_ACCOUNT \
  --partition long \
  --time 168:00:00 \
  --mem-per-cpu=48GB \
  --ntasks-per-node=2 \
  --job-name=SPAdes-${file} \
  --output=$WORK_DR/scripts/slurm-out/%j-%x.out \
  $WORK_DR/scripts/spades_child.sh \
  | sed 's/Submitted batch job //'
  )

printf "
 | Submitted job $spades_job to annotate ${file}"
  sleep 2

done
