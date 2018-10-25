#!/bin/bash

filelist=`ls $1`
for list in $filelist;do
    echo $list' starting.....';
    for file in $list/results/GVCF/*g.vcf; do
        base_file=`basename $file`;
        echo $base_file;
        bgzip $file;
        gzfile=$file'.gz';
        tabix -p vcf $gzfile;
    done
    echo 'done!';
done
