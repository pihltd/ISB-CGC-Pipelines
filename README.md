# ISB-CGC-Pipelines
Demonstration scripts for use with either ISB-CGC-pipelines or directly with Google Genomics Pipelines
## Files
*samtools.sh* - This script will use a samtools docker container to create bam index files from bam files.  This script is dependent on having the ISB-CGC-Pipelines software installed

*samtoolsGGP.sh* - This script performs the same indexing function as samtools.sh, but works directly with the Google Genomics Pipeline

*samindex.json* - This file contains the docker processing information required by samtoolsGGP

*samindex.yaml* - The yaml version of the processing information

*mRNATest.txt* - A list of 10 TCGA-KICH mRNA Sequencing .bam files

*miRNATest.txt* - A list of 10 TCGA-KICH miRNA Sequencing .bam files
