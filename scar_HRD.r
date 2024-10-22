#library(devtools)
#install_github('sztup/scarHRD',build_vignettes = TRUE)


library(readr)
library("scarHRD")


args <- commandArgs(trailingOnly = TRUE)
file <- args[1]

file_name <- basename(file)
print(file_name)

out <- scar_score(file_name ,reference = "grch37", seqz=F)

file_name <- gsub("_final.txt", "", file_name)
write.table(out, paste0(file_name,"_HRD.txt"), row.names = F)



