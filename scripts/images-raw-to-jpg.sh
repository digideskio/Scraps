#!/bin/bash
# -----------------------------------------------------------------------------
# images-raw-to-jpg.sh
# -----------------------------------------------------------------------------
#
# Convert RAW (arw, nef) file formats 
#
# Example: ./images-raw-to-jpg.sh /path/to/raw/images
#
# Dependencies: imagemagick, ufraw, netpbm, dcraw

for image in $1/*
do
	extension_get="${image##*.}"
	extension="${extension_get,,}"
	filename=$(basename "$image" $extension_get)
	if [[ $extension = "arw" ]]; then
		echo "Converting $image -> ${filename}jpg"
		convert $image $1/${filename}jpg
	elif [[ $extension = "nef" ]]; then
		echo "Converting $image -> ${filename}jpg"
		dcraw -c -w $image | convert -compress lzw - $1/${filename}jpg
	else
		echo "$image is not RAW or cannot be processed"
	fi
done
