parent_dir="/projects/p30996/mammoth/metagenomes"
anvio_bins=file.path(parent_dir,"anvio-bins")
assemblies=file.path(parent_dir, "assembled-spades")
metagenome_parent=file.path(parent_dir, "metaWRAP-refined-bins-50compl-50contam")

home.dir=getwd()
setwd(anvio_bins)

list.files()
i="AW_RC_01_21_S2"
assembly.path=file.path(assemblies, i, "tmp-bin", "scaffolds.fasta")
contigs=read.delim(assembly.path, header = FALSE)

names(contigs)
