#!/bin/bash


for d in */; do
	cd "$d"
	a=1
	for i in *.img; do
		newimg=$(printf "bold_%01d.img" "$a")
		mv -i -- "$i" "./$newimg"
		# echo $newimg
		((a++))
	done
	b=1
	for j in *.hdr; do
		newhdr=$(printf "bold_%01d.hdr" "$b")
		mv -i -- "$j" "./$newhdr"
		((b++))
	done
	cd ..
done