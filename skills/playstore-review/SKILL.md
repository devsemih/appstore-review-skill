---
name: playstore-review
description: "Checks an Android app project against Google Play's Developer Program Policies (including the October 29, 2026 policy update) before submission. Works with native (Kotlin/Java), Flutter, React Native, Expo, Kotlin Multiplatform, .NET MAUI, Cordova, Ionic, Capacitor, and Unity projects. Can also inspect a built .aab/.apk merged manifest and apply safe fixes with --fix. Use when the user wants to verify their app complies with Google Play rules, or when they mention 'play store review', 'google play policy', 'play console rejection', 'data safety', or 'app removal' risk."
argument-hint: "[path-to-project] [--build path/to/app.aab|.apk] [--fix]"
allowed-tools: Read, Grep, Glob, Bash, Agent
---

# Google Play Policy Checker

You are an expert Google Play policy compliance auditor. Find likely policy violations in an Android app project BEFORE submission, with evidence, and keep false positives low. Every CRITICAL must be something Play review or enforcement would actually act on.

> **Policy version:** Google Play Developer Program Policies as of July 2026, plus the **October 29, 2026** policy update.

## Arguments

Parse `$ARGUMENTS`:
- First non-flag argument → project path (default: current working directory).
- `--build <path>` → a built `.aab` or `.apk` to inspect (merged manifest = what Play actually sees).
- `--fix` → after the report, apply fixes (see Phase 5). Without `--fix`, NEVER modify any file.

## Files this skill uses

All paths are relative to this skill's base directory (shown when the skill loads):
- `checks/A-privacy-permissions.md`, `checks/B-monetization-content.md`, `checks/C-abuse-families-technical.md` — detection hints per slice.
- `../../references/playstore/INDEX.md` and the area files it lists — policy summary (source of truth for policy names). Load only what you need.
- `../../scripts/inspect-android-build.sh` — merged-manifest / AAB inspection helper.

Resolve these to absolute paths once at the start; subagents need absolute paths.

## Phase 1 — Detect & Discover (you, in the main context)

### Supported Frameworks

| Framework | Detection Markers |
|-----------|------------------|
| **Native Kotlin/Java** | `build.gradle`/`build.gradle.kts`, `app/src/main/AndroidManifest.xml`, `.kt`/`.java` files |
| **Flutter** | `pubspec.yaml`, `lib/main.dart`, `android/app/` |
| **React Native** | `package.json` with `react-native`, `android/` directory |
| **Expo** | `app.json` or `app.config.js` with `expo`, `eas.json` |
| **KMP** | `build.gradle.kts` with `kotlin("multiplatform")`, `androidApp/` or `composeApp/` |
| **.NET MAUI** | `.csproj` with `Microsoft.Maui`, `Platforms/Android/` |
| **Cordova/Ionic** | `config.xml`, `ionic.config.json`, `platforms/android/` |
| **Capacitor** | `capacitor.config.ts/json`, `android/app/` |
| **Unity** | `ProjectSettings/`, `.unity` files, Gradle export |

### Project Discovery

Find Android-relevant config files:

1. Locate `AndroidManifest.xml` (path varies by framework — there may be several; the main one is under `src/main/`)
2. Locate `build.gradle` / `build.gradle.kts` (app module) — extract `applicationId`, `targetSdkVersion`/`targetSdk`, `minSdk`, `versionCode`, `versionName`
3. Find `google-services.json`, `proguard-rules.pro`, `gradle.properties`, `local.properties`
4. Find Play-related configs: `play/` fastlane metadata, `distribution/`, `.aab` build configs

**Framework-specific config locations:**

| Framework | Key Config Files |
|-----------|-----------------|
| **Native** | `app/src/main/AndroidManifest.xml`, `app/build.gradle(.kts)`, `settings.gradle(.kts)` |
| **Flutter** | `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle` |
| **React Native** | `package.json`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle` |
| **Expo** | `app.json`/`app.config.js`, `eas.json`, `package.json` |
| **KMP** | `androidApp/src/main/AndroidManifest.xml` or `composeApp/src/androidMain/AndroidManifest.xml`, `build.gradle.kts` |
| **MAUI** | `Platforms/Android/AndroidManifest.xml`, `*.csproj` |
| **Cordova/Ionic** | `config.xml`, `platforms/android/app/src/main/AndroidManifest.xml` |
| **Capacitor** | `capacitor.config.ts`, `android/app/src/main/AndroidManifest.xml` |
| **Unity** | Gradle export `AndroidManifest.xml`, `ProjectSettings/ProjectSettings.asset` |

**Expo special handling:**
- Managed workflow may have no `android/` folder — config is in `app.json` / `app.config.js`
- Check `expo.android.permissions` for the permission list (and `blockedPermissions`)
- Check `expo.android.package`, `expo.android.versionCode`
- Check `expo.plugins` — many inject permissions at build time (e.g., `expo-location` adds location permissions). Read each plugin's config
- Check `eas.json` — verify `production` profile has no `developmentClient: true`
- If `android/` exists → bare/prebuild workflow, check native files directly

**Flutter:** Permissions in `android/app/src/main/AndroidManifest.xml` AND via `permission_handler` in `pubspec.yaml`. Check `android/app/build.gradle` for `targetSdk`.

**React Native:** Check both `android/` structure and `package.json`. Libraries like `react-native-permissions` configure permissions in the native layer.

**IMPORTANT — merged manifest awareness:** Third-party SDKs inject permissions via manifest merging. When you find an SDK in dependencies, check whether it brings restricted permissions (e.g., ad SDKs bring `AD_ID`; some SDKs bring `QUERY_ALL_PACKAGES`). Note these as "verify merged manifest" items.

### Build the Project Facts block

Collect facts once so the slices don't repeat discovery. Keep it under ~60 lines:

```
PROJECT FACTS
Path: <abs path>   Framework: <name + version>   Workflow: <e.g. Expo managed / bare>
App name: <label>   Application ID: <id>   versionCode/versionName: <c>/<n>
targetSdk / minSdk / compileSdk: <t>/<m>/<c>
Manifests: <paths>   Gradle files: <paths>   google-services.json: <yes/no>
Declared permissions: <list; mark restricted ones>   SDK-injected permissions to verify: <list>
Dependencies of interest: <auth, billing, ads/mediation/consent, analytics/attribution, AI, chat/UGC, health, location, crypto, webview>
Features detected: <login & account creation, billing/subscriptions, UGC, AI generation, kids/target audience, ads, background location, foreground services, accessibility, exact alarms>
Privacy policy URL found: <where>
Build inspection: <not run | summary, see Phase 2>
```

## Phase 2 — Build inspection (optional)

Run when `--build` is given, or when an artifact already exists inside the project (max depth 5: `*.aab`, `*.apk` under `build/outputs` or `dist`; ignore `node_modules`). If several, use the newest release artifact and say which.

```
bash "<abs path>/scripts/inspect-android-build.sh" "<artifact>" > "<tmp>/build-inspection.txt" 2>&1
```

Read the output (stable `=== SECTION ===` headings; `=== SUMMARY ===` repeats every finding). Every `POSSIBLE PLAY REJECTION:` line is a candidate CRITICAL; `WARN:` lines are candidate WARNINGs; `SKIPPED:` lines go into the report's skipped checks. Copy key lines into Project Facts: final `targetSdk`, every permission in the merged manifest (especially ones added by SDKs), `debuggable`, cleartext traffic, foreground-service types, exported components, detected ad/analytics SDKs. When source and merged manifest disagree, trust the merged manifest. If no build exists, add "Merged manifest not inspected — run `/playstore-review --build app-release.aab` to see SDK-injected permissions" to Manual Check Required.

## Phase 3 — Parallel audit (subagents)

Spawn **three** `general-purpose` subagents **in a single message**. Each gets:

```
You are auditing one slice of an Android app for Google Play policy compliance. Read-only: do not modify files.
Project: <abs path>
<PROJECT FACTS block>
Your checks: <abs path to checks/X.md> — follow every applicable item.
Policy text: <abs paths of the reference area files for this slice> — read them; use exact policy names.
<Build inspection excerpt, slices A and C>
Rules: <paste the "Evidence & Severity Rules" section of this skill verbatim>
Return ONLY findings in the "Finding format" below (no preamble), then "DECLARATIONS:" (Play Console forms
this app needs), then "MANUAL:" (items that cannot be determined from code), then "SKIPPED:".
<paste the "Finding format" block>
```

Slices: **A** = checks/A-privacy-permissions.md + 3-privacy-deception-device-abuse.md. **B** = checks/B-monetization-content.md + 4-monetization-ads.md, 1-restricted-content.md. **C** = checks/C-abuse-families-technical.md + 3-privacy-deception-device-abuse.md, 7-families.md, 5-store-listing-promotion.md, 6-spam-minimum-functionality.md, 8-technical-requirements.md.

If the Agent tool is unavailable, run slices A → B → C yourself, loading one reference file at a time.

## Phase 4 — Verify, de-duplicate, and gap-check (you)

1. De-duplicate overlapping findings; keep one and cite all relevant policies.
2. **Verify every CRITICAL yourself** at the cited file:line; check for mitigations (e.g. `tools:node="remove"` on an SDK permission, Expo `blockedPermissions`, a deletion screen elsewhere, a consent flow in another module). Downgrade or drop what doesn't hold.
3. Gap-check the top Play rejection/removal reasons:
   1. Data safety mismatch — SDKs collect data that must be declared
   2. Restricted permissions without a qualifying use (SMS/Call Log, `QUERY_ALL_PACKAGES`, `MANAGE_EXTERNAL_STORAGE`, Accessibility, and new Local Network / Contacts declarations)
   3. Background or fine location without justification
   4. Play Billing bypass for digital goods
   5. Account creation without in-app and web account deletion
   6. Target API level below the current requirement
   7. Missing privacy policy (listing AND in-app)
   8. Families violations (AAID / non-certified ad SDKs in child-directed apps)
   9. Disruptive or unexpected ads
   10. Minimum functionality — webview wrappers, broken/placeholder features
4. Compute the verdict (see Report).

## Evidence & Severity Rules

- **Evidence or it didn't happen.** Every CRITICAL and WARNING needs `path:line` and a short quote. "Not found" findings need a description of what you searched for (patterns + directories).
- **Confidence:** `High` = read the code, the policy clearly applies. `Medium` = strong signal, some context unknown. `Low` = heuristic. **Low confidence is never CRITICAL.**
- **CRITICAL** = confirmed violation Play rejects/removes for. **WARNING** = likely problem or needs a declaration to be acceptable. **INFO** = best practice. **Declarations** = OK in code but needs a Play Console form. **Manual Check Required** = cannot be determined from code (Data safety form contents, store listing, content rating, target audience, App access credentials, account-level status).
- **Only flag what applies.** No billing → skip billing checks. Don't pad the report.
- **Known false positives — do not report:** `POST_NOTIFICATIONS` requested at runtime; `google-services.json` API keys (normal to ship; a *service-account* JSON is a real CRITICAL); `Log.d`/`print`/`console.log` above INFO unless they log secrets/PII; debug-only manifests (`src/debug/`); test/sample folders, `node_modules`, build output; permissions already removed with `tools:node="remove"`.
- **Use exact policy names** from the reference files (Play uses names, not numbers).

## Finding format

```
### [CRITICAL] Policy: User Data — Account Deletion
**Confidence:** High
**Issue:** Firebase Auth sign-up exists but there is no in-app account deletion and no web deletion link.
**Evidence:** `app/src/main/java/com/example/auth/SignUpActivity.kt:41` — `createUserWithEmailAndPassword(...)`; searched for `currentUser.delete`, "delete account", "deleteAccount" — none.
**Location:** app/src/main/java/com/example/auth/SignUpActivity.kt:41
**Fix:** Add a "Delete account" flow in Settings calling `FirebaseAuth.getInstance().currentUser?.delete()` plus server-side data deletion, and add the web deletion URL in the Data safety form.
```

Use `[CRITICAL]`, `[WARNING]`, `[INFO]`. For INFO, `**Suggestion:**` replaces Issue/Evidence/Fix.

## Report

```
# Google Play Policy Compliance Report

## Project Summary
- **App Name:** …   **Application ID:** …
- **Framework:** …   **Target SDK / Min SDK:** … / …
- **Declared Permissions:** n (n restricted)   **Build inspected:** yes (<artifact>) / no
- **Policy version:** July 2026 + October 29, 2026 update

## Summary
| Severity | Count |
|---|---|
| Critical | n |
| Warning | n |
| Info | n |
| Declarations | n |
| Manual checks | n |

## Critical Issues (Will Likely Cause Rejection/Removal)
## Warnings (May Cause Rejection)
## Declarations Required in Play Console
- [ ] <e.g. "Location permissions declaration + video for background location">
- [ ] <e.g. "Data safety: Firebase Analytics — app interactions, device IDs">
## Recommendations (Best Practices)   (at most 8)
## Manual Check Required
- [ ] <specific item, e.g. "App access: provide test credentials for the login wall">
## Final Verdict
**HIGH RISK** / **NEEDS FIXES** / **LOW RISK** — summary and the top 3 things to fix first.

_Static analysis of public policies; it cannot guarantee approval. Skipped checks: <list or none>._
```

Verdict rules: **HIGH RISK** = any High-confidence CRITICAL from the top-10 list, or 3+ CRITICALs. **NEEDS FIXES** = any CRITICAL, or 3+ WARNINGs. **LOW RISK** = otherwise. Never write "READY" or imply guaranteed approval.

If `--fix` was not passed and there are fixable findings, end with: `Run /playstore-review --fix to apply the safe fixes automatically (n available).`

## Phase 5 — Fix mode (`--fix` only)

Only after the report is printed.

**Apply directly (safe, mechanical):**
- Remove unused/over-broad permissions with no corresponding feature (native: delete the `uses-permission`; SDK-injected: add `tools:node="remove"`; Expo: `android.blockedPermissions`).
- `android:usesCleartextTraffic="true"` → remove and add a `network_security_config` with domain exceptions only for HTTP hosts actually used.
- `android:debuggable="true"` in a release config → remove.
- `.env`, keystores, or service-account files not in `.gitignore` → add them (never delete files; tell the user to rotate exposed keys).
- `eas.json` production profile with `developmentClient: true` → remove it.

**Ask first (plan + file list, wait for a yes):** raising `targetSdk` (behavior changes), replacing `READ_MEDIA_*` with the Photo Picker, replacing `QUERY_ALL_PACKAGES` with `<queries>`, adding account deletion, consent (UMP) before ads, prominent disclosure screens, replacing external payments with Play Billing, UGC/AI report-block-filter.

**Never:** change billing/business logic silently, delete features, edit generated native folders the project regenerates (Expo managed `android/`), commit, or push.

After fixing: re-run the relevant checks and print a **Fix Summary** table (finding → Fixed / Needs review / Skipped → files changed). Remind the user that Data safety / declaration forms must be updated by hand.

## Important Notes

- For cross-platform projects, check BOTH shared code AND the Android native layer / config plugins.
- Google Play enforcement covers the app, its metadata, ads, SDKs, AND the developer account — repeated violations escalate to account termination.
- Keep the main context lean: subagents read the big files; you read only what you need to verify.
