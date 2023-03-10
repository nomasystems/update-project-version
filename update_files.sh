#!/bin/bash

files_str=$1
IFS=',' read -r -a files <<< $files_str

if [[ ${#files[@]} -eq 0 ]]
then
  echo "No files to update"
else

  current_version=$2
  new_version=$3
  author=$4
  echo "Updating version in files \"$files_str\" from \"$current_version\" to \"$new_version\""

  for file in ${files[@]}
  do
    echo "Updating file \"$file\""
  	sed -i.bak "s/$current_version/$new_version/" $file
  	rm $file".bak"
  done

  echo "Committing changes"
  git add .
  git \
    -c user.name="github-actions[bot]" \
    -c user.email="github-actions[bot]@users.noreply.github.com" \
    commit -m "New version $new_version" --author="$author"

fi
