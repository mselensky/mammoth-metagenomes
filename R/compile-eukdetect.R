library(tidyverse)

# input EukDetect results directory
eukdetect.path = "/projects/p30996/mammoth/metagenomes/eukdetect"

list.files(eukdetect.path)

samples <- unique(gsub("_filtered.*", "", list.files(eukdetect.path)))
samples <- samples[!samples %in% c("filtering", "aln")]

input.data = list()

for (i in samples) {
  
  sample.results = list.files(eukdetect.path)[grepl(i, list.files(eukdetect.path)) == TRUE]
  
  for (x in sample.results) {
    input.data[[i]][[x]] <- read_tsv(file.path(eukdetect.path, x), col_types = cols())
  }
  
  #input.data[[i]] <- Reduce(full_join, input.data[[i]])

}

