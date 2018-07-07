#!/bin/bash
filter_anno=(./*.hg19_multianno.header.txt)

for ((i=0;i<${#filter_anno[@]};i++)); do
    one_header=`basename ${filter_anno[$i]} .txt`
    perl /mnt/workshop/xinchen.pan/pipeline/tools/variant_filter_dbanno.pl -i $one_header.txt -o $one_header.maf002.txt -f 0.02  -d /home/jimmy/exon/hg19_genedb.txt
    echo "annovar $one_header"
done; echo "annovar done"