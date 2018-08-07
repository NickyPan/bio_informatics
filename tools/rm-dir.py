#!/usr/bin/env python

import os, sys, shutil
import argparse

# optional args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", required=True, help="input dir")
parser.add_argument("-d", "--delete", action="store_true", default=False, help="remove bam and depth files")
parser.add_argument("-r", "--recal_bam", action="store_true", default=False, help="remove recal_bam files")
args = parser.parse_args()

if args.input:
    inputDir = args.input

def removeDir(path):
    try:
        if os.path.isdir(path):
            shutil.rmtree(path)
    except:
        sys.exit('failed')

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

if args.delete:
    scan_bam(inputDir)
    print ('remove process done!')
