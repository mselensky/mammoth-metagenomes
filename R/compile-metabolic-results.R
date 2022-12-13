# purpose: this script formats METABOLIC-C output data into a single output csv 
#          that is more easily manipulated in R/Python
# date: 07 Dec 2022

library(tidyverse)

# input METABOLIC-C directory for Mammoth MAGs
work.dir = "/projects/p30996/mammoth/metagenomes"
metabolic.in = file.path(work.dir, "metabolic_c-assemblies")
metadata.path = file.path(work.dir, "data", "MC_field_data.csv")
sample.key.path = file.path(work.dir, "data", "MC_sample_key.csv")
MW.score.path = file.path(work.dir, "data", "MW-score_key.txt")
combined.output.path = file.path(metabolic.in, "metabolic-c-results-combined.csv")

# each sample was ran separately...
mag.samples = list.files(metabolic.in)
print(mag.samples)

# import sample metadata
field_metadata <- read_csv(metadata.path) %>%
  mutate(sample_type2 = case_when(grepl("sed", sample_type) ~ "sediment",
                                  grepl("micro", sample_type) ~ "biofilm",
                                  grepl("actino", sample_type) ~ "biofilm",
                                  grepl("coralloids", sample_type) ~ "mineral feature",
                                  grepl("polyps", sample_type) ~ "mineral feature",
                                  grepl("coating", sample_type) ~ "mineral feature",
                                  grepl("water", sample_type) ~ "water"))
sample_key <- read_csv(sample.key.path)

# import MW score key
MW_key <- read_delim(MW.score.path, delim = "\t")
MWscore_byhmm <- select(MW_key, -Gene, -Substrate, -Product) %>%
  rename(Hmm.file = `Hmm files`) %>%
  mutate(filesimp = str_remove_all(Hmm.file,'_')) %>%
  mutate(filesimp = str_remove_all(filesimp, '-')) %>%
  separate_rows(filesimp)


# import each METABOLIC result csv file 
dat.in.list = list()
for (i in mag.samples) {
  dat.in.list[[i]] <- read_tsv(file.path(metabolic.in, i,
                                         "METABOLIC_result_each_spreadsheet", 
                                         "METABOLIC_result_worksheet1.tsv"),
                               col_types = cols()) %>%
    select(!contains("presence")) %>%
    select(!contains("Hits")) %>%
    pivot_longer(cols = 11:ncol(.), names_to = "bin", values_to = "gene_hits") %>%
    dplyr::mutate(bin = str_remove_all(bin, " Hit numbers"),
                  `sample-id` = str_remove_all(string = i, pattern = regex("_S[0-9]+$")))
}

dat.in <- Reduce(bind_rows, dat.in.list) %>%
  dplyr::mutate(`sample-id` = if_else(`sample-id` == "EN_DV_02_21", "EN_DV_02_20", `sample-id`))

# output combined MAG data
write_csv(dat.in, combined.output.path)
