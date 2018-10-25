#!/bin/bash

if [ "$1" == "hit" ];then
    echo $1
    for i in *recal.dedup.sorted.bam;
    do
        suffix_name="$(cut -d'.' -f1 <<<"$i")";
        {
            samtools view -@ 10 -F 4 $i |  perl -lane 'print "$F[2]\t$F[3]"' > $suffix_name.hits
            sed -i 's/chr//g' $suffix_name.hits && echo "$suffix_name done!"
        }&
    done
elif [ "$1" == "cnv" ];then
    echo $1
    window="5000000"
    if [ $# -ge 4 ]; then
        window=$4
    fi
    echo $window
    cnv-seq.pl --test $2 --ref $3 --genome human --global-normalization --window-size $window
    outName="$2-vs-$3.window-$window.minw-4.cnv"
    grep -v 'MT' $outName | grep -v '_' | grep -v 'Y' > "$2-$3.cnv"
    Rscript /home/xiaoliang.tian/pipeline/tools/SC_tools/test.R "$2-$3.cnv" "$2-$3"
else
    echo "参数输入有误！"
fi
