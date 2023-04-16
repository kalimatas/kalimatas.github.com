#!/usr/bin/env bash

set -x

COMMIT_MESSAGE="${1:-"Published on "`date +%Y-%m-%d`}"

current_branch=`git branch --show-current`
gh_pages_branch="gh-pages"

bundle exec jekyll build

git checkout $gh_pages_branch
cp -r _site/ .
git add .
git commit -am "${COMMIT_MESSAGE}"
git push origin $gh_pages_branch
git checkout $current_branch

