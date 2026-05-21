# Asset Distribution Packaging

This folder documents the local packaging flow for encrypted GitHub Release assets.

## Source Inputs

- Bible DB sources: `Original Alkitab DB/`
- Hymnal PDF sources: `Original PDF/`

## Generate Packages

```bash
dart run tool/asset_distribution/package_release_assets.dart --version=2026.05.21
```

Output is written under:

```text
build/asset_distribution/<version>/
```

Each track gets:

- encrypted `.gyspkg` files
- one manifest JSON
- SHA-256 checksum metadata per package

## Publish To GitHub Releases

Set a GitHub token with permission to manage releases in `ThenGB/GYSApp-Data`, then run:

```bash
set GITHUB_TOKEN=your_token_here
dart run tool/asset_distribution/publish_release_assets.dart --version=2026.05.21
```

Optional flags:

- `--owner=ThenGB`
- `--repo=GYSApp-Data`
- `--input=build/asset_distribution/2026.05.21`

## GitHub Release Layout

- Bible release tag example: `bibles-2026.05.21`
- Hymnal release tag example: `hymnals-2026.05.21`
- The publish tool creates the release when missing, replaces same-named assets, and uploads the matching manifest file plus all generated packages into `ThenGB/GYSApp-Data`

## Bundling Policy

- App bundle keeps `b_tb` and `KR`
- Remote releases carry the other Bible / hymnal versions
