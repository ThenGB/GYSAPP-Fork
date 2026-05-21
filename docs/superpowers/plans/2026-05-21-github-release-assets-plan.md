# GitHub Release Assets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add encrypted GitHub Releases based Bible and hymnal distribution, bundle only `b_tb` and `KR`, expose install/update/delete/cache controls in Settings, and remove the remaining Google auth/backup wiring.

**Architecture:** Introduce a small asset-management layer made of a release client, package installer, persistent installed-asset registry, and cache maintenance service. Update Bible and hymnal loaders to resolve content from bundled assets or persistent installed files, then wire the resulting status/actions into Settings.

**Tech Stack:** Flutter, Dio, Hydrated Bloc, file IO, path_provider, encrypt, archive, GitHub Releases REST API.

---

### Task 1: Add asset metadata and persistent registry

**Files:**
- Create: `lib/data/services/asset_distribution/models.dart`
- Create: `lib/data/services/asset_distribution/installed_asset_registry.dart`
- Modify: `lib/di/injection.dart`
- Test: `test/installed_asset_registry_test.dart`

- [ ] **Step 1: Write the failing registry persistence test**
- [ ] **Step 2: Run the registry test to verify it fails**
- [ ] **Step 3: Implement file-backed installed asset models and registry storage in app support**
- [ ] **Step 4: Run the registry test to verify it passes**

### Task 2: Add GitHub release manifest client and encrypted package installer

**Files:**
- Create: `lib/data/services/asset_distribution/github_release_asset_client.dart`
- Create: `lib/data/services/asset_distribution/encrypted_asset_package_service.dart`
- Modify: `lib/di/injection.dart`
- Test: `test/github_release_asset_client_test.dart`
- Test: `test/encrypted_asset_package_service_test.dart`

- [ ] **Step 1: Write failing tests for manifest parsing / latest release selection / package decrypt install**
- [ ] **Step 2: Run the new tests to verify they fail**
- [ ] **Step 3: Implement the GitHub release client and encrypted package installer**
- [ ] **Step 4: Run the focused tests to verify they pass**

### Task 3: Teach Bible and hymnal loaders about persistent installed assets

**Files:**
- Modify: `lib/data/services/local_bible_asset_service.dart`
- Modify: `lib/data/services/local_asset_service.dart`
- Modify: `lib/presentations/bible/cubit/bible_cubit.dart`
- Modify: `lib/data/repository/song_repository_impl.dart`
- Test: `test/local_asset_service_test.dart`
- Test: `test/local_bible_asset_service_test.dart` or extend existing tests

- [ ] **Step 1: Write failing tests for installed hymnals resolving from local files and downloaded Bibles appearing as selectable**
- [ ] **Step 2: Run the focused tests to verify they fail**
- [ ] **Step 3: Implement installed-file resolution and persistent Bible DB discovery**
- [ ] **Step 4: Re-run the focused tests to verify they pass**

### Task 4: Add cache maintenance and download orchestration services

**Files:**
- Create: `lib/data/services/asset_distribution/asset_cache_maintenance_service.dart`
- Create: `lib/data/services/asset_distribution/asset_distribution_service.dart`
- Modify: `lib/data/services/pdf_note_service.dart`
- Modify: `lib/di/injection.dart`
- Test: `test/asset_cache_maintenance_service_test.dart`

- [ ] **Step 1: Write failing tests for cache deletion preserving installed assets**
- [ ] **Step 2: Run the cache tests to verify they fail**
- [ ] **Step 3: Implement download/install/delete/update orchestration and cache maintenance**
- [ ] **Step 4: Re-run the cache tests to verify they pass**

### Task 5: Wire settings UI and state

**Files:**
- Create: `lib/presentations/settings/cubit/asset_management_cubit.dart`
- Create: `lib/presentations/settings/cubit/asset_management_state.dart`
- Modify: `lib/presentations/settings/view/settings_view.dart`
- Modify: `lib/presentations/settings/cubit/settings_cubit.dart`
- Modify: `lib/presentations/settings/cubit/settings_state.dart`
- Test: `test/settings_asset_management_test.dart`

- [ ] **Step 1: Write failing tests for asset rows, delete-cache action, and selected-Bible fallback behavior**
- [ ] **Step 2: Run the focused tests to verify they fail**
- [ ] **Step 3: Implement the settings asset sections and action handlers**
- [ ] **Step 4: Re-run the focused tests to verify they pass**

### Task 6: Remove legacy Google sign-in / Drive backup wiring

**Files:**
- Modify: `lib/di/injection.dart`
- Modify: `lib/presentations/auth/cubit/auth_cubit.dart`
- Modify: `lib/presentations/auth/view/login_view.dart`
- Modify: `lib/presentations/settings/view/settings_view.dart`
- Modify: `lib/presentations/backup/cubit/backup_cubit.dart`
- Modify: `lib/presentations/backup/view/backup_view.dart`
- Modify: `lib/data/repository/repository.dart`
- Delete or stop exporting legacy Google repository / backup repository code as appropriate
- Test: `test/source_hygiene_test.dart`

- [ ] **Step 1: Write failing source-hygiene assertions for removed Google sign-in / Drive backup usage**
- [ ] **Step 2: Run the source-hygiene test to verify it fails**
- [ ] **Step 3: Remove the remaining legacy Google auth / backup dependencies and UI**
- [ ] **Step 4: Re-run the source-hygiene test to verify it passes**

### Task 7: Reduce bundled asset footprint and add packaging tooling

**Files:**
- Modify: `pubspec.yaml`
- Create: `tool/asset_distribution/package_release_assets.dart`
- Create: `docs/archive/asset-distribution/README.md`
- Test: `test/source_hygiene_test.dart`

- [ ] **Step 1: Write failing source-hygiene assertions for bundled PDF scope and removed Google packages**
- [ ] **Step 2: Run the source-hygiene test to verify it fails**
- [ ] **Step 3: Limit bundled assets to `b_tb` and `KR`, and add packaging tooling for encrypted GitHub release assets**
- [ ] **Step 4: Re-run the source-hygiene test to verify it passes**

### Task 8: Verify the integrated flow

**Files:**
- Modify as needed based on failures above
- Test: `test/local_asset_service_test.dart`
- Test: `test/home_cubit_logic_test.dart`
- Test: `test/initial_view_logic_test.dart`
- Test: `test/song_view_logic_test.dart`
- Test: `test/source_hygiene_test.dart`

- [ ] **Step 1: Run focused asset, settings, and hygiene tests**
- [ ] **Step 2: Run `flutter analyze`**
- [ ] **Step 3: Fix any regressions and re-run the failing scopes**
- [ ] **Step 4: Document any manual GitHub Release publishing steps that still require account access outside this workspace**
