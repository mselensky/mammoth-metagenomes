#!/bin/bash

printf "
 | ----------------------------------------
 | Metabolic path: $MB
 | Reads folder  : $READS_DR
 | Output folder : $OUT_DR
 | User path     : $PATH
 | ---------------
 | JobID         : $SLURM_JOB_ID
 | CPUs          : $SLURM_NTASKS
 | Node          : `hostname`
 | Date          : `date`
 | ----------------------------------------
 | User          : $USER
 | ________________________________________
 | The following will be annotated:
`ls -f $BIN_DR | grep fasta`\n"

# run metabolic for each site
SECONDS=0

perl $MB/METABOLIC-C.pl \
-in-gn $BIN_DR \
-o $OUT_DR \
-r ${READS_DR}/${site}-paths.txt \
-t $SLURM_NTASKS \
-tax phylum 

meta_time=$SECONDS

printf "\n
-------------------------------
 | Job $SLURM_JOB_ID completed!
 | CPUs: $SLURM_NTASKS
 | Node: `hostname`
 | Date: `date`
-------------------------------
 | function       | runtime (s)
 | ----------------------------
 | METABOLIC-C.pl | $meta_time\n"

# export slurm runtime stats
export JOB_2_SUMM=$SLURM_JOB_ID

printf "\n | Generating runtime job report...\n"

sbatch \
--job-name=$SLURM_JOB_NAME \
--output=/home/$USER/scripts/slurm-out/job-reports/$JOB_2_SUMM-job-report-%x.out \
/home/$USER/scripts/job-report.sh

printf " | Runtime stats saved to /home/$USER/scripts/slurm-out/job-reports/$JOB_2_SUMM-job-report-${SLURM_JOB_NAME}.out\n"
