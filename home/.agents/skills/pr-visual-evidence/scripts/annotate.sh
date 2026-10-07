#!/usr/bin/env bash
# Draw red review boxes on a before/after screenshot pair.
#
# usage: annotate.sh BEFORE.png AFTER.png [BOX...]
#
# With no BOX, boxes come from a pixel diff of the pair: changed pixels are
# grouped into at most 3 regions, padded by 8px, and drawn on both images.
# Each BOX is x0,y0,x1,y1 (tight content bounds, padding is added) and
# replaces the diff boxes. Prefix a BOX with b: or a: to draw it on only the
# before or after image, for an element that moved.
#
# Writes BEFORE.annotated.png and AFTER.annotated.png next to the inputs (or
# in $OUT_DIR) and prints each box drawn. The inputs are never modified.
set -euo pipefail

usage() { sed -n '4,13p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }
[ $# -ge 2 ] || usage
before=$1 after=$2
shift 2
command -v magick >/dev/null || { echo "annotate.sh: ImageMagick 7 (magick) is required" >&2; exit 1; }

size_before=$(magick identify -format '%wx%h' "$before")
size_after=$(magick identify -format '%wx%h' "$after")
[ "$size_before" = "$size_after" ] || {
  echo "annotate.sh: size mismatch ($size_before vs $size_after); capture both at the same viewport" >&2
  exit 1
}
width=${size_before%x*} height=${size_before#*x}

pad=8 max_regions=3
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Components of a black/white mask, as "x0,y0,x1,y1" of white areas larger than noise.
components() {
  magick "$1" -define connected-components:verbose=true \
    -define connected-components:area-threshold=20 \
    -connected-components 8 null: |
    awk '/gray\(255\)|white/ { split($2, g, /[x+]/); print g[3] "," g[4] "," g[3] + g[1] "," g[4] + g[2] }'
}

boxes_before=() boxes_after=()
if [ $# -gt 0 ]; then
  for box in "$@"; do
    case $box in
      b:*) boxes_before+=("${box#b:}") ;;
      a:*) boxes_after+=("${box#a:}") ;;
      *) boxes_before+=("$box") boxes_after+=("$box") ;;
    esac
  done
else
  # compare exits 1 when the images differ, which is the expected case.
  magick compare -fuzz 10% "$before" "$after" -compose src \
    -highlight-color white -lowlight-color black "$tmp/mask.png" 2>/dev/null || [ $? -eq 1 ]

  # Merge nearby changes with a growing dilation until at most 3 regions remain.
  regions=()
  for radius in 12 24 48 96 192 384; do
    magick "$tmp/mask.png" -morphology Dilate "Square:$radius" "$tmp/grown.png"
    regions=()
    while IFS= read -r region; do regions+=("$region"); done < <(components "$tmp/grown.png")
    [ ${#regions[@]} -le $max_regions ] && break
  done
  [ ${#regions[@]} -gt 0 ] || { echo "annotate.sh: no visible difference; pass boxes by hand" >&2; exit 1; }
  [ ${#regions[@]} -le $max_regions ] || { echo "annotate.sh: changes too scattered; pass boxes by hand" >&2; exit 1; }

  # Shrink each grown region back to the changed pixels inside it.
  for region in "${regions[@]}"; do
    IFS=, read -r x0 y0 x1 y1 <<<"$region"
    tight=$(magick "$tmp/mask.png" -crop "$((x1 - x0))x$((y1 - y0))+$x0+$y0" +repage -format '%@' info:)
    IFS='x+' read -r w h tx ty <<<"$tight"
    box="$((x0 + tx)),$((y0 + ty)),$((x0 + tx + w)),$((y0 + ty + h))"
    boxes_before+=("$box") boxes_after+=("$box")
    if [ $((w * h * 5)) -gt $((width * height)) ]; then
      echo "annotate.sh: box $box covers over 20% of the image; likely a layout shift, so check it and pass boxes by hand" >&2
    fi
  done
fi

# Pad, clamp inside the image so the 3px stroke stays visible, and draw.
draw() {
  local src=$1 dst=$2 label=$3
  shift 3
  local args=() x0 y0 x1 y1
  for box in "$@"; do
    IFS=, read -r x0 y0 x1 y1 <<<"$box"
    if ! [ "$x0" -lt "$x1" ] 2>/dev/null || ! [ "$y0" -lt "$y1" ] || [ "$x1" -gt "$width" ] || [ "$y1" -gt "$height" ]; then
      echo "annotate.sh: bad box '$box' for a ${width}x$height image; want x0,y0,x1,y1 with x0<x1 and y0<y1" >&2
      exit 1
    fi
    x0=$((x0 - pad < 2 ? 2 : x0 - pad)) y0=$((y0 - pad < 2 ? 2 : y0 - pad))
    x1=$((x1 + pad > width - 3 ? width - 3 : x1 + pad)) y1=$((y1 + pad > height - 3 ? height - 3 : y1 + pad))
    args+=(-draw "rectangle $x0,$y0 $x1,$y1")
    echo "$label box: $x0,$y0,$x1,$y1"
  done
  magick "$src" -fill none -stroke "#FF0000" -strokewidth 3 ${args[@]+"${args[@]}"} "$dst"
  echo "wrote $dst"
}

out_path() {
  local dir=${OUT_DIR:-$(dirname "$1")}
  local name
  name=$(basename "$1" .png)
  echo "$dir/$name.annotated.png"
}

draw "$before" "$(out_path "$before")" before ${boxes_before[@]+"${boxes_before[@]}"}
draw "$after" "$(out_path "$after")" after ${boxes_after[@]+"${boxes_after[@]}"}
