#!/bin/bash

#Heavily modified version of startFastqc.sh 
#https://github.com/isb-cgc/ISB-CGC-pipelines/blob/master/lib/examples/launch_scripts/startFastqc.sh
# Last modified

usage() { echo "Usage: $0 [-i <input file>] [-o <output directory>] [-l <log directory>] [-j <job name>] [-p Use pre-emptible VMs]" 1>&2; exit 1; }

JOBNAME="samtools-index"
PREEMPTIBLE=false

while getopts "i:o:l:j:p" args; do
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
	j)
	  JOBNAME=${OPTARG}
	  ;;
        p)
         PREEMPTIBLE=TRUE
         ;;
	*)
	  usage
	  ;;
  esac
done

if [ -z "${INPUTFILE}" ] || [ -z "${OUTDIR}" ] || [ -z "${LOGDIR}" ]; then
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

#If the user installed ISB-CGC tools correctly, calculateDiskSize should be in /usr/bin
CALCSCRIPT="/usr/bin/calculateDiskSize"
while read bamFile; do
  #If file is not in a Google bucket, fail
    if  [[ $bamFile != "gs://"* ]]; then
      echo "$bamFile is not in a Google bucket"
      continue
    fi

  #Test to see if file exists and go on to next if it doesnt
  gsutil -q stat $bamFile
  if [ $? -eq 1 ]; then
    echo "$bamFile does not exist"
    continue
  fi

    #Extract the file name from the path
    bamFileName=$(echo $bamFile | rev | cut -d '/' -f 1 | rev)
    echo "Processing ${bamFileName}"

    # Use the "calculateDiskSize" utility script to calculate the size of the disk if it is known
	if [ -e $CALCSCRIPT ]; then
          diskSize=$($CALCSCRIPT --inputFile $bamFile --roundToNearestGbInterval 100)
	#If the script doesn't exist, do it the bash way with a 100G minimum
	else
          BYTES=$(gsutil du $bamFile | cut -d ' ' -f1)
          GIG=$(( $BYTES/1073741824 ))
          diskSize=$(( (($GIG+100)/10)*10 ))
	fi

    # Submit a task to the Google Genomics Pipelines API for the given BAM file
       if [ "$PREEMPTIBLE" = true ]; then
           isb-cgc-pipelines submit --pipelineName $JOBNAME \
		--inputs "${bamFile}:${bamFileName}" \
		--outputs "*bai:${OUTDIR}" \
		--cmd "samtools index $bamFileName" \
		--imageName nareshr/samtoolsindex \
		--cores 1 --mem 2 \
		--diskSize $diskSize \
                --logsPath $LOGDIR \
		--preemptible
       else
           isb-cgc-pipelines submit --pipelineName $JOBNAME \
                --inputs "${bamFile}:${bamFileName}" \
                --outputs "*bai:${OUTDIR}" \
                --cmd "samtools index $bamFileName" \
                --imageName nareshr/samtoolsindex \
                --cores 1 --mem 2 \
                --diskSize $diskSize \
                --logsPath $LOGDIR
        fi

    #Add a wait time to avoid overwhelming the scheduler
    sleep 5

done < $INPUTFILE
