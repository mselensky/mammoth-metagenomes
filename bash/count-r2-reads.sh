#!/bin/bash
#SBATCH -A p31618
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH --mem=12G
#SBATCH --ntasks-per-node=1
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END
#SBATCH --job-name="count-r2-reads"
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out

# count number of paired (trimmed) reads per metagenome
cd /projects/p31618/nu-seq/Osburn02_12.10.2021_metagenomes/trimmomatic
gzip -d *R2_paired.fastq.gz
echo r2-counts > r2-counts
echo r2-filename > r2-filename
for i in *R2_paired.fastq; do
	i=`basename ${i}`
	echo ${i} >> r2-filename
	echo $(cat $i | wc -l)/4 | bc >> r2-counts
done

paste -d, r2-filename r2-counts	> /projects/p30996/mammoth/metagenomes/r2-counts.csv
