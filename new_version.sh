#!/bin/bash

commit_message="$1"
current_version="$2"
echo "Obtaining new version from commit message \"$commit_message\" and current version \"$current_version\""

current_version_major=$(echo $current_version | cut -d. -f1)
current_version_minor=$(echo $current_version | cut -d. -f2)
current_version_revision=$(echo $current_version | cut -d. -f3)

commit_part=$(echo $commit_message | cut -d "(" -f1)
minor_changes=("build" "chore" "ci" "docs" "feat" "perf" "refactor" "style" "test")
if [[ "$commit_part" == *! ]]
then
  new_version="`expr $current_version_major + 1`.0.0"
elif [[ " ${minor_changes[@]} " =~ " ${commit_part} " ]]
then
  new_version="$current_version_major.`expr $current_version_minor + 1`.0"
elif [[ "$commit_part" == "fix" ]]
then
  new_version="$current_version_major.$current_version_minor.`expr $current_version_revision + 1`"
fi

echo "New version: $new_version"

echo "NEW_VERSION=$new_version" >> $GITHUB_ENV
