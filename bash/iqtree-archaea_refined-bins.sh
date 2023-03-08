#!/bin/bash
#SBATCH -A p30996
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH -n 4
#SBATCH --mem-per-cpu=36G
#SBATCH --job-name=iqtree-denovo_archaea_MC-refined-mags
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out
#SBATCH --mail-user=mselensky@u.northwestern.edu \
#SBATCH --mail-type=END,FAIL

module purge all
module load python-miniconda3
source activate /projects/p31618/software/iqtree

proj_dir=/projects/p30996/mammoth/metagenomes

iqtree -s \
  ${proj_dir}/refined_bins_gtdbtk-denovo-wf_archaea/align/gtdbtk.ar53.msa.fasta.gz \
  --prefix ${proj_dir}/refined-bins-archaea-tree \
  -nt $SLURM_NTASKS \
  -mem 144G
