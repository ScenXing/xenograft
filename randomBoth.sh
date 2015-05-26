#!/bin/bash

Location_DIR=/scratch/speng/projects/bam2fastq/GraftMapped_HostAligned
DES_DIR=/scratch/speng/projects/Mouse_Xeno/Alignment
SCRIPTS='/scratch/speng/projects/bam2fastq/script'
COUNT=0

for sample in `find ${Location_DIR} -type d -name "JC*_GraftMapped"|sort`
do
       let COUNT=$COUNT+1
	   fileName=`basename $sample|cut -d_ -f1`
	   output_dir=${DES_DIR}/${fileName}_HB
	   mkdir -p ${output_dir}
	   pbsOutput="${output_dir}/${fileName}_randomBoth.out"
	  
       qsub -N $fileName -o $pbsOutput -v OUTPUT_DIR=${output_dir},FILENAME=${fileName} $SCRIPTS/randomBoth.pbs
done

echo $COUNT