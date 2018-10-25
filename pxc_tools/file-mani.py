#!/usr/bin/env python

import sys
import os
import argparse

# optional args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", required=True, help="input file")
parser.add_argument("-sv", "--var", type=int, default=-1, help="stat var info")
parser.add_argument("-sr", "--shift_reads", action="store_true", default=False, help="shift reads")
parser.add_argument('-w', '--shift_window', type=int, help='shift window')
args = parser.parse_args()

if args.input:
    inputFile = args.input

headIdx = []
varStats = {}
zeroReads = 0
shortReads = 0

def statsVar(line):
    global headIdx, varStats, heads
    for idx in headIdx:
        varLine = line[idx].split(':')
        varGeno = varLine[0]

        if heads[idx] not in varStats.keys():
            varStats[heads[idx]] = {}
            varStats[heads[idx]]['var'] = 0
            varStats[heads[idx]]['varAll'] = 0
            varStats[heads[idx]]['varSnp'] = 0
            varStats[heads[idx]]['allSnp'] = 0
            varStats[heads[idx]]['varRatio'] = 0

        varStats[heads[idx]]['allSnp'] += 1

        if varGeno == '0/0':
            varDp= int(varLine[1].split(',')[1])
        elif varGeno == '1/1':
            varDp= int(varLine[1].split(',')[0])
        else:
            varDp = 0
        if varDp > args.var:
            totalDp = int(varLine[2])
            ratio = float(varDp)/float(totalDp)
            if 0.02 < ratio < 0.15 and varGeno in ('0/0', '1/1'):
                varStats[heads[idx]]['varRatio'] += ratio
                varStats[heads[idx]]['var'] += varDp
                varStats[heads[idx]]['varAll'] += totalDp
                varStats[heads[idx]]['varSnp'] += 1

def shiftReads(line):
    global zeroReads, shortReads
    reads = abs(int(line[8]))
    if 0 < reads < args.shift_window:
        return True
    return False

with open(inputFile) as textFile:
    header = textFile.readline()
    if args.shift_reads:
        print (header.strip())
    heads = header.strip().split('\t')

    if args.var >= 0:
        for head in heads:
            sample = head.split('_')
            idx = heads.index(head)
            if len(sample) > 1 and 'F' in sample[0] and 'S' in sample[0] and idx > 100:
                headIdx.append(idx)

    for row in textFile:
        if '@' in row[:1]:
            print (row.strip())
            continue
        else:
            rowLine = row.strip().split('\t')
            if args.shift_reads and shiftReads(rowLine):
                print (row.strip())
            if args.var >= 0:
                statsVar(rowLine)

if args.var >= 0:
    for sample in varStats.keys():
        varRatio = varStats[sample]['var']/varStats[sample]['varAll']
        varSnpRatio = varStats[sample]['varSnp']/varStats[sample]['allSnp']
        mean = varStats[sample]['varRatio']/varStats[sample]['varSnp']
        print (sample, varStats[sample]['var'], varStats[sample]['varAll'], varRatio, varStats[sample]['varSnp'], varStats[sample]['allSnp'], varSnpRatio, mean)
