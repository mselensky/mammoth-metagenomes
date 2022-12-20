# this script copies fine-tuned metabat2 bins into metawrap folder for refinement with bins from other software

IFS=$'\n' read -d '' -r -a input_args < /home/mjs9560/scripts/mammoth-metagenomes/samples

base_dir=/projects/p30996/mammoth/metagenomes/

for i in ${input_args[@]}; do

	mkdir -p ${base_dir}/metaWRAP-initial-bins/${i}/metabat2_bins
	cp ${base_dir}/metabat2-mammoth-scaffolds-c_2000/${i}/*.fasta ${base_dir}/metaWRAP-initial-bins/${i}/metabat2_bins
	rm ${base_dir}/metaWRAP-initial-bins/${i}/metabat2_bins/*tooShort.fasta

done
