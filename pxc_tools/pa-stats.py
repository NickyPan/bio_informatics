#!/usr/bin/env python
# coding=utf-8

import json,os,sys

posList = []
negList = []
otherList = []
case = ''

def case_var(line, case):
    if case == 'positive':
        posList.append(line)
    elif case == 'negative':
        negList.append(line)
    elif case == 'other':
        otherList.append(line)
    elif case == '':
        pass
    else:
        print (case, '------------------------wrong case-----------------------------')

def collect_var(file):
    global case
    with open(file) as var:
        var.readline()
        for line in var:
            line = line.strip()
            if line:
                if 'Positive' in line:
                    case ='positive'
                    continue
                elif 'Negative' in line:
                    case ='negative'
                    continue
                elif 'Other' in line:
                    case ='other'
                    continue
                elif 'Reports' in line:
                    break

                case_var(line, case)

def scan_var(path):
    for entry in os.scandir(path):
        if entry.is_dir() and entry.name == 'results':
            varPath = entry.path + '/var-report.txt'
            if os.path.isfile(varPath):
                collect_var(varPath)
        elif entry.is_dir():
            scan_var(entry.path)

scan_var(sys.argv[1])

print (len(posList)+len(negList)+len(otherList))
print (len(posList), len(negList), len(otherList))
posStr = '\n'.join(posList)
negStr = '\n'.join(negList)
otherStr = '\n'.join(otherList)

with open(sys.argv[2], 'w') as pa:
    pa.write(posStr + '\n')
    pa.write(negStr + '\n')
    pa.write(otherStr + '\n')
