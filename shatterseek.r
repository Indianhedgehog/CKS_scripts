##https://github.com/parklab/ShatterSeek

library(ShatterSeek)
library(dplyr)
library(stringr)
library(tidyr)
library(qs)



args <- commandArgs(trailingOnly = TRUE)

seg.df <- args[1]

print(paste("Processing file:", seg.df))

df2 <- read.table(paste0(seg.df), header= T)
df2 <- df2 %>%
  filter(!chrom1 %in% "Y") %>%
  filter(!chrom2 %in% "Y")

df2$SVtype <- ifelse(df2$SVtype == "BND", "TRA", df2$SVtype)
df2$SVtype <- ifelse(df2$SVtype == "INV" & df2$strand1 == "+" & df2$strand2 == "+", "h2hINV", df2$SVtype )
df2$SVtype <- ifelse(df2$SVtype == "INV" & df2$strand1 == "-" & df2$strand2 == "-", "t2tINV", df2$SVtype )

basename <- tools::file_path_sans_ext(basename(seg.df))

#setwd()
df3 <- read.table(paste0("/omics/odcf/analysis/hipo/hipo_021/RP_all_RNAseq/hmf/chromothripsis/CNA/",seg.df), header= T)
df3 <- df3 %>%
  filter(!chromosome %in% "Y")
#write(df,"/omics/odcf/analysis/hipo/hipo_021/RP_all_RNAseq/sv_analysis/Delly/delly_alt_analysis_stringent_filter/sensa_test/samples_test/txt_files/results/test.txt")

SV_data <- SVs(chrom1=as.character(df2$chrom1), 
               pos1=as.numeric(df2$start1),
               chrom2=as.character(df2$chrom2), 
               pos2=as.numeric(df2$end2),
               SVtype=as.character(df2$SVtype), 
               strand1=as.character(df2$strand1),
               strand2=as.character(df2$strand2))




CN_data <- CNVsegs(chrom=as.character(df3$chromosome),
                   start=df3$start,
                   end=df3$end,
                   total_cn=df3$total_cn)

chromothripsis <- shatterseek(
  SV.sample=SV_data,
  seg.sample=CN_data,
  genome="hg19")

summary <- as.data.frame(chromothripsis@chromSummary)

setwd("/directory/")
write.table(data, paste0(basename,".chr_txt"))
write.table(summary, paste0(basename,".summary_txt"), quote = F, sep = "\t")
qsave(chromothripsis,paste0(basename,".qs"))

print(basename)
