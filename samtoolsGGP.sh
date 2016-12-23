#!/bin/bash

# Heavily modified version of startFastqc.sh that uses Google Genomics Piplein instead of ISB-CGC Pipeline
# https://github.com/isb-cgc/ISB-CGC-pipelines/blob/master/lib/examples/launch_scripts/startFastqc.sh
# Last modified

usage() { echo "Usage: $0 [-i <input file>] [-o <output directory>] [-l <log directory>] [-p <pipeline file>]" 1>&2; exit 1; }

JOBNAME="samtools-index"
while getopts "i:o:l:p:" args; do
  case "${args}" in
    i)
	  INPUTFILE=${OPTARG}
	  ;;
	o)
	  OUTDIR=${OPTARG}
	  ;;
	l)
	  LOGDIR=${OPTARG}
	  ;;
        p)
          PIPELINEFILE=${OPTARG}
          ;;
        *)
	  usage
	  ;;
  esac
done

if [ -z "${INPUTFILE}" ] || [ -z "${OUTDIR}" ] || [ -z "${LOGDIR}" ] || [ -z "${PIPELINEFILE}" ]; then
  usage
fi

#Test to see if output directory and log directory are google buckets
if [[ $OUTDIR != "gs://"* ]]; then
  echo "Output Directory should be a Google bucket"
  exit 1
fi

if  [[ $LOGDIR != "gs://"* ]]; then
  echo "Log directory should be a Google bucket"
  exit 1
fi

#Test to make sure the pipelinefile exists
if [ ! -e $PIPELINEFILE ]; then
  echo "${PIPELINEFILE} does not exist.  Please specific an existing pipeline file"
  usage
fi
 
#Put a / on the end of the output directory if it isn't there already
if [[ "${OUTIDIR:-1}" != "/" ]]; then
  OUTDIR=$OUTDIR/
fi

#If the user installed ISB-CGC tools correctly, calculateDiskSize should be in /usr/bin
CALCSCRIPT="/usr/bin/calculateDiskSize"
while read bamFile; do
  #If file is not in a Google bucket, fail
    if  [[ $bamFile != "gs://"* ]]; then
      echo "$bamFile is not in a Google bucket"
      #exit 1
	  continue
    fi

    #Extract the file name from the path
    bamFileName=$(echo $bamFile | rev | cut -d '/' -f 1 | rev)
    echo "Processing ${bamFileName}"

   #Create a name for the bai file
    bamFileName=$(echo $bamFile | rev | cut -d '/' -f 1 | rev)
    baiFileName="${bamFileName}.bai"

    # Use the "calculateDiskSize" utility script to calculate the size of the disk if it is known
	if [ -e $CALCSCRIPT ]; then
          diskSize=$($CALCSCRIPT --inputFile $bamFile --roundToNearestGbInterval 100)
	#If the script doesn't exist, just use a 1T disk
	else
	  diskSize=1000
	fi

    # Submit a task to the Google Genomics Pipelines API for the given BAM file
	gcloud alpha genomics pipelines run \
                --pipeline-file $PIPELINEFILE \
                --logging $LOGDIR \
                --inputs INPUT_FILE=$bamFile \
                --outputs OUTPUT_FILE=${OUTDIR}${baiFileName} \
                --disk-size datadisk:$diskSize
    #Add a wait time to avoid overwhelming the scheduler
    sleep 5

done < $INPUTFILE
