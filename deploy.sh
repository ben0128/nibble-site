#!/bin/bash
# Deploy public/ to Cloudflare Pages via a clean staging copy, so wrangler's
# cache (.wrangler/ — it contains the Cloudflare account id) can never end up
# in the upload.
#
# Release-coupled numbers (version, download size) are stamped into the staged
# index.html from the latest GitHub release at deploy time, so the page can't
# drift from what brew actually installs. The committed index.html keeps the
# last-stamped values so it stays a readable, working page on its own.
set -euo pipefail
cd "$(dirname "$0")"

REL=$(curl -fsSL https://api.github.com/repos/ben0128/nibble/releases/latest)
read -r VERSION ZIP_KB < <(REL_JSON="$REL" python3 -c '
import json, os, sys
r = json.loads(os.environ["REL_JSON"])
zips = [a for a in r["assets"] if a["name"].endswith(".zip")]
if not zips:
    sys.exit("latest release has no zip asset")
print(r["tag_name"].lstrip("v"), round(zips[0]["size"] / 1024))
')

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
rsync -a --exclude='.wrangler' public/ "$STAGE"/

sed -i '' -E \
  -e "s|(\"softwareVersion\": \")[0-9.]+(\")|\1${VERSION}\2|" \
  -e "s|(Nibble doctor v)[0-9.]+|\1${VERSION}|" \
  -e "s|(A )[0-9]+( KB download as of v)[0-9.]+|\1${ZIP_KB}\2${VERSION}|" \
  "$STAGE/index.html"

# Fail loud if a stamp didn't land — that means the page text changed shape.
grep -q "\"softwareVersion\": \"${VERSION}\"" "$STAGE/index.html"
grep -q "Nibble doctor v${VERSION}" "$STAGE/index.html"
grep -q "A ${ZIP_KB} KB download as of v${VERSION}" "$STAGE/index.html"
echo "stamped: v${VERSION}, ${ZIP_KB} KB download"

wrangler pages deploy "$STAGE" --project-name nibble --branch main --commit-dirty=true
