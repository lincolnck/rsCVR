#!/bin/bash

for d in */; do
	cd "$d"
	echo $d
	find . ! \( -name 'bold*' -o -name 'RS_rCVRmap*' \) -exec rm -f {} +
	cd ..
done