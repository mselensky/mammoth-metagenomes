#!/bin/bash
#SBATCH -A p30996
#SBATCH -p short
#SBATCH -t 04:00:00
#SBATCH -n 12
#SBATCH -N 1
#SBATCH --array=0-20
#SBATCH --mem-per-cpu=4G
#SBATCH --job-name="anvi-gen-contigs-database-mammoth-frmttd_names"
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END,FAIL
#SBATCH -o /scratch/mjs9560/%A-%a-%x.out

# list of metagenomes to analyze
IFS=$'\n' read -d '' -r -a metagenome_samples < /home/mjs9560/scripts/mammoth-metagenomes/samples
module load singularity
anvio="singularity exec -B /projects:/projects /projects/p31618/software/anvio-7.1.simg"

parent_dir=/projects/p30996/mammoth/metagenomes
assemblies=${parent_dir}/assembled-spades
# parent MAG folder (subfolders are individual metagenomes)
metagenome_parent=${parent_dir}/metaWRAP-refined-bins-50compl-50contam
# output anvio folder
anvi_dir=${parent_dir}/anvio-bins-frmttd2
i=${metagenome_samples[$SLURM_ARRAY_TASK_ID]}


# add sample name to each bin; save to anvio folder
mkdir -p $anvi_dir
cd ${metagenome_parent}/${i}/metawrap_50_50_bins
for file in *.fa; do cp ${file} ${anvi_dir}/${i}-${file}; done

cd $anvi_dir
cat ${metagenome_parent}/${i}/metawrap_50_50_bins.contigs |
  awk -v metaname=`echo "${i}-"` 'BEGIN{OFS="\t"}$2=(metaname)$2' > ${i}.contigs

echo "Assembly '$i' contains: "
echo "$(ls ${anvio_dir}/${i}*.fa | wc -l) bins before manual refinement with anvio"

# note: container has a hard time mapping to /scratch :( fix this later
module load singularity
anvio="singularity exec -B /projects:/projects /projects/p31618/software/anvio-7.1.simg"

parent_dir=/projects/p30996/mammoth/metagenomes
assemblies=${parent_dir}/assembled-spades

$anvio anvi-script-reformat-fasta \
  ${assemblies}/${i}/tmp-bin/scaffolds.fasta \
  -o ${i}-scaffolds-anvio-frmttd.fasta \
  -l 150 \
  --simplify-names \
  --report-file ${i}-scaffolds-anvio-frmttd-key.txt

$anvio anvi-gen-contigs-database \
  -f ${i}-scaffolds-anvio-frmttd.fasta \
  -o ${i}-contigs-frmttd.db \
  -T $SLURM_NTASKS \
  -n "${i}" \
  --skip-mindful-splitting \
  --ignore-internal-stop-codons
