#!/bin/bash
#SBATCH -A b1042
#SBATCH -p genomics-himem
#SBATCH -t 48:00:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --mem-per-cpu=60G
#SBATCH --array=0-1
#SBATCH --job-name=metabolic_c-high-quality-mags-redos
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out
#SBATCH --mail-user=mselensky@u.northwestern.edu \
#SBATCH --mail-type=END,FAIL

# activate METABOLIC conda environment
module purge all
module load python-miniconda3
source activate /projects/p31618/software/METABOLIC

# add METABOLIC executable path (don't edit)
MB=/projects/p31618/software/METABOLIC_run_folder/METABOLIC

# define parent directory for MAGs to annotate (each subfolder = 1 sample)
# (run prepare_high_quality_mags_for_annotation.sh first)
tmp_directory=/scratch/mjs9560/tmp-bins-to-annotate
# reads directory
READS_DR=/projects/p31618/nu-seq/Osburn02_12.10.2021_metagenomes/reads
# output directory
MB_OUT=/scratch/mjs9560/metabolic_c-high-quality-mags
mkdir -p $MB_OUT

# list of samples from which to annotate
#IFS=$'\n' read -d '' -r -a input_args < /home/mjs9560/scripts/mammoth-metagenomes/samples
input_args=(CX_GO_08_21_S17 BS_MC_01_21_S1)
metagenome=${input_args[$SLURM_ARRAY_TASK_ID]}

OUT_DR=$MB_OUT/${metagenome}
BIN_DR=$tmp_directory/${metagenome}

# rename all .fa extensions to .fasta
cd $BIN_DR
for file in *.fa; do mv -- "$file" "${file%.fa}.fasta"; done
cd ..

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




