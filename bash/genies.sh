#!/bin/bash
#SBATCH -A p30996               				  						
#SBATCH -p short            				  						 
#SBATCH -t 04:00:00
#SBATCH --array=0-7
#SBATCH -N 1        				      						
#SBATCH -n 4
#SBATCH --mem-per-cpu=4GB
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END
#SBATCH --job-name="genies-mags"
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%x_%A_%a.out

# activate MagicLamp conda environment and add executable to $PATH
module purge all
module load python-miniconda3
source activate /projects/p31618/software/magiclamp
PATH=$(echo "/projects/p31618/software/magiclamp_run_folder/MagicLamp:$PATH") 
# define 'genies' to run as separate jobs (https://github.com/Arkadiy-Garber/MagicLamp)
genies=(FeGenie WspGenie GasGenie MnGenie RosGenie MagnetoGenie Lucifer LithoGenie)

# add paths to output directory (OUT_DR) genome bin directory (BIN_DR); 
# both are children of $WORK_DR
cd /projects/p30996/mammoth/metagenomes
WORK_DR=`pwd`
BIN_DR=$WORK_DR/reassembled-redundant-HQ-MAGs
OUT_DR=$WORK_DR/MagicLamp/reassembled-redundant-HQ-MAGs/${genies[$SLURM_ARRAY_TASK_ID]}

# ensure output parent directory exists
mkdir -p $OUT_DR

# navigate to genome bin parent directory (samples are subfolders)
cd $BIN_DR

##### make element-specific heatmaps 

# remove any subfolder with data from previous runs (needs a clean output folder)
# and make clean subfolder for output in OUT_DR 
[ -d $OUT_DR ] && rm -rf $OUT_DR

echo "[`date`] Executing 'MagicLamp.py ${genies[$SLURM_ARRAY_TASK_ID]}' ..."     

SECONDS=0 # this line monitors how long the fastas each subfolder took to annotate
MagicLamp.py `echo ${genies[$SLURM_ARRAY_TASK_ID]}` \
-bin_dir $BIN_DR \
-bin_ext fasta \
--meta \
-t $SLURM_NTASKS \
-out $OUT_DR/${dir} 

printf "\n     
---------------- 'MagicLamp.py ${genies[$SLURM_ARRAY_TASK_ID]}' complete !
	Output path: $OUT_DR
	Runtime (s): $SECONDS\n\n"      

#####

