#!/bin/bash

# Set counter for new subdirectory names at 1
d_number=1
new_subdir_name="group_$d_number"
mkdir ../t1_groups/$new_subdir_name
# loop through all the images in each subdirectory
for i in */*; do
	# extract the subdirectory name to append to image name later
	files=(../t1_groups/$new_subdir_name/*)
	if [[ ${#files[@]} -lt 20 ]];
	then
		case $i in 
			(*NORM*)
			first_part=${i/T1*}
			subject_name=${first_part%/}
			image_name=${i/${first_part}}
			dest_name=$subject_name"_"$image_name
			cp $i "../t1_groups/$new_subdir_name/$dest_name";;
		esac
	else
		((d_number++))
		new_subdir_name="group_$d_number"
		mkdir ../t1_groups/$new_subdir_name
	fi
done
