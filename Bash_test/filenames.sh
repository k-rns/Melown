#!/bin/bash

renaming()
{
  in_path=$1

  filename=$(basename -- "$in_path")
  extension="${filename##*.}"
  filename="${filename%.*}"
  echo $extension
  echo  $filename
  echo "$extension""$filename"
}


#!/bin/bash
generate_overview()
{
  local in_path=$1

  filename=$(basename -- "$in_path")
  extension="${filename##*.}"
  filename="${filename%.*}"

  for resampling in min max cubicspline
  do
    echo "$filename"".""$resampling"
  done
}

generate_overview thisissupposedtobeapath.th
exec $SHELL
