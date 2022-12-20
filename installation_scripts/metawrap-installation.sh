#!/bin/bash

# metaWRAP: https://github.com/bxlab/metaWRAP

# steps to install on Quest:
module purge all
module load mamba
mamba create --prefix /projects/p31618/software/metawrap python=2.7 -y
source activate /projects/p31618/software/metawrap
mamba install --only-deps -c ursky metawrap-mg -y
mamba install blas=2.5=mkl -y 
mamba install -c conda-forge biopython -y
mamba install -c bioconda concoct samtools bwa -y

