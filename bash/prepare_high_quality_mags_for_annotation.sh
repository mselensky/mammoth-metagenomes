#!/bin/bash

# this script saves high quality MAGs defined in mags_to_annotate
# in separate folders representing a single metagenome for 
# mapping and annotation via METABOLIC-c

tmp_directory=/scratch/mjs9560/tmp-bins

IFS=$'\n' read -d '' -r -a input_args < mags_to_annotate.txt 

cd $1
for i in */; do 
  
  i=`basename $i`

  mkdir -p $tmp_directory/$i
  
  for j in ${input_args[@]}; do
    cp $i/reassembled_bins/${j}.fasta $tmp_directory/$i/${j}.fasta
  done

done
