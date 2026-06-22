#!/usr/bin/env bash
# Build the full published site: the book + every chapter's slide deck, all under _book/.
#
#   _book/index.html
#   _book/chapters/<theme>/index.html   (book chapter)
#   _book/chapters/<theme>/slides.html  (slide deck, generated from the same _body.qmd)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "==> Rendering the book"
quarto render

echo "==> Rendering slide decks"
for slides in chapters/*/slides.qmd; do
  [ -e "$slides" ] || continue
  dir="$(dirname "$slides")"            # chapters/<theme>
  quarto render "$slides" >/dev/null
  # slides are self-contained (embed-resources), so a single html moves cleanly
  mkdir -p "_book/$dir"
  mv "$dir/slides.html" "_book/$dir/slides.html"
  echo "    $dir/slides.html -> _book/$dir/slides.html"
done

echo "==> Done. Open _book/index.html"
