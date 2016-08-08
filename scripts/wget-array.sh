#!/bin/bash
# Perform wget on items in an array

files=(
  "bullet-symbolic.svg"
  "bullet-symbolic.symbolic.png"
  "check-symbolic.svg"
  "check-symbolic.symbolic.png"
)

for i in "${files[@]}"
do
   # do whatever on $i
   url="https://git.gnome.org/browse/gtk+/plain/gtk/theme/Adwaita/assets/$i"
   echo "Downloading... $url"
   wget $url --directory-prefix=imgs/
done
