#!/usr/bin/env python
# -*- coding: utf-8 -*-

import tinify
import os, sys
import argparse
import subprocess

# optional args
parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input', required=True, help='input file or dir')
parser.add_argument('-o', '--out_dir', help='out dir')
args = parser.parse_args()

if args.input:
    import_item = args.input

if args.out_dir:
    out_dir = args.out_dir + '/'
else:
    out_dir = './'

try:
  tinify.key = "ueBonZF4nckiT1azjO53vSuO6dB3MMoD"
  tinify.validate()
except (tinify.Error, e):
  sys.exit('Validation of API key failed')

def compress_one(oriFile):
    try:
        source = tinify.from_file(oriFile)
        filename, file_extension = os.path.splitext(oriFile)
        mod_name = out_dir + filename + '.mod' + file_extension
        source.to_file(mod_name)
        compressions_this_month = tinify.compression_count
        print (str(compressions_this_month) + '/500 compressions of this month remained.')
    except (tinify.AccountError, e):
        print ("# Verify your API key and account limit")
        print ("The error message is: %s" % e.message)
    except (tinify.ClientError, e):
        print ("# Check your source image and request options.")
        print ("The error message is: %s" % e.message)
    except (tinify.ServerError, e):
        print ("# Temporary issue with the Tinify API.")
        print ("The error message is: %s" % e.message)
    except (tinify.ConnectionError, e):
        print ("# A network connection error occurred.")
        print ("The error message is: %s" % e.message)
    except (Exception, e):
        print ("# Something else went wrong, unrelated to the Tinify API.")

def compress_multi(oripath):
    for file in os.listdir(oripath):
        if '.png' in file or '.jpg' in file:
            filename = oripath + '/' + file
            compress_one(filename)
        else:
            print (file, 'failed. Only support for jpg or png files!')

if os.path.isfile(import_item):
    print('file mode...')
    compress_one(import_item)
elif os.path.isdir(import_item):
    print('dir mode...')
    compress_multi(import_item)
else:
    print('can\'t recongize the input file or dir!')
