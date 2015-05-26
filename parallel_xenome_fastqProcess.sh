#!/bin/bash

Location_DIR=/scratch/speng/projects/Mouse_Xeno/fastqDir/PDX_Columbia/fastq/PDX_Columbia_Xenome_Output
OUTPUT_DIR=/scratch/speng/projects/Mouse_Xeno/fastqDir/PDX_Columbia/fastq/Alignment_human_both
SCRIPTS='/scratch/speng/projects/Mouse_Xeno/script'
COUNT=0

for i in {01..40}; 
 do 
       fileName=JC0$i
       let COUNT=$COUNT+1
	   pbsOutput="${OUTPUT_DIR}/${fileName}_fastqProcess.out"
	   read1="${OUTPUT_DIR}/${fileName}_xenomeHB_R1_001.fastq.gz"
	   read2="${OUTPUT_DIR}/${fileName}_xenomeHB_R2_001.fastq.gz"

       qsub -N $fileName -o $pbsOutput -v FILENAME=$fileName,READ1=$read1,READ2=$read2 $SCRIPTS/xenome_fastqProcess.pbs
done

echo $COUNT