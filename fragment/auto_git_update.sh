#!/bin/bash
DATE=`date '+%Y-%m-%d %H:%M:%S'`;
echo $DATE;
cd /mnt/workshop/xinchen.pan/pipeline/bio_informatics
git pull --rebase
echo ''