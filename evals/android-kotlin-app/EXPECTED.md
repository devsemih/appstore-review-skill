# Answer key: android-kotlin-app ("StrideClub")

Native Kotlin Android app (views, no Compose): Firebase Auth/Firestore/Storage, AdMob + UMP, Fused Location + WorkManager. Audited with `/playstore-review`.

## Planted violations (should be reported)

| # | Grader | Policy | Where | What |
|---|--------|--------|-------|------|
| 1 | `recall-target-sdk` | Target API level | `app/build.gradle.kts` | `targetSdk = 33` (Play requires 35 now, 36 from 2026-08-31) |
| 2 | `recall-query-all-packages` | Package visibility (restricted permission) | `AndroidManifest.xml`, `tracking/PartnerApps.kt` | `QUERY_ALL_PACKAGES` just to detect Strava. Should be `<queries><package android:name="com.strava"/></queries>` |
| 3 | `recall-background-location-disclosure` | Location permissions / prominent disclosure | `AndroidManifest.xml`, `settings/SettingsActivity.kt`, `tracking/AutoTrackScheduler.kt` | `ACCESS_BACKGROUND_LOCATION` requested right after foreground grant with no disclosure dialog. Worker samples location every 15 min |
| 4 | `recall-read-media-images` | Photo & video permissions | `AndroidManifest.xml`, `profile/ProfileActivity.kt` | `READ_MEDIA_IMAGES` for a one-off avatar pick. Should use the photo picker (`PickVisualMedia`) |
| 5 | `recall-account-deletion` | User Data: account deletion | `auth/SignUpActivity.kt`, `settings/SettingsActivity.kt` | Firebase signup; no in-app deletion, no web link |
| 6 | `recall-ads-before-consent` | Ads / EU user consent | `StrideApp.kt`, `MainActivity.kt` | `MobileAds.initialize()` in `Application.onCreate` and banner loaded before `gatherConsent()` |
| 7 | `recall-cleartext-traffic` | Security / data in transit | `AndroidManifest.xml` | `android:usesCleartextTraffic="true"` |

Verdict check (`verdict-not-low-risk`): NEEDS FIXES or HIGH RISK.

## Decoys (must NOT be CRITICAL/WARNING)

| Grader | What | Why it's fine |
|--------|------|---------------|
| `no-fp-post-notifications` | `POST_NOTIFICATIONS` requested at runtime on API 33+ after a rationale dialog (`MainActivity.maybeAskForNotifications`) | Correct runtime flow |

## Neutral (not graded)

- Test AdMob IDs. No `google-services.json` in the fixture.
- `allowBackup="true"` (a common best-practice note).
