# purpose: this script formats METABOLIC-C output data into a single output csv 
#          that is more easily manipulated in R/Python
# date: 18 Mar 2022

library(tidyverse)

# input METABOLIC-C directory for Mammoth MAGs
# work.dir = "/projects/p30996/mammoth/metagenomes"
work.dir = "/scratch/mjs9560/metabolic_c-assemblies-11Apr23"
metabolic.in = file.path(work.dir, "metabolic_c-assemblies")
#metadata.path = file.path(work.dir, "data", "MC_field_data.csv")
#sample.key.path = file.path(work.dir, "data", "MC_sample_key.csv")
#MW.score.path = file.path(work.dir, "data", "MW-score_key.txt")
combined.output.path = file.path(metabolic.in, "metabolic-c-results-combined.csv")

# each sample was ran separately...
mag.samples = list.files(metabolic.in)
print(mag.samples)

# import each METABOLIC result csv file 
dat.in.list = list()
for (i in mag.samples) {
  
  if (!i %in% c("z.intermediate_files", "metabolic-c-results-combined-assemblies.csv")){
    
    dat.in.list[[i]] <- read.delim(file.path(metabolic.in, i,
                                           "METABOLIC_result_each_spreadsheet", 
                                           "METABOLIC_result_worksheet1.tsv")) %>%
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

dat.in <- Reduce(bind_rows, dat.in.list) %>%
  dplyr::mutate(`sample-id` = if_else(`sample-id` == "EN_DV_02_21", "EN_DV_02_20", `sample-id`))

# output combined MAG data
write_csv(dat.in, combined.output.path)
