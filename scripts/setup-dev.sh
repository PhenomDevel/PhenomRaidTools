#!/usr/bin/env bash
# Puts the libraries into PhenomRaidTools/Libs (gitignored) so a git checkout
# runs in game, without svn:
#   - Ace3 incl. LibStub and CallbackHandler from GitHub (pinned tag below)
#   - LibSharedMedia, LibDBIcon, LibDataBroker from the
#     latest GitHub release zip (built by the packager from .pkgmeta)
# LibDeflate is tracked in git and left alone.
#
#   scripts/setup-dev.sh                    fetch libraries only
#   scripts/setup-dev.sh <AddOns folder>    also link PhenomRaidTools there
#
# Needs git, curl and unzip. Run it again to update the libraries.
set -euo pipefail

ACE3_TAG="Release-r1403"
ACE3_LIBS="LibStub CallbackHandler-1.0 AceAddon-3.0 AceComm-3.0 AceConsole-3.0 AceDB-3.0 AceEvent-3.0 AceLocale-3.0 AceSerializer-3.0 AceTimer-3.0"
RELEASE_LIBS="LibSharedMedia-3.0 LibDBIcon-1.0 LibDataBroker-1.1"
REPO="PhenomDevel/PhenomRaidTools"

root="$(cd "$(dirname "$0")/.." && pwd)"
libs="$root/PhenomRaidTools/Libs"
addons_dir="${1:-}"

for tool in git curl unzip; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Missing '$tool'." >&2; exit 1; }
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

copy_lib() {
  rm -rf "$libs/$2"
  cp -R "$1/$2" "$libs/$2"
  echo "  $2"
}

echo "Ace3 $ACE3_TAG"
git -c advice.detachedHead=false clone -q --depth 1 --branch "$ACE3_TAG" https://github.com/WoWUIDev/Ace3.git "$tmp/Ace3"
for lib in $ACE3_LIBS; do
  copy_lib "$tmp/Ace3" "$lib"
done

zip_url="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep -o '"browser_download_url": *"[^"]*\.zip"' | head -1 | sed 's/.*"\(https[^"]*\)"/\1/')"
if [ -z "$zip_url" ]; then
  echo "No release zip found for $REPO." >&2
  exit 1
fi
echo "Release $(basename "$zip_url")"
curl -fsSL "$zip_url" -o "$tmp/release.zip"
unzip -q "$tmp/release.zip" -d "$tmp/release"
for lib in $RELEASE_LIBS; do
  copy_lib "$tmp/release/PhenomRaidTools/Libs" "$lib"
done
echo "Libraries are in PhenomRaidTools/Libs."

if [ -n "$addons_dir" ]; then
  target="$addons_dir/PhenomRaidTools"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "$target exists and is no link. Move it away first (e.g. the release version)." >&2
    exit 1
  fi
  rm -f "$target"
  ln -s "$root/PhenomRaidTools" "$target"
  echo "Linked $target -> $root/PhenomRaidTools"
fi
