#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_QUARTZ_DIR="${SITE_ROOT}/ctf-quartz"

QUARTZ_DIR="${CTF_QUARTZ_DIR:-$DEFAULT_QUARTZ_DIR}"
CONTENT_DIR="${CTF_CONTENT_DIR:-$QUARTZ_DIR/content}"
OUTPUT_DIR="${CTF_OUTPUT_DIR:-$SITE_ROOT/static/ctf}"

if [[ ! -d "$QUARTZ_DIR" ]]; then
  echo "Quartz directory not found: $QUARTZ_DIR" >&2
  echo "Set CTF_QUARTZ_DIR if your Quartz project lives somewhere else." >&2
  exit 1
fi

if [[ ! -f "$QUARTZ_DIR/package.json" ]]; then
  echo "Quartz directory does not contain package.json: $QUARTZ_DIR" >&2
  exit 1
fi

if [[ ! -f "$QUARTZ_DIR/quartz/bootstrap-cli.mjs" ]]; then
  echo "Quartz bootstrap file not found at $QUARTZ_DIR/quartz/bootstrap-cli.mjs" >&2
  exit 1
fi

if [[ ! -d "$QUARTZ_DIR/node_modules" ]]; then
  echo "Quartz dependencies are missing in $QUARTZ_DIR/node_modules" >&2
  echo "Run 'npm ci' in the Quartz directory first." >&2
  exit 1
fi

if [[ ! -d "$CONTENT_DIR" ]]; then
  echo "Quartz content directory not found: $CONTENT_DIR" >&2
  echo "Set CTF_CONTENT_DIR if your publishable Obsidian notes live elsewhere." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

cd "$QUARTZ_DIR"
node ./quartz/bootstrap-cli.mjs build -d "$CONTENT_DIR" -o "$OUTPUT_DIR"

# Hugo serves files in static/ literally and doesn't rewrite extensionless paths
# to ".html", so mirror Quartz's page.html files to page/index.html.
while IFS= read -r -d '' html_file; do
  rel_path="${html_file#"$OUTPUT_DIR"/}"
  stem="${rel_path%.html}"
  mkdir -p "$OUTPUT_DIR/$stem"
  cp "$html_file" "$OUTPUT_DIR/$stem/index.html"
done < <(find "$OUTPUT_DIR" -type f -name '*.html' ! -name 'index.html' ! -name '404.html' -print0)
