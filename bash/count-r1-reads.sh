#!/bin/bash
#SBATCH -A p31618
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH --mem=12G
#SBATCH --ntasks-per-node=1
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END
#SBATCH --job-name="count-r1-reads"
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out

# count number of paired (trimmed) reads per metagenome
cd /projects/p31618/nu-seq/Osburn02_12.10.2021_metagenomes/trimmomatic
gzip -d *R1_paired.fastq.gz
echo r1-counts > r1-counts
echo r1-filename > r1-filename
for i in *R1_paired.fastq; do
	i=`basename ${i}`
	echo ${i} >> r1-filename
	echo $(cat $i | wc -l)/4 | bc >> r1-counts
done

paste -d, r1-filename r1-counts > /projects/p30996/mammoth/metagenomes/r1-counts.csv
