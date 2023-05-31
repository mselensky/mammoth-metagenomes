# summarize checkM outputs for each metabat2 iteration

library(tidyverse)

home.dir <- "/home/mjs9560"
proj.dir <- "/projects/p30996/mammoth/metagenomes/anvio-bins-frmttd2/manual_bins/bin_fastas"
setwd(proj.dir)

# input checkM directories. 
# each input folder has a subfolder for each sample's MAG bins!
input.dirs <- list.files()

# import results from `checkm qa` into R 
qa.results <- list()
for (i in input.dirs) {
  qa.results[[i]] <- read.delim(file.path(i, "checkm/qa_results.txt"))
  
  # for (x in mag.samples) {
  #   
  #   if (file.exists(file.path(i, x, "qa_results.txt"))) {
  #     qa.results[[i]][[x]] <- read_tsv(file.path(i, x, "qa_results.txt"),
  #                                      col_types = cols())
  #   } else {
  #     warning("File ", file.path(i, x, "qa_results.txt"), " does not exist; skipping.")
  #   }
  # }
}

# join and write results to file
qa.joined <- Reduce(rbind, qa.results)
qa.joined$sample = gsub("_S[0-9].*","",qa.joined$Bin.Id)
write_delim(qa.joined, file = "all_qa_results.txt", delim = "\t")

qa.filt <- qa.joined %>%
  filter(Completeness >= 50) %>%
  filter(Contamination <= 10)

qa.joined %>%
  ggplot(aes(x = `Completeness`, y = `Contamination`, color = sample)) +
  geom_point() 
qa.filt %>%
  ggplot(aes(x = `Completeness`, y = `Contamination`, color = sample)) +
  geom_point() 

qa.filt %>%
  group_by(sample) %>%
  dplyr::summarise(n())
  
qa.joined %>%
  filter(Completeness >= 50 & Contamination >=10) %>%
  group_by(sample) %>%
  dplyr::summarise(n())
  

  
qa.joined %>%
  ggplot(aes(x = `# genomes`, y = `Contamination`)) +
  geom_point() +
  facet_wrap(~metabat2_iteration) 

qa.joined %>%
  filter(Completeness >= 50) %>%
  filter(Contamination <= 10) %>%
  group_by(sample) %>%
  dplyr::summarize(mean_contamination = mean(Contamination), 
                   mean_completeness = mean(Completeness),
                   median_contamination = median(Contamination), 
                   median_completeness = median(Completeness),
                   n_bins = n(), 
                   n_genomes = sum(`X..genomes`))

qa.full %>%
  ggplot(aes(x = `Completeness`)) +
  geom_histogram() +
  facet_wrap(~metabat2_iteration) 

mags.filt <- qa.filt %>%
  filter(metabat2_iteration == "checkm-mags-c_2500")

