#!/usr/bin/bash

FILENAME=$1
OUTPUT_DIR=$2

convert $FILENAME -alpha extract tmp_mask.png 2> /dev/null

OLD_IFS=$IFS
IFS=$'\n'

# https://imagemagick.org/script/connected-components.php
arr=(`convert tmp_mask.png \
    -define connected-components:verbose=true \
    -define connected-components:area-threshold=10 \
    -define connected-components:mean-color=true \
    -connected-components 8 \
    null: | tail -n +2 | grep --color=never 'gray(255)'`)

IFS=$OLD_IFS

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

num=${#arr[*]}
for ((i=0; i<num; i++))
do
    rect=`echo "${arr[$i]}" | awk '{print $2}'`
    convert $FILENAME -crop $rect +repage -background none ${OUTPUT_DIR}/${i}.png
    echo -n '.'
done

rm tmp_mask.png
