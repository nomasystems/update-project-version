#!/bin/bash

prefix=$1
suffix=$2
new_version=$3
committer_email=$5
committer_username=$6

echo "COMMITTER USERNAME: $committer_username"
echo "COMMITTER EMAIL: $committer_email"


new_tag=$prefix$new_version$suffix

echo "Creating new tag \"$new_tag\""

git \
  -c user.name="$committer_username" \
  -c user.email="$committer_email" \
  tag -a "$new_tag" -m "$new_tag"

if [[ "$4" == "true" ]]
then
  echo "Creating/updating tag \"latest\""
  git push origin :refs/tags/latest
  git \
  -c user.name="$committer_username" \
  -c user.email="$committer_email" \
  tag -fa "latest" -m "latest"
fi
