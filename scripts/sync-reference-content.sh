#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

NOTES_REPO="${NOTES_REPO:-https://github.com/CameronCandau/Cheatsheets.git}"
NOTES_REF="${NOTES_REF:-main}"
NOTES_DIR="${NOTES_DIR:-$SITE_ROOT/content/notes}"

PENTEST_REPO="${PENTEST_REPO:-https://github.com/CameronCandau/Pentest-Reference.git}"
PENTEST_REF="${PENTEST_REF:-main}"
PENTEST_DIR="${PENTEST_DIR:-$SITE_ROOT/content/pentest}"

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

usage() {
  cat <<'EOF'
Usage: scripts/sync-reference-content.sh [notes] [pentest]

No arguments syncs both sections.
EOF
}

clear_section_dir() {
  local section_dir="$1"

  if [[ ! -d "$section_dir" ]]; then
    echo "Section directory not found: $section_dir" >&2
    exit 1
  fi

  find "$section_dir" -mindepth 1 ! -name '_index.md' -exec rm -rf {} +
}

sync_section() {
  local name="$1"
  local repo="$2"
  local ref="$3"
  local dest_dir="$4"
  local repo_dir="$tmpdir/$name"
  local file_count=0

  clear_section_dir "$dest_dir"
  git clone --depth 1 --branch "$ref" "$repo" "$repo_dir" >/dev/null 2>&1

  while IFS= read -r -d '' source_file; do
    local rel_path dest_path
    rel_path="${source_file#$repo_dir/}"

    if [[ "$rel_path" == "README.md" ]]; then
      continue
    fi

    dest_path="$dest_dir/$rel_path"
    mkdir -p "$(dirname "$dest_path")"
    cp "$source_file" "$dest_path"
    file_count=$((file_count + 1))
  done < <(find "$repo_dir" -type f -name '*.md' -print0 | sort -z)

  printf 'Synced %s %s page(s) from %s@%s\n' "$file_count" "$name" "$repo" "$ref"
}

if (($# == 0)); then
  set -- notes pentest
fi

for target in "$@"; do
  case "$target" in
    notes)
      sync_section notes "$NOTES_REPO" "$NOTES_REF" "$NOTES_DIR"
      ;;
    pentest)
      sync_section pentest "$PENTEST_REPO" "$PENTEST_REF" "$PENTEST_DIR"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown target: $target" >&2
      usage >&2
      exit 1
      ;;
  esac
done
