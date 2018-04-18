#!/bin/bash
# This is a simple script
#
#cd /mnt/Users/Gebruiker/Documents/USGS/Melown/Bash_test
echo 'bash'
echo $PWD
echo "omething again"
ogr2ogr -f GeoJSON targets_test.json targets.kmz
#exec $SHELL
