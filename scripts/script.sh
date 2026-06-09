#!/bin/bash

############## Check the docker ##################
analysis=~/circ_analysis
ref_files=~/circ_analysis/ref_files
data=~/circ_analysis/data
fastp=~/circ_analysis/fastp
fastqc=~/circ_analysis/fastqc
multiqc=~/circ_analysis/multiqc
align=~/circ_analysis/alignment
ciri=~/circ_analysis/ciri_output



########################### Download the Ref files required for downstream analysis ##########################

######################## Reference genome File #############################

wget -O ${ref_files}/genome.fa.gz https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44/GRCh38.primary_assembly.genome.fa.gz


####################### Reference gtf file ###############################

wget -O ${ref_files}/annotation.gtf.gz https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44/gencode.v44.primary_assembly.annotation.gtf.gz

######################## Before starting the analysis, lets index the reference genome ########################

docker run --rm -v "${analysis}":/data pegi3s/bwa bwa index /data/ref_files/genome.fa


################# Create a Samtools index of the reference genome ##########################

gunzip ${ref_files}/genome.fa.gz

docker run --rm -v "${analysis}":/data pegi3s/samtools_bcftools samtools faidx /data/ref_files/genome.fa

######################## Fastq-dump ########################################################

docker run -t --rm -v "${analysis}":/data_in_container:rw -w /data_in_container ncbi/sra-tools fasterq-dump -e 2 -p -O data SRR36681182


####################### FASTQC ###########################################################


docker run --rm -v "${analysis}":/data pegi3s/fastqc fastqc /data/data/SRR36681182_1.fastq  /data/data/SRR36681182_2.fastq -o /data/fastqc


########################## Compress the files ################################

gzip ${data}/SRR36681182_1.fastq 
gzip ${data}/SRR36681182_2.fastq

############################### Fastp ########################################################


docker run --rm -v "${analysis}":/fastp chrishah/fastp:0.23.1 fastp -i /fastp/data/SRR36681182_1.fastq.gz -I /fastp/data/SRR36681182_2.fastq.gz  -o /fastp/fastp/trimmed_SRR36681182_1.fastq.gz -O /fastp/fastp/trimmed_SRR36681182_2.fastq.gz -j /fastp/fastp/fastp.json -h /fastp/fastp/fastp.html



################################### SUBSET THE DATASET ################################################

seqtk sample -s100 ${fastp}/trimmed_SRR36681182_1.fastq.gz 1000000 > ${data}/sub_SRR36681182_1.fastq.gz
seqtk sample -s100 ${fastp}/trimmed_SRR36681182_2.fastq.gz 1000000 > ${data}/sub_SRR36681182_2.fastq.gz

################################ Alignment using BWA MEM #######################################

docker run --rm pegi3s/bwa bwa mem

docker run --rm -v "${analysis}":/data pegi3s/bwa bwa mem -T 19 /data/ref_files/genome.fa /data/data/sub_SRR36681182_1.fastq.gz /data/data/sub_SRR36681182_2.fastq.gz 1> "${analysis}/alignment/align.sam" 2> "${analysis}/alignment/align.log" 


############################ Run CIRI2 ############################################

############ Make sure the required perl version is installed ###################

############### Download the Zip file and unzip it #########################

wget https://sourceforge.net/projects/ciri/files/CIRI2/CIRI_v2.0.5.zip

unzip CIRI_v2.0.5.zip

perl ~/CIRI_v2.0.5/CIRI_v2.0.5.pl --help

perl ~/CIRI_v2.0.5/CIRI_v2.0.5.pl -I ${align}/align.sam -O ${ciri}/outfile -F ${ref_files}/genome.fa -A ${ref_files}/annotation.gtf
