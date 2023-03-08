#!/bin/bash
#SBATCH -A p30996
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH -n 12
#SBATCH --mail-user=mselensky@u.northwestern.edu
#SBTACH --mail-type=FAIL,END
#SBATCH --job-name="eukdetect-mammoth"
#SBATCH --output=/home/mjs9560/scripts/slurm-out/mammoth-metagenomes/%j-%x.out

module purge all
module load python-miniconda3
#module load snakemake
source activate eukdetect

# snakemake method (doesn't work bc snakemake and conda do not play nicely)
#snakemake \
#  --snakefile /projects/p31618/software/EukDetect/rules/eukdetect.rules \
#  --configfile ~/scripts/mammoth-metagenomes/bash/eukdetect-config.yml \
#  --cores $SLURM_NTASKS \
#  runall

# direct python method (incredibly slow but works)
eukdetect \
--mode runall \
--configfile ~/scripts/mammoth-metagenomes/bash/eukdetect-config.yml \
--cores $SLURM_NTASKS
