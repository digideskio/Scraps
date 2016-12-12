#!/bin/bash
# -----------------------------------------------------------------------------
# png-to-ascii.sh
# -----------------------------------------------------------------------------
# Converts a PNG file to JPG and then outputs ASCII art to screen. Or to output
# ASCII art to a file (in current dir) append the "--output" flag
# 
# Example: $ path/to/image.png --output 
#
# Requires "imagemagick" and "jp2a" packages installed
#
# :authors: Brennan Novak, 01AEEADB9EED1B5B4280E5B6C4CAA23B0F8C68B2
# :license: BSD license
# :date 16 November 2016
# :version: 0.0.1
# -----------------------------------------------------------------------------

# Variables
pathname=$(dirname "$1")
filename="$(basename "$1" .png)"
jpgfile="${filename}.jpg"
jpgfilepath="${pathname}/${jpgfile}"

# Generate JPG
echo "Converting to $jpgfile"
convert $1 $jpgfilepath

# Output ASCII
if [[ $2 == "--output" ]]; then
	echo "Generating ASCII art to ${filename}.txt"
	jp2a -i --chars="  00xx@@" --width=48 $jpgfilepath | tee "${filename}.txt"
else
	echo "Generating ASCII art right here"
	jp2a -i --chars="  00xx@@" --width=48 $jpgfilepath
fi

# Cleanup
echo "Deleting $jpgfile"
rm $jpgfilepath
