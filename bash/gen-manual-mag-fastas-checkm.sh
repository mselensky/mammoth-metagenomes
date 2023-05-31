#!/bin/bash
#SBATCH -A p30996
#SBATCH -p short
#SBATCH -t 04:00:00
#SBATCH -n 12
#SBATCH -N 1
#SBATCH --array=0-20
#SBATCH --mem-per-cpu=4G
#SBATCH --job-name="generate-manual-mag-fastas-checkm"
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBATCH --mail-type=END,FAIL
#SBATCH -o /home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%A_%a-%x.out

# this script takes exported "bin collections" from the anvio interactive
# manual genome binning tool, saves each bin as a separate fasta by 
# searching for matching sequences from the corresponding assembly,
# and performs checkm on the compiled bin fastas for a given assembly.

#### import software and define number of cores
module purge all 
N=$SLURM_NTASKS

#### define IO directories
# parent MAG folder (subfolders are individual metagenomes)
parent_dir=/projects/p30996/mammoth/metagenomes
anvio_bins=${parent_dir}/anvio-bins-frmttd2
metagenome_parent=${parent_dir}/metaWRAP-refined-bins-50compl-50contam
assemblies=${parent_dir}/assembled-spades
# list of metagenomes to analyze
IFS=$'\n' read -d '' -r -a metagenome_samples < /home/mjs9560/scripts/mammoth-metagenomes/samples
# run this iteratively as you manually check/refine MAGs
# (ideally in groups of three for this array job)
# 8 March 2023:
# metagenome_samples=(AW_RC_05_21_S5 AW_RC_10_21_S16 BB_DV_03_21_S15)
# 12 March 2023:
# metagenome_samples=(BL_LC_01_21_S4 BP_LC_01_21_S7)
# 13 March 2023 rerun (after fixing ambiguous file error):
# metagenome_samples=(AW_RC_05_21_S5 AW_RC_10_21_S16 BB_DV_03_21_S15 BL_LC_01_21_S4 BP_LC_01_21_S7 BS_MC_01_21_S1)
# oops I forgot to reformat the first metagenome
#metagenome_samples=(AW_RC_01_21_S2)
# 14 March 2023:
#metagenome_samples=(BS_MC_01_21_S1 CX_GO_08_21_S17 CX_GO_13_21_S3 EN_DV_02_21_S20)
# 15 March 2023:
#metagenome_samples=(EP_LC_04_21_S19 FR_ND_02_21_S8 GZ_MC_03_20_S13 GZ_MC_13_20_S11 PA_XL_04_20_S12 PA_XL_07_20_S21)
# 16 March 2023:
#metagenome_samples=(PP_CC_04_21_S6 TS_DV_03_21_S14 VD_CC_01_21_S18 VH_MC_02_21_S10 VH_MC_04_21_S9)
metagenome=${metagenome_samples[$SLURM_ARRAY_TASK_ID]}

echo "[`date`] Creating MAG fasta files from assembly '$metagenome'"

# copy contigs/scaffolds to anvio bin folder
cd ${anvio_bins}/manual_bins
assemblies_path=${assemblies}/${metagenome}/tmp-bin/scaffolds.fasta
cp $assemblies_path ${metagenome}-scaffolds.fasta
# checkm IO
checkm_in=`pwd`/bin_fastas/${metagenome}
checkm_out=${checkm_in}/checkm
mkdir -p $checkm_out; mkdir -p $checkm_in

# rename bin collection node names to match original contigs/scaffolds
awk -F '\t' -vOFS='\t' '{ gsub("_split_00001", "", $1) ; print }' \
 ${metagenome}-manual-bins.txt \
 > ${metagenome}-manual-bins-contig-keys.txt

### split scaffold nodes into separate temp files that are then rejoined for 
### each bin based on ${metagenome}-manual-bins-orig-contig-names.txt
# get unique manual bin names
awk -F '\t' '!a[$2]++' ${metagenome}-manual-bins-contig-keys.txt \
  | awk -F '\t' '{print $2}' \
  > ${checkm_in}/bin_names

# this R script will take the anvio bins contig keys and return a list of 
# contigs with original names mapped to manually curated bins
# consult the R script for positional argument info
#    note: output is ${checkm_in}/manual-bins-orig-contig-names.txt
module load R/4.1.1
Rscript /home/mjs9560/scripts/mammoth-metagenomes/R/reformat_anvio_contig_names.R \
  ${anvio_bins} \
  ${metagenome} \
  TRUE
module purge R/4.1.1

cd ${checkm_in}
# this function will export fasta files 
export_fasta () {
  local i=$1

  echo "[`date`] Exporting fasta file for bin '$i'"

  # obtain node names for each bin
   awk -F '\t' -v binny=$i '$2 == (binny)' \
     manual-bins-orig-contig-names.txt \
     | awk -F '\t' '{ print $1 }' > ${i}_contig.names

  # rename bin to include assembly name if missing
  if [[ $(ls ${i}_contig.names | grep ${metagenome}) == "" ]] ; then
    echo "[`date`] Note: renamed '${i}' to '${metagenome}-${i}'"
    mv ${i}_contig.names ${metagenome}-${i}_contig.names
  fi
  # clean mag name for downstream functions
  mag_name=$(ls -f *${i}_contig.names | sed 's/_contig.names//')

  # split contigs/scaffolds into separate files based on contig.names files
  IFS=$'\n' read -d '' -r -a node_names < *${i}_contig.names
  (
  for x in ${node_names[@]}; do  
     awk -F '\n' -v RS='>' -v ORS= -v node=$x \
       '$1==(node){print RS $0;exit}' \
       ../../${metagenome}-scaffolds.fasta >> ${mag_name}.fasta
  done
  )
}
# parallelize as N batches (N = number of requested cores via Slurm)
    # this really speeds it up...reference https://unix.stackexchange.com/questions/103920/parallelize-a-bash-for-loop
IFS=$'\n' read -d '' -r -a mag_bins < bin_names
for i in ${mag_bins[@]}; do
  ((z=z%N)); ((z++==0)) && wait
  export_fasta $i &
done


module load checkm
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
rm ${checkm_in}/*contig.names
