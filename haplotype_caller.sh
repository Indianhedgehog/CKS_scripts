
PID=$1
Control=$2
path=/omics/odcf/project/hipo/hipo_021/sequencing/whole_genome_sequencing/view-by-pid

mkdir -p ${PID}

###Marking_duplicates
picard -Xms4G -Xmx32G MarkDuplicates \
-I ${Control} \
-O ${PID}/${PID}.bam \
-M ${PID}/${PID}dup.metrics \
--TMP_DIR ${PID} \
--CREATE_INDEX true --VALIDATION_STRINGENCY SILENT 
###

###Calibrating_Bases
gatk BaseRecalibrator -R /path/to/reference_genome \
-I ${Control} \
-O ${PID}/${PID}_recal.data.csv \
--intervals /path_to/Interval_file \
--known-sites /path/to/high_confidence_snps \
--known-sites /path/to/high_confidence_indels \ 
--known-sites /path/to/dbsnps


###BQSR
gatk ApplyBQSR -R /path/to/reference_genome \
-I ${PID}/${PID}.bam \
-O ${PID}/${PID}_processed.bam \
--intervals /path_to/Interval_file \
--bqsr-recal-file ${PID}/${PID}_recal.data.csv .csv 



###Calling variants
gatk HaplotypeCaller R /path/to/reference_genome \
-I ${PID}/${PID}_processed.bam \
-O ${PID}/${PID}.vcf \
--intervals /path_to/Interval_file \
-D /path/to/dbsnps \
--dont-use-soft-clipped-bases 
###

###Selecting SNPS
gatk SelectVariants -V ${PID}/${PID}.vcf \
-select-type SNP -O ${PID}/${PID}.snps.vcf.gz  

###

###Selecting INDELS
gatk SelectVariants -V ${PID}/${PID}.vcf \
-select-type INDEL -O ${PID}/${PID}.indels.vcf.gz  

###

###hardfiltering SNPS

gatk VariantFiltration         \
-V ${PID}/${PID}.snps.vcf.gz          \
-filter 'QD < 2.0' --filter-name 'QD2' -filter 'QUAL < 30.0' --filter-name 'QUAL30' -filter 'SOR > 3.0' --filter-name 'SOR3' \
-filter 'FS > 60.0' --filter-name 'FS60'  -filter 'MQ < 40.0' --filter-name 'MQ40'  -filter 'MQRankSum < -12.5' --filter-name 'MQRankSum-12.5'   \
-filter 'ReadPosRankSum < -8.0' --filter-name 'ReadPosRankSum-8' \
-O ${PID}/${PID}.snps.filtered.vcf.gz
###

###hardfiltering INDELS
gatk VariantFiltration        \
-V ${PID}/${PID}.indels.vcf.gz         \
-filter 'QD < 2.0' --filter-name 'QD2'         -filter 'QUAL < 30.0' --filter-name 'QUAL30'         -filter 'FS > 200.0' --filter-name 'FS200'       \
-filter 'ReadPosRankSum < -20.0' --filter-name 'ReadPosRankSum-20'         \
-O ${PID}/${PID}.indels.filtered.vcf.gz 

###Merging VCF
bcftools merge  ${PID}/${PID}.snps.filtered.vcf.gz \
${PID}/${PID}.indels.filtered.vcf.gz  \          
-o ${PID}/${PID}.merged.filtered.vcf.gz \         
--force-samples          

#Annoation
java -jar pave.jar \ 
  -sample ${PID} \
  -vcf_file ${PID}/${PID}.merged.filtered.vcf.gz \
  -ensembl_data_dir /path_to_ensembl_files \
  -driver_gene_panel /path_to_gene_panel \
  -ref_genome /path/to/refGenome.fasta \
  -ref_genome_version 37 \
  -output_dir ${PID}/pave/ \
  -threads 10
