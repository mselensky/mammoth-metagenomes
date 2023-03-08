#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

anvio_bins_dir=args[1] # anvio fasta parent folder
metagenome=args[2] # name of assembly
manual_bins=[3] # boolean; true = manual bins to format for post-anvio processing, false = automatic bins to format for anvio

message("---------- reformat_autobin_names_for_anvio.R ----------")

message("Start: ", Sys.time(), "\nBin folder: ", anvio_bins_dir,
        "\nReformatting contig names for MAGs automatically binned from assembly: ", metagenome,
        "\nAutomatic bins supplied: ", manual_bins)

# anvio contig name keys
contig.key = read.delim(file.path(anvio_bins_dir, 
                                  paste0(metagenome,
                                         "-scaffolds-anvio-frmttd-key.txt")),
                        header = F,
                        col.names = c("anvio_name", "orig_name"))

if (manual_bins == FALSE) {
  
  user.bins = read.delim(file.path(anvio_bins_dir,
                                   paste0(metagenome,
                                          "-bins-formatted.txt")),
                         header = F,
                         col.names = c("anvio_name", "user_bin"))
} else {
  
  user.bins = read.delim(file.path(anvio_bins_dir, "manual_bins",
                                   paste0(metagenome,
                                          "-manual-bins-contig-keys.txt")),
                         header = F,
                         col.names = c("anvio_name", "user_bin"))
  
}


contig.names.joined <- merge(user.bins, contig.key)

if (manual_bins == FALSE) {
  data.out <- contig.names.joined[, c("anvio_name", "user_bin")]
  out.path=file.path(anvio_bins_dir, paste0(metagenome,
                                            "-bins-formatted.txt"))
} else {
  data.out <- contig.names.joined[, c("orig_name", "user_bin")]
  out.path=file.path(anvio_bins_dir, 
                     "manual_bins", "bin_fastas", metagenome,
                     "manual-bins-orig-contig-names.txt")
}

write.table(data.out, sep = "\t", quote = FALSE,
            row.names = FALSE, col.names = FALSE,
            file = out.path)
message("End: ", Sys.time(),
        "\nContig name reformatting complete.",
        "\nOutput saved to: ", out.path)

