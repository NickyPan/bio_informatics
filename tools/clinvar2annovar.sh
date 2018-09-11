#!/bin/bash

if [ "$2" = "down" ];then
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/$1
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/$1.md5
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/$1.tbi
fi

if md5sum -c $1.md5; then
    suffix_name="$(cut -d'.' -f2 <<<"$1")";
    echo suffix_name
    # vt decompose $1 -o temp.split.vcf
    # prepare_annovar_user.pl -dbtype clinvar_preprocess2 temp.split.vcf -out temp.split2.vcf
    # vt normalize temp.split2.vcf -r /opt/seqtools/gatk/ucsc.hg19.fasta -o temp.norm.vcf -w 2000000
    # filename='hg19_'$suffix_name'.txt'
    # prepare_annovar_user.pl -dbtype clinvar2 temp.norm.vcf -out temp.norm.txt
    # index_annovar.pl temp.norm.txt -out $filename -comment comment_temp.txt
else
    echo "md5 check failed"
fi