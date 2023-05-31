# compile CheckM results from reassemblied bins via metaWRAP

setwd("/scratch/mjs9560/anvio-bins-frmttd2-manual_reassembled_bins")
metagenomes <- list.files("/scratch/mjs9560/anvio-bins-frmttd2-manual_reassembled_bins")

qa.results <- lapply(metagenomes, function(i) {
  if (!i %in% "reassembled_bin_stats_compiled.csv") {
    read.delim(file.path(i, "reassembled_bins.stats"))
    }
  })
names(qa.results) = metagenomes

#qa.results <- lapply(qa.results, function(i) {i$`sample-id` = names(i)})
for (i in metagenomes) {
  if (!i %in% "reassembled_bin_stats_compiled.csv") {
    qa.results[[i]]$`sample-id` = rep(i, nrow(qa.results[[i]]))
  }
}

qa.full <- Reduce(rbind,qa.results)
write.csv(qa.full, "reassembled_bin_stats_compiled.csv", row.names = FALSE)

# export high-quality MAGs for functional gene annotation
mags.to.annotate <- qa.full %>%
  filter(completeness >= 50 & contamination <= 10) %>%
  distinct(bin) 
write.table(mags.to.annotate, "/scratch/mjs9560/mags_to_annotate.txt", 
            row.names = FALSE, col.names = FALSE, quote = FALSE)


