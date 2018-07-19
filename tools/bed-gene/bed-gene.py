#!/usr/bin/env python

import sys
import os
import json

bedFile = 'Exome_v1_Targets_Standard.bed'
geneList = json.load(open('endo-gene.json'))
print (len(geneList))

newBeds = []
geneBed = []
with open(bedFile) as beds:
    for line in beds:
        bed = line.strip()
        bedList = bed.split('\t')
        if len(bedList) > 3:
            geneStr = bedList[3].split('_')
            if geneStr[0] == '11471':
                gene = geneStr[2].split('(')[0]
            else:
                gene = geneStr[2].split('(')[1].split(')')[0]
            if gene in geneList and bed not in newBeds:
                newBeds.append(bed)
                if gene not in geneBed:
                    geneBed.append(gene)

print(len(geneBed))
results = '\n'.join(newBeds)
with open('whs_endo_panel.bed', "w") as text_file:
    text_file.write(results)

notGene = []
for gene in geneList:
    if gene not in geneBed:
        notGene.append(gene)
print(notGene, len(notGene))