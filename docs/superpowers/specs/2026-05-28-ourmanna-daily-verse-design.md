# Daily Devotional (OurMannna API) - Design Spec

**Date:** 2026-05-28
**Status:** Approved

## Overview

Replace the hardcoded daily verse on the dashboard with dynamic content from the OurMannna API. If the API fails or returns no data, the verse card will simply not be displayed.

## Architecture

```
HomeCubit
├── todayVerse: String?
├── todayVerseRef: String?
└── fetchTodayVerse()

OurMannnaService
└── GET https://beta.ourmanna.com/api/v1/get
    → Cache for 24 hours
    → Return verse + reference OR null

_DailyVerseCard (home_view.dart)
├── If verse exists → Show card
└── If verse is null → Hide card entirely
```

## API Endpoint

- **URL:** `https://beta.ourmanna.com/api/v1/get`
- **Method:** GET
- **Expected Response:** JSON with `verse` and `reference` fields

## Files to Modify

| File | Change |
|------|--------|
| `lib/data/services/ourmanna_service.dart` | **NEW** - API service |
| `lib/presentations/home/cubit/home_cubit.dart` | Add verse state + fetch method |
| `lib/presentations/home/cubit/home_state.dart` | Add `todayVerse`, `todayVerseRef` |
| `lib/presentations/home/view/home_view.dart` | Update `_DailyVerseCard` to use state |
| `lib/di/injection.dart` | Register `OurMannnaService` |

## Implementation Steps

1. Create `OurMannnaService` with HTTP GET to API endpoint
2. Add caching with `SharedPreferences` (24-hour TTL)
3. Update `HomeState` with nullable verse fields
4. Add `fetchTodayVerse()` to `HomeCubit` (called on init)
5. Update `_DailyVerseCard` to:
   - Show loading state while fetching
   - Display verse if available
   - Return empty widget if verse is null

## Behavior

| Scenario | Result |
|----------|--------|
| API succeeds | Show verse card with text + reference |
| API fails | Hide verse card (no fallback) |
| No internet + no cache | Hide verse card |
| Loading | Show shimmer placeholder |

## No Fallback

The previous hardcoded verse (`Matius 5:8`) will be removed. If API fails, the card simply won't appear on the dashboard.