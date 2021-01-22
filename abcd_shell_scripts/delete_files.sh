#!/bin/bash

for d in $1/; do
	cd "$d"
	find . ! \( -name 'bold*' -o -name 'RS_rCVRmap*' -o -name 'dicom' \) -exec rm -f {} +
	cd ..
done