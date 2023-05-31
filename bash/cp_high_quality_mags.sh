#!/bin/bash

# this script copies the final list of high quality MAGs (mags_to_annotate.txt)
# to a separate temporary folder for subsequent annotation
# positional arguments:
# 1 - path to directory containing MAGs
# 2 - path to file listing MAGs to copy to temp folder

tmp_directory=/scratch/mjs9560/tmp-bins
mkdir -p $tmp_directory

IFS=$'\n' read -d '' -r -a input_args < $2

cd $1
for j in ${input_args[@]}; do
  cp ${j}.fasta $tmp_directory/${j}.fasta
done

echo "[`date`] High quality MAGs copied to $tmp_directory"
echo "Input MAG directory: $1"
echo "List of MAGs to annotate: $2"
