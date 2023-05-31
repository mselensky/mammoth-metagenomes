library(tidyverse)

drep_dir="/scratch/mjs9560/anvio-bins-frmttd2-manual_dereplicated_12Apr23/data_tables"
drep_info <- read.csv(file.path(drep_dir, "Widb.csv"))
clusters_info <- read.csv(file.path(drep_dir, "Cdb.csv")) %>%
  dplyr::rename(cluster = secondary_cluster)
full_checkm_results <- read.csv("/scratch/mjs9560/anvio-bins-frmttd2-manual_reassembled_bins/reassembled_bin_stats_compiled.csv")

drep_joined <- left_join(clusters_info, drep_info, by = c("genome", "cluster"))

# list representative genomes for MAGs that were dereplicated
columns.to.keep = c("genome", "cluster", "completeness", "contamination", "N50", "size")
a <- drep_joined %>%
  select(any_of(columns.to.keep), score) %>%
  #pivot_longer(2:ncol(.))
  group_by(cluster) %>%
  dplyr::mutate(rep_genome = if_else(is.na(score), "fill", genome))

no_comp_ <- a %>%
  filter(is.na(score)) %>%
  select(genome) %>%
  dplyr::mutate(genome = str_remove_all(genome, ".fasta")) %>%
  left_join(full_checkm_results, by = c('genome'='bin')) %>%
  select(any_of(columns.to.keep))

b <- a %>%
  select(any_of(columns.to.keep), rep_genome, score) %>%
  filter(!is.na(score)) %>%
  select(-score) %>%
  full_join(no_comp_) 

drep_joined_split <- split(b, b$cluster)

name_representatives <- function(x) {
  representative = x[!is.na(x$rep_genome), ]$genome
  x$rep_genome = representative
  x
}

drep_renamed <- lapply(drep_joined_split, name_representatives)
drep_renamed <- Reduce(rbind, drep_renamed)


write.csv(drep_renamed, file.path(drep_dir, "drep_info.csv"), row.names = FALSE)

