#!/bin/bash
#SBATCH -A p30996
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH -n 12
#SBATCH -N 1
#SBATCH --array=0-13
#SBATCH --mem-per-cpu=7G
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
# list of metagenomes to rerun with more memory
#IFS=$'\n' read -d '' -r -a metagenome_samples < /home/mjs9560/scripts/mammoth-metagenomes/samples
metagenome_samples=(BS_MC_01_21_S1 CX_GO_08_21_S17 CX_GO_13_21_S3 EN_DV_02_21_S20 EP_LC_04_21_S19 FR_ND_02_21_S8 GZ_MC_03_20_S13 GZ_MC_13_20_S11 PA_XL_04_20_S12 PP_CC_04_21_S6 TS_DV_03_21_S14 VD_CC_01_21_S18 VH_MC_02_21_S10 VH_MC_04_21_S9)
metagenome=${metagenome_samples[$SLURM_ARRAY_TASK_ID]}


cd ${anvio_bins}

$anvio anvi-run-hmms \
  -c ${anvio_bins}/${metagenome}-contigs-frmttd.db \
  --num-threads ${SLURM_NTASKS}
