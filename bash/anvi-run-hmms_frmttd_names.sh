#!/bin/bash
#SBATCH -A p30996
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH -n 12
#SBATCH -N 1
#SBATCH --array=0-20
#SBATCH --mem-per-cpu=4G
#SBATCH --job-name="anvi-run-hmms-frmttd_names"
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END,FAIL
#SBATCH -o /scratch/mjs9560/%A-%a-%x.out

# on the compute node:
module purge all 
module load singularity
anvio="singularity exec -B /projects:/projects /projects/p31618/software/anvio-7.1.simg"

# parent MAG folder (subfolders are individual metagenomes)
parent_dir=/projects/p30996/mammoth/metagenomes
anvio_bins=${parent_dir}/anvio-bins-frmttd2
# list of metagenomes to analyze
IFS=$'\n' read -d '' -r -a metagenome_samples < /home/mjs9560/scripts/mammoth-metagenomes/samples
metagenome=${metagenome_samples[$SLURM_ARRAY_TASK_ID]}


cd ${anvio_bins}

$anvio anvi-run-hmms \
  -c ${anvio_bins}/${metagenome}-contigs-frmttd.db \
  --num-threads ${SLURM_NTASKS}
