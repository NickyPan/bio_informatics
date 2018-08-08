#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json, sys

inputFile = sys.argv[1]
omimFile = '../wh_db/omim_pheno_gene.txt'

omim_db = {}
with open(omimFile) as omim:
    omim.readline()
    for line in omim:
        line = line.strip().split('\t')
        if line[2] not in omim_db.keys():
            omim_db[line[2]] = {}
        omim_db[line[2]]['loc'] = line[0]
        omim_db[line[2]]['inherit'] = line[3]
        omim_db[line[2]]['gene'] = line[5]
        omim_db[line[2]]['gene_mim'] = line[6]
        try:
            print (line[7])
            omim_db[line[2]]['annovar'] = line[7]
        except IndexError:
            omim_db[line[2]]['annovar'] = '.'

res = []
with open(inputFile, encoding='utf-16') as text:
    header = text.readline()
    header = header.strip() + '\tgene\tgene_mim\tloc\tinherit\tannovar'
    res.append(header)
    for line in text:
        line = line.strip()
        lines = line.split('\t')
        if lines[7] in omim_db.keys():
            line += '\t' + omim_db[lines[7]]['gene'] + '\t' + omim_db[lines[7]]['gene_mim'] + '\t' + omim_db[lines[7]]['loc'] + '\t' + omim_db[lines[7]]['inherit'] + '\t' + omim_db[lines[7]]['annovar']
        res.append(line)
# res = []
# header = '\t'.join(list(json_data[0].keys()))


# for data in json_data:
#     string = ''
#     if data['cname']:
#         string += data['cname'] + '\t'
#     else:
#         string += '.\t'

#     if data['ename']:
#         string += data['ename'] + '\t'
#     else:
#         string += '.\t'

#     if data['inherited']:
#         string += data['inherited'] + '\t'
#     else:
#         string += '.\t'

#     if 'diseaseId' in data.keys() and data['diseaseId']:
#         string += data['diseaseId'] + '\t'
#     else:
#         string += '.\t'

#     if 'ratio' in data.keys() and data['ratio']:
#         string += data['ratio'] + '\t'
#     else:
#         string += '.\t'

#     if 'omimId' in data.keys() and data['omimId']:
#         omimId = data['omimId'].replace('https://omim.org/entry/', '')
#         string += omimId + '\t'
#     else:
#         string += '.\t'

#     if data['description']:
#         des = data['description'].replace('\n', '')
#         string += des
#     else:
#         string += '.'

#     res.append(string)

outResults = '\n'.join(res)
csvFile = inputFile.split('.')[0] + '_omim.txt'
with open(csvFile, 'w', encoding='utf-16') as outfile:
    outfile.write(outResults)