#!/bin/bash

# 
# Usage:
#   $ ./mobile_validation.sh mobile.txt
# 

Usage="Usage: $0 mobile_file"
if [ $# -ne 1 ]; then
    echo ${Usage}
    exit 1
fi

# input file
filename=$1
total_count=`wc -l $filename | cut -d' ' -f1`
valid_count=`grep "^0\?\(13[0-9]\|15[012356789]\|17[0678]\|18[0-9]\|14[57]\)[0-9]\{8\}" $filename | wc -l`
echo "valid mobile: ${valid_count}"
echo "toatl mobile: ${total_count}"
