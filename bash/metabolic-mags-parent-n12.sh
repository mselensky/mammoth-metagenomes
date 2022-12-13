#!/bin/bash
#SBATCH -A p31618
#SBATCH -p short
#SBATCH -t 01:00:00
#SBATCH -N 1
#SBATCH --mem=10mb
#SBATCH --job-name=metabolic_mags-parent-c_2000-redos
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out

# activate METABOLIC conda environment
module purge all
module load python-miniconda3
source activate /projects/p31618/software/METABOLIC

# add path to METABOLIC executable (don't edit)
export MB=/projects/p31618/software/METABOLIC_run_folder/METABOLIC

# define parent directory for MAGs to annotate (each subfolder = 1 sample)
WORK_DR=/projects/p30996/mammoth/metagenomes/metabat2-mammoth-scaffolds-c_2000
cd $WORK_DR
export MB_OUT=../metabolic_c-mags-c_2000
mkdir -p $MB_OUT

# submit a METABOLIC job for each sample site.
# this matches previously assembled MAGs ($BIN_DR) to each site's original paired-end reads ($READS_DR).

#for site in BS_MC_01_21_S1 CX_GO_08_21_S17 EN_DV_02_21_S20 EP_LC_04_21_S19/; do
for site in ; do

  export site=`echo ${site} | sed 's|/||'`

	printf "\n |     ----- ${site} -----     | "
	export OUT_DR=$MB_OUT/${site}
	export BIN_DR=$WORK_DR/${site}
	export READS_DR=/projects/p31618/nu-seq/Osburn02_12.10.2021_metagenomes/reads

  # rename all .fa extensions to .fasta
  cd $BIN_DR
  for file in *.fa; do mv -- "$file" "${file%.fa}.fasta"; done
  cd ..

  # metabolic requires file paths to each read pair to be referenced in a text file
  # (this is referenced in metabolic-mags-child.sh)
  # echo "$READS_DR/${site}_R1_001.fastq.gz,$READS_DR/${site}_R2_001.fastq.gz" > ${READS_DR}/${site}-paths.txt
  # (commented out because controls have different naming pattern)

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
  --account p30996 \
  --job-name=${site}-metabolic-c \
  --mem-per-cpu=20G \
  --partition genhimem \
  --ntasks-per-node=12 \
  --time 48:00:00 \
  --output=/home/$USER/scripts/slurm-out/mammoth-metagenomes/%j-%x.out \
  --mail-user=mselensky@u.northwestern.edu \
  --mail-type=END,FAIL \
  /home/$USER/scripts/metabolic-child.sh

  sleep 2

done
