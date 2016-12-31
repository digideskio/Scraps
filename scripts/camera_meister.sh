#!/bin/bash
# -----------------------------------------------------------------------------
# camera-meister.sh
# -----------------------------------------------------------------------------
#
# Look for either Android Device or SD cards containing pictures and then copy
# into date specific folders 
#
# TODOs:
# - Importing video files
# - Deletinig of RAW source
# - Renaming files by dates
#
# Dependencies: bash 4.3, rsync, imagemagick, ufraw, netpbm, dcraw
#
# -----------------------------------------------------------------------------
# Manually create/edit a .backup_meisterrc config file in your home directory
# -----------------------------------------------------------------------------
#
# declare -A CameraSD1=(
#	[mount]="/media/user/CameraMount"
#	[pictures_path]="DCIM/100MSDCF"
#	[videos_path]="PRIVATE/AVCHD"
#	[delete_source]="true"
#	[delete_raw]="true"
# )
#
# CAMERAS=(CameraSD1 CameraSD2)
# PICTURES_PATH="/home/user/Pictures"
#
# -----------------------------------------------------------------------------
# Preferably run as a cron job or manually with ./camera-meister.sh

# Load Config
source ~/.backup_meisterrc

LINE="\e[36m-------------------------------------------------------------------"

SEASONS[1]="Winter"
SEASONS[2]="Winter"
SEASONS[3]="Spring"
SEASONS[4]="Spring"
SEASONS[5]="Spring"
SEASONS[6]="Summer"
SEASONS[7]="Summer"
SEASONS[8]="Summer"
SEASONS[9]="Fall"
SEASONS[10]="Fall"
SEASONS[11]="Fall"
SEASONS[12]="Winter"

# Check Cameras
echo -e $LINE

for idx in "${CAMERAS[@]}"; do
	# Check if Mounted
    declare -n camera="$idx"

	if mount | grep $camera[mount] > /dev/null; then
		echo -e "\e[36mCamera: ${camera[mount]} connected"
		echo -e $LINE
		sleep 1	

		# Copy Pictures
		pictures_path="${camera[mount]}/${camera[pictures_path]}/"
		echo "Getting pictures: $pictures_path"
		for picture in "${pictures_path[@]}"*
		do
			# 1. Analyze Picture
			echo -e "\e[94mAnalyzing: $picture"
			pic_info=$(identify -verbose "$picture")
			pic_exif_datetime=$(echo "$pic_info" | grep "exif:DateTime:")
			pic_datetime=${pic_exif_datetime/exif:DateTime: /""}
			pic_date=${pic_datetime:0:-9}
			set -f
			pic_date_array=(${pic_date//:/ })
			# year=`date +%Y`
			# month=`date +%m`
			year=${pic_date_array[0]}
			month=$(echo ${pic_date_array[1]} | sed 's/^0//')
			season="${SEASONS[$month]}"
			local_folder="$PICTURES_PATH/$year/$season"

			# Create local folders
			if [[ ! -d $local_folder ]]; then
				echo "Creating $local_folder"
				mkdir -p $local_folder
			else
				echo "Folder $local_folder exists"
			fi

			# 2. Copy Picture
			echo -e "\e[94mCopying $picture"
			echo -e "\e[37m--> $local_folder"
			cp "$picture" "$local_folder"

			# 3. Convert if RAW
			extension_get="${picture##*.}"
			extension="${extension_get,,}"
			filename=$(basename "$picture" $extension_get)
			if [[ $extension = "arw" ]]; then
				echo -e "\e[94mConverting RAW ${filename}arw --> ${filename}jpg"
				convert $picture $local_folder/${filename}jpg
			elif [[ $extension = "nef" ]]; then
				echo -e "\e[94mConverting RAW ${filename}nef --> ${filename}jpg"
				dcraw -c -w $picture | convert -compress lzw - $local_folder/${filename}jpg
			else
				echo -e "\e[94mFormat (${extension}) and is not RAW"
			fi

			# Delete RAW
			#if [[ "${camera[delete_raw]}" = true ]]; then
				# echo "Deleting local raw"
				#rm $local_folder/${filename}
			#fi

			# 4. Delete From Camera
			if [[ "${camera[delete_source]}" = true ]]; then
				echo -e "\e[94mDeleting source file"
				rm "$picture"
			fi
	
			echo -e $LINE
		done
		echo "Done copying pictures!"
		sleep 1
	else
		echo -e "\e[37mCamera ${camera} is not connected :("
		echo -e $LINE
	fi
	sleep 1
done
