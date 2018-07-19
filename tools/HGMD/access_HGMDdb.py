#!/usr/bin/env python

import os
import sys

dbSet = []
with open('other_allmut_HD.txt',"r") as beds:
    for bed in beds:
        bed = bed.strip()
        bed = bed.split('\t')
        item = bed[15] + '\t' + bed[16] + '\t' + bed[17] + '\t' + bed[17] + '\t' + bed[17] + '\t' + bed[17] + '\t' + 'https://www.ncbi.nlm.nih.gov/pubmed/' + bed[26] + '\t' + bed[18] + '\t' + bed[17] + '\t' + bed[1] + '\t' + bed[13] + '\t' + bed[11] + '\t' + bed[14] + '\t' + bed[0]
        dbSet.append(item)
    beds.close()
result = '\n'.join(dbSet)
with open('dbset.txt', "w") as text_file:
    text_file.write(result)