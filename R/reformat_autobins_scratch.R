#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

anvio_bins_dir=args[1] # anvio fasta parent folder
metagenome=args[2] # name of assembly

message("---------- reformat_autobin_names_for_anvio.R ----------")

message("Start: ", Sys.time(), "\nBin folder: ", anvio_bins_dir,
        "\nReformatting contig names for MAGs automatically binned from assembly: ", metagenome)

# anvio contig name keys
contig.key = read.delim(file.path(anvio_bins_dir, 
                                  paste0(metagenome,
                                         "-scaffolds-anvio-frmttd-key.txt")),
                        header = F,
                        col.names = c("anvio_name", "orig_name"))

user.bins = read.delim(file.path(anvio_bins_dir, "manual_bins",
                                 paste0(metagenome,
                                        "-manual-bins-contig-keys.txt")),
                       header = F,
                       col.names = c("anvio_name", "bin_name"))

contig.names.joined <- merge(user.bins, contig.key)

data.out <- contig.names.joined[, c("anvio_name", "auto_bin")]
out.path=file.path(anvio_bins_dir, paste0(metagenome,
                                          "-bins-formatted.txt"))
write.table(data.out, sep = "\t", quote = FALSE,
            row.names = FALSE, col.names = FALSE,
            file = out.path)
message("End: ", Sys.time(),
        "\nContig name reformatting complete.",
        "\nOutput saved to: ", out.path)

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
