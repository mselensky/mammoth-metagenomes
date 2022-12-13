#!/bin/bash
#SBATCH -A p31618
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH --mem=48G
#SBATCH --ntasks-per-node=4
#SBATCH --array=0-3
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END
#SBATCH --job-name="CheckM-mammoth-mags"
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%A_%a-%x.out

#### user inputs ####
# define parent genome directory
PARENT_DR=/projects/p30996/mammoth/metagenomes
# define minimum contig length for binning ($MIN_CONTIG_LEN) (should be >=1500)
MIN_CONTIG_LEN=(3000 2500 2000 1500)
####             ####

# define parent folder for metabat2 outputs
BIN_DR=${PARENT_DR}/metabat2-mammoth-scaffolds-c_${MIN_CONTIG_LEN[$SLURM_ARRAY_TASK_ID]}
cd $BIN_DR

echo "Date: `date`"
echo "Node: `hostname`"
echo "Job : ${SLURM_ARRAY_JOB_ID}_$SLURM_ARRAY_TASK_ID"
echo "Path: `pwd`"

module load checkm

# manually clean up rogue folder names from metabat2 array job
rm -r metabat2*

for i in */
do
  i=`echo ${i} | sed 's|/||'`

  # rename 'tooShort' and 'unbinned' bins to .fasta extension so they can be skipped over
  mv ${i}/${i}.tooShort.fa ${i}/${i}.tooShort.fasta
  mv ${i}/${i}.unbinned.fa ${i}/${i}.unbinned.fasta

  echo "`date` Running CheckM on input directory $i ..." 
  
  # create output folder
  CHECKM_OUT=${PARENT_DR}/checkm-mags-c_${MIN_CONTIG_LEN[$SLURM_ARRAY_TASK_ID]}/$i
  mkdir -p $CHECKM_OUT
  checkm lineage_wf \
    -t $SLURM_NTASKS \
    -x fa \
    $i \
    $CHECKM_OUT

  # calculate completeness/contamination for each bin
  checkm qa \
    -t $SLURM_NTASKS \
    -o 1 \
    -f $CHECKM_OUT/qa_results.txt \
    --tab_table \
    ${CHECKM_OUT}/lineage.ms \
    ${CHECKM_OUT}

  echo "`date` CheckM complete for directory $i"
  echo "CheckM output path from parent: $CHECKM_OUT"
done

echo "`date` Job ${SLURM_ARRAY_JOB_ID}_$SLURM_ARRAY_TASK_ID complete!"
