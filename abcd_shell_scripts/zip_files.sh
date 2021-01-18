#!/bin/bash

for d in $1/; do
	cd $d
	for sub_d in */; do
		cd $sub_d
		echo ${sub_d%/}"_mpr.zip"
		zip -r ${sub_d%/}"_mpr.zip" . -x ".*" -x "__MACOSX"
		echo "Successfully zipped $sub_d"
		cd ..
	done
	cd ..
done

echo "FINISHED ZIPPING!"
