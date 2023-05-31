# purpose: this script formats METABOLIC-C output data into a single output csv 
#          that is more easily manipulated in R/Python
# date: 18 Mar 2022

library(tidyverse)

args = commandArgs(trailingOnly=TRUE)

# input METABOLIC-C directory
metabolic.in = file.path(args[1])

# define output path
combined.output.path = file.path(metabolic.in, "metabolic-c-results-combined.csv")

# list metagenomes
mag.samples = list.files(metabolic.in)
print(mag.samples)

# import each METABOLIC result csv file 
dat.in.list = list()
for (i in mag.samples) {
  
  if (!i %in% c("z.intermediate_files", "gtdbtk-taxonomy-metadata.csv")){
    
    dat.in.list[[i]] <- read_tsv(file.path(metabolic.in, i,
                                           "METABOLIC_result_each_spreadsheet", 
                                           "METABOLIC_result_worksheet1.tsv"),
                                 col_types = cols()) %>%
      select(!contains("presence")) %>%
      select(!contains("Hits")) 
    
    if (ncol(dat.in.list[[i]]) >= 11 ) {
      dat.in.list[[i]] <- dat.in.list[[i]] %>%
        pivot_longer(cols = 11:ncol(.), names_to = "bin", values_to = "gene_hits") %>%
        dplyr::mutate(bin = str_remove_all(bin, " Hit numbers"),
                      `sample-id` = str_remove_all(string = i, pattern = regex("_S[0-9]*+$")))
    }
    
  }
  
  dat.in.list[[i]]
  
}

dat.in <- Reduce(bind_rows, dat.in.list)

# output combined MAG data
write_csv(dat.in, combined.output.path)
