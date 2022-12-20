# purpose: this script formats MagicLamp output data into a single output csv 
#          that is more easily manipulated in R/Python
# date: 13 Dec 2022

library(tidyverse)

# input MagicLamp directory for Mammoth MAGs and assemblies
work.dir = "/projects/p30996/mammoth/metagenomes"
magiclamp.in = file.path(work.dir, "MagicLamp")
metadata.path = file.path(work.dir, "data", "MC_field_data.csv")
sample.key.path = file.path(work.dir, "data", "MC_sample_key.csv")
MW.score.path = file.path(work.dir, "data", "MW-score_key.txt")
combined.output.path = file.path(magiclamp.in, "magiclamp-results-combined.csv")

# each 'genie' was ran separately...
# options are 'mags' or 'assemblies'
compile.genie.data <- function(run.type) {
  magiclamp.in.mags = file.path(magiclamp.in, run.type)
  mag.samples = list()
  hm.mags = list()
  for (i in list.files(magiclamp.in.mags)) {
    if (i != "lithogenie") {
      path = file.path(magiclamp.in.mags, i)
      mag.samples[[i]] = list.files(path)
      
      data.in = list()
      for (x in mag.samples[[i]]) {
        data.in[[x]] <- list.files(file.path(magiclamp.in.mags, i, x))
        hm.file = grepl("heatmap", data.in[[x]])
        y = data.in[[x]][hm.file == TRUE]
        suppressMessages(
          hm.mags[[x]][[i]] <- read_csv(file.path(magiclamp.in.mags, i, x, y), col_types = cols())
        )
      }
    }
  }
  
  hm.mags.formatted <- list()
  for (x in names(hm.mags)) {
    
    genies = names(hm.mags[[x]])
    for (i in genies) {
      
      if (nrow(hm.mags[[x]][[i]]) != 0) {
        
        if (run.type == "assemblies") {
          if ("scaffolds.faa" %in% names(hm.mags[[x]][[i]])) {
            assembly.name = paste0(x, ".scaffolds.faa")
            hm.mags[[x]][[i]] <- hm.mags[[x]][[i]] %>%
              dplyr::rename_with(.fn = ~paste0(assembly.name), .cols = scaffolds.faa)
          } else {
            message("Sample ", x, " lacks hits for ", i, " ; skipping import.")
          }
        }
        
        hm.mags.formatted[[x]][[i]] <- hm.mags[[x]][[i]] %>%
          pivot_longer(2:ncol(.)) %>%
          filter(!is.na(value)) %>%
          filter(name != "file") %>%
          dplyr::mutate(genie = i,
                        bin = str_remove_all(string = name, pattern = regex(".faa+$")),
                        `sample-id` = str_remove_all(string = bin, pattern = regex("_S[0-9].[0-9]+$"))) %>%
          select(-name) %>%
          dplyr::rename(genie.hmm = X,
                        count = value)
      }
      
      if(nrow(hm.mags.formatted[[x]][[i]]) == 0) {
        hm.mags.formatted[[x]][[i]] <- NULL
      }
      
    }
    
    hm.mags.formatted[[x]] <- Reduce(bind_rows, hm.mags.formatted[[x]])
    
  }
  
  Reduce(bind_rows, hm.mags.formatted)
}
compile.lithogenie <- function(run.type) {
  magiclamp.in.mags = file.path(magiclamp.in, run.type)
  mag.samples = list()
  hm.mags = list()
  hm.mags.red = list()
  dat.out = list()
  # enter the for-loop hell
  for (i in list.files(magiclamp.in.mags)) {
    if (i %in% c("lithogenie", "LithoGenie")) {
      path = file.path(magiclamp.in.mags, i)
      mag.samples[[i]] = list.files(path)
      
      data.in = list()
      for (x in mag.samples[[i]]) {
        data.in[[x]] <- list.files(file.path(magiclamp.in.mags, i, x))
        hm.file = grepl("heatmap", data.in[[x]])
        y = data.in[[x]][hm.file == TRUE]
        for (z in y) {
          suppressMessages(
            hm.mags[[x]][[i]][[z]] <- read_csv(file.path(magiclamp.in.mags, i, x, z), col_types = cols()) %>%
              pivot_longer(2:ncol(.)) %>%
              filter(!is.na(value)) %>%
              dplyr::mutate(lithogenie.hm = z) %>%
              dplyr::rename(genie.hmm = X,
                            bin = name,
                            count = value)
          )
          if(nrow(hm.mags[[x]][[i]][[z]]) == 0) {
            hm.mags[[x]][[i]][[z]] <- NULL
          }
        }
        hm.mags.red[[x]] <- Reduce(bind_rows, hm.mags[[x]][[i]]) 
      }
      
      dat.out[[i]] <- Reduce(bind_rows, hm.mags.red) %>%
        dplyr::mutate(lithogenie.hm = str_remove_all(lithogenie.hm, "lithogenie.")) %>%
        dplyr::mutate(lithogenie.hm = str_remove_all(lithogenie.hm, ".heatmap.csv")) %>%
        dplyr::mutate(`sample-id` = str_remove_all(string = bin, pattern = regex("_S[0-9].scaffolds+$")),
                      `sample-id` = str_remove_all(string = `sample-id`, pattern = regex("_S[0-9].*.fasta+$")))
      
    }
  }
  
  dat.out
  
}

assemblies <- compile.genie.data("assemblies")
mags <- compile.genie.data("mags")
litho.assemblies <- compile.lithogenie("assemblies")
litho.mags <- compile.lithogenie("mags")

names(assemblies)
names(litho.assemblies$lithogenie)

assemblies %>%
  dplyr::mutate(`sample-id` = str_remove_all(string = bin, pattern = regex("_S[0-9].scaffolds+$")),
                `sample-id` = str_remove_all(string = `sample-id`, pattern = regex("_S[0-9].[0-9]+$")))


write_csv(assemblies, file.path(magiclamp.in, "genies-assemblies.csv"))
write_csv(mags, file.path(magiclamp.in, "genies-mags.csv"))
