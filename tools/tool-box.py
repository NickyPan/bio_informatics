#!/usr/bin/env python

import os, sys, shutil
import argparse

# optional args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", required=True, help="input dir")
parser.add_argument("-o", "--output", help="out")
parser.add_argument("-d", "--delete", action="store_true", default=False, help="remove bam and depth files")
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
            os.symlink(path, dst)
    except:
        sys.exit('link failed')

def scan_bam(path):
    for entry in os.scandir(path):
        if entry.is_dir() and (entry.name == 'bam' or entry.name == 'depth'):
            print (entry.path)
            removeDir(entry.path)
        elif args.recal_bam and entry.is_dir() and entry.name == 'recal_bam':
            print (entry.path)
            removeDir(entry.path)
        elif entry.is_dir():
            scan_bam(entry.path)

def scan_vcf(path):
    for entry in os.scandir(path):
        if entry.is_dir() and entry.name == 'GVCF':
            print (entry.path)
        elif entry.is_file() and 'g.vcf.gz' in entry.name:
            print(entry.name + '\t' + entry.path)
            linkFile(entry.path, args.output)
        elif entry.is_dir():
            scan_vcf(entry.path)

if args.delete:
    scan_bam(inputDir)
    print ('remove process done!')

if args.link_vcf:
    scan_vcf(inputDir)
    print ('link process done!')