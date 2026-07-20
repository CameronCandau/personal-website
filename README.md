# Personal Website

Hugo site for `cameroncandau.com`.

## Dev

```bash
hugo server
```

## New Blog Posts

Using `archetypes/`:

Nightly post:

```bash
hugo new --kind nightly blog/nightly/my-post/index.md
```

Stable post:

```bash
hugo new --kind stable blog/stable/my-post/index.md
```

## Cover Images

Procedural SVG generation for posts.

Generate one:

```bash
scripts/generate-cover-svg.sh 'foo' content/blog/nightly/foo/cover.svg
```

Recommended post layout:

```text
content/blog/nightly/x-http-headers/
  index.md
  cover.svg
```

## Theme Color Mapping

The cover generator uses colors from `assets/css/schemes/mint-technical.css`:

- Background: `--color-neutral-900` (`#181825`)
- Text gradient start: `--color-primary-300` (`#a6e3a1`)
- Text gradient middle: `--color-primary-500` (`#76b972`)
- Text gradient end: `--color-secondary-500` (`#62b7ae`)

## TODO
### Blog Posts
- Tailscale OAuth with Zitadel / Entra
- Firefox profiles and global config
- Filtering content and distractions
	- Ublock origin
	- DNS filtering
	- https://bloom.inc/
	- [iOS](https://support.apple.com/guide/deployment/filter-content-dep1129ff8d2/web)
- Email deliverability
- Nixpkgs contribution
- OSCP vibecoded tools (OpIndex, payload-server, artifact-locker)
- thoughts on AI usage, productivity, and what it means to learn