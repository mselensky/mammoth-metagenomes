#!/bin/bash

# This script copies refined bins from metaWRAP into a single folder for easier 
# functional annotation.

IFS=$'\n' read -d '' -r -a input_args < /home/mjs9560/scripts/mammoth-metagenomes/samples
base_dir=/projects/p30996/mammoth/metagenomes
BIN_DR=${base_dir}/refined_bins_50-10_compiled
mkdir -p $BIN_DR

for i in ${input_args[@]}; do 
  for j in ${base_dir}/metaWRAP-refined-bins/${i}/metawrap_50_10_bins/*.fa; do 
    echo "Copying ${j} to $BIN_DR/${i}/${i}-$(basename $j)"
    mkdir -p $BIN_DR/${i}
    cp $j $BIN_DR/${i}/${i}-$(basename $j) 
  done;
done
