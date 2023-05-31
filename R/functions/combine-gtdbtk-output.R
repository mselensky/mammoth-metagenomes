library(tidyverse)

args = commandArgs(trailingOnly=TRUE)

# input METABOLIC-C directory for Mammoth MAGs
metabolic.in = file.path(args[1])

# each sample was ran separately...
mag.samples = list.files(metabolic.in)
mag.samples = mag.samples[!mag.samples %in% "z.intermediate_files"]

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
      message("Sample ", i, " lacks archaeal genomes; skipping archaeal data import.")
    }
    
  } else {
    message("File ", i, " does not contain required data; skipping import.")
  }
  
}

# merge bacterial and archaeal taxonomies
bac.in <- Reduce(rbind, bac.in.list)
arc.in <- Reduce(rbind, arc.in.list)
merged.tax <- rbind(bac.in, arc.in)

out.path=file.path(metabolic.in, "gtdbtk-taxonomies.csv")
write_csv(merged.tax,
          out.path)

message("[ ", Sys.time(), " ] GTDB taxonomies compiled and exported to:\n", out.path)


