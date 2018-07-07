#!/usr/bin/env python

import sys
import os

firstDir = sys.argv[1]
secondDir = sys.argv[2]
targetDir = sys.argv[3]

# prepare
fileCheck = []

# functions list
def file_check(fileOne, fileType):
    global listTwo
    for item in listTwo:
        fileName = item.split('_')[0]
        if fileOne == fileName and fileType in item:
            return True, item
    return False, None

def cmd_check(cmd):
    cmdList = cmd.split(' ')
    fileOne = cmdList[1].split('/')[-1]
    fileTwo = cmdList[2].split('/')[-1]
    fileMerged = cmdList[4].split('/')[-1]
    fileNameOne = fileOne.split('_')
    fileNameTwo = fileTwo.split('_')
    fileNameMerged = fileMerged.split('_')
    if fileNameOne[0] == fileNameTwo[0] == fileNameMerged[0] and fileNameOne[-1] in fileNameTwo and fileNameOne[-1] in fileNameMerged:
        return True
    else:
        return False

# code start
if __name__ == "__main__":
    listOne = os.listdir(firstDir)
    listTwo = os.listdir(secondDir)
    for file in listOne:
        fileName = file.split('_')[0]
        if '_R1.fastq.gz' in file:
            fileType = 'R1'
        elif '_R2.fastq.gz' in file:
            fileType = 'R2'
        else:
            continue

        isMerged, fileNameTwo = file_check(fileName, fileType)
        if isMerged and fileName != 'Undetermined':
            fileOne = firstDir + file
            fileTwo = secondDir + fileNameTwo
            fileMerged = targetDir + file
            cmd = 'cat ' + fileOne + ' ' + fileTwo + ' > ' + fileMerged
            if cmd_check(cmd):
                print ('start to merge:', file)
                os.system(cmd)
