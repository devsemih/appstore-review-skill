---
name: appstore-review
description: "Checks an iOS/iPadOS/macOS app project against Apple's App Store Review Guidelines before submission. Works with native (Swift/Obj-C), Flutter, React Native, Expo, Kotlin Multiplatform, .NET MAUI, Cordova, Ionic, and Unity projects. Use when the user wants to verify their app complies with App Store rules, or when they mention 'app review', 'app store guidelines', 'submission check', or 'review rejection'."
argument-hint: "[path-to-project]"
allowed-tools: Read, Grep, Glob, Bash, Agent
context: fork
agent: general-purpose
---

# App Store Review Guidelines Checker

You are an expert App Store Review compliance auditor. Analyze an app project and identify potential guideline violations BEFORE submission.

**Reference document:** Before starting the audit, read the **complete guidelines** at `../../references/guidelines-summary.md` (relative to this skill file). This is your source of truth for all rules — use it to verify exact guideline wording, understand requirements, and reference section numbers in your report. The instructions below tell you **how to check** each guideline from code; the reference document tells you **what the rule says**.

> **Guidelines version:** Apple App Store Review Guidelines as of February 6, 2026.

## Supported Frameworks

| Framework | Detection Markers |
|-----------|------------------|
| **Native Swift/ObjC** | `.xcodeproj`, `.swift` files, `AppDelegate.swift` |
| **Flutter** | `pubspec.yaml`, `lib/main.dart`, `ios/Runner/` |
| **React Native** | `package.json` with `react-native`, `ios/` directory |
| **Expo** | `app.json` or `app.config.js` with `expo`, `eas.json` |
| **KMP** | `build.gradle.kts` with `kotlin("multiplatform")`, `iosApp/` |
| **.NET MAUI** | `.csproj` with `Microsoft.Maui`, `Platforms/iOS/` |
| **Cordova/Ionic** | `config.xml`, `ionic.config.json`, `platforms/ios/` |
| **Capacitor** | `capacitor.config.ts/json`, `ios/App/` |
| **Unity** | `ProjectSettings/`, `.unity` files, Xcode export |

## Instructions

Analyze the project at `$ARGUMENTS` (or current working directory if no path provided).

## Prioritization

1. **Must complete (critical rejection risks):** Steps 0–1, then: Sign in with Apple (4.8), Account Deletion (5.1.1v), Privacy Manifest (5.1.1), IAP compliance (3.1), Usage Descriptions (2.3)
2. **Should complete:** Remaining items in Steps 2–7
3. **If time allows:** Best-practice recommendations

If running low on turns, skip Step 7 (overlaps with Steps 2–6). Always produce the final report; note any skipped sections.

## Audit Steps

### Step 0: Detect Project Type & Framework

Identify the framework from the detection markers table above. Adapt all subsequent checks to that framework's file structure.

### Step 1: Project Discovery

Find iOS-relevant config files:

1. Locate `Info.plist` (path varies by framework)
2. Find `PrivacyInfo.xcprivacy`
3. Locate `.entitlements` files
4. Find `.xcodeproj` or `.xcworkspace`

**Framework-specific config locations:**

| Framework | Key Config Files |
|-----------|-----------------|
| **Native** | `Info.plist`, `.entitlements`, `Podfile`, `Package.swift` |
| **Flutter** | `pubspec.yaml`, `ios/Runner/Info.plist`, `ios/Podfile`, `ios/Runner/*.entitlements` |
| **React Native** | `package.json`, `ios/*/Info.plist`, `ios/Podfile`, `ios/*/*.entitlements` |
| **Expo** | `app.json`/`app.config.js`, `eas.json`, `package.json` |
| **KMP** | `iosApp/iosApp/Info.plist`, `build.gradle.kts`, `iosApp/*.entitlements` |
| **MAUI** | `Platforms/iOS/Info.plist`, `*.csproj`, `Entitlements.plist` |
| **Cordova/Ionic** | `config.xml`, `platforms/ios/*/Info.plist` |
| **Capacitor** | `capacitor.config.ts`, `ios/App/App/Info.plist` |
| **Unity** | Xcode export `Info.plist`, `ProjectSettings/ProjectSettings.asset` |

**Expo special handling:**
- Managed workflow may have no `ios/` folder — config is in `app.json` / `app.config.js`
- Check `expo.ios.infoPlist` for permission descriptions
- Check `expo.ios.bundleIdentifier`, `expo.ios.config`
- Check `expo.plugins` — many inject permissions/entitlements at build time (e.g., `expo-camera` auto-adds `NSCameraUsageDescription`). Read each plugin's config
- Check `eas.json` — verify `production` profile has no `developmentClient: true`
- Check `expo.ios.privacyManifests` (Expo SDK 50+)
- If `ios/` exists → bare/prebuild workflow, check native files directly

**Flutter:** Permissions in `ios/Runner/Info.plist` AND via `permission_handler` in `pubspec.yaml`. Check `project.pbxproj` for deployment target.

**React Native:** Check both `ios/` structure and `package.json`. Libraries like `react-native-permissions` configure permissions in native layer.

### Step 2: Safety Checks (Section 1)

**Guideline 1.1 — Objectionable Content (1.1.1–1.1.7):**
- Scan user-facing strings for offensive content:
  - Native: `Localizable.strings`, `.xcstrings`
  - Flutter: `lib/l10n/`, `*.arb`
  - RN/Expo: `i18n/`, `locales/`, `translations/`
  - MAUI: `Resources/Strings/`
- **(1.1.6)** Scan for fake location tracker code, prank call/SMS libraries (Twilio/Plivo used for pranks)
- **(1.1.7)** Scan strings for references capitalizing on disasters, epidemics, conflicts

**Guideline 1.2 — User-Generated Content:**
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

### Step 3: Performance Checks (Section 2)

**Guideline 2.1 + 2.2 — App Completeness & Beta Testing:**
- Search for "beta", "trial", "demo version" in user-facing strings and app name
- **(2.1b)** If IAP product IDs defined (StoreKit config, product arrays), verify fulfillment code exists
- Scan for `TODO`, `FIXME`, `HACK` comments
- Scan for placeholder text: `Lorem ipsum`, `TODO`, `placeholder`
- Scan for debug code:
  - Flutter: `kDebugMode`, `print()` | RN/Expo: `__DEV__`, `console.log()` | Native: `#if DEBUG`, `print()`
  - All: `localhost`, `127.0.0.1`, staging/dev URLs

**Guideline 2.3 — Accurate Metadata:**
- Verify required keys in Info.plist / `app.json`:
  - `CFBundleDisplayName`/`CFBundleName`, `CFBundleShortVersionString`, `CFBundleVersion`, `CFBundleIdentifier`
  - Expo: `expo.name`, `expo.version`, `expo.ios.buildNumber`, `expo.ios.bundleIdentifier`
  - Flutter: `pubspec.yaml` → `name`, `version`
- **(2.3.1a)** Scan for hidden feature flags: Firebase Remote Config, LaunchDarkly, `featureFlag`, `killSwitch`, `isHidden`
- **(2.3.7)** Verify app display name ≤ 30 characters
- **(2.3.10)** Scan for "Android", "Google Play", "Play Store", "Windows Phone" in code/strings/assets
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
- **(2.5.18)** Scan extension targets for ad SDK imports (`GoogleMobileAds`, `FBAudienceNetwork`, `AdSupport`). Verify main app has ad-reporting mechanism if ads present

### Step 4: Business Checks (Section 3)

**Guideline 3.1 — Payments / In-App Purchase:**
- Detect IAP:
  - Native: `import StoreKit` | Flutter: `in_app_purchase`, `purchases_flutter` | RN/Expo: `react-native-iap`, `react-native-purchases`
- Flag non-IAP payment for DIGITAL goods:
  - Stripe, PayPal, Braintree for digital content = violation
  - Custom payment forms for feature unlock = violation
  - Crypto payments for digital features = violation
  - **(3.1.3e)** Physical goods/services outside app → MUST use external payment
- **(3.1.1)** Scan for "gift card", "voucher", "coupon" + external payment SDK → must use IAP for digital
- **(3.1.1)** Scan for NFT references (`NFT`, `ERC-721`, `ERC-1155`, OpenSea, Alchemy) — verify ownership doesn't gate features
- Scan for randomized reward/loot box code — verify odds display in UI

**Guideline 3.1.2 — Subscriptions & Restore Purchases (Common Rejection):**
- Verify **Restore Purchases** exists:
  - Native: `SKPaymentQueue.restoreCompletedTransactions()` / StoreKit 2 `Transaction.currentEntitlements`
  - Flutter: `InAppPurchase.instance.restorePurchases()` / RevenueCat `Purchases.restorePurchases()`
  - RN/Expo: `RNIap.getAvailablePurchases()` / RevenueCat `Purchases.restorePurchases()`
- **(3.1.2a)** Verify subscription periods ≥ 7 days (check StoreKit config / period constants)
- **(3.1.2b)** If multiple tiers, verify upgrade/downgrade handling code
- **(3.1.2c)** Verify terms (price, period, renewal, cancel) displayed BEFORE purchase button in paywall UI
- Verify free trial terms clearly stated if offered

**Guideline 3.1.3 — Other Purchase Methods:**
- **(3.1.3a)** If reader app, verify no IAP prompts for previously purchased content

**Guideline 3.1.4 — Hardware-Specific Content:**
- If features unlock via hardware (`CBCentralManager`, `EAAccessoryManager`), verify no unrelated product purchase required

**Guideline 3.1.5 — Cryptocurrencies:**
- Detect crypto packages: `web3swift`, `ethers`, `WalletConnect`, `solana-swift`
- If wallet → flag: must be org account
- Scan for on-device mining code → instant rejection
- If exchange/trading → flag: licensing + geo-restriction required
- **(3.1.5v)** Scan for "earn tokens", "download to earn", "share to earn" + crypto

**Guideline 3.2 — Other Business Model Issues:**
- Detect review prompts:
  - Native: `SKStoreReviewController` | Flutter: `in_app_review` | RN/Expo: `react-native-in-app-review`, `expo-store-review`
- **(5.6.1)** Flag custom review dialogs (star-rating UI) that bypass system `requestReview()` API
- Scan for incentivized review patterns
- **(3.2.1v)** If insurance app → verify free, no IAP
- **(3.2.1viii)** If trading/investing → flag: must be licensed financial institution
- **(3.2.2i)** Scan for store-like interfaces, "install" buttons for external apps, `itms-services://`
- **(3.2.2iii)** Flag hidden ad views or apps predominantly displaying ads
- **(3.2.2viii)** Scan for "binary options", "call/put" trading. If CFD/FOREX → flag licensing
- **(3.2.2ix)** If loan app (search "loan", "APR", "borrow", "lending") → verify APR disclosure, max 36%, repayment > 60 days

### Step 5: Design Checks (Section 4)

**Guideline 4.1 — Copycats:**
- Check bundle ID and app name for trademark issues
- Scan for competing app names in code/resources

**Guideline 4.2 — Minimum Functionality (4.2.1–4.2.7):**
- **(4.2.2)** Flag apps that are primarily marketing materials, ad collections, or link aggregators
- Detect web-wrapper apps:
  - Flutter: single `WebView` widget | RN/Expo: single `WebView` component | Native: single `WKWebView`
  - Cordova/Ionic/Capacitor: check for native functionality beyond web shell
- **(4.2.1)** If ARKit used (`ARSession`, `ARView`, `ARSCNView`), verify rich experience beyond single model placement
- **(4.2.3i)** Scan for `canOpenURL` gating core features on other apps
- **(4.2.3ii)** If large resource download at launch, verify size disclosure + user prompt
- **(4.2.6)** Scan for template service markers (BuildFire, Appy Pie, GoodBarber, Shoutem)
- **(4.2.7)** If remote desktop/screen mirroring (VNC, `RPScreenRecorder`), verify LAN-only, user-owned device

**Guideline 4.3 — Spam:**
- Verify single bundle ID per app concept

**Guideline 4.4 — Extensions (4.4.1–4.4.2):**
- Check for extension targets in `.xcodeproj` / `ios/`
- **(4.4.1)** If keyboard extension → verify `advanceToNextInputMode()` called from UI button
- **(4.4.2)** If Safari extension → check `SFSafariWebsiteAccess` — flag `All Websites` if only specific domains needed
- Verify: keyboard works without full network, doesn't launch other apps; App Clips have no ads

**Guideline 4.5 — Apple Sites and Services (4.5.1–4.5.6):**
- **(4.5.1)** Scan for Apple website scraping (apple.com, App Store, iTunes)
- If MusicKit used: verify user-initiated playback, standard controls, no payment gate
  - **(4.5.2ii)** Flag file-saving on MusicKit content
  - **(4.5.2iii)** If Apple Music user data accessed, verify purpose string + no ad SDK sharing
- **(4.5.3)** Scan for bulk push notification patterns, Game Center spam
- **(4.5.4)** Verify push notifications not required for core functionality, not used for marketing without opt-in
- **(4.5.5)** If GameKit → verify `GKPlayer.gamePlayerID`/`teamPlayerID` not displayed in UI or sent to third parties
- **(4.5.6)** Check for Apple emoji embedded in binary (PNG/SVG assets)

**Guideline 4.7 — Mini Apps / Emulators (4.7.1–4.7.5):**
- Detect code execution: JavaScript injection, eval patterns
- **(4.7.1)** If mini-apps/plugins hosted → verify privacy compliance, content moderation, IAP for digital goods
- **(4.7.2)** Scan `WKScriptMessageHandler` / JS bridge — flag native API exposure to embedded content
- **(4.7.3)** Flag blanket permission grants to embedded content without per-instance consent
- **(4.7.4)** Verify index/catalog with universal links. Check `apple-app-site-association`
- **(4.7.5)** Verify age-gating for content exceeding app's rating

**Guideline 4.8 — Login Services (CRITICAL):**
- Detect third-party login:
  - Flutter: `google_sign_in`, `flutter_facebook_auth`, `sign_in_with_apple`
  - RN/Expo: `@react-native-google-signin`, `react-native-fbsdk-next`, `expo-auth-session`, `expo-apple-authentication`
  - Native: Google Sign-In, Facebook Login, `ASAuthorizationAppleIDProvider`
  - All: OAuth to Google, Facebook, Twitter/X, LinkedIn, Amazon, WeChat
- **If ANY third-party login → verify Sign in with Apple exists**
- Check for `AuthenticationServices` framework
- Exceptions: company-only login, education/enterprise SSO, government ID

**Guideline 4.9 — Apple Pay:**
- Detect: Native `PassKit`, `PKPaymentAuthorizationViewController` | Flutter: `pay` | RN/Expo: `@stripe/stripe-react-native` Apple Pay, `react-native-payments`
- If found, verify recurring payment disclosures in UI

**Guideline 4.10 — Monetizing Built-In Capabilities:**
- Search for paywalls/IAP gates around native device features (camera, push, gyroscope, iCloud, Screen Time)

### Step 6: Privacy & Legal Checks (Section 5)

**Guideline 5.1.1 — Data Collection & Storage:**
- Check `PrivacyInfo.xcprivacy` existence:
  - Expo: `expo-build-properties` or config plugin | Flutter: `ios/Runner/PrivacyInfo.xcprivacy`
- Verify privacy manifest declares: `NSPrivacyTracking`, `NSPrivacyTrackingDomains`, `NSPrivacyCollectedDataTypes`, `NSPrivacyAccessedAPITypes`
- Check required API reason declarations: file timestamp, boot time, disk space, active keyboard, user defaults APIs
- Flag third-party SDKs needing own privacy manifests
- **(5.1.1i)** Search for "privacy policy", "privacyPolicy" URL in code/config/settings
- **(5.1.1ii)** Scan for permission-denial handlers that block premium content
- **(5.1.1iii)** Flag full `PHPhotoLibrary`/`CNContact` access when `PHPickerViewController`/`CNContactPickerViewController` alternatives exist
- **(5.1.1iv)** Verify fallback behavior on permission denial (not full block)
- **(5.1.1vii)** If `SFSafariViewController` used, verify not hidden/zero-frame
- **(5.1.1viii)** Flag web scraping libraries, people-search API integrations
- **(5.1.1ix)** If banking/healthcare/gambling/cannabis/aviation/crypto domain → flag: must be legal entity

**Guideline 5.1.1(v) — Account Deletion (CRITICAL):**
- If account creation exists → account deletion MUST exist
- Search for: "delete account", "remove account", "deactivate" in code/strings
  - Flutter: delete account screens/dialogs | RN/Expo: delete account components | Native: delete account views
- Check for server-side deletion API calls

**Guideline 5.1.2 — Data Use and Sharing:**
- Detect tracking/ad SDKs:
  - Flutter: `google_mobile_ads`, `facebook_audience_network`, `appsflyer_sdk`, `adjust_sdk`
  - RN/Expo: `react-native-google-mobile-ads`, `react-native-fbsdk-next`, `react-native-appsflyer`
  - Native: `AdSupport`, `AppTrackingTransparency`
- If found → verify: `AppTrackingTransparency` used, `NSUserTrackingUsageDescription` in Info.plist, ATT prompt before tracking
- **(5.1.2ii)** Cross-check data collection SDKs with sharing destinations for repurposing
- **(5.1.2iii)** Flag device fingerprinting: `UIDevice` property aggregation (model+OS+screen+timezone+language)
- **(5.1.2iv)** If Contacts/Photos accessed, flag bulk-upload patterns
- **(5.1.2v)** If contact messaging, verify no "Select All" option, message preview before send
- **(5.1.2vi)** If HomeKit/ClassKit/ARKit depth data → verify not sent to ad SDKs
- **(5.1.2vii)** If Apple Pay → verify `PKPayment` data not shared beyond delivery

**Guideline 5.1.3 — Health and Health Research:**
- Detect health packages:
  - Flutter: `health`, `flutter_health_connect` | RN/Expo: `react-native-health`, `expo-health` | Native: `HealthKit`, `CareKit`, `ResearchKit`
- If found → cross-check against ad/marketing SDKs for data sharing. Check for iCloud health data storage
- If research features → verify consent flow UI exists (note as "Manual Check Required" for ethics board)

**Guideline 5.1.4 — Kids:**
- If app targets children → verify no third-party analytics/ads (see also 1.3)
- Check "For Kids"/"For Children" not in metadata unless Kids Category (Guideline 2.3.8)
- Verify parental gate if Kids Category

**Guideline 5.1.5 — Location Services:**
- Detect location usage:
  - Flutter: `geolocator`, `location`, `background_locator`
  - RN/Expo: `expo-location`, `react-native-geolocation-service`
  - Native: `CoreLocation`
- Verify purpose strings are descriptive. Check background location justification

**Guideline 5.2 — Intellectual Property (5.2.1–5.2.5):**
- **(5.2.1)** Scan for copyrighted assets, third-party trademarks
- **(5.2.2)** If third-party APIs used (YouTube, Spotify, Google Maps), flag TOS compliance check
- **(5.2.3)** Scan for `ytdl-core`, media download from YouTube/SoundCloud/Vimeo. Flag `AVAssetExportSession` on third-party streams
- **(5.2.4)** Scan strings for "Apple recommended", "Apple approved", "endorsed by Apple"
- **(5.2.5)** Scan for Apple emoji in binary assets, UI mimicking Apple apps, Activity ring visualizations

**Guideline 5.3 — Gaming, Gambling, and Lotteries (5.3.1–5.3.4):**
- Scan for: "bet", "wager", "casino", "poker", "lottery", "sweepstakes" in code/strings
- **(5.3.1)** If sweepstakes/contests → verify developer is the sponsor
- **(5.3.2)** If sweepstakes/contests → verify official rules presented in-app stating Apple is not sponsor
- **(5.3.3)** If gambling features → verify no IAP for credits/currency used in gambling
- **(5.3.4)** If real-money gaming (sports betting, poker, casino, horse racing) → flag: licensing required, geo-restriction, must be free on App Store

**Guideline 5.4 — VPN Apps:**
- Detect: Native `NetworkExtension`, `NEVPNManager`, `NETunnelProviderManager` | Flutter: `flutter_vpn`, `wireguard_flutter` | RN: `react-native-vpn`
- If found → flag: must use `NEVPNManager`, org account required, data disclosure before use

**Guideline 5.5 — Mobile Device Management:**
- Check for MDM entitlements/profiles → flag: commercial/edu/gov entity only

**Guideline 5.6 — Developer Code of Conduct:**
- Scan for dark patterns: hidden cancel buttons, misleading free trial UI, fake urgency/scarcity strings
- **(5.6.3)** Scan for review manipulation: automated submissions, bot patterns, review-farming integrations

### Step 7: Common Rejection Quick-Check

1. **Crashes** — Swift force unwraps (`!`), Dart `!` on nullables, JS unhandled rejections
2. **Broken Links** — Hardcoded URLs, verify HTTPS
3. **Incomplete Config** — Required Info.plist / app.json keys
4. **Missing Privacy Descriptions** — All `NS*UsageDescription` for used permissions
5. **No Privacy Policy URL** — Search "privacy policy" in code/config
6. **Debug Code** — `print()`/`console.log()`, staging URLs, localhost
7. **Hardcoded Credentials** — API keys, tokens, `.env` files
8. **Missing Sign in with Apple** — When third-party login exists
9. **Missing Account Deletion** — When account creation exists
10. **Missing Privacy Manifest** — `PrivacyInfo.xcprivacy`

## Output Format

```
# App Store Review Compliance Report

## Project Summary
- **App Name:** [name]
- **Bundle ID:** [id]
- **Framework:** [detected framework]
- **Deployment Target:** [version]
- **Platforms:** [iOS/iPadOS/macOS]

## Critical Issues (Will Likely Cause Rejection)

### [CRITICAL] Guideline X.X.X — [Title]
**Issue:** [Description]
**Location:** [File:Line]
**Fix:** [Framework-specific fix]

## Warnings (May Cause Rejection)

### [WARNING] Guideline X.X.X — [Title]
**Issue:** [Description]
**Location:** [File:Line]
**Fix:** [Recommended fix]

## Recommendations (Best Practices)

### [INFO] Guideline X.X.X — [Title]
**Suggestion:** [Description]

## Checklist Summary
- [ ] Project type & framework detected
- [ ] Info.plist / app.json metadata complete
- [ ] App display name ≤ 30 characters
- [ ] No references to other mobile platforms
- [ ] All NS*UsageDescription keys present
- [ ] No hardcoded secrets or API keys
- [ ] App Transport Security configured
- [ ] Privacy manifest present and complete
- [ ] Privacy policy URL in app
- [ ] Data minimization — pickers over full access
- [ ] Sign in with Apple (if third-party login)
- [ ] Account deletion (if account creation)
- [ ] IAP for digital goods
- [ ] Restore Purchases exists (if IAP/subscriptions)
- [ ] Subscription terms before purchase
- [ ] No debug/test code in production
- [ ] No placeholder/TODO content
- [ ] No beta/trial/demo labels
- [ ] No dynamic code loading / hot-patching
- [ ] Background modes match actual usage
- [ ] No ads in extensions/widgets/App Clips
- [ ] ATT implemented (if tracking/ad SDKs)
- [ ] UGC moderation (if UGC exists)
- [ ] Support URL accessible in-app
- [ ] No on-device crypto mining
- [ ] No dark patterns in purchase flows
- [ ] No illegal media downloading

## Final Verdict
READY / NEEDS FIXES / HIGH RISK — with summary
```

## Important Notes

- Be thorough but avoid false positives
- Always reference the specific guideline number
- Provide framework-specific fix suggestions
- If something cannot be determined from code, note as "Manual Check Required"
- Consider app context — a medical app has different requirements than a game
- For cross-platform projects, check BOTH shared code AND iOS native layer
