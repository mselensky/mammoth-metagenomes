#!/bin/bash
#SBATCH -A p30996
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH -n 4
#SBATCH --mem-per-cpu=4G
#SBATCH --array=0-20
#SBATCH --job-name=fegenie_c-refined-mags
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%A_%a-%x.out
#SBATCH --mail-user=mselensky@u.northwestern.edu \
#SBATCH --mail-type=END,FAIL

# activate MagicLamp conda environment and add executable to $PATH
# note: FeGenie.py is from fegenie conda distribution which I installed in MagicLamp separately.
#       it does not come from MagicLamp.py in magiclamp_run_folder like the other genies.
#       I am still adding the run folder to my $PATH in c
module purge all
module load python-miniconda3
source activate /projects/p31618/software/magiclamp
PATH=/projects/p31618/software/magiclamp_run_folder/MagicLamp:$PATH 

# add paths to output directory (OUT_DR) genome bin directory (BIN_DR); 
# both are children of $WORK_DR
cd /projects/p30996/mammoth/metagenomes
WORK_DR=`pwd`
BIN_DR=$WORK_DR/refined_bins_50-10_compiled
OUT_DR=$WORK_DR/MagicLamp/refined-mags/FeGenie

# list of samples from which to annotate
IFS=$'\n' read -d '' -r -a input_args < /home/mjs9560/scripts/mammoth-metagenomes/samples
metagenome=${input_args[$SLURM_ARRAY_TASK_ID]}

# ensure output parent directory exists
mkdir -p $OUT_DR

# navigate to genome bin parent directory (samples are subfolders)
cd $BIN_DR

##### loop through directories to make element-specific heatmaps 

input_genomes=${BIN_DR}/${metagenome}

# remove any subfolder with data from previous runs (needs a clean output folder)
# and make clean subfolder for output in OUT_DR 
#[ -d $OUT_DR/${dir} ] && rm -rf $OUT_DR/${dir}

echo "[`date`] Executing 'FeGenie.py' for ' $metagenome '..."     

SECONDS=0 
# using .faa files from prodigal in METABOLIC pipeline
FeGenie.py \
  -bin_dir $input_genomes \
  -bin_ext faa \
  --orfs \
  -out $OUT_DR/${metagenome} \
  --heme \
  --meta \
  --nohup
  
printf "\n     
---------------- 'FeGenie.py' complete for ' $metagenome '!
                 Output path: $OUT_DR/${metagenome}
	             Runtime (s): $SECONDS\n\n"      

#####
