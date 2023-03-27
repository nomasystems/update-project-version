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

is_minor_change() {
  commit_type="$1"
  extra_minor_commit_types_str="$2"

  declare -A minor_commit_types=(["feat"]=1)
  for type in ${extra_minor_commit_types_str//,/ }
  do
    if [[ $type == "fix" ]]
    then
      echo "WARNING: Ignoring type \"$type\" for extra-minor-commit-types"
    else
      minor_commit_types+=([$type]=1)
    fi
  done

  [ "${minor_commit_types[$commit_type]}" ]
}

is_patch_change() {
  commit_type="$1"
  extra_patch_commit_types_str="$2"

  declare -A patch_commit_types=(["fix"]=1)
  for type in ${extra_patch_commit_types_str//,/ }
  do
    if [[ $type == "feat" ]]
    then
      echo "WARNING: Ignoring type \"$type\" for extra-patch-commit-types"
    else
      patch_commit_types+=([$type]=1)
    fi
  done

  [ "${patch_commit_types[$commit_type]}" ]
}

commit_message="$1"
current_version="$2"
extra_minor_commit_types="$3"
extra_patch_commit_types="$4"
echo "Obtaining new version from commit message \"$commit_message\", current version \"$current_version\", extra minor commit types \"$extra_minor_commit_types\" and extra patch commit types \"$extra_patch_commit_types\""

current_version_major=$(echo "$current_version" | cut -d. -f1)
current_version_minor=$(echo "$current_version" | cut -d. -f2)
current_version_patch=$(echo "$current_version" | cut -d. -f3)

commit_type=$(echo "${commit_message%%:*}" | cut -d "(" -f1)
if is_breaking_change "$commit_message";
then
  new_version="$(("$current_version_major" + 1)).0.0"
elif is_minor_change "$commit_type" "$extra_minor_commit_types";
then
  new_version="$current_version_major.$(("$current_version_minor" + 1)).0"
elif is_patch_change "$commit_type" "$extra_patch_commit_types";
then
  new_version="$current_version_major.$current_version_minor.$(("$current_version_patch" + 1))"
else
  echo "ERROR: Couldn't obtain new version for commit type \"$commit_type\""
  exit 1
fi

echo "New version: $new_version"

echo "NEW_VERSION=$new_version" >> $GITHUB_ENV
