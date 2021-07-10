#!/bin/bash

# Repo URL to base links off of
REPOSITORY_URL=https://github.com/PhenomDevel/PhenomRaidTools

# Get a list of all tags in reverse order
# Assumes the tags are in version format like v1.2.3
GIT_TAGS=$(git tag -l --sort=-version:refname)

# Make the tags an array
LATEST_TAG=$(git describe --tags --abbrev=0)
PREVIOUS_TAG=$(git describe --abbrev=0 --tags `git rev-list --tags --skip=1 --max-count=1`)

COMMITS=$(git log $PREVIOUS_TAG..$LATEST_TAG --pretty=format:"%H")

echo "Processing all commits between tags $LATEST_TAG and $PREVIOUS_TAG"

NOW=$(date +'%d.%m.%Y - %H:%M:%S')

# Store our changelog in a variable to be saved to a file at the end
MARKDOWN="# Release $LATEST_TAG ~ $NOW"
MARKDOWN+='\n'

BUG_PATTERN="\[bug\]|\[fix\]"
FEATURE_PATTERN="\[feature\]|\[feat\]"

MARKDOWN_BUGS=""
MARKDOWN_FEATURES=""
MARKDOWN_MISC=""

BUG_COUNT=0
FEATURE_COUNT=0
MISC_COUNT=0

# Loop over each commit and look for merged pull requests
for COMMIT in $COMMITS; do
    # Get the subject of the current commit
    SUBJECT=$(git log -1 ${COMMIT} --pretty=format:"%s")
    BODY=$(git log -1 ${COMMIT} --pretty=format:"%b")

    CLEAN_SUBJECT="${SUBJECT/\[bug\]/}"
    CLEAN_SUBJECT="${CLEAN_SUBJECT/\[fix\]/}"
    CLEAN_SUBJECT="${CLEAN_SUBJECT/\[feature\]/}"
    CLEAN_SUBJECT="${CLEAN_SUBJECT/\[feat\]/}"

    IS_BUG=$( grep -Eo $BUG_PATTERN <<< "$SUBJECT")
    IS_FEATURE=$( grep -Eo $FEATURE_PATTERN <<< "$SUBJECT")

    if [[ ! -z $IS_BUG ]]; then
	BUG_COUNT=$((BUG_COUNT + 1))
	MARKDOWN_BUGS+=" - $CLEAN_SUBJECT"
	MARKDOWN_BUGS+="\n"
    fi

    if [[ ! -z $IS_FEATURE ]]; then
	FEATURE_COUNT=$((MARKDOWN_COUNT + 1))
	MARKDOWN_FEATURES+=" - $CLEAN_SUBJECT"
	MARKDOWN_FEATURES+="\n"
    fi

    if [ ! $IS_BUG ] && [ ! $IS_FEATURE ]; then
	MISC_COUNT=$((MISC_COUNT + 1))
	MARKDOWN_MISC+=" - $CLEAN_SUBJECT"
	MARKDOWN_MISC+="\n"
    fi
done

echo "Found $BUG_COUNT bug commit(s)"
echo "Found $FEATURE_COUNT feature commit(s)"
echo "Found $MISC_COUNT misc commit(s)"

if [[ "$BUG_COUNT" -gt 0 ]]; then
    MARKDOWN+="## Bugfixes\n$MARKDOWN_BUGS\n"
fi

if [[ "$FEATURE_COUNT" -gt 0 ]]; then
    MARKDOWN+="## Features\n$MARKDOWN_FEATURES\n"
fi

if [[ "$MISC_COUNT" -gt 0 ]]; then
    MARKDOWN+="## Misc\n$MARKDOWN_MISC\n"
fi

# Save our markdown to a file
echo -e $MARKDOWN > CHANGELOG.md
