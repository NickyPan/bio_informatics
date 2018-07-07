#!/bin/bash
raw_vcf=(./*.fastq.gz.raw.vcf)
multi_anno=(./*.hg19_multianno.txt)

for ((i=0;i<${#multi_anno[@]};i++)); do
    one_vcf=`basename ${raw_vcf[$i]} .raw.vcf`
    one_multianno=`basename ${multi_anno[$i]} .txt`
    perl /mnt/workshop/xinchen.pan/pipeline/tools/header.pl $one_vcf.raw.vcf $one_multianno.txt > $one_multianno.header.txt
    echo "fixed $i"
done; echo "header fixed"