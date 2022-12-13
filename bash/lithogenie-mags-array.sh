#!/bin/bash
#SBATCH -A p30996               				  						
#SBATCH -p short            				  						 
#SBATCH -t 04:00:00            				      						
#SBATCH -n 1
#SBATCH --array=0-20
#SBATCH --mem=12GB
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END
#SBATCH --job-name="LithoGenie-mammoth-MAGs"
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%A_%a.out

# activate MagicLamp conda environment and add executable to $PATH
module purge all
module load python-miniconda3
source activate /projects/p31618/software/magiclamp
PATH=$(echo "/projects/p31618/software/magiclamp_run_folder/MagicLamp:$PATH") # this adds MagicLamp.py executable to user $PATH

# add paths to output directory (OUT_DR), genome bin directory (BIN_DR); 
# both are children of $WORK_DR
cd /projects/p30996/mammoth/metagenomes
export WORK_DR=`pwd`
export BIN_DR=$WORK_DR/metabat2-mammoth-scaffolds-c_2000
export OUT_DR=$WORK_DR/MagicLamp/assemblies/lithogenie

# ensure output parent directory exists
mkdir -p $OUT_DR

# navigate to genome bin parent directory (samples are subfolders)
cd $BIN_DR

##### loop through directories to annotate with FeGenie
ls -df */ | sed "s|/||" > directories.txt
IFS=$'\n' read -d '' -r -a input_args < directories.txt

MagicLamp.py LithoGenie \
  -bin_dir $BIN_DR/${input_args[$SLURM_ARRAY_TASK_ID]} \
  -bin_ext fasta \
  -out $OUT_DR/${input_args[$SLURM_ARRAY_TASK_ID]}
