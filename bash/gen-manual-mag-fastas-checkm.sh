#!/bin/bash
#SBATCH -A p30996
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH -n 12
#SBATCH -N 1
#SBATCH --mem-per-cpu=4G
#SBATCH --job-name="generate-manual-mag-fastas-checkm-AW_RC_01_21_S2"
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END,FAIL
#SBATCH -o /home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out

# this script takes exported "bin collections" from the anvio interactive
# manual genome binning tool, saves each bin as a separate fasta by 
# searching for matching sequences from the corresponding assembly,
# and performs checkm on the compiled bin fastas for a given assembly.

#### import software and define number of cores
module purge all 
module load checkm
N=$SLURM_NTASKS


#### define IO directories
# parent MAG folder (subfolders are individual metagenomes)
parent_dir=/projects/p30996/mammoth/metagenomes
anvio_bins=${parent_dir}/anvio-bins-frmttd2
metagenome_parent=${parent_dir}/metaWRAP-refined-bins-50compl-50contam
assemblies=${parent_dir}/assembled-spades
# list of metagenomes to analyze
IFS=$'\n' read -d '' -r -a metagenome_samples < /home/mjs9560/scripts/mammoth-metagenomes/samples

# test with this one
metagenome=AW_RC_01_21_S2

echo "[`date`] Creating MAG fasta files from assembly '$metagenome'"

# copy contigs/scaffolds to anvio bin folder
cd ${anvio_bins}/manual_bins
assemblies_path=${assemblies}/${metagenome}/tmp-bin/scaffolds.fasta
cp $assemblies_path ${metagenome}-scaffolds.fasta
# checkm IO
checkm_in=bin_fastas/${metagenome}
checkm_out=${checkm_in}/checkm
mkdir -p $checkm_out; mkdir -p $checkm_in

# (out of date)
# rename bin collection node names to match original contigs/scaffolds
#awk -F '\t' -vOFS='\t' '{ gsub("_split_00001", "", $1) ; print }' \
#  ${metagenome}-manual-bins.txt \
#  > ${metagenome}-manual-bins-orig-contig-names.txt

### split scaffold nodes into separate temp files that are then rejoined for 
### each bin based on ${metagenome}-manual-bins-orig-contig-names.txt
# get unique manual bin names
awk -F '\t' '!a[$2]++' ${checkm_in}/manual-bins-orig-contig-names.txt \
  | awk -F '\t' '{print $2}' \
  > ${checkm_in}/bin_names

IFS=$'\n' read -d '' -r -a mag_bins < ${checkm_in}/bin_names
for i in ${mag_bins[@]}; do
  # obtain node names for each bin
	awk -F '\t' -v binny=$i '$2 == (binny)' \
	  ${checkm_in}/manual-bins-orig-contig-names.txt \
	  | awk -F '\t' '{ print $1 }' > ${i}_contig.names

  # rename bin to include assembly name if missing
  if [[ $(ls ${i}_contig.names | grep ${metagenome}) == "" ]] ; then
  	mv ${i}_contig.names ${metagenome}-${i}_contig.names
  fi
  # clean mag name for downstream functions
  mag_name=$(ls -f *${i}_contig.names | sed 's/_contig.names//')

  # split contigs/scaffolds into separate files based on contig.names files
    # parallelize as N batches (N = number of requested cores via Slurm)
    # this really speeds it up...reference https://unix.stackexchange.com/questions/103920/parallelize-a-bash-for-loop
  IFS=$'\n' read -d '' -r -a node_names < *${i}_contig.names
  (
  for x in ${node_names[@]}; do 
     ((z=z%N)); ((z++==0)) && wait
     awk -F '\n' -v RS='>' -v ORS= -v node=$x \
       '$1==(node){print RS $0}' \
       ${metagenome}-scaffolds.fasta >> ${checkm_in}/${mag_name}.fasta & 
  done
  )
done

# check contamination and completeness of manual+automatic binned MAGs with checkm
checkm lineage_wf \
  -t $SLURM_NTASKS \
  -x fasta \
  $checkm_in \
  $checkm_out

# calculate completeness/contamination for each bin
checkm qa \
  -t $SLURM_NTASKS \
  -o 1 \
  -f ${checkm_out}/qa_results.txt \
  --tab_table \
  ${checkm_out}/lineage.ms \
  ${checkm_out}

# remove temp *contig.names files
rm *contig.names

