#!/bin/bash

Location_DIR=/scratch/speng/projects/bam2fastq/Graft_aligned_BAM
#OUTPUT_DIR=/scratch/speng/projects/Mouse_Xeno/fastqDir/PDX_Columbia/fastq/PDX_Columbia_Xenome_Output
SCRIPTS='/scratch/speng/projects/bam2fastq/script'
COUNT=0

for sample in `find ${Location_DIR} -type d -name "*_Graft"|sort`
do
       let COUNT=$COUNT+1
	   fileName=`basename $sample|cut -d_ -f1`
	   output_dir=${Location_DIR}/${fileName}_Graft
	   pbsOutput="${output_dir}/${fileName}_compFastq.out"
 #      bam=${Location_DIR}/${fileName}/*.proj.Aligned.out.sorted.md.bam
	  
       qsub -N $fileName -o $pbsOutput -v OUTPUT_DIR=${output_dir},FILENAME=${fileName} $SCRIPTS/CompFastq.pbs
done

echo $COUNT