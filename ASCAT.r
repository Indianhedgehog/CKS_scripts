##ASCAT SCRIPT and PARAMETERS USED
##Adjust the parameters accordingly depending on the experiment 
##https://github.com/VanLoo-lab/ascat

library(ASCAT)
library(tibble)

args <- commandArgs(trailingOnly = TRUE)

PID <- args[1]
Tumor <- args[2]
Control <-args[3] 
Path <- "/omics/odcf/project/hipo/hipo_021/sequencing/whole_genome_sequencing/view-by-pid"

dir.create(PID)

ascat.prepareHTS(
  tumourseqfile = paste0(Path,"/",PID,"/",Tumor,"/paired/merged-alignment/",Tumor,"_",PID,"_merged.mdup.bam"),
  normalseqfile = paste0(Path,"/",PID,"/",Control,"/paired/merged-alignment/",Control,"_",PID,"_merged.mdup.bam"),
  tumourname = paste0(Tumor,"_",PID),
  normalname = paste0(Control,"_",PID),
  allelecounter_exe = "/PATH/TO/allelecounter",
  alleles.prefix = "/PATH/TO/G1000_alleles_hg19_chr",
  loci.prefix = "/PATH/TO/G1000_loci_hg19_chr",
  gender = "XX",
  genomeVersion = "hg19",
  nthreads = 8,
  tumourLogR_file = "Tumor_LogR.txt",
  tumourBAF_file = "Tumor_BAF.txt",
  normalLogR_file = "Germline_LogR.txt",
  normalBAF_file = "Germline_BAF.txt")

ascat.bc = ascat.loadData(Tumor_LogR_file = "Tumor_LogR.txt", Tumor_BAF_file = "Tumor_BAF.txt", Germline_LogR_file = "Germline_LogR.txt", Germline_BAF_file = "Germline_BAF.txt", gender = 'XX', genomeVersion = "hg19")
ascat.plotRawData(ascat.bc, img.prefix = "Before_correction_")
ascat.bc = ascat.correctLogR(ascat.bc, GCcontentfile = "GC_file.txt", replictimingfile = "RT_file.txt")
ascat.plotRawData(ascat.bc, img.prefix = "After_correction_")
ascat.bc = ascat.aspcf(ascat.bc)
ascat.plotSegmentedData(ascat.bc)

ascat.output = ascat.runAscat(ascat.bc, gamma=1, write_segments = T)
QC = ascat.metrics(ascat.bc,ascat.output)


