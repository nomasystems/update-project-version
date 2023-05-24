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
  new_version="$3"
  escaped_new_version="${new_version//./"$escaped_dot"}"
  author=$4
  committer_email=$5
  committer_username=$6
  echo "Updating version in files \"$files_str\" from \"$current_version\" to \"$new_version\""

  for file in ${files[@]}
  do
    echo "Updating file \"$file\""
  	sed -i.bak "s/$escaped_current_version/$escaped_new_version/" $file
  	rm $file".bak"
  done

  echo "Committing changes"
  git add .
  git \
    -c user.name="$committer_username" \
    -c user.email="$committer_email" \
    commit -m "New version $new_version" --author="$author"

fi
