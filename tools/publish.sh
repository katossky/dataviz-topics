#!/usr/bin/env bash
# Publish the site to GitHub Pages WITHOUT GitHub Actions.
# Builds _book/ locally and force-pushes it to the `gh-pages` branch.
# Pages must be configured to serve the gh-pages branch (root).
#
# Use this until GitHub Actions is unblocked (billing); after that the
# workflow in .github/workflows/publish.yml can take over automatically.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> Building site"
./tools/build.sh

touch _book/.nojekyll   # stop GitHub Pages from running Jekyll over _book

REMOTE_URL="$(git remote get-url origin)"
TMP="$(mktemp -d)"
cp -R _book/. "$TMP/"
(
  cd "$TMP"
  git init -q
  git checkout -q -b gh-pages
  git add -A
  git -c user.email=publish@local -c user.name=publish \
      commit -q -m "Publish site $(date -u +%FT%TZ)"
  echo "==> Pushing to gh-pages"
  git push -q --force "$REMOTE_URL" gh-pages
)
rm -rf "$TMP"
echo "==> Published. Live at https://katossky.github.io/dataviz-topics/ (allow ~1 min)"
