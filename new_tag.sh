#!/bin/bash

prefix=$1
suffix=$2
new_version=$3

new_tag=$prefix$new_version$suffix

echo "Creating new tag \"$new_tag\""

git \
  -c user.name="github-actions[bot]" \
  -c user.email="github-actions[bot]@users.noreply.github.com" \
  tag -a "$new_tag" -m "$new_tag"

if [[ "$1" == "true" ]]
then
  echo "Creating/updating tag \"latest\""
  git push --force origin latest
else
  echo "LO QUE LLEGA COMO LATEST-TAG ES: \"$1\""
fi