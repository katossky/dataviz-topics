#!/usr/bin/env bash
# Regression test for the single-source -> book + slides mechanism.
#
# The whole "book in prose / slides generated in parallel from the same _body.qmd"
# design relies on Quarto's `.content-hidden when-format="revealjs"` /
# `.content-visible when-format="revealjs"` semantics. revealjs derives from html,
# so naive `when-format="html"` leaks into slides. This test pins the behaviour:
# if a Quarto update changes it, CI fails here instead of in every chapter.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/fixtures/slide-mechanism"
PAGE="$DIR/page.html"
SLIDES="$DIR/slides.html"
fail=0

cleanup() { rm -f "$PAGE" "$SLIDES"; rm -rf "$DIR"/*_files; }
trap cleanup EXIT

echo "Rendering fixtures..."
quarto render "$DIR/page.qmd"   >/dev/null 2>&1
quarto render "$DIR/slides.qmd" >/dev/null 2>&1

check() { # check <label> <file> <pattern> <expected-count: 0 | atleast1>
  local label="$1" file="$2" pat="$3" mode="$4"
  local n; n=$(grep -c "$pat" "$file" || true)
  if [ "$mode" = "0" ] && [ "$n" -ne 0 ]; then
    echo "  ✗ FAIL: $label — '$pat' found $n time(s), expected 0"; fail=1
  elif [ "$mode" = "atleast1" ] && [ "$n" -lt 1 ]; then
    echo "  ✗ FAIL: $label — '$pat' not found, expected at least 1"; fail=1
  else
    echo "  ✓ $label"
  fi
}

echo "Book page (page.html):"
check "book-only prose present"     "$PAGE"   "BOOKONLY_MARKER"  atleast1
check "slide-only bullet absent"    "$PAGE"   "SLIDEONLY_MARKER" 0
check "code chunk executed (42)"    "$PAGE"   "42"               atleast1

echo "Slides (slides.html):"
check "slide-only bullet present"   "$SLIDES" "SLIDEONLY_MARKER" atleast1
check "book-only prose absent"      "$SLIDES" "BOOKONLY_MARKER"  0
check "code chunk executed (42)"    "$SLIDES" "42"               atleast1

if [ "$fail" -ne 0 ]; then
  echo "SLIDE MECHANISM TEST FAILED — Quarto conditional-content behaviour may have changed."
  exit 1
fi
echo "All slide-mechanism checks passed."
