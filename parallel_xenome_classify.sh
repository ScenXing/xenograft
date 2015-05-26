#!/bin/bash

Location_DIR=/scratch/speng/projects/Mouse_Xeno/fastqDir/PDX_Columbia/fastq
OUTPUT_DIR=/scratch/speng/projects/Mouse_Xeno/fastqDir/PDX_Columbia/fastq/PDX_Columbia_Xenome_Output
SCRIPTS='/scratch/speng/projects/Mouse_Xeno/script'
COUNT=0

for sample in `find ${Location_DIR} -name "*_R1_001.fastq.gz"`
do
       let COUNT=$COUNT+1
	   fileName=`basename $sample|cut -d_ -f1-3`
	   pbsOutput="${OUTPUT_DIR}/${fileName}_xenomeClassify.out"
       read1=$sample
	   read2=${sample/%_R1_001.fastq.gz/_R2_001.fastq.gz}
	   output="${OUTPUT_DIR}/${fileName}"
   
	  
       qsub -N $fileName -o $pbsOutput -v READ1=$read1,READ2=$read2,OUTPUT=$output $SCRIPTS/xenome_classify_p.pbs
done

echo $COUNT