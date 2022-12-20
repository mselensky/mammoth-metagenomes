#!/bin/bash
#SBATCH -A p30996               				  						
#SBATCH -p normal
#SBATCH -t 48:00:00    				      						
#SBATCH -n 1
#SBATCH --mem-per-cpu=4GB
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END
#SBATCH --job-name="FeGenie-mammoth-assemblies-norm"
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%x_%j.out

# activate MagicLamp conda environment and add executable to $PATH
# note: FeGenie.py is from fegenie conda distribution which I installed in MagicLamp separately
module purge all
module load python-miniconda3
source activate /projects/p31618/software/magiclamp
PATH=$(echo "/projects/p31618/software/magiclamp_run_folder/MagicLamp:$PATH") 

# add paths to output directory (OUT_DR) genome bin directory (BIN_DR); 
# both are children of $WORK_DR
cd /projects/p30996/mammoth/metagenomes
export WORK_DR=`pwd`
export BIN_DR=$WORK_DR/assembled-spades
export OUT_DR=$WORK_DR/MagicLamp/assemblies/FeGenie

# ensure output parent directory exists
mkdir -p $OUT_DR

# navigate to genome bin parent directory (samples are subfolders)
cd $BIN_DR

##### loop through directories to make element-specific heatmaps 
for dir in */; do

	dir=$(basename $dir)
	INPUT_GENOMES=${BIN_DR}/${dir}/tmp-bin

	# remove any subfolder with data from previous runs (needs a clean output folder)
	# and make clean subfolder for output in OUT_DR 
	#[ -d $OUT_DR/${dir} ] && rm -rf $OUT_DR/${dir}

	echo "[`date`] Executing 'FeGenie.py' for ' $dir '..."     

	SECONDS=0 # this line monitors how long the fastas each subfolder took to annotate
	# using .faa files from prodigal in METABOLIC pipeline
	FeGenie.py \
	-bin_dir $INPUT_GENOMES \
	-bin_ext faa \
	--orfs \
	--norm \
	--skip \
	-out $OUT_DR/${dir} \
	--heme \
	--meta \
	--nohup

printf "\n     
---------------- 'FeGenie.py' complete for ' $dir '!
	Output path: $OUT_DR/${dir}
	Runtime (s): $SECONDS\n\n"      

done
#####

