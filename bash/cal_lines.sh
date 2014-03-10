#!/bin/bash

dir=$1
if [ "x$dir" = "x" ]
then
    dir="."
fi

files=`ls $dir`
if [ "x$files" = "x" ]
then
    echo "[ERROR] Cannot find directory $dir"
    exit 1
fi

lines=0
for file in $files
do
    # echo "[DEBUG] calculating file $dir/$file ... ..."
    if [[ "$file" =~ ^.+\.gz$ ]]
    then
        count=`zcat $dir/$file | wc -l`
    else
        count=`wc -l $dir/$file | cut -d' ' -f1`
    fi
    lines=`expr $lines + $count`
done
echo "[INFO] total lines in the directory \`$dir': $lines"
