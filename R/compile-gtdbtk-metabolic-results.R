library(tidyverse)

# input METABOLIC-C directory for Mammoth MAGs
work.dir = "/projects/p30996/mammoth/metagenomes"
metabolic.in = file.path(work.dir, "metabolic_c-mags-c_2000")
metadata.path = file.path(work.dir, "data", "MC_field_data.csv")
sample.key.path = file.path(work.dir, "data", "MC_sample_key.csv")
MW.score.path = file.path(work.dir, "data", "MW-score_key.txt")
combined.output.path = file.path(metabolic.in, "metabolic-c-results-combined.csv")

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

# each sample was ran separately...
mag.samples = list.files(metabolic.in)

# import each taxonomy result tsv file (Bacteria and Archaea are separate)
bac.in.list = list()
arc.in.list = list()
for (i in mag.samples) {
  
  if (file.exists(file.path(metabolic.in, i, "gtdbtk_classify"))) {
    
    bac.path <- file.path(metabolic.in, i, "gtdbtk_classify", "gtdbtk.bac120.summary.tsv")
    bac.in.list[[i]] <- read_tsv(bac.path, col_types = cols()) %>%
      dplyr::mutate(`sample-id` = str_remove_all(string = i, pattern = regex("_S[0-9]+$")), 
                    across(.cols = everything(), .fns = as.character))
    
    # not every sample has archaeal genomes
    arc.path <- file.path(metabolic.in, i, "gtdbtk_classify", "gtdbtk.ar122.summary.tsv")
    
    if (file.exists(arc.path)) {
      arc.in.list[[i]] <- read_tsv(arc.path, col_types = cols()) %>%
        dplyr::mutate(`sample-id` = str_remove_all(string = i, pattern = regex("_S[0-9]+$")), 
                      across(.cols = everything(), .fns = as.character))
    } else {
      message("Sample ", i, " lacks archaeal genomes; skipping import.")
    }
    
  } else {
    message("File ", i, " does not contain required data; skipping import.")
  }
  
}

# merge bacterial and archaeal taxonomies
bac.in <- Reduce(rbind, bac.in.list)
arc.in <- Reduce(rbind, arc.in.list)
merged.tax <- rbind(bac.in, arc.in)

full.tax <- merged.tax %>% 
  left_join(., sample_key, by = c("sample-id" = "reconciled_name")) %>%
  left_join(., field_metadata, by = "record")

write_csv(merged.tax,
          file.path(metabolic.in, "gtdbtk-taxonomy-metadata.csv"))
