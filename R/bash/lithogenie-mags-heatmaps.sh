#!/bin/bash
#SBATCH -A p30996               				  						
#SBATCH -p normal            				  						 
#SBATCH -t 48:00:00            				      						
#SBATCH -n 1
#SBATCH --mem=24GB
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END
#SBATCH --job-name="LithoGenie-heatmaps-mammoth-assemblies"
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%x_%j.out

# activate MagicLamp conda environment and add executable to $PATH
module purge all
module load python-miniconda3
source activate /projects/p31618/software/magiclamp
PATH=$(echo "/projects/p31618/software/magiclamp_run_folder/MagicLamp:$PATH") # this adds MagicLamp.py executable to user $PATH

# add paths to output directory (OUT_DR) genome bin directory (BIN_DR); 
# both are children of $WORK_DR
cd /projects/p30996/mammoth/metagenomes
export WORK_DR=`pwd`
export BIN_DR=$WORK_DR/metabat2-mammoth-scaffolds-c_2000
export OUT_DR=$WORK_DR/MagicLamp/mags/lithogenie

# ensure output parent directory exists
mkdir -p $OUT_DR

# navigate to genome bin parent directory (samples are subfolders)
cd $BIN_DR

##### loop through directories to make element-specific heatmaps 
for dir in */; do

	dir=$(basename $dir)

	#INPUT_GENOMES=${BIN_DR}/${dir}

	# remove any subfolder with data from previous runs (needs a clean output folder)
	# and make clean subfolder for output in OUT_DR 
	#[ -d $OUT_DR/${dir} ] && rm -rf $OUT_DR/${dir}

	echo "[`date`] Making element-specific heatmaps for $dir ..."     

	elements=(sulfur hydrogen methane nitrogen oxygen carbon-monoxide C1compounds carbon urea halogenetated-compounds arsenic selenium nitriles iron)

	for element in ${elements[@]}; do	
		[ -d $OUT_DR/${dir}/heatmaps ] && rm -rf $OUT_DR/${dir}/heatmaps
		#mkdir -p $OUT_DR/${dir}/heatmaps/${element}

		SECONDS=0 # this line monitors how long the fastas each subfolder took to annotate
		MagicLamp.py LithoGenie \
		-bin_dir $OUT_DR/${dir}/ORF_calls \
		-bin_ext faa \
		--orfs \
		-out $OUT_DR/${dir} \
		--skip \
		-cat ${element} \
		--makeplots \
		--nohup
	done

printf "\n     
---------------- Element-specific heatmaps generated for ' ${dir} '!
	Genome path: $INPUT_GENOMES
	Output path: $OUT_DR/${dir}
	Runtime (s): $SECONDS\n\n"      

done
#####

# export slurm runtime stats
export JOB_2_SUMM=$SLURM_JOB_ID
sbatch \
--job-name=$SLURM_JOB_NAME-report \
--output=/home/$USER/scripts/slurm-out/job-reports/$JOB_2_SUMM-$SLURM_JOB_NAME-report.out \
/home/$USER/scripts/job-report.sh

printf " | Runtime stats saved to /home/$USER/scripts/slurm-out/job-reports/$JOB_2_SUMM-$SLURM_JOB_NAME-report.out\n"
