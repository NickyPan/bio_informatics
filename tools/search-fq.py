#!/usr/bin/env python

import os, sys, shutil

fileList = ['QW1412', 'QW1415', 'QW1418', 'QW1422', 'QW1424', 'QW1426', 'QW3936', 'QW1431', 'QW1432', 'QW1434', 'QW1446', 'QW1442', 'QW1450', 'QW1449', 'QW1458', 'QW3939', 'QW3943', 'QW3945', 'QW3948', 'QW3952', 'QW3907', 'QW3953', 'QW3955', 'QW3959', 'QW3965', 'QW2914']

def copy_file(src_prefix):
    shutil.copy(src_prefix, '/data/tmp_fq')

folders = []
files = []

def walk_dir(path):
    for entry in os.scandir(path):
        if entry.is_dir():
            walk_dir(entry.path)
        elif entry.is_file() and 'fastq.gz' in entry.name:
            print(entry.name + '\t' + entry.path)
            files.append(entry.name + '\t' + entry.path)

def scan_dir(path):
    for entry in os.scandir(path):
        if entry.is_dir() and (entry.name == 'split' or entry.name == 'PF_data'):
            walk_dir(entry.path)
        elif entry.is_file() and 'fastq.gz' in entry.name:
            print(entry.name + '\t' + entry.path)
            files.append(entry.path)
        elif entry.is_dir():
            scan_dir(entry.path)

# scan_dir('/data/raw_data')

def txt2json(txt):
    with open(txt) as text:
        for line in text:
            line =  line.strip()

