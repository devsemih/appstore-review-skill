# Checks C — Device Abuse, Deception, Families, Store Listing & Technical

Check instructions for one slice of the `/playstore-review` audit. Use with the **Project Facts** you were given and the policy text in `3-privacy-deception-device-abuse.md (Device & Network Abuse, Deceptive Behavior, Malware sections), 7-families.md, 5-store-listing-promotion.md, 6-spam-minimum-functionality.md, 8-technical-requirements.md` (under the plugin's `references/playstore/`). Report findings in the exact finding format and evidence rules you were given. These are *detection hints*, not verdicts: a grep hit is only a finding once you have read the surrounding code / merged manifest context and confirmed it applies.

## Device & Network Abuse / Deceptive Behavior Checks

**Dynamic code loading (mirror of Apple 2.5.2, stricter on Play):**
- Apps must NOT download/execute executable code (dex, JAR, .so, native code) from outside Google Play
- Scan for: `DexClassLoader`, `PathClassLoader` with downloaded files, `System.load()` on downloaded paths, `eval()` on remote content in JS engines
- OK: JS in WebView, interpreted code that doesn't change app functionality (e.g., React Native OTA like CodePush/expo-updates is tolerated only for JS bundles consistent with Play policy — flag native-code hot patching)

**Interference with other apps / system:**
- Scan for: killing other apps' processes, modifying system settings without consent, blocking uninstall
- Overlay abuse: `TYPE_APPLICATION_OVERLAY` windows covering other apps

**Ad fraud patterns:**
- Background ad loading, click injection (`MotionEvent` synthesis on ad views), install attribution manipulation

**Deceptive Behavior / Misrepresentation:**
- App must function as described — flag "beta", "test", "coming soon" placeholder screens in production
- Scan for fake system dialogs, fake virus alerts, fake cleaner/booster claims
- Hidden functionality: feature flags themselves are fine — flag only flags that unlock undisclosed behavior post-review (reviewer/test-environment detection, Remote Config gating entire hidden features, date/geo-based unlocks)
- **Review manipulation (clarified October 2026):** any behavior that manipulates the app review process (reviewer detection, serving different content to reviewers, cloaking) → CRITICAL
- **AppFunctions (new October 2026):** if the app exposes Android AppFunctions (`androidx.appfunctions`, `@AppFunction`), they must not deceive or manipulate AI agents, bypass security controls, or interfere with other apps — verify function descriptions match behavior

**Malware / MUwS basics:**
- Scan for: SMS premium sending, hidden device admin (`DeviceAdminReceiver` without user-facing purpose), root exploitation, keylogging patterns, apps hiding their icon (`setComponentEnabledSetting` disabling launcher activity)
- If the app has monitoring features (parental control, employee monitoring): verify `IsMonitoringTool` metadata flag in manifest, persistent notification while monitoring, and no covert-tracking marketing — covert partner/adult tracking is banned (stalkerware)

## Families & Kids Checks

- Determine target audience: check Play metadata configs, strings like "for kids", "for children", cartoon-branded assets, `isDesignedForFamilies` markers
- If app targets children (or mixed audience):
  - NO advertising ID: `AD_ID` permission must be absent/removed for child audiences
  - Only Families Self-Certified Ads SDKs allowed (AdMob with `setTagForChildDirectedTreatment`, configured mediation) — flag non-certified ad SDKs
  - No interest-based ads / remarketing to children
  - Verify `setTagForChildDirectedTreatment(true)` / `tagForChildDirectedTreatment` / `COPPA` config in ad SDK init
  - No location permissions for child-directed apps
  - No social features requiring personal info without parental consent
  - Mixed audience → neutral age screen required (date-of-birth picker that doesn't encourage lying)
  - In-app purchases must not deceive kids ("buy now!" pressure) — verify purchase flows are parent-gated where appropriate
- Check content rating questionnaire hints (IARC) — note as manual check in Play Console

## Store Listing, Spam & Technical Requirements

**Target API level (hard technical gate):**
- Read `targetSdk` from build config. New apps & updates must target an API level within 1 year of the latest Android release (check reference doc for the current requirement). Flag if below
- `minSdk` extremely low (< 21) → note maintenance/compatibility warning only
- **Play Console items (Manual Check Required):** trader status declaration (required from November 2026), Japan payments authorization (deadline December 1, 2026, if selling into/out of Japan), new memory and code-optimization quality thresholds (deadline February 2027)
- **Play Age Signals API:** if the app has age-dependent features (UGC, dating, gambling-like mechanics, mature content), recommend Play Age Signals as INFO

**Metadata policy:**
- Check fastlane metadata / store listing files if present (`fastlane/metadata/android/`): 
  - Title ≤ 30 chars, no emoji/emoticons/ALL CAPS (unless brand), no "best", "#1", "free", "sale" style promo in title
  - No competitor names / keyword stuffing in description
- Check app name in `strings.xml` (`app_name`) for the same issues

**Spam & Minimum Functionality:**
- Detect webview-wrapper apps: single `WebView`/`CustomTabsIntent` around a website with no native features → minimum functionality violation
- Flag template-generated app markers (AppsGeyser etc.)
- Verify app has actual functionality: activities beyond splash + webview
- Broken functionality: TODO/FIXME placeholders in user-facing flows, "Lorem ipsum" strings, dead buttons

**App must not resemble/impersonate:**
- Check `applicationId` and app name for trademark issues (other brands, "WhatsApp", "TikTok" etc. in name/id)
- Check launcher icon assets for copied brand assets — note as manual check

**Debug/test hygiene:**
- `android:debuggable="true"` in manifest release config → CRITICAL
- `android:usesCleartextTraffic="true"` or missing network security config with HTTP URLs → flag
- Scan for `Log.d`/`Log.v`/`print()`/`console.log` with sensitive data, staging/localhost URLs (`10.0.2.2`, `localhost`)
- Hardcoded secrets: scan `.kt`/`.java`/`.dart`/`.ts`/`.js`/`.cs` and `gradle.properties`, `local.properties`, `.env` for `apiKey`, `secret`, `password`, `token`, `Bearer`
- Keystore files (`.jks`, `.keystore`) committed to repo → CRITICAL security issue
- `google-services.json` exposed keys → note (normal to ship, but check for service-account JSON which must NEVER be in the app)
