#!/bin/bash
#SBATCH -A p31618
#SBATCH -p short
#SBATCH -t 01:00:00
#SBATCH -N 1
#SBATCH --mem=10mb
#SBATCH --job-name=metabolic_assemblies-parent
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out

# activate METABOLIC conda environment
module purge all
module load python-miniconda3
source activate /projects/p31618/software/METABOLIC

# add path to METABOLIC executable (don't edit)
export MB=/projects/p31618/software/METABOLIC_run_folder/METABOLIC

# define parent directory and create output folder
WORK_DR=/projects/p30996/mammoth/metagenomes
export MB_OUT=${WORK_DR}/metabolic_c-assemblies
mkdir -p $MB_OUT

# submit a METABOLIC job for each sample site.
# this matches spade assemblies ($BIN_DR) to each site's original paired-end reads ($READS_DR).
cd ${WORK_DR}/assembled-spades

for site in */; do

  export site=`echo ${site} | sed 's|/||'`

  printf "\n |     ----- ${site} -----     | "
  export OUT_DR=${MB_OUT}/${site}
  export BIN_DR=`pwd`/${site}
  export READS_DR=/projects/p31618/nu-seq/Osburn02_12.10.2021_metagenomes/reads

  # rename all .fa extensions to .fasta and move scaffolds.fasta to its own folder for annotation
  cd $BIN_DR
  for file in *.fa; do mv -- "$file" "${file%.fa}.fasta"; done
  mkdir -p ${BIN_DR}/tmp-bin
  mv scaffolds.fasta tmp-bin/scaffolds.fasta
  export BIN_DR=${BIN_DR}/tmp-bin
  cd ..

  # metabolic requires file paths to each read pair to be referenced in a text file
  # (this is referenced in metabolic-mags-child.sh)
  # echo "$READS_DR/${site}_R1_001.fastq.gz,$READS_DR/${site}_R2_001.fastq.gz" > ${READS_DR}/${site}-paths.txt

  printf "\n
 | ________________________________________
 |
 | / METABOLIC MAG annotations / 
 |
 | Job ID                 : $SLURM_JOB_ID
 | Job name               : $SLURM_JOB_NAME
 | Node                   : `hostname`
 | Date                   : `date`
 | Input MAG folder       : $BIN_DR
 | Output directory       : $OUT_DR
 | Input metagenomic reads: $READS_DR
 | ________________________________________\n"

sbatch \
  --account b1042 \
  --job-name=${site}-metabolic-c_assemblies \
  --mem-per-cpu=20G \
  --partition genomics-himem \
  --ntasks-per-node=12 \
  --time 168:00:00 \
  --output=/home/$USER/scripts/slurm-out/mammoth-metagenomes/%j-%x.out \
  --mail-user=mselensky@u.northwestern.edu \
  --mail-type=END,FAIL \
  /home/$USER/scripts/metabolic-child.sh

  sleep 2

done
