#!/bin/bash
wh_anno=(./*.hg19_multianno.header.maf002.txt)

for ((i=0;i<${#wh_anno[@]};i++)); do
    one_whanno=`basename ${wh_anno[$i]} .txt`
    perl /mnt/workshop/xinchen.pan/pipeline/tools/whpanel_anno_pxc.pl -i $one_whanno.txt -o $one_whanno.wh_anno.txt -f 109 -f 110 -f 111
    echo "whanno $one_whanno"
done; echo "whanno done"
