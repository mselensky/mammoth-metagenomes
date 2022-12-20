#!/bin/bash

# This script copies refined bins from metaWRAP into a single folder for easier 
# functional annotation.

IFS=$'\n' read -d '' -r -a input_args < /home/mjs9560/scripts/mammoth-metagenomes/samples
base_dir=/projects/p30996/mammoth/metagenomes/

cd /projects/p30996/mammoth/metagenomes
export WORK_DR=`pwd`
export BIN_DR=$WORK_DR/refined_bins_50-10_compiled
mkdir -p $BIN_DR

for i in ${input_args[@]}; do 
  for j in metaWRAP-refined-bins/${i}/metawrap_50_10_bins/*.fa; do 
    j=$(basename $j)
    echo "Copying ${j} to $BIN_DR/${i}-${j}";
    cp $j $BIN_DR/${i}-${j}
  done;
done
