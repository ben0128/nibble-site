# nibble-site

Landing page for [Nibble](https://github.com/ben0128/nibble) — 530 KB zero-dependency Logitech mouse control for macOS.

**Live:** [nibble-45j.pages.dev](https://nibble-45j.pages.dev) (Cloudflare Pages, project `nibble`)

## Structure

- `public/index.html` — the whole site: one self-contained file, no build step, no dependencies

## Deploy

```sh
./deploy.sh   # needs wrangler (npm i -g wrangler) and a one-time `wrangler login`
```

Deploys `public/` through a clean staging copy so wrangler's `.wrangler/` cache
(it contains the Cloudflare account id) never ends up in the upload.

## License

MIT
