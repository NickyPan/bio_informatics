#!/usr/bin/env python

import sys
import argparse

# optional args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", required=True, help="input")
parser.add_argument("-o", "--output", required=True, help="out")
parser.add_argument("--dtype", required=True, help="database type")
args = parser.parse_args()

if args.input:
    inputFile = args.input

if args.dtype and args.dtype in ('clinvar'):
    dtype = args.dtype
else:
    sys.exit('wrong database type!')

if args.output:
    output = args.output

def mod_clinvar(items):
    items = items.split('\t')
    newLine = items[0] + '\t' + items[1] + '\t' + items[2] + '\t' + items[3] + '\t' + items[4] + '\t' + items[9].replace('\\x2c', ',') + '\t' + items[6].replace('\\x2c', ',') + '\t' + items[7].replace('\\x2c', ',')
    return newLine

res = []
with open(inputFile) as data:
    header = '#Chr\tStart\tEnd\tRef\tAlt\tCLNSIG\tCLNDN\tCLNDISDB'
    res.append(header)
    for line in data:
        line = line.strip()
        if dtype == 'clinvar':
            res.append(mod_clinvar(line))

outRes = '\n'.join(res)
with open(output, "w") as text_file:
    text_file.write(outRes)