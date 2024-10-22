## Telomeric fusion 
 
PID=${1}
TBAM=${2}

mkdir -p ${PID}

python3 TelFusDetectorCaller.py --bam ${TBAM} --genome Hg19 --outfolder ${PID} --sample ${PID} --threads 6
		    
python3 TelFusDetectorRates.py --fusion_file ${PID}/${PID}.summary_fusions.pass.tsv --outfile ${PID}/Fusion_rates.txt

