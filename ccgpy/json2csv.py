#!/usr/bin/env python
# -*- coding: utf-8 -*-

import csv, json, sys

inputFile = sys.argv[1]

with open(inputFile, encoding='utf-8') as jsons:
    json_data = json.load(jsons)
print (len(json_data))

res = []
header = '\t'.join(list(json_data[12].keys()))
res.append(header)

for data in json_data:
    string = ''

    if data['url']:
        string += data['url'] + '\t'
    else:
        string += '.\t'

    if data['id']:
        string += data['id'] + '\t'
    else:
        string += '.\t'

    if data['cname']:
        string += data['cname'] + '\t'
    else:
        string += '.\t'

    if data['ename']:
        string += data['ename'] + '\t'
    else:
        string += '.\t'

    if 'inherited' in data.keys() and data['inherited']:
        string += data['inherited'] + '\t'
    else:
        string += '.\t'

    if 'diseaseId' in data.keys() and data['diseaseId']:
        string += data['diseaseId'] + '\t'
    else:
        string += '.\t'

    if 'ratio' in data.keys() and data['ratio']:
        string += data['ratio'] + '\t'
    else:
        string += '.\t'

    if 'omimId' in data.keys() and data['omimId']:
        omimId = data['omimId'].replace('https://omim.org/entry/', '')
        string += omimId + '\t'
    else:
        string += '.\t'

    if data['description']:
        des = data['description'].replace('\n', '')
        string += des
    else:
        string += '.'

    res.append(string)

outResults = '\n'.join(res)
csvFile = inputFile.split('.')[0] + '.txt'
with open(csvFile, 'w', encoding='utf-16') as outfile:
    outfile.write(outResults)