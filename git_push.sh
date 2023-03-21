#!/bin/bash

echo "LISTING REMOTE TAGS"
git ls-remote --tags origin

echo "Pushing changes"

git push origin --follow-tags --atomic
