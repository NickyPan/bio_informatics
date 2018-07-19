#!/usr/bin/env python

import sys
import os
import json

# inputFile = sys.argv[1]
# targetGene = sys.argv[2]
# refFile = '/opt/seqtools/annovar/humandb/hg19_refGene.txt'

refFile = sys.argv[1]

def utrFilter(utrUpStart, utrUpEnd, utrDownStart, utrDownEnd, eStart, eEnd):
    if eEnd <= utrUpEnd or eStart >= utrDownStart:
        return 0, 0
    elif eStart >= utrUpEnd and eEnd <= utrDownStart:
        if eEnd == 43625797:
            print (eStart, eEnd, 1)
        return eStart, eEnd
    elif utrUpStart <= eStart < utrUpEnd and utrUpEnd < eEnd <= utrDownStart:
        if eEnd == 43625797:
            print (utrUpEnd, eEnd, 2)
        return utrUpEnd, eEnd
    elif eStart < utrDownStart and utrDownStart < eEnd <= utrDownEnd:
        if eEnd == 43625797:
            print (eStart, utrDownStart, 3)
        return eStart, utrDownStart

refGenes = {}
with open(refFile) as ref:
    for line in ref:
        line = line.strip()
        refLine = line.split('\t')
        chrPos = refLine[2]
        chrRm = chrPos.split('_')
        if chrPos == 'chrMT' or len(chrRm) > 1:
            continue
        else:
            gene = {}
            symbol = refLine[12]
            toward = refLine[3]
            utrStart = int(refLine[4])
            utrEnd = int(refLine[5])
            codeStart = int(refLine[6])
            codeEnd = int(refLine[7])
            gene['exonNum'] = int(refLine[8])
            gene['codeLen'] = codeEnd - codeStart
            gene['utrLen'] = utrEnd - utrStart
            gene['chr'] = chrPos
            gene['exon'] = {}
            exonStartList = refLine[9].rstrip(',').split(',')
            exonEndList = refLine[10].rstrip(',').split(',')
            for i in range(0, gene['exonNum']):
                start, end = utrFilter(utrStart, codeStart, codeEnd, utrEnd, int(exonStartList[i]), int(exonEndList[i]))
                if symbol == 'RET':
                    print (utrStart, codeStart, codeEnd, utrEnd, int(exonStartList[i]), int(exonEndList[i]))
                if start == 0:
                    continue
                elif toward == '+':
                    exonId = i + 1
                elif toward == '-':
                    exonId = abs(i - gene['exonNum'])
                gene['exon'][exonId] = str(start) + '-' + str(end)

            if symbol not in refGenes.keys():
                refGenes[symbol] = gene
            elif refGenes[symbol]['codeLen'] > gene['codeLen'] or ( refGenes[symbol]['codeLen'] == gene['codeLen'] and refGenes[symbol]['utrLen'] > gene['utrLen'] ):
                continue
            else:
                refGenes[symbol] = gene

print (len(refGenes))
with open('gene-exons2.json', 'w') as outfile:
    json.dump(refGenes, outfile)