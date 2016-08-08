#!/bin/bash
# Unzip all items in a directory 

for file in $1*
do
	echo unzipping: $file
	unzip $file
done
