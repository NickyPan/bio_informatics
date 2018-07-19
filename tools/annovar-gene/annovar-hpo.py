#!/usr/bin/env python
import json
import sys

latest_hgnc = json.load(open('./protein-coding_gene.json'))['response']['docs']

hpoFile = sys.argv[1]
annoFile = sys.argv[2]

def access_hgnc(gene):
    geneList = []
    for g in latest_hgnc:
        if gene == g['symbol'] or ('alias_symbol' in g.keys() and gene in g['alias_symbol']) or ('prev_symbol' in g.keys() and gene in g['prev_symbol']):
            geneList.append(g['symbol'])
            if 'alias_symbol' in g.keys():
                geneList += g['alias_symbol']
            if 'prev_symbol' in g.keys():
                geneList += g['prev_symbol']
            return True, geneList
        else:
            return False, geneList

def access_hpo(file, idx):
    geneList = []
    with open(file) as hpo:
        hpo.readline()
        for line in hpo:
            line = line.strip().split('\t')
            gene = line[idx]
            if gene not in geneList:
                geneList.append(gene)
    return geneList

def access_mito(gene):
    for g in latest_hgnc:
        if gene == g['symbol'] or ('alias_symbol' in g.keys() and gene in g['alias_symbol']) or ('prev_symbol' in g.keys() and gene in g['prev_symbol']):
            if g['location_sortable'] == 'mitochondria':
                gene += '*'
        return gene

hpoGenes = access_hpo(hpoFile, 1)
print ('hpo:', len(hpoGenes))

newAnno = []
with open(annoFile) as annovar:
    title = annovar.readline().strip() + '\tHPO'
    newAnno.append(title)
    for line in annovar:
        line = line.strip()
        oldLine = line.split('\t')
        gene = oldLine[0]
        newLine = line
        if gene in hpoGenes:
            newLine += '\t' + access_mito(gene)
        else:
            isInHgnc, symList = access_hgnc(gene)
            if isInHgnc:
                for symbol in symList:
                    if symbol in hpoGenes:
                        newLine += '\t' + access_mito(symbol)
        newAnno.append(newLine)

result = '\n'.join(newAnno)
with open('Annova-hg38_HPO.refGene.txt', "w") as text_file:
    text_file.write(result)