#!/usr/bin/env bash
# RezChest release helper - run from Git Bash inside your local clone of the public RezChest repo.
# (Usually you don't call this yourself: ../RezChest/publish.sh calls it with the newest build.)
#
#   ./release.sh test    1.04 "/c/Users/Bart/Asheron's Call/RezChest/builds/RezChest.Test.v1.04/RezChest.Test.v1.04.dll" "What changed"
#   ./release.sh release 1.05 "/path/to/RezChest.v1.05.dll" "First public release"
#
# The release asset is named after the build (RezChest.Test.v1.04.dll); the updater installs it under that name.
# Build ids: test = RezChest.Test.v1.04, ...   release = RezChest.v1.05, ...  (the updater compares ids; channels never cross).
#
# What it does:
#   1. computes the SHA-256 of the DLL
#   2. creates the GitHub release (tag = build id, pre-release for test builds) with the DLL attached
#   3. rewrites the channel manifest (latest-test.txt or latest.txt)
#   4. commits and pushes the manifest to main
#
# One-time setup: GitHub CLI (winget install GitHub.cli), `gh auth login`, and a clone of
# https://github.com/ResistanceLab/RezChest.git (setup-repos.sh in the source folder does the clone).

set -euo pipefail

CHANNEL="${1:-}"; NUM="${2:-}"; DLL="${3:-}"; NOTES="${4:-}"
REPO="ResistanceLab/RezChest"

usage() { echo "usage: $0 <test|release> <version e.g. 2.03> <path-to-dll> [notes]"; exit 1; }
[[ -z "$CHANNEL" || -z "$NUM" || -z "$DLL" ]] && usage
[[ "$CHANNEL" != "test" && "$CHANNEL" != "release" ]] && usage
[[ -f "$DLL" ]] || { echo "DLL not found: $DLL"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Run this from inside your RezChest (public) git clone."; exit 1; }
command -v gh >/dev/null || { echo "GitHub CLI (gh) not found. Install: winget install GitHub.cli, then: gh auth login"; exit 1; }

if [[ "$CHANNEL" == "test" ]]; then
  BUILD="RezChest.Test.v$NUM"; MANIFEST="latest-test.txt"; PRE="--prerelease"; TITLE="RezChest test build v$NUM"
else
  BUILD="RezChest.v$NUM";      MANIFEST="latest.txt";      PRE="";             TITLE="RezChest v$NUM"
fi
[[ -z "$NOTES" ]] && NOTES="$TITLE"

# Sanity: the DLL must have been built with this exact build id baked in.
# .NET stores the id as UTF-16 (a NUL after every character); build a byte pattern "R.e.z..." and search with LC_ALL=C.
PAT=$(printf '%s' "$BUILD" | sed 's/\(.\)/\1./g')
if ! LC_ALL=C grep -aq "$PAT" "$DLL" && ! tr -d '\000' < "$DLL" | grep -aq "$BUILD"; then
  echo "WARNING: '$BUILD' not found inside $DLL — was it built with that build id?"
  read -rp "Continue anyway? [y/N] " yn; [[ "$yn" == "y" || "$yn" == "Y" ]] || exit 1
fi

SHA=$(sha256sum "$DLL" | cut -d' ' -f1)
ASSET="$BUILD.dll"
URL="https://github.com/$REPO/releases/download/$BUILD/$ASSET"

echo "== Build:    $BUILD"
echo "== Manifest: $MANIFEST"
echo "== SHA-256:  $SHA"
echo "== Notes:    $NOTES"

# Publish under the exact asset name the manifest points at (RezChest.Test.v2.03.dll etc).
TMPDIR_=$(mktemp -d); cp "$DLL" "$TMPDIR_/$ASSET"

git checkout -q main
git pull -q --ff-only

echo "== Creating GitHub release $BUILD ..."
gh release create "$BUILD" "$TMPDIR_/$ASSET" --repo "$REPO" --title "$TITLE" --notes "$NOTES" $PRE
rm -rf "$TMPDIR_"

echo "== Updating $MANIFEST ..."
printf '%s\r\n%s\r\n%s\r\n%s\r\n' "$BUILD" "$URL" "$SHA" "$NOTES" > "$MANIFEST"
git add "$MANIFEST"
git commit -q -m "$BUILD: update $MANIFEST"
git push -q origin main

echo
echo "Done. $BUILD is live on the $CHANNEL channel."
echo "Manifest: https://raw.githubusercontent.com/$REPO/main/$MANIFEST  (raw cache may lag ~1-2 min)"
