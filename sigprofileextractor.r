###Sigprofileextractor 
#https://github.com/AlexandrovLab/SigProfilerExtractor

##matrix generator for SBS, ID, DBS
from SigProfilerMatrixGenerator.scripts import CNVMatrixGenerator as scna
input_file = "/path/to/input_file.tsv"
output_path = "/output_dir/"
project = "snv_alt"
scna.generateCNVMatrix(file_type, input_file, project, output_path)

from SigProfilerExtractor import sigpro as sig
sig.sigProfilerExtractor("matrix", "/output_dir/", "matrix.tsv", reference_genome="GRCh37", minimum_signatures=1, maximum_signatures=10, nmf_replicates=100, cpu=8)


##for CNA
from SigProfilerMatrixGenerator.scripts import CNVMatrixGenerator as scna
input_file = "/path/to/input_file.tsv"
output_path = "/output_dir/"
file_type = "ASCAT"
project = "ascat_tel"
scna.generateCNVMatrix(file_type, input_file, project, output_path)

from SigProfilerExtractor import sigpro as sig
sig.sigProfilerExtractor("matrix", "/output_dir/", "matrix.tsv", reference_genome="GRCh37", minimum_signatures=1, maximum_signatures=10, nmf_replicates=100, cpu=8)

##for SV
from SigProfilerMatrixGenerator.scripts import SVMatrixGenerator as sv
input_file = "/path/to/input_file.tsv"
output_path = "/output_dir/"
project = "560-Breast"
sv.generateSVMatrix(input_dir, project, output_dir)

from SigProfilerExtractor import sigpro as sig
sig.sigProfilerExtractor("matrix", "/output_dir/", "matrix.tsv", reference_genome="GRCh37", minimum_signatures=1, maximum_signatures=10, nmf_replicates=100, cpu=8)
