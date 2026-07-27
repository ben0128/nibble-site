# CLAUDE.md

Maintainer notes for the Nibble landing page. User-facing docs live in README.md.

## Deploy pipeline

- Single self-contained file (`public/index.html`), no build step. Cloudflare Pages project `nibble`, production = branch `main`, live at nibble-45j.pages.dev. Deploys are **manual** via `./deploy.sh` (not push-triggered); each machine needs a one-time `wrangler login`.
- `deploy.sh` stamps release-coupled numbers into the **staging copy** at deploy time, fetched from the latest GitHub release of `ben0128/nibble`: the version and the zip download size in KB. Three stamped patterns in `index.html`:
  - `"softwareVersion": "X.Y.Z"` (JSON-LD)
  - `Nibble doctor vX.Y.Z` (terminal mockup)
  - `A NNN KB download as of vX.Y.Z` (size note)
- After stamping, the script greps each pattern and **aborts the deploy if one didn't land**. Rewording any of those three strings therefore requires updating the sed patterns in `deploy.sh` in the same change.
- The committed `index.html` keeps the last-stamped values — it stays a complete, readable page; stamping never dirties the git worktree.

## Coupling to nibble releases

Shipping a nibble release (`git tag vX.Y.Z && git push --tags` over there) builds the universal app, uploads the zip, and bumps the Homebrew tap automatically — then run `./deploy.sh` here so the site's numbers follow. The install command shown on the site is the cask (`brew install --cask nibble`), which delivers CLI + menu bar app with no Swift toolchain requirement.
