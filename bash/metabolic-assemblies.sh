#!/bin/bash
#SBATCH -A b1042
#SBATCH -p genomicslong
#SBATCH -t 240:00:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --mem-per-cpu=12G
#SBATCH --array=0-20
#SBATCH --job-name=metabolic_c-mammoth-assemblies
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%A_%a-%x.out
#SBATCH --mail-user=mselensky@u.northwestern.edu \
#SBATCH --mail-type=END,FAIL

# activate METABOLIC conda environment
module purge all
module load python-miniconda3
source activate /projects/p31618/software/METABOLIC

# add path to METABOLIC executable (don't edit)
export MB=/projects/p31618/software/METABOLIC_run_folder/METABOLIC

# define parent directory and create output folder
IFS=$'\n' read -d '' -r -a input_args < /home/mjs9560/scripts/mammoth-metagenomes/samples
metagenome=${input_args[$SLURM_ARRAY_TASK_ID]}
SCRATCH_DR=/scratch/${USER}
WORK_DR=/projects/p30996/mammoth/metagenomes
READS_DR=/projects/p31618/nu-seq/Osburn02_12.10.2021_metagenomes/reads
MB_OUT=${SCRATCH_DR}/metabolic_c-assemblies-mammoth/$SLURM_ARRAY_JOB_ID
OUT_DR=$MB_OUT/${metagenome}
mkdir -p $OUT_DR

# submit a METABOLIC job for each sample site.
# this matches spade assemblies ($BIN_DR) to each site's original paired-end reads ($READS_DR).
BIN_DR=${WORK_DR}/assembled-spades/${metagenome}/tmp-bin

# rename all .fa extensions to .fasta and move scaffolds.fasta to its own folder for annotation
#cd $BIN_DR
#for file in *.fa; do mv -- "$file" "${file%.fa}.fasta"; done
#mkdir -p ${BIN_DR}/tmp-bin
#mv scaffolds.fasta tmp-bin/scaffolds.fasta
#BIN_DR=${BIN_DR}/tmp-bin

  # metabolic requires file paths to each read pair to be referenced in a text file
# echo "$READS_DR/${metagenome}_R1_001.fastq.gz,$READS_DR/${metagenome}_R2_001.fastq.gz" > ${READS_DR}/${metagenome}-paths.txt

printf "\n
   ===> MAGs from metagenome: ${metagenome}
 | __________________________
 |
 | Annotating with METABOLIC!
 | 
 | Array job................. ${SLURM_ARRAY_TASK_ID} of ${SLURM_ARRAY_TASK_MAX}
 | Job ID.................... ${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}
 | Job name.................. $SLURM_JOB_NAME
 | Node...................... `hostname`
 | Date...................... `date`
 | Input MAG folder.......... $BIN_DR
 | Output directory.......... $OUT_DR
 | Input metagenomic reads... $READS_DR
 | __________________________
 |
 | The following bins will be
 | annotated:\n`ls -f $BIN_DR | grep fasta`\n"

# run metabolic for each metagenome separately
SECONDS=0
perl ${MB}/METABOLIC-C.pl \
  -in-gn $BIN_DR \
  -o $OUT_DR \
  -r ${READS_DR}/${metagenome}-paths.txt \
  -t $SLURM_NTASKS \
  -tax phylum 
meta_time=$SECONDS

printf "\n
-----------------------------
Array job: ${SLURM_ARRAY_TASK_ID} of ${SLURM_ARRAY_TASK_MAX}
Job ID: ${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}
Job name: $SLURM_JOB_NAME
Node: `hostname`
Date: `date`
Input MAG folder: $BIN_DR
Output directory: $OUT_DR
Input metagenomic reads: $READS_DR
__________________________
The following MAGs were annotated:\n`ls -f $BIN_DR | grep fasta`\n" | mail -s "'${metagenome}' annotated" mselensky@u.northwestern.edu




