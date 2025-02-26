#!/bin/bash

files=$(ls ./)
for file in $files
do
    if test -f $file
    then
        if [[ $file = *"anno.hg19_multianno"* || $file = *"target.txt"* || $file = *"recal.dedup.sorted"* ||
              $file = *"g.vcf"* || $file = *"gz.raw.vcf"* || $file = *"wh_anno.txt"* ]]
        then
            file_name="$(cut -d'_' -f1 <<<"$file")";
            if test -d /mnt/workshop/xinchen.pan/WES_Project_Done/test/$file_name
            then
                mv $file /mnt/workshop/xinchen.pan/WES_Project_Done/test/$file_name;
            else
                mkdir -p /mnt/workshop/xinchen.pan/WES_Project_Done/test/$file_name;
                mv $file /mnt/workshop/xinchen.pan/WES_Project_Done/test/$file_name;
            fi
        fi
    fi
done;
echo "move_done!";
