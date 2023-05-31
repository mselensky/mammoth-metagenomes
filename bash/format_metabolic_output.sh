#!/bin/bash

# move intermediate files from METABOLIC output to another folder so we only have to 
# transfer output data via Globus

# move to input directory
cd $1

for sample in */; do

	# create output folder 
	export SAMPLE=`echo ${sample} | sed 's|/||'`
	export WORK_D=`pwd`
	export OUT_DR="${WORK_D}/z.intermediate_files/${SAMPLE}"
	mkdir -p $OUT_DR

	# move GTDB classification results to sample folder
	cd ${SAMPLE}/intermediate_files 
	mv gtdbtk_Genome_files/classify ${WORK_D}/${SAMPLE}/gtdbtk_classify

	# move remaining intermediate files to $OUT_DR
	mv dbCAN2_Files $OUT_DR
	mv Hmmsearch_Outputs $OUT_DR
	mv MEROPS_Files $OUT_DR
	mv gtdbtk_Genome_files $OUT_DR
	
	# move HMM AAs and KEGG outputs too
	cd ${WORK_D}/${SAMPLE}
	mv Each_HMM_Amino_Acid_Sequence $OUT_DR
	mv KEGG_identifier_result $OUT_DR

	# return to parent folder and clean up empty folder
	cd $WORK_D
	rm -r ${SAMPLE}/intermediate_files

done
