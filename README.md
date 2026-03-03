# appstore-review-skill

> A Claude Code plugin that audits your iOS app against Apple's App Store Review Guidelines — **before** Apple rejects it.

Stop guessing. Run `/appstore-review-skill:appstore-review` and get a full compliance report in seconds.

---

## Supported Frameworks

This skill auto-detects your project type and adapts all checks accordingly:

| Framework | Detection |
|-----------|-----------|
| **Swift / SwiftUI / UIKit** | `.xcodeproj`, `.swift` files |
| **Flutter** | `pubspec.yaml`, `ios/Runner/` |
| **React Native** | `package.json` + `react-native` |
| **Expo** | `app.json` / `app.config.js` + `expo` |
| **Kotlin Multiplatform** | `build.gradle.kts` + `iosApp/` |
| **.NET MAUI** | `.csproj` + `Platforms/iOS/` |
| **Cordova / Ionic / Capacitor** | `config.xml`, `capacitor.config.ts` |
| **Unity** | `ProjectSettings/`, Xcode export |

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
/appstore-review-skill:appstore-review
```

That's it. The skill will scan your project and output a structured compliance report.

## What Gets Checked

### Section 1 — Safety
- Objectionable content in strings and resources
- User-generated content moderation (filtering, reporting, blocking)
- Kids Category compliance (no third-party analytics/ads)
- Medical app disclaimers
- Data security (ATS, hardcoded secrets, secure storage)

### Section 2 — Performance
- App completeness (TODOs, placeholders, debug code, staging URLs)
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

### Section 5 — Privacy & Legal
- `PrivacyInfo.xcprivacy` existence and completeness
- Required API reason declarations
- **Account deletion** — required when account creation exists
- App Tracking Transparency for ad/analytics SDKs
- Location services justification
- Hardcoded credentials and `.env` file exposure

### Quick-Check — Top 10 Rejection Reasons
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

## Example Reports

<details>
<summary><b>Swift / SwiftUI Project</b></summary>

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
<summary><b>Flutter Project</b></summary>

```
# App Store Review Compliance Report

## Project Summary
- App Name: MyFlutterApp
- Bundle ID: com.example.myflutterapp
- Framework: Flutter 3.x
- Deployment Target: iOS 15.0

## Critical Issues

### [CRITICAL] Guideline 5.1.1(v) — Account Deletion Missing
Issue: App uses firebase_auth for sign-up but no delete account flow found
Location: lib/features/auth/
Fix: Add account deletion calling FirebaseAuth.instance.currentUser?.delete()

## Warnings

### [WARNING] Guideline 1.6 — Hardcoded API Key
Issue: Stripe publishable key found in source code
Location: lib/services/payment_service.dart:12
Fix: Move to --dart-define or .env via flutter_dotenv

## Final Verdict: NEEDS FIXES
```
</details>

<details>
<summary><b>Expo Project</b></summary>

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

## Warnings

### [WARNING] Guideline 2.3 — Missing Privacy Description
Issue: expo-camera installed but no camera usage description in app.json
Location: app.json
Fix: Add expo.ios.infoPlist.NSCameraUsageDescription to app.json

## Final Verdict: NEEDS FIXES
```
</details>

## Guidelines Coverage

Based on Apple's [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/):

| Section | Coverage |
|---------|----------|
| 1. Safety | 1.1 — 1.7 |
| 2. Performance | 2.1 — 2.5 |
| 3. Business | 3.1 — 3.2 |
| 4. Design | 4.1 — 4.10 |
| 5. Legal | 5.1 — 5.2 |

## Guidelines Version

This skill is based on Apple's **App Store Review Guidelines as of February 6, 2026**. Apple updates these guidelines periodically — if you encounter a mismatch, please open an issue or PR.

## Contributing

PRs welcome. Here's how you can help:

- **Add checks** — Found a rejection reason not covered? Add it to `skills/appstore-review/SKILL.md`
- **Reduce false positives** — Help make detection more precise
- **Update guidelines** — Apple updates their guidelines periodically
- **Share rejection stories** — Real-world examples help everyone

## License

MIT — see [LICENSE](LICENSE)

---

**Disclaimer:** This skill checks against publicly available Apple guidelines. It does not guarantee App Store approval. Always review the [official guidelines](https://developer.apple.com/app-store/review/guidelines/) before submission.
