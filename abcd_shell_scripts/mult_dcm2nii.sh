#!/bin/bash
# My first script

for d in */; do
	echo ./$d
	echo "WHS"
	dcm2nii -a n -d n -e n -i n -p n -g n -n n -s y -x n -r y ./$d;
done
