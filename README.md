# nibble-site

Landing page for [Nibble](https://github.com/ben0128/nibble) — under-1-MB zero-dependency Logitech mouse control for macOS.

**Live:** [nibble-45j.pages.dev](https://nibble-45j.pages.dev) (Cloudflare Pages, project `nibble`)

## Structure

- `public/index.html` — the whole site: one self-contained file, no build step, no dependencies

## Deploy

```sh
./deploy.sh   # needs wrangler (npm i -g wrangler) and a one-time `wrangler login`
```

Deploys `public/` through a clean staging copy so wrangler's `.wrangler/` cache
(it contains the Cloudflare account id) never ends up in the upload.

At deploy time the script also stamps the latest GitHub release's version and
zip size into the staged `index.html` — three spots: JSON-LD `softwareVersion`,
the `Nibble doctor vX.Y.Z` mockup line, and the "A NNN KB download as of
vX.Y.Z" size note — then greps that every stamp landed and aborts the deploy on
a miss. If you reword any of those three strings, update the sed patterns in
`deploy.sh` in the same change. The committed `index.html` keeps the
last-stamped values, so it stays a complete page on its own.

## License

MIT
