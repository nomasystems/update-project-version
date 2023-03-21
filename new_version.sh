#!/bin/bash

has_breaking_exclamation() {
  commit_message="$1"
  commit_part="${commit_message%%:*}"

  [[ $commit_part == *! ]]
}

has_breaking_footer() {
  commit_message="$1"
  breaking_token1="BREAKING CHANGE"
  breaking_token2="BREAKING-CHANGE"

  if [[ "$commit_message" == *$'\n\n'"$breaking_token1: "* ]]
  then true
  elif [[ "$commit_message" == *$'\n\n'"$breaking_token2: "* ]]
  then true
  else false
  fi
}

is_breaking_change() {
  has_breaking_footer "$1" || has_breaking_exclamation "$1"
}

commit_message="$1"
current_version="$2"
echo "Obtaining new version from commit message \"$commit_message\" and current version \"$current_version\""

current_version_major=$(echo $current_version | cut -d. -f1)
current_version_minor=$(echo $current_version | cut -d. -f2)
current_version_patch=$(echo $current_version | cut -d. -f3)

commit_part=$(echo $commit_message | cut -d "(" -f1)
minor_changes=("build" "chore" "ci" "docs" "feat" "perf" "refactor" "style" "test")
if is_breaking_change "$commit_message";
then
  new_version="`expr $current_version_major + 1`.0.0";
elif [[ " ${minor_changes[@]} " =~ " ${commit_part} " ]]
then
  new_version="$current_version_major.`expr $current_version_minor + 1`.0"
elif [[ "$commit_part" == "fix" ]]
then
  new_version="$current_version_major.$current_version_minor.`expr $current_version_patch + 1`"
fi

echo "New version: $new_version"

echo "NEW_VERSION=$new_version" >> $GITHUB_ENV