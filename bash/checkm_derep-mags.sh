#!/bin/bash
#SBATCH -A p31618
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH --mem=48G
#SBATCH --ntasks-per-node=4
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END
#SBATCH --job-name="CheckM-mammoth-dereplicated_bins"
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out

module purge all
module load checkm

parent_dir=/scratch/${USER}
input_genomes=${parent_dir}/anvio-bins-frmttd2-manual_dereplicated_12Apr23/dereplicated_genomes
checkm_out=${parent_dir}/derep-bins-checkm
scratch=/scratch/${USER}/tmp-${SLURM_JOB_ID}

echo "Date: `date`"
echo "Node: `hostname`"
echo "Job : ${SLURM_JOB_ID}"
echo "Out : ${checkm_out}"
echo "Path: `pwd`"

# move genomes to single scratch folder 
mkdir -p $scratch
cd $input_genomes
cp *.fasta ${scratch}

mkdir -p $checkm_out

checkm lineage_wf \
  -t $SLURM_NTASKS \
  -x fasta \
  $scratch \
  $checkm_out

# calculate completeness/contamination for each bin
checkm qa \
  -t $SLURM_NTASKS \
  -o 1 \
  -f ${checkm_out}/qa_results.txt \
  --tab_table \
  ${checkm_out}/lineage.ms \
  ${checkm_out} && rm -r $scratch
