#!/bin/bash
#SBATCH -A b1042
#SBATCH -p genomics
#SBATCH -t 48:00:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --array=0-20
#SBATCH --mem-per-cpu=20G
#SBATCH --job-name=bin_refinement-mammoth
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%A_%a-%x.out

# list of samples from which to bin (not run):
# assemblies=${parent_dir}/assembled-spades
# for i in $(ls -df $assemblies/*/); do basename $i;done > samples
IFS=$'\n' read -d '' -r -a input_args < /home/mjs9560/scripts/mammoth-metagenomes/samples
metagenome=${input_args[$SLURM_ARRAY_TASK_ID]}

#### user inputs ####
# define parent genome directory and trimmed reads folder
parent_dir=/projects/p30996/mammoth/metagenomes
initial_bins=${parent_dir}/metaWRAP-initial-bins/${metagenome}
output_dir=${parent_dir}/metaWRAP-refined-bins/${metagenome}
####             ####
module purge all
#module load metawrap/1.3.2
#module load python-miniconda3
#source activate /projects/p31618/software/metawrap-binning
module load checkm
module load mamba
source activate /projects/p31618/software/metawrap
PATH=/projects/p31618/software/metaWRAP/bin:$PATH

mkdir -p ${parent_dir}/metaWRAP-refined-bins

metawrap bin_refinement \
  -o ${output_dir} \
  -t $SLURM_NTASKS \
  -A ${initial_bins}/metabat2_bins/ \
  -B ${initial_bins}/maxbin2_bins/ \
  -C ${initial_bins}/concoct_bins/ \
  -c 50 -x 10

# back up results to scratch space
backup_dir=/scratch/$USER/refined_bins/${metagenome}
mkdir -p $backup_dir
cp -r ${output_dir} ${backup_dir}
