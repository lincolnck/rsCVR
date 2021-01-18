#!/bin/bash

for d in */; do
	cd $d
	for i in */*; do
		if [[ "$i" == *"co"* ]]; then
		    first_part=${i/NDAR*}
		    x=${i/${first_part}}
		    second_part=${x/s*}
		    mkdir -p ./$second_part
		fi
		mv -i -- "$i" "$second_part"
		# cp $i $second_part
	done
	# for j in */*; do
	# 	cp $j ./$second_part
	# done
	cd ..
	    # mkdir -p $second_part
	    # cp $i $second_part
done