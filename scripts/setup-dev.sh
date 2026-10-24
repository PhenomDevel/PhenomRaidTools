#!/usr/bin/env bash
# Fetches the libraries from .pkgmeta into PhenomRaidTools/Libs (gitignored)
# with the same packager the release workflow uses, so a git checkout runs in
# game. Optionally links the addon into the game's AddOns folder.
#
#   scripts/setup-dev.sh                    fetch libraries only
#   scripts/setup-dev.sh <AddOns folder>    also link PhenomRaidTools there
#
# Needs git, svn (most externals are CurseForge svn repos) and curl.
# Run it again to update the libraries.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
addons_dir="${1:-}"
packager_url="https://raw.githubusercontent.com/BigWigsMods/packager/v2/release.sh"

for tool in git svn curl; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing '$tool'. macOS: brew install subversion; Debian/Ubuntu: apt install subversion; Windows: Git Bash + TortoiseSVN with command line tools." >&2
    exit 1
  fi
done

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "Downloading packager..."
curl -fsSL "$packager_url" -o "$work/release.sh"

# -d no upload, -z no zip, -l no localization replacement; the package lands
# in $work/release/PhenomRaidTools (move-folders in .pkgmeta).
echo "Fetching libraries (this takes a moment)..."
bash "$work/release.sh" -t "$root" -r "$work/release" -d -z -l >"$work/packager.log" 2>&1 || {
  cat "$work/packager.log" >&2
  echo "Packager failed, see the log above." >&2
  exit 1
}

package_libs="$work/release/PhenomRaidTools/Libs"
if [ ! -d "$package_libs" ]; then
  cat "$work/packager.log" >&2
  echo "No Libs folder in the package." >&2
  exit 1
fi

# LibDeflate is tracked in git; everything else under Libs is ignored.
for lib in "$package_libs"/*; do
  name="$(basename "$lib")"
  [ "$name" = "LibDeflate" ] && continue
  rm -rf "$root/PhenomRaidTools/Libs/$name"
  cp -R "$lib" "$root/PhenomRaidTools/Libs/$name"
  echo "  $name"
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
