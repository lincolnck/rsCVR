#!/bin/bash

for d in */; do
	subject_name=${d/_*}
	mkdir -p $subject_name
	mv -v $d/* $subject_name
	rm -r $d
done