#!/usr/bin/env python

import os
import sys

snpFile = sys.argv[1]
all_snp = {}
with open(snpFile,"r") as snps:
    for snp in snps:
        snp = snp.strip()
        snp = snp.split('\t')
        pos = snp[0] + ":" +  snp[1] + "-" + snp[2]
        all_snp[pos] = snp[3] + '/' + snp[4]
    snps.close()
print ("snp done!")
dbSet = []
with open('dbset.txt',"r") as sets:
    for setSnp in sets:
        setSnp = setSnp.strip()
        setSnp = setSnp.split('\t')
        setPos = setSnp[0] + ":" +  setSnp[1] + "-" + setSnp[2]
        if setPos in all_snp.keys():
            ref = all_snp[setPos].split('/')[0]
            setSnp[3] = ref
        item = '\t'.join(setSnp)
        dbSet.append(item)
    sets.close()
result = '\n'.join(dbSet)
with open('dbset_wRef.txt', "w") as text_file:
    text_file.write(result)