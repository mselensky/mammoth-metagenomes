# compile quant_bins results

parent_dir="/scratch/mjs9560"
output_dir=file.path(parent_dir, "redundant_nonreassembled_bins_quant_12Apr23")
metagenomes <- list.files(output_dir)
metagenomes <- metagenomes[!metagenomes %in% "quantified_bins_compiled.csv"]

quantified_bins <- lapply(metagenomes,
       function(x){
         tmp <- read.delim(file.path(output_dir, x, "bin_abundance_table.tab"))
         colnames(tmp) = c("bins", "bin_copies_Mreads")
         tmp
         }
       )
data.out <- Reduce(rbind, quantified_bins)
write.csv(data.out, file.path(output_dir, "quantified_bins_compiled.csv"), row.names = FALSE)


# visualize distribution
data.out %>% ggplot() + geom_histogram(aes(bin_copies_Mreads), bins = 50)
