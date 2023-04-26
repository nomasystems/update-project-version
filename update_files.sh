#!/bin/bash

files_str=$1
IFS=',' read -r -a files <<< $files_str

if [[ ${#files[@]} -eq 0 ]]
then
  echo "No files to update"
else

  escaped_dot="\."
  current_version="$2"
  escaped_current_version="${current_version//./"$escaped_dot"}"
  echo "escaped_current_version=$escaped_current_version"
  new_version="$3"
  escaped_new_version="${new_version//./"$escaped_dot"}"
  echo "escaped_new_version=$escaped_new_version"
  author=$4
  echo "Updating version in files \"$files_str\" from \"$current_version\" to \"$new_version\""

  for file in ${files[@]}
  do
    echo "Updating file \"$file\""
    echo "comando sed = s/$escaped_current_version/$escaped_new_version/"
  	sed -i.bak "s/$escaped_current_version/$escaped_new_version/" $file
  	rm $file".bak"
  done

  echo "Committing changes"
  git add .
  git \
    -c user.name="github-actions[bot]" \
    -c user.email="github-actions[bot]@users.noreply.github.com" \
    commit -m "New version $new_version" --author="$author"

fi
