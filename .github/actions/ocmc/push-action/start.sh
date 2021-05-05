#!/bin/sh
set -e

REPOSITORY=${INPUT_REPOSITORY:-$GITHUB_REPOSITORY}

echo "Push to branch $INPUT_BRANCH";
[ -z "${INPUT_GITHUB_TOKEN}" ] && {
    echo 'Missing input "github_token: ${{ secrets.GITHUB_TOKEN }}".';
    exit 1;
};

cd '.'

remote_repo="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${REPOSITORY}.git"

git push "${remote_repo}" HEAD:${INPUT_BRANCH};
