# appstore-review-skill

> A Claude Code plugin that audits your mobile app against store review policies — **before** the store rejects it.

Two skills, one plugin:

| Command | Store | Based On |
|---------|-------|----------|
| `/appstore-review` | Apple App Store | [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) |
| `/playstore-review` | Google Play | [Developer Program Policies](https://play.google/developer-content-policy/) |

Stop guessing. Run the command and get a full compliance report in seconds.

---

## Supported Frameworks

Both skills auto-detect your project type and adapt all checks accordingly:

| Framework | Detection |
|-----------|-----------|
| **Swift / SwiftUI / UIKit** | `.xcodeproj`, `.swift` files |
| **Kotlin / Java (native Android)** | `build.gradle(.kts)`, `AndroidManifest.xml` |
| **Flutter** | `pubspec.yaml`, `ios/Runner/`, `android/app/` |
| **React Native** | `package.json` + `react-native` |
| **Expo** | `app.json` / `app.config.js` + `expo` |
| **Kotlin Multiplatform** | `build.gradle.kts` + `iosApp/` / `androidApp/` |
| **.NET MAUI** | `.csproj` + `Platforms/iOS/` / `Platforms/Android/` |
| **Cordova / Ionic / Capacitor** | `config.xml`, `capacitor.config.ts` |
| **Unity** | `ProjectSettings/`, Xcode/Gradle export |

## Installation

### Via Plugin Manager (Recommended)

```
/plugin marketplace add devsemih/appstore-review-skill
/plugin install appstore-review-skill
```

### Via Git Clone

**Global (all projects):**

```bash
git clone https://github.com/devsemih/appstore-review-skill ~/.claude/skills/appstore-review-skill
```

**Project-specific:**

```bash
git clone https://github.com/devsemih/appstore-review-skill .claude/skills/appstore-review-skill
```

Then restart Claude Code.

## Updating

### Plugin Manager

```
/plugin marketplace update
```

### Git Clone

```bash
cd ~/.claude/skills/appstore-review-skill && git pull
```

## Usage

Open your project in Claude Code and run:

```
/appstore-review     # audit against Apple's App Store guidelines
/playstore-review    # audit against Google Play policies
```

That's it. The skill will scan your project and output a structured compliance report.

---

## `/appstore-review` — What Gets Checked

### Section 1 — Safety
- Objectionable content in strings and resources
- User-generated content moderation (filtering, reporting, blocking)
- Kids Category compliance (no third-party analytics/ads)
- Medical app disclaimers and physical harm checks
- Developer contact / support URL accessibility
- Data security (ATS, hardcoded secrets, secure storage)
- Criminal activity reporting app restrictions

### Section 2 — Performance
- App completeness (TODOs, placeholders, debug code, staging URLs)
- Beta / trial / demo labels in production app (must use TestFlight)
- Info.plist / app.json required keys and usage descriptions
- iPad support and adaptive layout
- Private API usage, IPv6 compatibility
- All `NS*UsageDescription` keys cross-checked against actual SDK usage

### Section 3 — Business
- In-App Purchase compliance (digital goods must use IAP)
- Restore Purchases mechanism and subscription terms display
- Detection of Stripe/PayPal for digital content (violation)
- Loot box odds disclosure
- Review prompt abuse

### Section 4 — Design
- Minimum functionality (web wrapper detection)
- **Sign in with Apple** — required when any third-party login exists
- Bundle ID uniqueness
- Extension compliance (keyboard, Safari, widgets, App Clips)
- Apple Sites and Services (Push Notification abuse, Apple Music rules)
- Apple Pay branding and recurring payment disclosures
- No monetization of built-in OS/hardware capabilities

### Section 5 — Privacy & Legal
- `PrivacyInfo.xcprivacy` existence and completeness
- Required API reason declarations
- **Account deletion** — required when account creation exists
- App Tracking Transparency for ad/analytics SDKs
- Health data protection (no ads/marketing use of HealthKit data)
- Kids privacy (COPPA, GDPR children's provisions)
- Location services justification
- Hardcoded credentials and `.env` file exposure
- Intellectual property and third-party content usage
- Gaming, gambling, and lottery compliance
- VPN app requirements (NEVPNManager API)
- Mobile Device Management (MDM) restrictions
- Developer Code of Conduct (dark patterns, scam detection)

### Quick-Check — Top 10 App Store Rejection Reasons
1. Crashes / risky code patterns
2. Broken or HTTP links
3. Incomplete metadata
4. Missing privacy descriptions
5. No privacy policy URL
6. Debug / test code left in production
7. Hardcoded API keys and secrets
8. Missing Sign in with Apple
9. Missing account deletion
10. Missing privacy manifest

---

## `/playstore-review` — What Gets Checked

### Privacy & User Data
- Privacy policy linked in-app (required in listing AND in app)
- **Data safety consistency** — every data-collecting SDK cross-checked against what must be declared in the Data safety form
- Prominent disclosure & consent before sensitive data collection
- **Account deletion** — in-app deletion + web resource required when account creation exists
- Advertising ID (`AD_ID`) usage and Android 13+ requirements

### Permissions & Sensitive APIs
- **SMS & Call Log** restrictions (with SMS Retriever API alternatives)
- `QUERY_ALL_PACKAGES`, `MANAGE_EXTERNAL_STORAGE` — declaration-gated permissions
- Accessibility API misuse detection
- **Background location** — justification, declaration, prominent disclosure
- Photo/Video permissions vs. Android photo picker
- Foreground service types (Android 14+), exact alarms, full-screen intent
- VPN service, overlay, and package-install permission checks
- Unused-permission detection (minimal permission principle)

### Monetization & Ads
- **Google Play Billing** compliance (digital goods must use Play Billing)
- Detection of Stripe/PayPal for digital content (violation)
- Subscription terms, trial disclosure, easy cancellation
- Disruptive ads (unexpected interstitials, lockscreen ads, hidden ads)
- Consent (UMP/CMP) before ad personalization
- Loot box odds disclosure, review prompt manipulation

### Restricted Content
- Financial services (loan app rules: APR caps, repayment periods, prohibited permissions)
- Real-money gambling licensing and geo-restrictions
- User-generated content moderation (report, block, filter)
- Health Connect restricted data use
- Blockchain/NFT declarations
- **AI-generated content** reporting mechanism requirement

### Device Abuse & Deception
- Dynamic code loading from outside Play (dex/native code)
- Hidden features and kill switches (post-review unlocks)
- Ad fraud patterns, overlay abuse
- Fake system dialogs, cleaner/booster scams
- Malware / MUwS basics (icon hiding, device admin abuse)

### Families & Kids
- Families Self-Certified Ads SDKs only
- No AAID / location for child-directed apps
- `tagForChildDirectedTreatment` verification
- Neutral age screens for mixed audiences

### Store Listing & Technical
- **Target API level** requirement
- Metadata policy (title length, emoji, promo language)
- Webview-wrapper / minimum functionality detection
- `debuggable`, cleartext traffic, committed keystores
- Hardcoded secrets and staging URLs

### Quick-Check — Top 10 Play Rejection/Removal Reasons
1. Data safety form mismatch
2. Restricted permissions without declaration
3. Background location without justification
4. Play Billing bypass
5. Missing account deletion
6. Target API level too old
7. Missing privacy policy
8. Families policy violations
9. Disruptive ads
10. Minimum functionality (webview wrappers)

---

## Example Reports

<details>
<summary><b>Swift / SwiftUI Project (App Store)</b></summary>

```
# App Store Review Compliance Report

## Project Summary
- App Name: MyApp
- Bundle ID: com.example.myapp
- Framework: Swift / SwiftUI
- Deployment Target: iOS 16.0

## Critical Issues

### [CRITICAL] Guideline 4.8 — Sign in with Apple Required
Issue: App uses Google Sign-In but does not implement Sign in with Apple
Location: AuthManager.swift:45
Fix: Add ASAuthorizationAppleIDProvider flow alongside Google Sign-In

### [CRITICAL] Guideline 5.1.1(v) — Account Deletion Missing
Issue: App has account creation but no account deletion feature
Location: SettingsView.swift
Fix: Add "Delete Account" option in settings with server-side deletion

## Final Verdict: NEEDS FIXES — 2 critical issues must be resolved
```
</details>

<details>
<summary><b>Kotlin Project (Google Play)</b></summary>

```
# Google Play Policy Compliance Report

## Project Summary
- App Name: MyApp
- Application ID: com.example.myapp
- Framework: Native Kotlin
- Target SDK: 34 / Min SDK: 24
- Declared Permissions: 9 (2 restricted)

## Critical Issues

### [CRITICAL] Policy: Permissions — QUERY_ALL_PACKAGES Without Qualifying Use Case
Issue: Manifest declares QUERY_ALL_PACKAGES but the app is not a launcher/security app
Location: app/src/main/AndroidManifest.xml:12
Fix: Replace with a <queries> element listing the specific packages you interact with

### [CRITICAL] Policy: User Data — Account Deletion Missing
Issue: Firebase Auth signup exists but no in-app account deletion found
Location: app/src/main/java/.../SettingsActivity.kt
Fix: Add "Delete Account" flow calling currentUser.delete() + declare a web deletion resource in the Data safety form

## Declarations Required in Play Console
- [ ] Data safety form: Firebase Analytics (device IDs, app interactions)

## Final Verdict: NEEDS FIXES — 2 critical issues must be resolved
```
</details>

<details>
<summary><b>Flutter Project (Google Play)</b></summary>

```
# Google Play Policy Compliance Report

## Project Summary
- App Name: MyFlutterApp
- Application ID: com.example.myflutterapp
- Framework: Flutter 3.x
- Target SDK: 34 / Min SDK: 23

## Critical Issues

### [CRITICAL] Policy: Background Location — Undeclared Use
Issue: ACCESS_BACKGROUND_LOCATION declared but no core feature requires it
Location: android/app/src/main/AndroidManifest.xml:8
Fix: Remove the permission, or justify it via the Play Console declaration + prominent in-app disclosure

## Warnings

### [WARNING] Policy: Ads — Consent Before Personalization
Issue: google_mobile_ads initialized before any consent flow (UMP not found)
Location: lib/main.dart:22
Fix: Integrate the User Messaging Platform and gate ad requests on consent

## Final Verdict: NEEDS FIXES
```
</details>

<details>
<summary><b>Expo Project (App Store)</b></summary>

```
# App Store Review Compliance Report

## Project Summary
- App Name: MyExpoApp
- Bundle ID: com.example.myexpoapp
- Framework: Expo SDK 52 (managed workflow)
- Deployment Target: iOS 15.0

## Critical Issues

### [CRITICAL] Guideline 4.8 — Sign in with Apple Required
Issue: expo-auth-session used for Google OAuth but expo-apple-authentication not found
Location: app/(auth)/login.tsx:23
Fix: npx expo install expo-apple-authentication and add Apple sign-in button

## Final Verdict: NEEDS FIXES
```
</details>

## Policy Coverage & Versions

| Skill | Source | Version |
|-------|--------|---------|
| `/appstore-review` | [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) — Sections 1–5 | February 6, 2026 |
| `/playstore-review` | [Google Play Developer Program Policies](https://play.google/developer-content-policy/) — all policy areas | July 2026 |

Apple and Google update these policies periodically — if you encounter a mismatch, please open an issue or PR.

## Contributing

PRs welcome. Here's how you can help:

- **Add checks** — Found a rejection reason not covered? Add it to `skills/appstore-review/SKILL.md` or `skills/playstore-review/SKILL.md`
- **Reduce false positives** — Help make detection more precise
- **Update guidelines** — Apple and Google update their policies periodically
- **Share rejection stories** — Real-world examples help everyone

## License

MIT — see [LICENSE](LICENSE)

---

**Disclaimer:** This plugin checks against publicly available Apple and Google policies. It does not guarantee store approval. Always review the official [App Store guidelines](https://developer.apple.com/app-store/review/guidelines/) and [Google Play policies](https://play.google/developer-content-policy/) before submission.
