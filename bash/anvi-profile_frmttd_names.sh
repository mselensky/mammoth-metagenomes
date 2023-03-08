#!/bin/bash
#SBATCH -A p30996
#SBATCH -p short
#SBATCH -t 04:00:00
#SBATCH -n 1
#SBATCH --mem=48G
#SBATCH --array=0-20
#SBATCH --job-name="anvi-profile_frmtted_names"
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END,FAIL
#SBATCH -o /scratch/mjs9560/%A-%a-%x.out

# list of metagenomes to analyze
IFS=$'\n' read -d '' -r -a metagenome_samples < /home/mjs9560/scripts/mammoth-metagenomes/samples
# parent MAG folder (subfolders are individual metagenomes)
parent_dir=/projects/p30996/mammoth/metagenomes
anvio_bins=${parent_dir}/anvio-bins-frmttd2
assemblies=${parent_dir}/assembled-spades
metagenome=${metagenome_samples[$SLURM_ARRAY_TASK_ID]}
metagenome_parent=${parent_dir}/metaWRAP-refined-bins-50compl-50contam

# create blank Anvio profile for each metagenome to manually edit MAGs
module load singularity
anvio="singularity exec -B /projects:/projects /projects/p31618/software/anvio-7.1.simg"

cd ${anvio_bins}
#mkdir -p ${metagenome}
#mv ${metagenome}-contigs.db ${metagenome}/${metagenome}-contigs.db
#rm -r ${metagenome}

${anvio} anvi-profile \
  -c ${metagenome}-contigs-frmttd.db \
  -o ${metagenome} \
  -S ${metagenome} \
  --blank-profile
