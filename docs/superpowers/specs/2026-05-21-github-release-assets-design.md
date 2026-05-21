# GitHub Release Assets Design

**Goal:** Replace the old local-only / legacy cloud remnants with a GitHub Releases based asset distribution system that keeps the shipped app small, bundles only `TB` and `KR`, supports encrypted downloadable Bible and hymnal assets, and gives users explicit install/update/delete/cache controls in Settings.

## Approved Product Decisions

- Use a public GitHub repository with encrypted release assets.
- Default repository target: `ThenGB/GYSApp-Data`.
- Keep only `b_tb` and `KR` bundled with the app.
- Deliver other Bible versions from GitHub Releases.
- Deliver other hymnals from GitHub Releases.
- Downloaded assets stay available offline.
- “Delete cache” must remove fast-access caches without deleting installed versions.
- After download finishes, perform the local processing needed for fast later access.
- After cache deletion, installed assets should rebuild their fast-access state on later use.
- Keep only the `e.gys` login flow. Remove legacy Google sign-in / Google Drive backup integration from the app code.

## Architecture

### 1. Asset Catalog And Release Metadata

The app will treat Bible and hymnal assets as catalog items with a stable code, title, type, bundled status, and optional release-backed package metadata. Two release tracks are used:

- `bibles-*` releases contain Bible packages.
- `hymnals-*` releases contain hymnal packages.

Each release exposes a manifest JSON asset describing:

- release tag
- published timestamp
- supported app version floor
- package entries
- per-package version
- encrypted package filename
- package size
- package checksum
- installed output filename

The app will query GitHub’s release API, select the newest release for each track, download the manifest, and compare remote versions against local registry state.

### 2. Installed Asset Registry

Installed versions cannot live only in temporary cache locations because cache deletion must not remove downloaded Bible or hymnal content. A file-backed registry in app support storage will track:

- installed package version per asset code
- source file path for installed assets
- originating release tag
- checksum
- install timestamp
- whether the asset is bundled-only or downloaded

Bundled assets (`b_tb`, `KR`) remain usable even if no registry record exists.

### 3. Storage Layout

Separate installed source assets from disposable cache:

- installed Bible DBs: app support `installed_assets/bible/`
- installed hymnal master PDFs: app support `installed_assets/hymnal/`
- downloaded encrypted temp packages: app cache / temp
- prepared bundled master PDFs: existing fast-access cache directory
- PDF note extraction cache: temp cache
- MIDI render cache: existing song render cache

This lets “Delete cache” clear preparation artifacts while preserving installed versions.

### 4. Encryption / Packaging

GitHub release files are public, so the protection model is app-side encrypted packages plus in-app decryption. This is deterrence, not perfect secrecy.

Package format:

- original file compressed into an archive when useful
- encrypted binary payload
- package header with format version and IV / metadata

The app downloads a package, verifies checksum, decrypts it locally, extracts the payload, moves the installed file into the persistent install directory, updates the registry, and removes the temporary package.

### 5. Bible Loading

`LocalBibleAssetService` continues to serve bundled `b_tb` directly from assets. `BibleCubit` continues to open non-bundled `.db` files from disk, but the install location changes from disposable cache storage to the persistent installed-assets folder.

Settings will show:

- bundled `TB`
- downloadable `KJV`
- downloadable `CUV`

If a downloaded Bible is removed, `BibleCubit` must stop listing it. If the currently selected Bible is removed, fallback to `b_tb`.

### 6. Hymnal Loading

Song metadata and indices remain bundled. Large hymnal PDFs move to a hybrid model:

- `KR` stays bundled
- other master PDFs are downloaded and stored locally

`LocalAssetService` must resolve a master PDF path from either:

- bundled asset
- installed persistent file

Bundled PDFs still need one-time extraction for fast file-based access. Installed PDFs can be opened directly from their persistent file path and should not show the “first-time preparation” popup used for bundled KR.

### 7. Cache Maintenance

Settings gets a dedicated cache action that clears:

- prepared bundled master PDFs
- PDF note extraction cache
- MIDI render cache
- any temporary downloaded package leftovers

It must not delete:

- installed Bible DBs
- installed hymnal master PDFs
- registry metadata
- user notes / bookmarks / settings

### 8. Settings UX

Add separate sections for:

- Bible downloads
- Hymnal downloads
- Cache maintenance

Each asset row shows status such as:

- Bundled
- Not installed
- Installed
- Update available
- Downloading / Installing
- Failed

Row actions:

- Download
- Update
- Delete

Cache section actions:

- Delete fast-access cache
- Show what is removed vs preserved

### 9. Legacy Auth / Backup Cleanup

The app should no longer expose Google sign-in or Google Drive backup flows. The remaining login entry point is the `e.gys` web flow. Local backup import/export can remain if it is purely file-based; cloud backup UI and DI bindings tied to Google must be removed.

## Error Handling

- No internet: keep installed assets usable and show offline status for update checks.
- Manifest missing or malformed: keep current installed assets and show a recoverable error in settings.
- Checksum / decrypt failure: fail installation and delete partial files.
- Delete currently selected Bible: switch back to `b_tb`.
- Delete currently selected hymnal source: keep indices, but switch visible book back to `KR` if needed.

## Testing Strategy

- release manifest parsing and latest-release selection
- registry persistence and deletion rules
- Bible install path / list visibility
- hymnal local path resolution for bundled vs installed masters
- cache deletion preserving installed assets
- settings actions and fallback behavior when selected assets are deleted
- source hygiene test updates for removed Google backup wiring and reduced bundled PDF assets
