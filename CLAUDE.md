# CLAUDE.md

Maintainer notes for the Nibble landing page. User-facing docs live in README.md.

## Deploy pipeline

- Single self-contained file (`public/index.html`), no build step. Cloudflare Pages project `nibble`, production = branch `main`, live at nibble-45j.pages.dev. Deploys are **manual** via `./deploy.sh` (not push-triggered); each machine needs a one-time `wrangler login`.
- `deploy.sh` stamps release-coupled numbers into the **staging copy** at deploy time, fetched from the latest GitHub release of `ben0128/nibble`: the version and the zip download size in KB. Four stamped patterns in `index.html`:
  - `"softwareVersion": "X.Y.Z"` (JSON-LD)
  - `Nibble doctor vX.Y.Z` (terminal mockup)
  - `A NNN KB download as of vX.Y.Z` (size note)
  - `class="after-label">NNN KB<` (the Nibble bar in the compare chart)
- After stamping, the script greps each pattern and **aborts the deploy if one didn't land**. Rewording any of those strings therefore requires updating the sed patterns in `deploy.sh` in the same change.
- The committed `index.html` keeps the last-stamped values — it stays a complete, readable page; stamping never dirties the git worktree.

## Coupling to nibble releases

Shipping a nibble release (`git tag vX.Y.Z && git push --tags` over there) builds the universal app, uploads the zip, and bumps the Homebrew tap automatically — then run `./deploy.sh` here so the site's numbers follow. The install command shown on the site is the cask (`brew install --cask nibble`), which delivers CLI + menu bar app with no Swift toolchain requirement.

Numbers deploy.sh does **not** stamp are maintained by hand and must be measured, not remembered: per-arch binary size (`lipo -detailed_info` on the release binary), the test count in the "Nothing to take on faith" card (`make test` prints it as N checks), and the G HUB / Options+ comparison sizes.

## Platform status (Windows / Linux)

- Windows shows **β beta** (hero chip + platform row + amber note in `#install`): the port is built and CI-tested, but not yet validated against a real mouse. **The page carries no Windows install command on purpose** — the main repo's release gate (`windows/scoop/nibble.json`, `windows/spike/README.md` §5) says nothing ships to a package manager before touching real hardware.
- When `win-v0.1.0` actually ships: swap the beta badge to shipping, add the Scoop install command, and consider widening JSON-LD `operatingSystem` (kept `macOS`-only until a Windows release exists, to avoid advertising a download that isn't there).
- Linux stays "coming soon" — the protocol core is OS-free; a port is one transport file (hidraw).

## Copy & design guidelines

- Clean and simple, English-only copy, dark terminal aesthetic. Don't add decorative animation beyond the existing typing demo unless asked.
- Honest voice, concrete verified numbers, no marketing superlatives. Platform claims distinguish "shipping" / "beta" / "coming soon" and say what beta means.
- A shelved 3D scroll-landing experiment ("scroll-world") has prompt assets only on Ben's MacBook in `landing-work/` (gitignored) — don't recreate it unprompted.

## SEO / assets

- `canonical`, `robots.txt`, `sitemap.xml`, og/twitter tags and JSON-LD all hardcode `nibble-45j.pages.dev` — moving to a custom domain means updating every one of them.
- `og.jpg` (1200×630) is drawn by `og.swift` (CoreGraphics, no dependencies); regenerate it there rather than editing the image.

## Working conventions (cross-machine)

- Ben develops from multiple machines and parallel sessions. Deploys are manual, so the live site tracks whoever deployed last: **pull before editing, push after committing, and redeploy after content changes.** An unpushed local commit once caused a deploy from another machine to revert the live Windows-beta copy (2026-07-27).
- Reply to the maintainer in Traditional Chinese; keep technical terms in English.
