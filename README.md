# ISB-CGC-Pipelines
Demonstration scripts for use with either ISB-CGC-pipelines or directly with Google Genomics Pipelines
## Files
*samtools.sh* - This script will use a samtools docker container to create bam index files from bam files.  This script is dependent on having the ISB-CGC-Pipelines software installed
  This program has three required and two optional parameters:
  
     -i <input file>  **Required** The input file is a fully qualified list of BAM files to index, one BAM file per line.
     -o <output directory> **Required**  This is the bucket and directory where results should be stored
     -l <logfile directory> **Required** The bucket and directory where the log files should be stored
     -j <job name>  **Optional**  By default this is set to "samtools-index" but can be changed with the -j flag if desired.  If you do change the job name, be sure to only use lower case letters, number and the dash(-) as the job name is also used to identify the VM disks and must meet Google's disk naming rules  (https://cloud.google.com/compute/docs/reference/latest/disks#name)
     -p  **Optional**  Use pre-emptible VMs instead of normal VMs.

*samtoolsGGP.sh* - This script performs the same indexing function as samtools.sh, but works directly with the Google Genomics Pipeline
    This program has four required parameters:
    
      -i <input file>  **Required** The input file is a fully qualified list of BAM files to index, one BAM file per line.
      -o <output directory> **Required**  This is the bucket and directory where results should be stored
      -l <logfile directory> **Required** The bucket and directory where the log files should be stored 
      -p <parameter file> **Required**  This is the JSON or YAML parameter file for GGP (https://cloud.google.com/genomics/v1alpha2/pipelines)

*samindex.json* - This file contains the docker processing information required by samtoolsGGP

*samindex.yaml* - The yaml version of the processing information

*mRNATest.txt* - A list of 10 TCGA-KICH mRNA Sequencing .bam files

*miRNATest.txt* - A list of 10 TCGA-KICH miRNA Sequencing .bam files
