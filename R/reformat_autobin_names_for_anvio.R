#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

anvio_bins_dir=args[1]
metagenome=args[2]

message("---------- reformat_autobin_names_for_anvio.R ----------")

message("Start: ", Sys.time(), "\nBin folder: ", anvio_bins_dir,
        "\nReformatting contig names for MAGs automatically binned from assembly: ", metagenome)

# anvio contig name keys
contig.key = read.delim(file.path(anvio_bins_dir, 
                                  paste0(metagenome,
                                  "-scaffolds-anvio-frmttd-key.txt")),
                        header = F,
                        col.names = c("anvio_name", "orig_name"))
# automatic bins
auto.bins = read.delim(file.path(anvio_bins_dir,
                                 paste0(metagenome,
                                 "-bins-formatted.txt")),
                       header = F,
                       col.names = c("orig_name", "auto_bin"))

contig.names.joined <- merge(auto.bins, contig.key)

data.out <- contig.names.joined[, c("anvio_name", "auto_bin")]
out.path=file.path(anvio_bins_dir, paste0(metagenome,
                                          "-bins-formatted.txt"))
write.table(data.out, sep = "\t", quote = FALSE,
            row.names = FALSE, col.names = FALSE,
            file = out.path)
message("End: ", Sys.time(),
        "\nContig name reformatting complete.",
        "\nOutput saved to: ", out.path)
