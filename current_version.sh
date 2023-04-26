#!/bin/bash

last_tag=$(git describe --tags --abbrev=0)
echo $last_tag
if [[ $last_tag == "latest" ]]
then
  last_tag=$(git describe --abbrev=0 --tags `git rev-list --tags --skip=1 --max-count=1`)
  echo $(git describe --abbrev=0 --tags `git rev-list --tags --skip=1 --max-count=4`)
fi
prefix=$1
suffix=$2

echo "Obtaining current version from tag \"$last_tag\" with prefix \"$prefix\" and suffix \"$suffix\""

current_version=$(echo $last_tag | sed -e "s/^$prefix//" -e "s/$suffix$//")
echo "Current version: $current_version"

echo "CURRENT_VERSION=$current_version" >> $GITHUB_ENV
