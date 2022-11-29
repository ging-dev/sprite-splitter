#!/usr/bin/bash

FILENAME=$1
OUTPUT_DIR=$2

convert $FILENAME -alpha extract tmp_mask.png 2> /dev/null

OLD_IFS=$IFS
IFS=$'\n'

# https://imagemagick.org/script/connected-components.php
components=(`convert tmp_mask.png \
    -define connected-components:exclude-header=true \
    -define connected-components:verbose=true \
    -define connected-components:area-threshold=10 \
    -define connected-components:mean-color=true \
    -connected-components 8 \
    null: | grep --color=never 'gray(255)'
`)

result=(`
    for value in "${components[@]}"
    do
        bbox=$(echo $value | awk '{print $2}')
        x=$(echo $bbox | awk -F '+' '{print $2}')
        echo "$x $bbox"
    done | sort -nk1
`)

IFS=$OLD_IFS

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

i=0
for value in "${result[@]}"
do
    rect=`echo $value | awk '{print $2}'`
    convert $FILENAME -crop $rect +repage -background none ${OUTPUT_DIR}/${i}.png
    i=$((i+1))
    echo -n '.'
done

rm tmp_mask.png
