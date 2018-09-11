#!/bin/bash

ANNOVAR=/opt/seqtools/annovar
TOOL_DIR=/mnt/workshop/xinchen.pan/bio_informatics/tools

if [ "$2" = "down" ];then
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/$1
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/$1.md5
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/$1.tbi
fi

if md5sum -c $1.md5; then
    suffix_name="$(cut -d'.' -f1 <<<"$1")";
    fileRaw='hg19_'$suffix_name'.raw.txt'
    filename='hg19_'$suffix_name'.txt'
    echo "$suffix_name"
    vt decompose $1 -o temp.split.vcf
    perl $ANNOVAR/prepare_annovar_user.pl -dbtype clinvar_preprocess2 temp.split.vcf -out temp.split2.vcf
    sed 's/^/chr/' temp.split2.vcf | sed 's/chr#/#/' - | sed 's/##contig=<ID=/##contig=<ID=chr/' - > temp.split3.vcf
    sed -i '/chrNW/d' temp.split3.vcf
    vt normalize -n temp.split3.vcf -r hg19.fa -o temp.norm.vcf -w 2000000
    perl $ANNOVAR/prepare_annovar_user.pl -dbtype clinvar2 temp.norm.vcf -out $fileRaw
    python $TOOL_DIR/mod_annovar.py -i $fileRaw -o $filename --dtype clinvar
    rm -f temp.* $fileRaw
    # index_annovar.pl temp.norm.txt -out $filename -comment comment_temp.txt
else
    echo "md5 check failed"
fi