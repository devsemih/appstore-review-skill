---
name: appstore-review
description: "Checks an iOS/iPadOS/macOS app project against Apple's App Store Review Guidelines before submission. Works with native (Swift/Obj-C), Flutter, React Native, Expo, Kotlin Multiplatform, .NET MAUI, Cordova, Ionic, and Unity projects. Use when the user wants to verify their app complies with App Store rules, or when they mention 'app review', 'app store guidelines', 'submission check', or 'review rejection'."
argument-hint: "[path-to-project]"
allowed-tools: Read, Grep, Glob, Bash, Agent
context: fork
agent: general-purpose
---

# App Store Review Guidelines Checker

> **Guidelines version:** Based on Apple's App Store Review Guidelines as of February 6, 2026. If you encounter guideline references you're unsure about, consult the reference document below for the exact wording.

You are an expert App Store Review compliance auditor. Your job is to analyze an app project targeting iOS/iPadOS/macOS and identify potential App Store Review Guidelines violations BEFORE the developer submits for review.

**Reference document:** Before starting the audit, read the guidelines summary at `../../references/guidelines-summary.md` (relative to this skill file). Use it to verify exact guideline wording and section numbers when reporting findings. If the file is not accessible, proceed using your knowledge of the guidelines but note this in the report.

You support ALL frameworks that produce iOS apps:
- **Native:** Swift, SwiftUI, UIKit, Objective-C
- **Flutter:** Dart + ios/ directory
- **React Native:** JavaScript/TypeScript + ios/ directory
- **Expo:** JavaScript/TypeScript (managed or bare workflow)
- **Kotlin Multiplatform (KMP):** Kotlin + iosApp/ directory
- **.NET MAUI / Xamarin:** C# + Platforms/iOS/
- **Cordova / Ionic / Capacitor:** Web tech + ios/ platform
- **Unity:** C# + iOS build output
- **Other:** Any framework producing an iOS binary

## Instructions

Analyze the project at `$ARGUMENTS` (or the current working directory if no path is provided).

Perform a thorough audit by checking the categories below. For each finding, reference the specific guideline number and explain the issue clearly.

## Prioritization Strategy

**Always complete the audit steps in the order listed, but prioritize depth on high-rejection-risk areas.** If the project is large, allocate your effort as follows:

1. **Must complete (critical rejection risks):** Steps 0–1, then focus on: Sign in with Apple (4.8), Account Deletion (5.1.1v), Privacy Manifest (5.1.1), IAP compliance (3.1), Usage Descriptions (2.3)
2. **Should complete:** Remaining items in Steps 2–7
3. **If time allows:** Recommendations and best-practice suggestions

If you are running low on turns, skip Step 7 (Quick-Check) — its items overlap with Steps 2–6. Always produce the final report even if some lower-priority checks were skipped; note any skipped sections in the report.

## Audit Steps

### Step 0: Detect Project Type & Framework

Identify the framework by looking for these markers:

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

Once detected, adapt all checks to that framework's file structure and conventions.

### Step 1: Project Discovery

Find the iOS-relevant configuration files based on the detected framework:

**All frameworks — find the iOS native layer:**
1. Locate `Info.plist` (path varies by framework — see table below)
2. Find `PrivacyInfo.xcprivacy` (privacy manifest)
3. Locate entitlements files (`.entitlements`)
4. Find the `.xcodeproj` or `.xcworkspace` (often in `ios/` subdirectory)

**Framework-specific config files:**

| Framework | Key Config Files |
|-----------|-----------------|
| **Native** | `Info.plist`, `.entitlements`, `Podfile`, `Package.swift` |
| **Flutter** | `pubspec.yaml`, `ios/Runner/Info.plist`, `ios/Podfile`, `ios/Runner/*.entitlements` |
| **React Native** | `package.json`, `ios/*/Info.plist`, `ios/Podfile`, `ios/*/*.entitlements` |
| **Expo** | `app.json`/`app.config.js` (generates Info.plist), `eas.json`, `package.json` |
| **KMP** | `iosApp/iosApp/Info.plist`, `build.gradle.kts`, `iosApp/*.entitlements` |
| **MAUI** | `Platforms/iOS/Info.plist`, `*.csproj`, `Entitlements.plist` |
| **Cordova/Ionic** | `config.xml`, `platforms/ios/*/Info.plist` |
| **Capacitor** | `capacitor.config.ts`, `ios/App/App/Info.plist` |
| **Unity** | Xcode export `Info.plist`, `ProjectSettings/ProjectSettings.asset` |

**Expo special handling:**
- Expo managed workflow may NOT have an `ios/` folder — config is in `app.json` / `app.config.js`
- Check `expo.ios.infoPlist` for permission descriptions
- Check `expo.ios.bundleIdentifier` for bundle ID
- Check `expo.ios.config` for build settings
- Check `expo.plugins` for config plugins that modify native code — many plugins inject permissions, entitlements, and Info.plist keys at build time (e.g., `expo-camera` auto-adds `NSCameraUsageDescription`). Read each plugin's config to understand what native changes it makes.
- Check `eas.json` for build profiles — verify the `production` profile exists and does not include `developmentClient: true` or debug-only settings
- If `expo-dev-client` is in dependencies, verify it is NOT included in production builds (should only be in development profile)
- Check `expo.ios.privacyManifests` in `app.json` for privacy manifest configuration (Expo SDK 50+)
- If `ios/` exists, it's a bare/prebuild workflow — check native files directly
- For prebuild workflow: run `npx expo config --type introspect` mentally — the final native config is a merge of `app.json` + all plugins

**Flutter special handling:**
- Permissions are declared in `ios/Runner/Info.plist` AND may also be managed via `permission_handler` package in `pubspec.yaml`
- Check `ios/Runner.xcodeproj/project.pbxproj` for deployment target

**React Native special handling:**
- Check both `ios/` directory structure and `package.json` dependencies
- Libraries like `react-native-permissions` configure permissions in native layer
- `react-native.config.js` may reveal native module configurations

### Step 2: Safety Checks (Section 1)

**1.1 Objectionable Content:**
- Scan for hardcoded offensive strings, slurs, or inappropriate content in code/resources
- Check user-facing strings:
  - Native: `Localizable.strings`, String Catalogs (`.xcstrings`)
  - Flutter: `lib/l10n/`, `*.arb` files
  - React Native/Expo: `i18n/`, `locales/`, `translations/` directories
  - MAUI: `Resources/Strings/`
  - Unity: localization assets

**1.2 User-Generated Content:**
- If app has UGC features (chat, posts, comments, media uploads), verify:
  - Content filtering/moderation mechanism exists
  - Report/flag functionality exists
  - Block user functionality exists
  - Contact information is accessible in-app
- Check for UGC-related packages:
  - Flutter: `firebase_core`, `cloud_firestore`, `stream_chat_flutter`
  - RN/Expo: `@stream-io/flat-list-mvcp`, `react-native-gifted-chat`, Firebase packages
  - Any: Socket.IO, WebSocket chat implementations, Supabase realtime

**1.3 Kids Category:**
- Check if app targets kids (look for Kids Category markers)
- If yes, verify no third-party analytics/ad SDKs:
  - Flutter: `google_mobile_ads`, `firebase_analytics`, `facebook_audience_network`
  - RN/Expo: `react-native-google-mobile-ads`, `@react-native-firebase/analytics`
  - Native: `AdSupport.framework`, `ASIdentifierManager`

**1.4 Physical Harm:**
- Check for health/medical features:
  - Flutter: `health`, `flutter_health_connect`
  - RN/Expo: `react-native-health`, `expo-health`
  - Native: `HealthKit`
- Verify medical disclaimers exist if applicable
- Check drug dosage calculators come from approved entities (Guideline 1.4.2)
- Check app does not encourage tobacco, vape, illegal drugs, or excessive alcohol (Guideline 1.4.3)

**1.5 Developer Information:**
- Verify app includes accessible contact information / support URL
- Check for a support link or contact method in the app UI (not just App Store metadata)
- For Expo: check `expo.ios.supportsTablet`, support URL in `app.json`
- For all: search for "support", "contact", "help" screens or links in code

**1.6 Data Security:**
- Check for `NSAppTransportSecurity` exceptions in Info.plist
- Verify `NSAllowsArbitraryLoads` is NOT set to YES (or has valid exceptions)
- Look for hardcoded API keys, secrets, credentials in source code:
  - Scan all source files (`.swift`, `.dart`, `.ts`, `.js`, `.kt`, `.cs`)
  - Check for common patterns: `apiKey`, `secret`, `password`, `token`, `API_KEY`, `Bearer`
  - Check `.env` files committed to repo (should be in `.gitignore`)
  - Check `google-services.json`, `GoogleService-Info.plist` for exposed keys
- Check for proper secure storage:
  - Flutter: `flutter_secure_storage` vs `shared_preferences` for sensitive data
  - RN: `react-native-keychain` / `expo-secure-store` vs `AsyncStorage` for sensitive data
  - Native: Keychain vs `UserDefaults` for sensitive data

**1.7 Reporting Criminal Activity:**
- If app has crime reporting features, verify it involves local law enforcement
- Check app is geo-restricted to regions where such law enforcement involvement is active

### Step 3: Performance Checks (Section 2)

**2.1 App Completeness (includes 2.2 Beta Testing):**
- Verify app is not labeled as "beta", "trial", or "demo" in code/UI/config (Guideline 2.2 — use TestFlight for betas)
- Search for "beta", "trial", "demo version" in user-facing strings and app name
- Check for TODO/FIXME/HACK comments indicating incomplete features (Guideline 2.1)
- Look for placeholder text in UI:
  - Flutter: `Text('TODO')`, `Text('Lorem ipsum')` in widget files
  - RN/Expo: placeholder text in JSX components
  - Native: placeholder text in storyboards, xibs, SwiftUI
- Check for test/debug code that should be removed:
  - Flutter: `kDebugMode` guards, `print()` statements
  - RN/Expo: `__DEV__` guards, `console.log()` statements
  - Native: `#if DEBUG` blocks, `print()` statements
  - All: hardcoded `localhost`, `127.0.0.1`, staging URLs

**2.3 Accurate Metadata:**
- Verify Info.plist has required keys (or equivalent in framework config):
  - `CFBundleDisplayName` or `CFBundleName`
  - `CFBundleShortVersionString`
  - `CFBundleVersion`
  - `CFBundleIdentifier`
- For Expo: check these in `app.json` → `expo.name`, `expo.version`, `expo.ios.buildNumber`, `expo.ios.bundleIdentifier`
- For Flutter: check `pubspec.yaml` → `name`, `version` and `ios/Runner/Info.plist`

- Check that all usage description strings exist for used frameworks/permissions:
  - `NSCameraUsageDescription`
  - `NSPhotoLibraryUsageDescription`
  - `NSMicrophoneUsageDescription`
  - `NSLocationWhenInUseUsageDescription` / `NSLocationAlwaysUsageDescription`
  - `NSContactsUsageDescription`
  - `NSCalendarsUsageDescription`
  - `NSHealthShareUsageDescription` / `NSHealthUpdateUsageDescription`
  - `NSBluetoothAlwaysUsageDescription`
  - `NSFaceIDUsageDescription`
  - `NSMotionUsageDescription`
  - `NSSpeechRecognitionUsageDescription`
  - `NSLocalNetworkUsageDescription`
  - `NSUserTrackingUsageDescription`
- Cross-check: if a permission-requiring package is in dependencies, verify the corresponding `NS*UsageDescription` exists
- Verify usage descriptions are meaningful (not empty or generic like "We need access")

**2.4 Hardware Compatibility:**
- Check `UIRequiredDeviceCapabilities` in Info.plist
- Verify iPad support (`UIDeviceFamily`)
- Look for hardcoded screen sizes:
  - Flutter: hardcoded `width`/`height` instead of `MediaQuery`
  - RN/Expo: hardcoded dimensions instead of `Dimensions` API / responsive layouts
  - Native: hardcoded CGRect/frame values

**2.5 Software Requirements:**
- Check for private/undocumented API usage (primarily in native code layer)
- Verify minimum deployment target
- Check for deprecated API usage
- Verify IPv6 compatibility — no hardcoded IPv4 addresses anywhere in the project
- If it's a browser/webview app, check for WebKit compliance (Guideline 2.5.6)

### Step 4: Business Checks (Section 3)

**3.1 Payments / In-App Purchase:**
- Check for IAP integration:
  - Native: `import StoreKit`
  - Flutter: `in_app_purchase`, `purchases_flutter` (RevenueCat)
  - RN/Expo: `react-native-iap`, `react-native-purchases` (RevenueCat), `expo-in-app-purchases`
- Look for non-IAP payment mechanisms for DIGITAL goods:
  - Stripe, PayPal, Braintree SDK for in-app digital content (violation!)
  - Custom payment forms for unlocking features (violation!)
  - Crypto payments for digital features (violation!)
  - Note: physical goods/services CAN use external payment
- Verify loot box/randomized purchase odds disclosure if applicable

**3.1.2 Subscriptions & Restore Purchases (Common Rejection):**
- If app has IAP or subscriptions, verify a **"Restore Purchases"** button exists:
  - Native: look for `SKPaymentQueue.restoreCompletedTransactions()` or StoreKit 2 `Transaction.currentEntitlements`
  - Flutter: look for `InAppPurchase.instance.restorePurchases()` or RevenueCat `Purchases.restorePurchases()`
  - RN/Expo: look for `RNIap.getAvailablePurchases()` or RevenueCat `Purchases.restorePurchases()`
- If app has subscriptions, verify subscription management:
  - A way for users to view their active subscription status
  - A link or instructions to manage/cancel subscription (can link to iOS Settings)
  - Clear display of subscription terms (price, duration, renewal period) BEFORE purchase
  - Free trial terms clearly stated if offered (e.g., "3-day free trial, then $9.99/month")
- Check that subscription paywall does NOT block access before showing terms

**3.2 Other Business Model Issues:**
- Check for forced review prompts:
  - Native: `SKStoreReviewController`
  - Flutter: `in_app_review`
  - RN/Expo: `react-native-in-app-review`, `expo-store-review`
- Look for incentivized review patterns

### Step 5: Design Checks (Section 4)

**4.1 Copycats:**
- Check bundle identifier and app name for potential trademark issues
- Look for references to competing app names in code/resources

**4.2 Minimum Functionality:**
- Assess if the app is just a wrapper around a website:
  - Flutter: single `WebView` widget loading one URL
  - RN/Expo: single `WebView` component loading one URL
  - Native: single `WKWebView` loading one URL
  - Cordova/Ionic/Capacitor: check if there's meaningful native functionality beyond the web shell
- Check for actual native functionality beyond web content

**4.3 Spam:**
- Verify single bundle ID per app concept

**4.4 Extensions:**
- If app includes extensions (keyboard, Safari, widgets, App Clips), verify:
  - Extensions include some functionality (help screens, settings)
  - Keyboard extensions provide keyboard input, remain functional without full network access
  - Keyboard extensions don't launch other apps besides Settings
  - Safari extensions run on current Safari version and don't interfere with system UI
  - App Clips don't contain advertising (Guideline 2.5.16a)
- Check for extension targets:
  - Native: look for extension targets in `.xcodeproj`
  - Flutter: check `ios/` for extension targets
  - RN/Expo: check `ios/` for widget/keyboard/Safari extension targets

**4.5 Apple Sites and Services:**
- Verify app does not scrape Apple websites (apple.com, App Store, iTunes)
- If app uses Apple Music (MusicKit), verify:
  - Users initiate playback, standard media controls available
  - No payment required for Apple Music access
  - Follows Apple Music Identity Guidelines
- Verify Push Notifications are not required for core functionality (Guideline 4.5.4)
- Verify Push Notifications are not used for marketing without explicit opt-in
- Check app does not use Apple emoji embedded in binary or on other platforms (Guideline 4.5.6)

**4.7 Mini Apps / Emulators:**
- Check for code execution capabilities (JavaScript injection, eval patterns)
- If present, verify proper content filtering

**4.8 Login Services (CRITICAL — Common Rejection):**
- Detect third-party login SDKs:
  - Flutter: `google_sign_in`, `flutter_facebook_auth`, `sign_in_with_apple`
  - RN/Expo: `@react-native-google-signin`, `react-native-fbsdk-next`, `expo-auth-session`, `expo-apple-authentication`
  - Native: Google Sign-In, Facebook Login, `ASAuthorizationAppleIDProvider`
  - All: OAuth flows to Google, Facebook, Twitter/X, LinkedIn, Amazon, WeChat
- **If ANY third-party login exists, verify Sign in with Apple is also implemented**
- Check for `AuthenticationServices` framework or equivalent wrapper
- Exceptions: company-only login, education/enterprise SSO, government ID

**4.9 Apple Pay:**
- If app uses Apple Pay, verify:
  - All material purchase information is provided before sale
  - Apple Pay branding/UI used correctly
  - For recurring payments: renewal term, what's provided, actual charges, how to cancel — all disclosed
- Check for Apple Pay integration:
  - Native: `PassKit`, `PKPaymentAuthorizationViewController`
  - Flutter: `pay` package
  - RN/Expo: `@stripe/stripe-react-native` with Apple Pay, `react-native-payments`

**4.10 Monetizing Built-In Capabilities:**
- Verify app does not charge for built-in OS/hardware capabilities:
  - Push Notifications, camera, gyroscope, etc.
  - Apple services: Apple Music access, iCloud storage, Screen Time APIs
- Search for paywalls or IAP gates around native device features

### Step 6: Privacy & Legal Checks (Section 5)

**5.1.1 Data Collection & Storage:**
- Check for `PrivacyInfo.xcprivacy` file existence and completeness
- For Expo: check if `expo-build-properties` or config plugin handles privacy manifest
- For Flutter: check `ios/Runner/PrivacyInfo.xcprivacy` or plugin-generated manifests
- Verify privacy manifest declares:
  - `NSPrivacyTracking` and `NSPrivacyTrackingDomains`
  - `NSPrivacyCollectedDataTypes`
  - `NSPrivacyAccessedAPITypes` (required API reason declarations)
- Check for required API reason declarations:
  - File timestamp APIs
  - System boot time APIs
  - Disk space APIs
  - Active keyboard APIs
  - User defaults APIs
- Look for third-party SDKs that need their own privacy manifests

**5.1.1(v) Account Deletion (CRITICAL — Common Rejection):**
- If app has account creation/sign-up, it MUST have account deletion
- Search for account deletion UI/functionality:
  - Flutter: look for delete account screens/dialogs
  - RN/Expo: look for delete account components
  - Native: look for delete account views
  - All: search for "delete account", "remove account", "deactivate" in code and strings
- Check for server-side deletion API calls

**5.1.2 Data Use and Sharing:**
- Check for tracking/advertising:
  - Flutter: `google_mobile_ads`, `facebook_audience_network`, `appsflyer_sdk`, `adjust_sdk`
  - RN/Expo: `react-native-google-mobile-ads`, `react-native-fbsdk-next`, `react-native-appsflyer`
  - Native: `AdSupport`, `AppTrackingTransparency`
- If tracking/ads exist, verify:
  - `AppTrackingTransparency` framework is used
  - `NSUserTrackingUsageDescription` is in Info.plist
  - ATT prompt is shown before tracking begins

**5.1.3 Health and Health Research:**
- If app collects health/fitness/medical data (HealthKit, Clinical Health Records, Motion & Fitness):
  - Verify data is NOT used for advertising, marketing, or data mining
  - Verify data is NOT shared with third parties except for health management improvement
  - Verify app does not write false data into HealthKit
  - Verify personal health info is NOT stored in iCloud
- If app conducts health-related research:
  - Verify consent flow exists (nature, purpose, duration, risks, benefits, confidentiality, contact, withdrawal)
  - Verify independent ethics review board approval (note as "Manual Check Required")
- Check for health-related packages:
  - Flutter: `health`, `flutter_health_connect`
  - RN/Expo: `react-native-health`, `expo-health`, `@react-native-community/health`
  - Native: `HealthKit`, `CareKit`, `ResearchKit`

**5.1.4 Kids:**
- If app targets children or collects data from minors:
  - Verify compliance with COPPA, GDPR (children's provisions), and other child privacy laws
  - Apps intended primarily for kids should not include third-party analytics or advertising (see also 1.3)
  - Verify parental gate implementation if in Kids Category
  - Check app does not use "For Kids" or "For Children" in metadata unless in Kids Category (Guideline 2.3.8)
  - Verify no collection/transmission of personal info from minors without parental consent

**5.1.5 Location Services:**
- If location is used, verify purpose strings are descriptive
- Check for background location and proper justification:
  - Flutter: `geolocator`, `location`, `background_locator`
  - RN/Expo: `expo-location`, `react-native-geolocation-service`, `@react-native-community/geolocation`
  - Native: `CoreLocation`

**5.2 Intellectual Property:**
- Check for potentially copyrighted assets
- Look for hardcoded references to other brands/trademarks
- Verify app does not use third-party content (audio, video, images) without proper licensing
- Check for references to Apple trademarks used incorrectly (Guideline 5.2.5)

**5.3 Gaming, Gambling, and Lotteries:**
- If app involves real-money gaming, betting, poker, casino, horse racing, or lotteries:
  - Verify appropriate licensing exists (note as "Manual Check Required")
  - Verify app is geo-restricted to licensed jurisdictions
  - Verify app is free on the App Store (Guideline 5.3.4)
  - Verify app does NOT use IAP for real-money gambling credits (Guideline 5.3.3)
- Check for gambling-related packages/patterns:
  - Payment flows connected to game outcomes
  - "Bet", "wager", "casino", "poker", "lottery", "sweepstakes" in code/strings
- If app has sweepstakes/contests, verify official rules are presented in-app and state Apple is not a sponsor (Guideline 5.3.1, 5.3.2)

**5.4 VPN Apps:**
- If app provides VPN services:
  - Verify it uses `NEVPNManager` API (Guideline 5.4)
  - Verify developer is enrolled as an organization (not individual)
  - Verify clear data collection disclosure is shown before purchase/use
  - Verify privacy policy commits to not selling/sharing data with third parties
  - If available in territories requiring VPN license, verify license info in App Review Notes
- Check for VPN-related packages:
  - Native: `NetworkExtension`, `NEVPNManager`, `NETunnelProviderManager`
  - Flutter: `flutter_vpn`, `wireguard_flutter`
  - RN: `react-native-vpn`

**5.5 Mobile Device Management (MDM):**
- If app offers MDM services:
  - Verify it is offered by a commercial enterprise, educational institution, or government agency
  - Verify clear data collection disclosure before purchase/use
  - Verify privacy policy commits to not selling/sharing data
  - Verify app does not collect/transmit data beyond MDM app performance (no user/device profiling)
- Check for MDM-related entitlements and profiles in the project

**5.6 Developer Code of Conduct:**
- Check for patterns that manipulate users:
  - Dark patterns in subscription/purchase flows (e.g., hidden cancel buttons, misleading "free trial" that auto-charges)
  - Forced ratings or reviews (Guideline 3.2.2(x))
  - Fake urgency or scarcity tactics in UI strings
- Verify app does not contain scam or bait-and-switch patterns
- Check for review manipulation code (fake reviews, incentivized reviews)

### Step 7: Common Rejection Reasons Quick-Check

Run these fast checks for the most common rejection reasons:

1. **Crashes/Bugs** — Look for risky patterns:
   - Swift: force unwraps (`!`) overuse
   - Dart: `!` operator on nullable types overuse
   - JS/TS: unhandled promise rejections, missing error boundaries
2. **Broken Links** — Search for hardcoded URLs; verify they look valid and are HTTPS
3. **Incomplete Configuration** — All required Info.plist / app.json keys present
4. **Missing Privacy Descriptions** — All usage descriptions for used permissions
5. **No Privacy Policy URL** — Check if referenced anywhere:
   - Expo: `app.json` → `expo.ios.privacyManifests` or privacy policy in settings
   - Flutter: look for privacy policy URL in app
   - All: search for "privacy policy", "privacyPolicy" in code/config
6. **Debug/Test Code Left In** — Debug flags, print/console.log, staging URLs, localhost
7. **Hardcoded Credentials** — API keys, passwords, tokens in source (check `.env` files too)
8. **Missing Sign in with Apple** — When ANY third-party login is used
9. **Missing Account Deletion** — When account creation exists
10. **Missing Privacy Manifest** — `PrivacyInfo.xcprivacy` existence and completeness

## Output Format

Present your findings as a structured compliance report:

```
# App Store Review Compliance Report

## Project Summary
- **App Name:** [name]
- **Bundle ID:** [id]
- **Framework:** [Flutter / React Native / Expo / Swift / etc.]
- **Deployment Target:** [version]
- **Platforms:** [iOS/iPadOS/macOS/etc.]

## Critical Issues (Will Likely Cause Rejection)
Issues that will almost certainly cause App Store rejection.

### [CRITICAL] Guideline X.X.X — [Title]
**Issue:** [Description]
**Location:** [File:Line]
**Fix:** [Recommended fix, specific to the framework being used]

## Warnings (May Cause Rejection)
Issues that could cause rejection depending on reviewer interpretation.

### [WARNING] Guideline X.X.X — [Title]
**Issue:** [Description]
**Location:** [File:Line]
**Fix:** [Recommended fix]

## Recommendations (Best Practices)
Not strict violations but recommended improvements.

### [INFO] Guideline X.X.X — [Title]
**Suggestion:** [Description]

## Checklist Summary
- [ ] Project type & framework detected
- [ ] Info.plist / app.json metadata complete
- [ ] All NS*UsageDescription keys present for used permissions
- [ ] No hardcoded secrets or API keys in source
- [ ] App Transport Security properly configured
- [ ] Privacy manifest (PrivacyInfo.xcprivacy) present and complete
- [ ] Sign in with Apple implemented (if third-party login exists)
- [ ] Account deletion available (if account creation exists)
- [ ] In-App Purchase used for digital goods (no external payment for digital content)
- [ ] Restore Purchases mechanism exists (if IAP/subscriptions present)
- [ ] Subscription terms clearly displayed before purchase
- [ ] No debug/test code in production paths
- [ ] No placeholder or TODO content in UI
- [ ] No "beta" / "trial" / "demo" labels in production app
- [ ] Privacy policy URL referenced in app
- [ ] App Tracking Transparency implemented (if tracking/ad SDKs present)
- [ ] UGC moderation in place (if user-generated content exists)
- [ ] Developer contact / support URL accessible in-app
- [ ] Extensions comply with extension guidelines (if applicable)
- [ ] Apple Pay branding and disclosures correct (if applicable)
- [ ] No monetization of built-in OS capabilities
- [ ] Health data not used for ads/marketing (if HealthKit used)
- [ ] Kids privacy compliance (if app targets children)
- [ ] Gambling/lottery properly licensed and geo-restricted (if applicable)
- [ ] VPN uses NEVPNManager and org account (if applicable)
- [ ] No dark patterns or manipulative UI in purchase flows

## Final Verdict
READY / NEEDS FIXES / HIGH RISK — with summary
```

## Important Notes

- Be thorough but avoid false positives — only flag genuine concerns
- Always reference the specific guideline number (e.g., "Guideline 2.5.6")
- Provide actionable fix suggestions **specific to the detected framework** (e.g., for Flutter suggest Dart solutions, for Expo suggest config plugin solutions)
- Prioritize critical issues that commonly cause rejections
- If you cannot determine something from code alone (e.g., actual App Store metadata), note it as "Manual Check Required"
- Consider the app's context — a medical app has different requirements than a game
- For cross-platform projects, check BOTH the shared code AND the iOS-specific native layer
