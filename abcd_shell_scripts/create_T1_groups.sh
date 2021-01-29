#!/bin/bash

#************************************************#
#     create_T1_groups.sh                        #
#     written by Lincoln Kartchner               #
#     lincoln@jhu.edu                            #
#     January 28, 2021                           #
#                                                #
#     Creates t1 groups for batch processing     #
#     on MRICloud                                # 
#************************************************#

E_BADDIR=85 
t1_images_dir=$1  
num_of_subs=${2:-10}  
image_type=${3:-NORM}
zip_files=${4:-Y}
t1_groups_dir=${5:-t1_groups}  

# ----------------------------------------------------------- #
# t1_groups ()                                                #
# Combines images of one type from different subjects into    #
# one directory. The T1 segmentation pipeline on MRICloud     #
# allows batch segmentation of T1 images as long as there are #
# no more than 10 subjects in each directory (20 files due to #
# .hdr/.img analyze format). t1_groups was written with this  #
# in mind, but has broader functionality to automatically     # 
# copy files of a specified type into separate directories    #
# ensuring that no more than a specified number of files      #
# are in each directory.             						  #
# Parameters:  												  #	
#	$t1_images_dir - The filepath of the directory            #
#	containing all the subject directories which themselves   #
#	contain all the images for that subject.                  #
#	$num_of_subs - The number of subjects desired in each     #
#	combined directory. Default is 10.                        #
#	$image_type - A string unique to all images of the        #
#	desired type, i.e. T1, bold, NORM. Default is             #
#	NORM.                                                     #
#   $zip_files - compress the resulting directory for         #
#   uploading to MRICloud. Default is Y                       #
#	$t1_groups_dir - The name of the desired target           #
#	directory. Default is 't1_groups', this directory         #
#	will be created by default in the same directory          #
#	containing the t1_images_dir.                             #
# Returns: 0 on success, $E_BADDIR if something went wrong.   #
# ----------------------------------------------------------- #

t1_groups () 
{
	# Set counter for new subdirectory names at 1
	d_number=1
	new_subdir_name="group_$d_number"
	# Make a new directory with group # within the t1_groups subdirectory
	if [ ! -d "$t1_images_dir" ]
	then
		echo "$1 is not a directory"
		return "$E_BADDIR"
	fi
	if [ ! -d "$t1_groups_dir" ]
	then
		cd "./$t1_images_dir"
		cd ..
		mkdir -v "./$t1_groups_dir"
	fi
	mkdir -v "./$t1_groups_dir/$new_subdir_name"
	# loop through all the images in each subdirectory
	for image in "$t1_images_dir"/*/*; do
		# extract the subdirectory name to append to image name later
		files=(./$t1_groups_dir/$new_subdir_name/*)
		image_number=$(( $num_of_subs*2 ))
		if [[ ${#files[@]} -lt "$image_number" ]];
		then
			case $image in 
				(*"$image_type"*)
			    subject_and_image_name=${image/${t1_images_dir}}
			    subject_name=$( echo "$subject_and_image_name" |cut -d/ -f2 )
			    image_name=$( echo "$subject_and_image_name" |cut -d/ -f3)
				dest_name=$subject_name"_"$image_name
				cp $image "./$t1_groups_dir/$new_subdir_name/$dest_name";;
			esac
		else
			case $zip_files in
				(*Y*)
				zip -r "./$t1_groups_dir/$new_subdir_name/$new_subdir_name.zip" "./$t1_groups_dir/$new_subdir_name" -x ".*" -x "__MACOSX"
			esac
			((d_number++))
			new_subdir_name="group_$d_number"
			mkdir -v "./$t1_groups_dir/$new_subdir_name"
			case $image in 
				(*"$image_type"*)
			    subject_and_image_name=${image/${t1_images_dir}}
			    subject_name=$( echo "$subject_and_image_name" |cut -d/ -f2 )
			    image_name=$( echo "$subject_and_image_name" |cut -d/ -f3)
				dest_name=$subject_name"_"$image_name
				cp $image "./$t1_groups_dir/$new_subdir_name/$dest_name";;
			esac
		fi
	done
	return 0
}

t1_groups $t1_images_dir $num_of_subs $image_type $zip_files $t1_groups_dir 

