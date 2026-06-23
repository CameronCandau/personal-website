#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

CHEATSHEETS_REPO="${CHEATSHEETS_REPO:-https://github.com/CameronCandau/Cheatsheets.git}"
CHEATSHEETS_REF="${CHEATSHEETS_REF:-main}"
NOTES_DIR="${NOTES_DIR:-$SITE_ROOT/content/notes}"

if [[ ! -d "$NOTES_DIR" ]]; then
  echo "Notes directory not found: $NOTES_DIR" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

git clone --depth 1 --branch "$CHEATSHEETS_REF" "$CHEATSHEETS_REPO" "$tmpdir/repo" >/dev/null 2>&1

find "$NOTES_DIR" -maxdepth 1 -type f -name '*.md' ! -name '_index.md' -delete

while IFS= read -r -d '' source_file; do
  dest_file="$NOTES_DIR/$(basename "$source_file")"
  cp "$source_file" "$dest_file"
done < <(find "$tmpdir/repo" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)

note_count="$(find "$NOTES_DIR" -maxdepth 1 -type f -name '*.md' ! -name '_index.md' | wc -l | tr -d ' ')"
printf 'Synced %s notes from %s@%s\n' "$note_count" "$CHEATSHEETS_REPO" "$CHEATSHEETS_REF"
