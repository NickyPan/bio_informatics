#!/bin/sh 
raw_vcf=(./*.fastq.gz.raw.vcf)
multi_anno=(./*.hg19_multianno.txt)

for ((i=0;i<=${#raw_vcf[@]};i++)); do 
one_vcf=raw_vcf[i]
one_multianno=multi_anno[i]
${raw_vcf[i]}
${multi_anno[i]}
   echo $(basename $one_vcf .vcf) $(basename $one_multianno .txt)
done