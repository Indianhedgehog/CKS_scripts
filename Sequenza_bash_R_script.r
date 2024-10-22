##Sequenza  script
##Combination of bash and R script 

PID=$1
Tumor=$2
Control=$3

mkdir -p ${PID}

#Process a FASTA file to produce a GC Wiggle track file:
sequenza−utils gc_wiggle −w 50 --fasta hg19.fa -o hg19.gc50Base.wig.gz

#Process BAM and Wiggle files to produce a seqz file:
sequenza−utils bam2seqz -n ${PID}/${Control}/paired/merged-alignment/${Control}_${PID}_merged.mdup.bam\ 
-t ${PID}/${Tumor}/paired/merged-alignment/${Tumor}_${PID}_merged.mdup.bam\ 
--fasta hg19.fa -gc hg19.gc50Base.wig.gz -o ${PID}.seqz.gz

#Post-process by binning the original seqz file:
sequenza−utils seqz_binning --seqz  ${PID}.seqz.gz -w 50 -o out ${PID}.small.seqz.gz


#Sequenza analysis (in R) for plotting

library(sequenza)

args <- commandArgs(trailingOnly = TRUE)

PID <- args[1]

sample <- sequenza.extract(PID.small.seqz.gz, verbose = FALSE)
CP <- sequenza.fit(sample)

sequenza.results(sequenza.extract = test,
    cp.table = CP, sample.id = PID,
    out.dir=PID)