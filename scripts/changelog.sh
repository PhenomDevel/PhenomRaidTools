#!/usr/bin/env sh

# Obtain the latest tag, include lightweight tags.
CURRENT=$(git describe --long --tags)

if [[ ${CURRENT} =~ (.*)-([0-9]+)-g[0-9a-z]{7}$ ]]; then

  # If the current tag is the `HEAD`…
  if [ ${BASH_REMATCH[2]} -eq "0" ]; then
    # …compare the current tag and the previous tag.
    CURRENT="${BASH_REMATCH[1]}"
    TAG=$(git describe --abbrev=0 --tags "${BASH_REMATCH[1]}^")

  # Otherwise, compare `HEAD` with the latest tag.
  else
    CURRENT="HEAD"
    TAG="${BASH_REMATCH[1]}"
  fi

  # Log out the commits in a Markdown-friendly format.
  echo "## ${CURRENT}"
  echo ""
  git log --pretty="format: * %s" "${TAG}..${CURRENT}"
  echo ""

else
  echo "Invalid git response." >&2
  exit 1
fi