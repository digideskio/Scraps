#!/bin/bash
# -----------------------------------------------------------------------------
# camera-meister.sh
# -----------------------------------------------------------------------------
#
# Look for either Android Device or SD cards containing pictures and then copy
# into date specific folders 
#
# TODOs:
# - Better handling & deleting of RAW
# - Renaming files by dates
# - 
#
# Dependencies: rsync, imagemagick, ufraw, netpbm, dcraw
#
# -----------------------------------------------------------------------------
# Manually create/edit a .backup_meisterrc config file in your home directory
# -----------------------------------------------------------------------------
# Preferably run as a cron job or manually with ./backup-meister

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

# Check Camera
for CAMERA in "${CAMERAS[@]}"
do
	# Check if Mounted
	if mount | grep $CAMERA > /dev/null; then
		echo -e "\e[36mCamera ${CAMERA} is connected"
		echo -e $LINE
		sleep 1	

		# Copy Pictures
		for picture in $CAMERA/$CAMERA_PICTURES/*
		do
			# 1. Analyze Picture
			echo -e "\e[94mAnalyzing $picture"
			pic_info=$(identify -verbose $picture)
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
			echo -e "\e[94mCopying $picture --> $local_folder"
			cp $picture $local_folder

			# 3. Convert if RAW
			extension_get="${picture##*.}"
			extension="${extension_get,,}"
			filename=$(basename "$picture" $extension_get)
			if [[ $extension = "arw" ]]; then
				echo "Converting RAW ${filename}arw --> ${filename}jpg"
				convert $picture $local_folder/${filename}jpg
			elif [[ $extension = "nef" ]]; then
				echo "Converting RAW ${filename}nef --> ${filename}jpg"
				dcraw -c -w $picture | convert -compress lzw - $local_folder/${filename}jpg
			else
				echo "$picture is not (or unkown) RAW"
			fi

			# Delete RAW
			#if [[ "$CAMERA_DELETE_RAW" = true ]]; then
				# echo "Deleting local raw"
				#rm $local_folder/${filename}
			#fi

			# 4. Delete From Camera
			if [[ "$CAMERA_DELETE_SOURCE" = true ]]; then
				echo "Deleting source file"
				rm $picture
			fi
	
			echo -e $LINE
		done
		echo "Done copying pictures!"
		sleep 1
	else
		echo "Camera \"${CAMERA}\" is not connected :("
	fi
	sleep 1
done
