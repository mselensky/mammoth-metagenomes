# summarize checkM outputs for each metabat2 iteration

library(tidyverse)

home.dir <- "/home/mjs9560"
proj.dir <- "/projects/p30996/mammoth/metagenomes"
setwd(proj.dir)

# input checkM directories. 
# each input folder has a subfolder for each sample's MAG bins!
input.dirs <- list.files(pattern = "checkm-mags*")

# import results from `checkm qa` into R 
qa.results <- list()
for (i in input.dirs) {
  mag.samples <- list.files(i)
  
  for (x in mag.samples) {
    
    if (file.exists(file.path(i, x, "qa_results.txt"))) {
      qa.results[[i]][[x]] <- read_tsv(file.path(i, x, "qa_results.txt"),
                                       col_types = cols())
    } else {
      warning("File ", file.path(i, x, "qa_results.txt"), " does not exist; skipping.")
    }
  }
}

# join results for each metabat2 iteration
qa.joined <- list()
for (i in names(qa.results)) {
  suppressMessages(
    qa.joined[[i]] <- Reduce(full_join, qa.results[[i]])
  )
  
  qa.joined[[i]]$`metabat2_iteration` = i
  
}

qa.full <- suppressMessages(Reduce(full_join, qa.joined))

# write results to file
write_csv(qa.full, file.path(proj.dir, "checkm-mags-c_2000-qa-results.csv"))

qa.filt <- qa.full %>%
  filter(Completeness >= 50) %>%
  filter(Contamination <= 10)
qa.filt$sample = gsub("_S[0-9].*","",qa.filt$`Bin Id`)

qa.filt %>%
  ggplot(aes(x = `Completeness`, y = `Contamination`, color = sample)) +
  geom_point() +
  facet_wrap(~metabat2_iteration) 

qa.filt %>%
  ggplot(aes(x = `Completeness`, y = `Contamination`, color = sample)) +
  geom_point() +
  facet_wrap(~metabat2_iteration) 

  
qa.full %>%
  ggplot(aes(x = `# genomes`, y = `Contamination`)) +
  geom_point() +
  facet_wrap(~metabat2_iteration) 

qa.full %>%
  filter(Completeness >= 50) %>%
  filter(Contamination <= 10) %>%
  group_by(metabat2_iteration) %>%
  dplyr::summarize(mean_contamination = mean(Contamination), 
                   mean_completeness = mean(Completeness),
                   median_contamination = median(Contamination), 
                   median_completeness = median(Completeness),
                   n_bins = n(), 
                   n_genomes = sum(`# genomes`))

qa.full %>%
  ggplot(aes(x = `Completeness`)) +
  geom_histogram() +
  facet_wrap(~metabat2_iteration) 

mags.filt <- qa.filt %>%
  filter(metabat2_iteration == "checkm-mags-c_2500")

