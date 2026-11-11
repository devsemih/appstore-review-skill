# Checks A — Privacy, User Data & Permissions

Check instructions for one slice of the `/playstore-review` audit. Use with the **Project Facts** you were given and the policy text in `3-privacy-deception-device-abuse.md` (under the plugin's `references/playstore/`). Report findings in the exact finding format and evidence rules you were given. These are *detection hints*, not verdicts: a grep hit is only a finding once you have read the surrounding code / merged manifest context and confirmed it applies.

## Privacy & User Data Checks

**User Data — Privacy Policy:**
- Search for "privacy policy", "privacyPolicy" URL in code/config/settings screens
- The privacy policy must be linked BOTH in the Play Console store listing AND inside the app — verify an in-app link exists
- Verify the URL is HTTPS and not a placeholder

**Data safety section consistency (top removal reason):**
- Inventory every data-collecting SDK in dependencies:
  - Flutter: `firebase_analytics`, `google_mobile_ads`, `facebook_app_events`, `amplitude_flutter`, `mixpanel_flutter`, `appsflyer_sdk`, `adjust_sdk`, `sentry_flutter`
  - RN/Expo: `@react-native-firebase/analytics`, `react-native-google-mobile-ads`, `react-native-fbsdk-next`, `react-native-appsflyer`, `@amplitude/react-native`, `@sentry/react-native`, `expo-tracking-transparency`
  - Native: Firebase Analytics, GMA SDK, Facebook SDK, AppsFlyer, Adjust, Amplitude, Mixpanel, Sentry, Crashlytics
- Output the list as "must be declared in Data safety form" — mismatches between actual collection and the Data safety form cause removal
- Check for crash reporting (Crashlytics, Sentry) → crash logs + device IDs must be declared

**Prominent Disclosure & Consent:**
- If personal/sensitive data (location, contacts, phone, SMS, installed apps, accessibility data) is sent off-device for purposes NOT expected from core functionality, verify a runtime disclosure dialog exists BEFORE the permission request (search for consent/disclosure dialogs near permission request code)
- The disclosure must be in-app (not only in the privacy policy), describe data type + usage, and require affirmative action

**Account deletion (CRITICAL — same as Apple 5.1.1v):**
- If account creation exists (Firebase Auth, Supabase, Auth0, custom signup) → in-app account deletion MUST exist AND a web link for deletion requests must be declared in the Data safety form
- Search for: "delete account", "remove account", "deleteUser", `currentUser?.delete()`, account deletion API calls
- If missing → CRITICAL

**Advertising ID (AAID):**
- Check manifest for `com.google.android.gms.permission.AD_ID` — required on Android 13+ if the app (or any SDK) uses advertising ID
- If ad/analytics SDKs present but `AD_ID` permission not visible, note it's injected via merged manifest
- If the app targets children → `AD_ID` must NOT be used (see Families checks)

## Permissions & Sensitive API Checks

Parse ALL `<uses-permission>` entries from every `AndroidManifest.xml` (and `expo.android.permissions` / `permission_handler` usage). For each restricted permission below, flag it and verify the use case qualifies:

**SMS & Call Log (heavily restricted):**
- `READ_SMS`, `SEND_SMS`, `RECEIVE_SMS`, `READ_CALL_LOG`, `WRITE_CALL_LOG`, `PROCESS_OUTGOING_CALLS`
- Only allowed if the app is the default SMS/phone/assistant handler or in a narrow exception list, WITH an approved Permissions Declaration Form
- If used for OTP verification only → recommend SMS Retriever API / SMS User Consent API instead (no permission needed)
- **From January 27, 2027** account verification via phone call is no longer a permitted `READ_CALL_LOG` use case (October 2026 update) → flag call-log-based phone verification (e.g. missed-call verification SDKs) as WARNING now, CRITICAL after that date

**Local Network & Contacts (new restricted permissions, October 2026 update):**
- Local network access: restricted to apps that need it for core functionality when device pickers are insufficient; apps targeting Android 17+ (API 37+) need a Play Console declaration. Flag local-network permission declarations (and LAN discovery code such as `NsdManager`, mDNS/SSDP, raw sockets to private IP ranges) without a core feature → WARNING + declaration item
- Contacts: Play's "Manage Contacts" permission policy restricts broad contacts access to core-functionality use when system pickers are insufficient, with a declaration; everyone else must use narrowly scoped platform intents (contact picker). Flag `READ_CONTACTS`/`WRITE_CONTACTS` for one-off contact selection → WARNING. Confirm the exact permission names against the policy text in the reference file

**All files access:**
- `MANAGE_EXTERNAL_STORAGE` — only for file managers, antivirus, backup apps with core need + declaration. For most apps → use Storage Access Framework / MediaStore / photo picker
- Broad `READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE` with targetSdk ≥ 30 → flag as legacy

**Package visibility:**
- `QUERY_ALL_PACKAGES` — restricted; only launchers, antivirus, device management, etc. with declaration. Prefer `<queries>` element with specific packages
- Check for `getInstalledApplications`/`getInstalledPackages` usage in code

**Accessibility API:**
- `BIND_ACCESSIBILITY_SERVICE` / `AccessibilityService` subclasses — if NOT for helping users with disabilities, requires declaration and `isAccessibilityTool` handling; using it for automation/overlay/data capture → high removal risk

**Location (minimum-scope policy mandatory January 27, 2027):**
- Apps must use the minimum location scope for their core feature. Apps targeting Android 17 (API 37+) must use the **Android location button** for one-time/infrequent requests. `ACCESS_FINE_LOCATION` requires a Play Console declaration explaining why coarse location or the location button is insufficient → flag fine location used for city-level/one-off features as WARNING + declaration item
- `ACCESS_BACKGROUND_LOCATION` — requires core-feature justification + Play Console declaration + prominent disclosure + video review. Flag ALWAYS
- `ACCESS_FINE_LOCATION` with ad SDKs → verify location isn't shared with ads without consent
- Check foreground alternative: if background location is only for a delivery/tracking style feature while app is in use, recommend foreground service with `location` type instead

**Photos & Videos:**
- `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` — only for apps with broad media access as core functionality (gallery, editor). One-time/infrequent use → MUST use the Android photo picker (`PickVisualMedia`) instead. Flag if these permissions exist alongside simple avatar-upload style features

**Foreground services (targetSdk ≥ 34):**
- Every `<service android:foregroundServiceType=...>` must have a matching `FOREGROUND_SERVICE_<TYPE>` permission and a qualifying use case; `dataSync`/`specialUse` types face Play Console declaration
- Cross-check declared FGS types against actual code usage

**Exact alarms:**
- `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` — `USE_EXACT_ALARM` only for alarm clock/calendar apps. Otherwise use inexact alarms or `SCHEDULE_EXACT_ALARM` with graceful degradation

**Full-screen intent:**
- `USE_FULL_SCREEN_INTENT` — only for high-priority calls/alarms; misuse for ads/engagement → violation

**Other flags:**
- `REQUEST_INSTALL_PACKAGES` — app must not install other apps as a store; declaration required
- `SYSTEM_ALERT_WINDOW` (overlays) — flag if combined with accessibility or used for ads
- VPN: `BIND_VPN_SERVICE` / `VpnService` — must have VPN as core, user consent, no traffic manipulation for ads/fraud; declaration required
- `RECORD_AUDIO` / `CAMERA` while in background → flag

**Minimal-permission principle:** List any permission with no corresponding feature found in code — unused permissions are a violation of the Permissions policy.
