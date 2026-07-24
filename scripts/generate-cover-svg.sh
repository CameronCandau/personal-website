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

escape_svg() {
  printf '%s' "$1" \
    | sed \
      -e 's/&/\&amp;/g' \
      -e 's/</\&lt;/g' \
      -e 's/>/\&gt;/g'
}

trimmed_text=$(printf '%s' "$text" | tr '\n' ' ' | tr -s '[:space:]' ' ' | sed 's/^ //; s/ $//')

if [[ -z "$trimmed_text" ]]; then
  echo "Text must not be empty" >&2
  exit 1
fi

read -r -a words <<<"$trimmed_text"

plain_length=${#trimmed_text}
line_target=$(( (plain_length + 15) / 16 ))
(( line_target < 1 )) && line_target=1
(( line_target > 4 )) && line_target=4

target_width=$(( (plain_length + line_target - 1) / line_target ))

lines=()
current_line=""
for word in "${words[@]}"; do
  candidate="$word"
  if [[ -n "$current_line" ]]; then
    candidate="$current_line $word"
  fi

  if (( ${#candidate} <= target_width || ${#current_line} == 0 )); then
    current_line="$candidate"
    continue
  fi

  lines+=("$current_line")
  current_line="$word"
done

[[ -n "$current_line" ]] && lines+=("$current_line")

while (( ${#lines[@]} > 4 )); do
  last_index=$((${#lines[@]} - 1))
  prev_index=$((last_index - 1))
  lines[$prev_index]="${lines[$prev_index]} ${lines[$last_index]}"
  unset 'lines[$last_index]'
  lines=("${lines[@]}")
done

line_count=${#lines[@]}
max_line_length=0
for line in "${lines[@]}"; do
  (( ${#line} > max_line_length )) && max_line_length=${#line}
done

font_size=$(( 2500 / max_line_length ))
height_limit=$(( 640 / line_count ))
(( font_size > 560 )) && font_size=560
(( font_size > height_limit )) && font_size=height_limit
(( font_size < 120 )) && font_size=120

letter_spacing=$(( font_size / -16 ))
line_gap=$(( font_size + font_size / 6 ))
start_y=$(( 450 - ((line_count - 1) * line_gap / 2) ))

tspans=""
for i in "${!lines[@]}"; do
  y=$((start_y + i * line_gap))
  escaped_line=$(escape_svg "${lines[$i]}")
  tspans="${tspans}    <tspan x=\"800\" y=\"$y\">$escaped_line</tspan>
"
done

escaped_text=$(escape_svg "$trimmed_text")

cat >"$output" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 900" role="img" aria-labelledby="title desc">
  <title id="title">$escaped_text cover image</title>
  <desc id="desc">Large sharp mint text on a flat dark background, wrapped across multiple lines when needed.</desc>
  <defs>
    <linearGradient id="ink" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="$accent_a" />
      <stop offset="60%" stop-color="$accent_b" />
      <stop offset="100%" stop-color="$accent_c" />
    </linearGradient>
  </defs>

  <rect width="1600" height="900" fill="$bg_a" />
  <text
    x="800"
    y="450"
    text-anchor="middle"
    font-family="monospace"
    font-size="$font_size"
    font-weight="900"
    letter-spacing="$letter_spacing"
    fill="rgba(0,0,0,0.28)"
    style="shape-rendering: crispEdges;"
    transform="translate(14 14)">
$tspans  </text>
  <text
    x="800"
    y="450"
    text-anchor="middle"
    font-family="monospace"
    font-size="$font_size"
    font-weight="900"
    letter-spacing="$letter_spacing"
    fill="url(#ink)"
    style="shape-rendering: crispEdges;">
$tspans  </text>
</svg>
EOF

echo "Wrote $output"
