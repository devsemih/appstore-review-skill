# Checks A — Safety (Section 1) & Performance (Section 2)

Check instructions for one slice of the `/appstore-review` audit. Use with the **Project Facts** you were given and the guideline text in `1-safety.md, 2-performance.md` (under the plugin's `references/appstore/`). Report findings in the exact finding format and evidence rules you were given. These are *detection hints*, not verdicts: a grep hit is only a finding once you have read the surrounding code and confirmed it applies.

## Safety Checks (Section 1)

**Guideline 1.1 — Objectionable Content (1.1.1–1.1.7):**
- Scan user-facing strings for offensive content:
  - Native: `Localizable.strings`, `.xcstrings`
  - Flutter: `lib/l10n/`, `*.arb`
  - RN/Expo: `i18n/`, `locales/`, `translations/`
  - MAUI: `Resources/Strings/`
- **(1.1.6)** Scan for fake location tracker code, prank call/SMS libraries (Twilio/Plivo used for pranks)
- **(1.1.7)** Scan strings for references capitalizing on disasters, epidemics, conflicts

**Guideline 1.2 — User-Generated Content (expanded October 2026):**
- Scope now covers ANY app where users create, generate, upload, share, or contribute content: social, UGC platforms, **and AI content creation apps** (image/video/voice/text generation whose output can be saved, shared, or published).
- Detect generative AI: `openai`, `@anthropic-ai/sdk`, `@google/generative-ai` / Firebase Vertex AI / Gemini, `replicate`, `@fal-ai/*`, Stability, ElevenLabs, Runway, Luma, custom `/generate` endpoints. If outputs are shareable or depict people → verify prompt/output filtering, report mechanism, and safeguards against **nonconsensual intimate imagery** (e.g. undress/face-swap of real people). Missing safeguards on such an app → CRITICAL.
- Detect UGC features — search for:
  - Flutter: `firebase_core`, `cloud_firestore`, `stream_chat_flutter`
  - RN/Expo: `react-native-gifted-chat`, Firebase packages
  - Any: Socket.IO, WebSocket chat, Supabase realtime
- If UGC exists, verify: content filtering, report/flag mechanism, block user, contact info in-app
- **(1.2.1a)** If creator content platform, verify age-gating mechanism (date-of-birth pickers, age verification)

**Guideline 1.3 — Kids Category:**
- If app targets kids, verify NO third-party analytics/ad SDKs:
  - Flutter: `google_mobile_ads`, `firebase_analytics`, `facebook_audience_network`
  - RN/Expo: `react-native-google-mobile-ads`, `@react-native-firebase/analytics`
  - Native: `AdSupport.framework`, `ASIdentifierManager`

**Guideline 1.4 — Physical Harm (1.4.1–1.4.5):**
- Detect health/medical features:
  - Flutter: `health`, `flutter_health_connect`
  - RN/Expo: `react-native-health`, `expo-health`
  - Native: `HealthKit`
- **(1.4.1)** If medical app, verify disclaimers exist and methodology is disclosed
- **(1.4.2)** Flag drug dosage calculators — must come from approved entities
- **(1.4.3)** Scan for tobacco/vape/drug/alcohol encouragement in strings
- **(1.4.4)** If DUI checkpoint data, verify law-enforcement source only
- **(1.4.5)** Scan for challenge/bet patterns encouraging risky physical activity

**Guideline 1.5 — Developer Information:**
- Search for "support", "contact", "help" screens or links in code
- For Expo: check support URL in `app.json`

**Guideline 1.6 — Data Security:**
- Check `NSAppTransportSecurity` in Info.plist — flag `NSAllowsArbitraryLoads: YES`
- Scan source files (`.swift`, `.dart`, `.ts`, `.js`, `.kt`, `.cs`) for: `apiKey`, `secret`, `password`, `token`, `API_KEY`, `Bearer`
- Check `.env` files in repo (should be in `.gitignore`)
- Check `google-services.json`, `GoogleService-Info.plist` for exposed keys
- Verify sensitive data uses secure storage:
  - Flutter: `flutter_secure_storage` (not `shared_preferences`)
  - RN: `react-native-keychain` / `expo-secure-store` (not `AsyncStorage`)
  - Native: Keychain (not `UserDefaults`)

**Guideline 1.7 — Reporting Criminal Activity:**
- If app has crime reporting features, verify law enforcement involvement and geo-restriction

## Performance Checks (Section 2)

**Guideline 2.1 + 2.2 — App Completeness & Beta Testing:**
- Search for "beta", "trial", "demo version" in user-facing strings and app name
- **(2.1b)** If IAP product IDs defined (StoreKit config, product arrays), verify fulfillment code exists
- Scan for `TODO`, `FIXME`, `HACK` comments
- Scan for placeholder text: `Lorem ipsum`, `TODO`, `placeholder`
- Scan for debug code (severity: `print`/`console.log` alone → INFO at most, unless it logs secrets/PII → WARNING; localhost/staging URLs reachable in the release configuration → WARNING; never CRITICAL by themselves):
  - Flutter: `kDebugMode`, `print()` | RN/Expo: `__DEV__`, `console.log()` | Native: `#if DEBUG`, `print()`
  - All: `localhost`, `127.0.0.1`, staging/dev URLs

**Guideline 2.3 — Accurate Metadata:**
- Verify required keys in Info.plist / `app.json`:
  - `CFBundleDisplayName`/`CFBundleName`, `CFBundleShortVersionString`, `CFBundleVersion`, `CFBundleIdentifier`
  - Expo: `expo.name`, `expo.version`, `expo.ios.buildNumber`, `expo.ios.bundleIdentifier`
  - Flutter: `pubspec.yaml` → `name`, `version`
- **(2.3.1a)** New features must be described specifically in App Review notes → add to Manual Check Required when Remote Config / feature flags gate user-visible features.
- **(2.3.14, new)** Creative assets (product page header, search) → Manual Check Required: no misleading references to other apps, no unverifiable claims, no specific/discounted prices.
- **(2.3.7)** Verify app display name ≤ 30 characters
- **(2.3.10)** Scan for "Android", "Google Play", "Play Store", "Windows Phone" in **user-facing** strings/assets only (localization files, UI text literals, images, metadata). Platform branching in code (`Platform.OS === 'android'`, `Platform.isAndroid`, `defaultTargetPlatform`, Gradle/manifest files, comments) is NOT a violation — never report it.
- **(2.3.12)** Check `CHANGELOG.md`, `fastlane/metadata/*/release_notes.txt` — not empty/generic
- Verify all `NS*UsageDescription` keys exist for used permissions:
  `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSMicrophoneUsageDescription`, `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysUsageDescription`, `NSContactsUsageDescription`, `NSCalendarsUsageDescription`, `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`, `NSBluetoothAlwaysUsageDescription`, `NSFaceIDUsageDescription`, `NSMotionUsageDescription`, `NSSpeechRecognitionUsageDescription`, `NSLocalNetworkUsageDescription`, `NSUserTrackingUsageDescription`
- Cross-check: permission-requiring package in deps → corresponding `NS*UsageDescription` must exist
- Verify descriptions are meaningful (not empty/generic)

**Guideline 2.4 — Hardware Compatibility:**
- **(2.4.1)** Check `UIDeviceFamily` — verify iPad support
- Check `UIRequiredDeviceCapabilities`
- Scan for hardcoded screen sizes:
  - Flutter: hardcoded `width`/`height` instead of `MediaQuery`
  - RN/Expo: hardcoded dimensions instead of `Dimensions` API
  - Native: hardcoded CGRect/frame values
- **(2.4.2)** Scan for crypto mining: `coinhive`, `cryptonight`, `xmrig`, mining pool URLs. Flag unrelated background processing
- **(2.4.4)** Scan strings for "restart device", "turn off Wi-Fi", "disable" system settings
- **(2.4.5)** If macOS target: verify sandbox entitlements, no third-party installers, no auto-launch without consent, no license screens

**Guideline 2.5 — Software Requirements:**
- Check for private/undocumented API usage
- Verify minimum deployment target and deprecated API usage
- **(2.5.2)** Scan for dynamic code loading: `dlopen`, `NSBundle.load`, `JavaScriptCore` eval of remote scripts, JSPatch, Rollout.io, CodePush native changes, `eval()` with network content
- **(2.5.3)** Flag known malicious patterns, suspicious payloads, system file modification
- **(2.5.4)** Cross-check `UIBackgroundModes` in Info.plist against actual code usage. Flag declared-but-unused modes
- **(2.5.5)** Verify no hardcoded IPv4 addresses — must work on IPv6-only networks
- **(2.5.6)** If browser/webview app, check for WebKit compliance
- **(2.5.8)** Scan for home screen replacement / custom springboard UIs
- **(2.5.9)** Scan for volume button overrides, system gesture interception, `openURL` blocking
- **(2.5.11)** If `INIntent` / `Intents.intentdefinition` / `AppShortcutsProvider` exists, verify intents match app domain
- **(2.5.12)** If `CallKit` / `IdentityLookup` imported, check for `CXCallDirectoryProvider` / `ILMessageFilterExtension`
- **(2.5.13)** If facial recognition for auth (ARKit/Vision), verify `LocalAuthentication` is used instead. Check age-gating under 13
- **(2.5.14)** If `ReplayKit` / screen recording, verify visible recording indicator in UI
- **(2.5.15)** If file-picking, verify `UIDocumentPickerViewController` / `PHPickerViewController` (includes Files/iCloud)
- **(2.5.16)** If widget extensions exist, verify no ad SDK imports in widget code
- **(2.5.17)** If Matter (`MatterSupport`), verify Apple's framework used for pairing
- **(2.5.19, new — formerly 2.3.1a)** Hidden, dormant, or undocumented features. Feature flags by themselves are fine. Flag only code that hides functionality from App Review or users: review/TestFlight/sandbox detection that changes features (`isTestFlight`, `appStoreReceiptURL` containing `sandboxReceipt`, `isReviewer`, reviewer-account checks), date/geo/IP-gated unlocks of undisclosed features, remote switches that enable payments or content not visible during review, deliberate obfuscation of such logic. Confirmed → CRITICAL.
- **(2.5.18)** Scan extension targets for ad SDK imports (`GoogleMobileAds`, `FBAudienceNetwork`, `AdSupport`). Verify main app has ad-reporting mechanism if ads present
