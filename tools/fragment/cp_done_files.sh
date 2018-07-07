#!/bin/bash

file_dir_name=$2;

declare -A source_dir;
declare -A target_dir;
source_dir=( [wes]=/mnt/workshop/xinchen.pan/project/WES
           [eye]=/mnt/workshop/xinchen.pan/project/eye_panel
           [WCQZ]=/mnt/workshop/xinchen.pan/project/WCQZ
           [50gene]=/mnt/workshop/xinchen.pan/project/50gene
           [tp53]=/mnt/workshop/xinchen.pan/project/TP53
           [EGFR]=/mnt/workshop/xinchen.pan/project/EGFR );
target_dir=( [wes]=WES
           [eye]=eye_panel
           [WCQZ]=WCQZ
           [50gene]=50gene
           [tp53]=TP53
           [EGFR]=EGFR );

source_file_dir=${source_dir[$1]};
target_file_dir=${target_dir[$1]};

cd $source_file_dir/$file_dir_name/result/;

files=$(ls ./)

for file in $files
do
    if [[ $file = *"anno.hg19_multianno"* || $file = *"target.txt"* || $file = *"recal.dedup.sorted"* ||
          $file = *"g.vcf"* || $file = *"gz.raw.vcf"* || $file = *"wh_anno.txt"* ]]
    then
        label_name="$(cut -d'.' -f1 <<<"$file")";
        echo "$label_name";
    fi
done

# copy_files(){
#     cp $1 /mnt/workshop/xinchen.pan/WES_Project_Done/$2/;
#     if [[ $1 = *"recal.dedup.sorted"* ]]
#     then
#         cd /mnt/workshop/xinchen.pan/WES_Project_Done/$2/;
#         touch $2.view_bam.sh;
#         echo "samtools tview /mnt/b/$target_file_dir/$2/$1 /opt/seqtools/gatk/ucsc.hg19.fasta" > $2.view_bam.sh;
#     fi
# }

# for file in $files
# do
#     if test -f $file
#     then
#         if [[ $file = *"anno.hg19_multianno.txt"* || $file = *"target.txt"* || $file = *"wh_anno.txt"* ]]
#         then
#             file_name="$(cut -d'_' -f1 <<<"$file")";
#             if test -d /mnt/workshop/xinchen.pan/WES_Project_Done/$file_name
#             then
#                 copy_files $file $file_name;
#             else
#                 mkdir -p /mnt/workshop/xinchen.pan/WES_Project_Done/$file_name;
#                 copy_files $file $file_name;
#             fi
#         fi
#     fi
# done;

# echo "copy_done! starting moving...";

# mv ${source_dir[$1]} /mnt/b/$target_file_dir/$2;

# echo "moving done!";
