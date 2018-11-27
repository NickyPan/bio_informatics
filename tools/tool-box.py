#!/usr/bin/env python

import os, sys, shutil
from subprocess import Popen
import argparse

# optional args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", required=True, help="input dir")
parser.add_argument("-o", "--output", help="out")
parser.add_argument("-d", "--delete", action="store_true", default=False, help="remove bam and depth files")
parser.add_argument("--to_cram", action="store_true", default=False, help="transfer bam file to cram")
parser.add_argument("-lv", "--link_vcf", action="store_true", default=False, help="link gvcf file")
parser.add_argument("-r", "--recal_bam", action="store_true", default=False, help="remove recal_bam files")
args = parser.parse_args()

if args.input:
    inputDir = args.input

def removeDir(path):
    try:
        if os.path.isdir(path):
            shutil.rmtree(path)
    except:
        sys.exit('remove failed')

def linkFile(path, dst):
    try:
        if os.path.isfile(path):
            cmd = ['ln', '-s', path, dst]
            Popen(cmd)
    except:
        sys.exit('link failed')

def scan_bam(path):
    for entry in os.scandir(path):
        if entry.is_dir() and (entry.name == 'bam' or entry.name == 'depth'):
            print (entry.path)
            if entry.name == 'bam' and args.to_cram:
                toCram(entry.path)
            if args.delete:
                removeDir(entry.path)
        elif args.recal_bam and entry.is_dir() and entry.name == 'recal_bam':
            print (entry.path)
            removeDir(entry.path)
        elif entry.is_dir():
            scan_bam(entry.path)

def scan_vcf(path):
    for entry in os.scandir(path):
        if entry.is_dir() and entry.name == 'GVCF':
            vcf_file(entry.path)
        elif entry.is_dir():
            scan_vcf(entry.path)

def vcf_file(path):
    if os.path.isdir(path):
        for entry in os.scandir(path):
            if entry.is_file() and 'g.vcf.gz' in entry.name:
                try:
                    sample = entry.name.split('-')[1]
                except IndexError:
                    sample = entry.name[1:]
                if 'F' in sample:
                    print(entry.name + '\t' + entry.path)
                    linkFile(entry.path, args.output)
    else:
        sys.exit('link file error')

def toCram(path):
    if os.path.isdir(path):
        cramDir = path.replace('bam', 'cram')
        if not os.path.exists(cramDir):
            try:
                os.makedirs(cramDir)
            except:
                sys.exit('cram dir created failed')
        for entry in os.scandir(path):
            if entry.is_file() and '.bam' in entry.name:
                cramFile = cramDir + '/' + entry.name.replace('.bam', '.cram')
                cramCmd = ['samtools', 'view', '-@', '20', '-T', '/opt/seqtools/gatk/ucsc.hg19.fasta', '-C', '-o', cramFile, entry.path]
                step = Popen(cramCmd)
                step.wait()
    else:
        sys.exit('bam dir error')

if args.delete or args.to_cram:
    scan_bam(inputDir)
    print ('remove process done!')

if args.link_vcf and args.output:
    scan_vcf(inputDir)
    print ('link process done!')
else:
    print ('miss out dir')