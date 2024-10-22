## HMF WORKFLOW
##https://github.com/hartwigmedical/hmftools
##To run CKS samples following parameters were used.
#based on the average sequncing depth 
#sageExtraParameters="-panel_min_tumor_qual 80 -high_confidence_min_tumor_qual 130 -low_confidence_min_tumor_qual 200"


PID=$1
Tumor=$2
Control=$3
path=/omics/odcf/project/hipo/hipo_021/sequencing/whole_genome_sequencing/view-by-pid

tumorSample=$(samtools view -H ${Tumor} | grep '^@RG' | sed "s/.*SM:\([^\t]*\).*/\1/g" | uniq | head -1)
controlSample=$(samtools view -H ${Control} | grep '^@RG' | sed "s/.*SM:\([^\t]*\).*/\1/g" | uniq | head -1)

mkdir -p ${PID}

##SAGE
java -Xms4G -Xmx32G -cp sage.jar com.hartwig.hmftools.sage.SageApplication \
    -threads 10 
    -reference ${controlSample} -reference_bam ${Control} \
    -tumor ${tumorSample} -tumor_bam ${Tumor} \
    -ref_genome_version 37 \
    -ref_genome /path/to/refGenome.fasta \
    -hotspots /path/to/KnownHotspots.37.vcf.gz \
    -panel_bed /path/to/ActionableCodingPanel.37.bed.gz \
    -high_confidence_bed /path/to/NA12878_GIAB_highconf_IllFB-IllGATKHC-CG-Ion-Solid_ALLCHROM_v3.2.2_highconf.bed \
    -ensembl_data_dir /path_to_ensembl_cache/ \
    -output_vcf ${PID}/sage/${PID}.sage.vcf.gz

##PAVE

java -jar pave.jar \ 
  -sample ${PID} \
  -vcf_file ${PID}/sage/${PID}.sage.vcf.gz \
  -ensembl_data_dir /path_to_ensembl_files \
  -driver_gene_panel /path_to_gene_panel \
  -ref_genome /path/to/refGenome.fasta \
  -ref_genome_version 37 \
  -output_dir ${PID}/pave/ \
  -threads 10

##AMBER
java -jar amber.jar com.hartwig.hmftools.amber.AmberApplication \
    -reference ${controlSample} \
    -reference_bam ${Control} \ 
    -tumor ${tumorSample} \
    -tumor_bam ${Tumor} \ 
    -output_dir ${PID}/amber/ \
    -threads 10 \
    -loci /path/to/GermlineHetPon.37.vcf.gz 

##COBALT
java -jar -Xmx8G cobalt.jar \
    -reference ${controlSample} \
    -reference_bam ${Control} \ 
    -tumor ${tumorSample} \
    -tumor_bam /${Tumor} \ 
    -output_dir ${PID}/cobalt/ \ 
    -threads 10 \ 
    -gc_profile /ref_data/GC_profile.1000bp.37.cnp


##GRIDSS
gridss --reference /path/to/refGenome.fasta \
--output ${PID}/gridss/${PID}.vcf.gz --assembly ${PID}/gridss/${PID}.assembly.gridss.bam \
--threads 10 --workingdir ${PID}/gridss/ --jvmheap 30g \
--blacklist /path/to/exclude_list.bed \
--labels ${tumorSample},${controlSample}  ${Tumor} ${Control}

##GRIPSS
java -jar gripss.jar \
   -sample ${PID} \
   -reference ${controlSample} \
   -ref_genome_version 37 \
   -ref_genome /path/to/Homo_sapiens_assembly.fasta \
   -pon_sgl_file /path/to/gridss_pon_single_breakend.bed \
   -pon_sv_file /path/to/gridss_pon_breakpoint.bedpe \
   -known_hotspot_file /path/to/KnownFusionPairs.bedpe \
   -repeat_mask_file /path_to/37.fa.out.gz \
   -vcf ${PID}.vcf.gz \
   -output_dir ${PID}/gripss

##PURPLE
java -jar purple.jar \
   -reference ${controlSample} \
   -tumor ${Tumor} \
   -amber /${PID}/amber \
   -cobalt /${PID}/cobalt \
   -gc_profile /path/GC_profile.1000bp.37.cnp \
   -ref_genome /path/Homo_sapiens_assembly37.fasta \
   -ref_genome_version 37 \
   -ensembl_data_dir /path_to_ensembl_data_cache/ \
   -somatic_vcf /path/COLO829/COLO829.somatic.vcf.gz \
   -somatic_sv_vcf /${PID}/gripss/{PID}.sv.vcf.gz \
   -sv_recovery_vcf /${PID}/gripss/{PID}.sv.low_confidence.vcf.gz \
   -circos /path/circos-0.69-6/bin/circos \
   -output_dir /${PID}/purple/ \


##LINX
java -jar linx.jar \
    -sample ${PID} \
    -ref_genome_version 37 \
    -sv_vcf ${PID}/gripss/${PID}.vcf.gz \
    -purple_dir ${PID}/purple/ \
    -output_dir ${PID}/linx/ \ 
    -ensembl_data_dir /path_to_ensembl_data_cache/ 
    -known_fusion_file known_fusion_data.csv 
    -driver_gene_panel DriverGenePanel.tsv
    -log_debug