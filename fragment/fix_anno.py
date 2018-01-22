#! /usr/bin/python
# -*- coding: utf-8 -*-

import glob, os
from pathlib import Path
import subprocess
# import subprocess
# child = subprocess.Popen("ping -c 5 www.baidu.com",shell=True)
# child.wait()
# # 此时会等待子进程完成，再打印end
# print 'end'

raw_vcf = []
multi_anno = []

def getFileName():
    for file in glob.glob("*.raw.vcf"):
        raw_vcf.append(Path(file).stem)
    for file in glob.glob("*.hg19_multianno.txt"):
        multi_anno.append(Path(file).stem)

if __name__ == '__main__':
    getFileName()
    if len(multi_anno) > 0 :
        for i in range(len(multi_anno)) :
            file_path="/mnt/workshop/xinchen.pan/pipeline/tools/header.pl " + raw_vcf[i] + ".vcf" + multi_anno[i] + ".txt" + " > " + multi_anno[i] + ".header.txt"
            # os.system("echo \"Hello World\"" + raw_vcf[i])
            subprocess.call(["perl", file_path])
        #    os.system("perl /mnt/workshop/xinchen.pan/pipeline/tools/header.pl " + raw_vcf[i] + ".vcf" + multi_anno[i] + ".txt" + " > " + multi_anno[i] + ".header.txt")
        #    print ("fixed", multi_anno[i])