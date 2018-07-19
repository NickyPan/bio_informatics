#!/usr/bin/env python

import sys
import os
import json
import xlrd
import xlwt

sampleDetails = {}
rest = []
wes = []
total = 0

def stats(sampleType):
    if sampleType in sampleDetails.keys():
        sampleDetails[sampleType] += 1
    else:
        sampleDetails[sampleType] = 1

def minExcel(item, idx):
    global total
    data = xlrd.open_workbook(item)
    table = data.sheets()[idx]
    samples = table.col_values(1)
    if idx == 0:
        libIdx = samples.index('Lib ID')
    elif idx == 1:
        libIdx = samples.index('library ID')
    del samples[0:(libIdx+1)]
    total += len(samples)
    for sample in samples:
        sample = str(sample)
        sample = sample.replace(' ', '')
        if sample[0:2] == 'BR':
            stats('brca')
        elif sample[0:3] == '50G':
            stats('50gene')
        elif sample[0:3] == 'STR':
            stats('STR')
        elif sample[0:2] == 'YZ':
            stats('YZ')
        elif sample[0:2] == 'YG':
            stats('YG')
        elif sample[0:2] == 'NT':
            stats('NIPT')
        elif sample[0:3] == 'CYP':
            stats('CYP')
        elif sample[0:2] == 'ET':
            stats('ET')
        elif sample[0:3] == 'DIS':
            stats('DIS')
        elif sample[0:3] == 'WGS':
            stats('WGS')
        elif sample[0:3] == 'RNA':
            stats('RNA')
        elif sample[0:3] == 'XLT':
            stats('chrMT')
        elif sample[0:4] == 'MLPA':
            stats('MLPA')
        elif sample[0:2] == 'TP':
            stats('TP53')
        elif sample[0:2] == 'SC':
            stats('single-cell')
        elif sample[0:2] == 'QW' or sample[0:2] == 'G2':
            stats('WES')
            wes.append(sample)
        elif sample[0:1] == 'F':
            stats('paternity')
        elif sample[0:4] == 'PPGL' or sample[0:4] == 'ppgl' or sample[0:4] == 'PLP1':
            stats('PPGL')
        else:
            stats('other')
            rest.append(sample)

baseDir = './'
otherDir = baseDir + 'others'
jwzDir = baseDir + 'jwz'
fileList = os.listdir(otherDir)
jwzList = os.listdir(jwzDir)
for item in fileList:
    item = otherDir + '/' + item
    if item.endswith('.xlsx'):
        try:
            minExcel(item, 0)
        except:
            sys.exit(item)

print (sampleDetails)
print (total)

for item in jwzList:
    if item.endswith('.xlsx'):
        item = jwzDir + '/' + item
        try:
            minExcel(item, 1)
        except:
            sys.exit(item)

sampleDetails['total'] = total
print (sampleDetails)
print (wes, len(wes))

# workbook = xlwt.Workbook(encoding = 'ascii')
# worksheet = workbook.add_sheet('wes')
# for i in range(0, len(wes)):
#     worksheet.write(i, 0, wes[i])

# workbook.save('wes-samples.xls')

# with open('sample-stats.json', 'w') as outfile:
#     json.dump(sampleDetails, outfile)
