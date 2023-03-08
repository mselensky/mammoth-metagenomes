#!/bin/bash
#SBATCH -A p30996
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH -n 4
#SBATCH --mem=24G
#SBATCH --array=0-20
#SBATCH --job-name="anvi-gen-contigs-database-mammoth"
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END,FAIL
#SBATCH -o /home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%A-%a.out

# list of metagenomes to analyze
IFS=$'\n' read -d '' -r -a metagenome_samples < /home/mjs9560/scripts/mammoth-metagenomes/samples
# parent MAG folder (subfolders are individual metagenomes)
parent_dir=/projects/p30996/mammoth/metagenomes
anvio_bins=${parent_dir}/anvio-bins
assemblies=${parent_dir}/assembled-spades
metagenome=${metagenome_samples[$SLURM_ARRAY_TASK_ID]}
metagenome_parent=${parent_dir}/metaWRAP-refined-bins-50compl-50contam
scratch=/scratch/${USER}/anvio-bins

# add sample name to each bin; save to scratch space
#mkdir -p ${scratch}
#for i in ${metagenome_samples[@]}; do
#
#  cd ${metagenome_parent}/${i}/metawrap_50_50_bins
#  for file in *.fa; do cp ${file} ${scratch}/${i}-${file}; done
#
#  cd $scratch
#  cat ${metagenome_parent}/${i}/metawrap_50_50_bins.contigs |
#    awk -v metaname=`echo "${i}-"` 'BEGIN{OFS="\t"}$2=(metaname)$2' > ${i}.contigs
#
#done
echo "$(ls ${scratch}/*.fa | wc -l) bins before manual refinement with anvio"

# note: container has a hard time mapping to /scratch :( fix this later
module load singularity
anvio="singularity exec -B /projects:/projects /projects/p31618/software/anvio-7.1.simg"

mkdir -p $anvio_bins; cd $anvio_bins
$anvio anvi-gen-contigs-database \
  -f ${assemblies}/${metagenome}/tmp-bin/scaffolds.fasta \
  -o ${metagenome}-contigs.db \
  -T $SLURM_NTASKS \
  -n "${metagenome}" \
  --ignore-internal-stop-codons \
  --skip-mindful-splitting
