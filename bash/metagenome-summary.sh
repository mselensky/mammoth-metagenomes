#!/bin/bash

# count number of scaffolds per assembly
cd /projects/p30996/mammoth/metagenomes/assembled-spades
echo sample > samples
echo n.scaffolds > n-scaffolds
for i in */; do i=`basename ${i}`; echo "$i";done >> samples
for i in */; do i=`basename ${i}`; grep -c ">" ${i}/tmp-bin/scaffolds.fasta;done >> n-scaffolds
paste -d, samples n-scaffolds > ../metagenome-stats.csv
cd ..

# count forward and reverse reads (should be same length)
sbatch /home/mjs9560/scripts/mammoth-metagenomes/bash/count-r1-reads.sh
sbatch /home/mjs9560/scripts/mammoth-metagenomes/bash/count-r2-reads.sh
# bash /home/mjs9560/scripts/gzip.sh

# full metagenome stats summary
paste -d, metagenome-stats.csv r1-counts.csv r2-counts.csv > metagenome-summary.csv
