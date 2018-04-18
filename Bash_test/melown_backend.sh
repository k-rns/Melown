#!/bin/bash
generate_overview()
{
  #First step in setting up the DEM
  #Generating 3 sets of overviews of the DEM with different resampling algorithm
  #in_path = path to the DEM dataset, has to be stored in the /var/vts/mapproxy/datasets/sandwich folder
  local in_path=$1

  filename=$(basename -- "$in_path")
  extension="${filename##*.}"
  filename="${filename%.*}"

  for resampling in min max cubicspline
  do
    generatevrtwo
    --input "$in_path"
    --output "$filename"".""$resampling"
    --resampling $resampling
    --overwrite 1;
  done
}

symbolic_links()
{
  local in_path=$1

  filename=$(basename -- "$in_path")
  filename="${filename%.*}"
  name_new_directory="$filename""_links"

  mkdir "$name_new_directory" && cd "$name_new_directory"

}
