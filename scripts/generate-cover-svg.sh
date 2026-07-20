#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  cat >&2 <<'EOF'
Usage:
  scripts/generate-cover-svg.sh "TEXT" output.svg

Examples:
  scripts/generate-cover-svg.sh 'x-' content/blog/nightly/x-http-headers/cover.svg
  scripts/generate-cover-svg.sh 'RFC 6648' content/blog/stable/http-rfcs/cover.svg
EOF
  exit 1
fi

text="$1"
output="$2"

accent_a="#a6e3a1"
accent_b="#76b972"
accent_c="#62b7ae"
bg_a="#181825"

mkdir -p "$(dirname "$output")"

escaped_text=$(
  printf '%s' "$text" \
    | sed \
      -e 's/&/\&amp;/g' \
      -e 's/</\&lt;/g' \
      -e 's/>/\&gt;/g'
)

cat >"$output" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 900" role="img" aria-labelledby="title desc">
  <title id="title">$escaped_text cover image</title>
  <desc id="desc">Large sharp mint text on a flat dark background.</desc>
  <defs>
    <linearGradient id="ink" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="$accent_a" />
      <stop offset="60%" stop-color="$accent_b" />
      <stop offset="100%" stop-color="$accent_c" />
    </linearGradient>
  </defs>

  <rect width="1600" height="900" fill="$bg_a" />
  <text
    x="780"
    y="480"
    text-anchor="middle"
    dominant-baseline="middle"
    font-family="monospace"
    font-size="560"
    font-weight="900"
    letter-spacing="-32"
    fill="rgba(0,0,0,0.28)"
    style="shape-rendering: crispEdges;"
    transform="translate(14 14)">
    $escaped_text
  </text>
  <text
    x="780"
    y="480"
    text-anchor="middle"
    dominant-baseline="middle"
    font-family="monospace"
    font-size="560"
    font-weight="900"
    letter-spacing="-32"
    fill="url(#ink)"
    style="shape-rendering: crispEdges;">
    $escaped_text
  </text>
</svg>
EOF

echo "Wrote $output"
