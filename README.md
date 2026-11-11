# App Store & Google Play Rejection Checker for Claude Code

> Catch App Store and Google Play rejections **before** you submit, and fix them fast when they happen anyway.

[![GitHub stars](https://img.shields.io/github/stars/devsemih/appstore-review-skill?style=flat)](https://github.com/devsemih/appstore-review-skill/stargazers)
[![Version](https://img.shields.io/github/v/release/devsemih/appstore-review-skill?label=version)](https://github.com/devsemih/appstore-review-skill/releases)
[![Apple guidelines](https://img.shields.io/badge/Apple%20guidelines-Oct%2016%2C%202026-black)](https://developer.apple.com/app-store/review/guidelines/)
[![Play policies](https://img.shields.io/badge/Play%20policies-Oct%2029%2C%202026-green)](https://play.google/developer-content-policy/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

A Claude Code plugin with four commands:

| Command | What it does |
|---------|--------------|
| `/appstore-review` | Audits your project (and optionally your built `.ipa`) against Apple's [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) |
| `/playstore-review` | Audits your project (and optionally your `.aab`/`.apk`) against Google Play's [Developer Program Policies](https://play.google/developer-content-policy/) |
| `/appstore-rejection` | Paste an App Review rejection to get the root cause in your code, a fix, and a ready-to-send Resolution Center reply |
| `/playstore-rejection` | Paste a Play policy email to get the root cause, a fix-or-appeal decision, the Play Console forms to update, and an appeal draft |

Works with **Swift, Kotlin, Flutter, React Native, Expo, Kotlin Multiplatform, .NET MAUI, Capacitor/Cordova/Ionic and Unity**.

## What's new in 2.0

- **Rejection responders.** `/appstore-rejection` and `/playstore-rejection` turn a rejection message into a diagnosis and a reply.
- **Binary inspection (`--build`).** Finds likely ITMS-91053 / ITMS-91061 privacy-manifest problems in third-party SDKs, and SDK-injected Android permissions, before Apple or Google email you about them.
- **`--fix`.** Applies safe fixes automatically (purpose strings, privacy manifest, ATS, unused permissions…). Larger changes are planned first and wait for your OK.
- **Up to date.** Covers Apple's **October 16, 2026** guidelines (AI content apps under 1.2, new 2.3.14 and 2.5.19, rewritten 4.3) and Google Play's **October 29, 2026** policy update.
- **Faster, quieter reports.** Three parallel subagents do the audit. Every finding has a confidence level and `file:line` evidence, every CRITICAL is re-verified before it's reported, and items for App Store Connect / Play Console get their own "Manual Check Required" section.

See the [CHANGELOG](CHANGELOG.md) for details.

## Installation

### Via Plugin Manager (Recommended)

```
/plugin marketplace add devsemih/appstore-review-skill
/plugin install appstore-review-skill
```

### Via Git Clone

```bash
git clone https://github.com/devsemih/appstore-review-skill ~/.claude/skills/appstore-review-skill
```

Then restart Claude Code. To update, run `/plugin marketplace update` (or `git pull` in the clone).

## Usage

Open your project in Claude Code:

```
/appstore-review                                   # audit the current project for the App Store
/appstore-review --build build/MyApp.ipa           # also inspect the built binary (ITMS-91053/91061)
/appstore-review --fix                             # audit, then apply safe fixes
/playstore-review --build app/build/outputs/bundle/release/app-release.aab
```

Got rejected? Paste the message:

```
/appstore-rejection Guideline 5.1.1(v) - Data Collection and Storage. We noticed that your app supports account creation but does not include an option to initiate account deletion…
/playstore-rejection path/to/policy-email.txt
```

You get the cited rule, the root cause with `file:line`, a fix (applied only after you confirm), and a reply you can paste into the Resolution Center or the Play Console appeal form.

## How it works

```
1. Detect     framework, config files, dependencies, and features  →  one "Project Facts" summary
2. Inspect    (optional) the built .ipa / .aab: what the store actually reviews
3. Audit      3 subagents in parallel, each loading only its slice of the guidelines
                A: Safety + Performance    B: Business + Design    C: Privacy + Legal
4. Verify     every CRITICAL re-checked at its file:line, duplicates merged, top-10 gap check
5. Report     Critical / Warning / Info / Manual Check Required, verdict: LOW RISK · NEEDS FIXES · HIGH RISK
6. Fix        (--fix) safe fixes applied, bigger ones proposed, re-checked, Fix Summary table
```

The guideline text ships verbatim in [`references/`](references/), split by section and loaded on demand, so the skill quotes the actual rule rather than recalling it from memory.

## Accuracy

<!-- EVAL_RESULTS -->

The [`evals/`](evals/) suite runs the skills against fixture apps with planted violations and decoys (code that looks suspicious but is fine) using `claude plugin eval`. See [`evals/README.md`](evals/README.md) to run it yourself. False positive? [Report it](https://github.com/devsemih/appstore-review-skill/issues/new?template=false-positive.yml) and it becomes a regression test.

---

## `/appstore-review` — What Gets Checked

### Section 1 — Safety
- Objectionable content in strings and resources
- **UGC and AI content apps (1.2, updated Oct 2026)**: filtering, reporting, blocking, and safeguards against nonconsensual imagery
- Kids Category compliance (no third-party analytics/ads)
- Medical app disclaimers and physical harm checks
- Developer contact / support URL accessibility
- Data security (ATS, hardcoded server secrets, secure storage)

### Section 2 — Performance
- App completeness (placeholders, debug code, staging URLs)
- Beta / trial / demo labels in the production app (must use TestFlight)
- All `NS*UsageDescription` keys cross-checked against the SDKs actually used
- Other-platform references in **user-facing** text only (2.3.10)
- **Hidden / dormant features (2.5.19, new)**: reviewer detection, undisclosed remote unlocks
- iPad support, private APIs, dynamic code loading, background modes, IPv6

### Section 3 — Business
- In-App Purchase compliance (digital goods must use IAP); Stripe/PayPal for digital content
- External purchase links and entitlements (3.1.1(a), updated Oct 2026)
- Restore Purchases and subscription terms shown before the purchase button
- Loot box odds, review prompt abuse, crypto, loans, trading

### Section 4 — Design
- Minimum functionality (web wrapper detection, template apps)
- **Spam (4.3, rewritten Oct 2026)**: white-label / multi-bundle setups, saturated categories
- **Login services (4.8)**: an equivalent privacy-focused login when social login exists, with exceptions
- Extensions, App Clips, Live Activities and push abuse, Apple Pay, mini apps

### Section 5 — Privacy & Legal
- `PrivacyInfo.xcprivacy`, required-reason APIs, third-party SDK manifests (with `--build`: actual binary symbols)
- **Account deletion** when account creation exists
- App Tracking Transparency for ad/analytics SDKs
- Health, kids, and location data rules; IP; gambling; VPN; MDM; dark patterns

## `/playstore-review` — What Gets Checked

- **Privacy & user data:** privacy policy in-app, Data safety consistency per SDK, prominent disclosure, account deletion (in-app + web), Advertising ID
- **Permissions:** SMS/Call Log (incl. the Jan 2027 call-verification change), `QUERY_ALL_PACKAGES`, `MANAGE_EXTERNAL_STORAGE`, Accessibility, **new Local Network and Contacts declarations**, **location minimum scope / location button**, Photo Picker, foreground service types, exact alarms, full-screen intent, unused permissions
- **Monetization & ads:** Play Billing for digital goods, subscription and trial disclosures (incl. **eligibility-based discounts**), disruptive ads, UMP consent
- **Restricted content:** financial services and loan rules, gambling, UGC moderation, health, blockchain, **AI-generated content**, age-restricted features
- **Abuse & deception:** dynamic code loading, hidden features, review manipulation, **AppFunctions**, ad fraud, fake system dialogs, malware basics
- **Families:** certified ad SDKs only, no AAID for child-directed apps, neutral age screens
- **Technical:** target API level, `debuggable`, cleartext traffic, committed keystores and service-account keys, metadata policy

## Example Report

<details>
<summary><b>Expo project (App Store)</b></summary>

```
# App Store Review Compliance Report

## Project Summary
- App Name: MyExpoApp (9 chars)   Bundle ID: com.example.myexpoapp
- Framework: Expo SDK 57 (managed)   Deployment Target: iOS 16.0
- Build inspected: yes (build/MyExpoApp.ipa)   Guidelines version: October 16, 2026

## Summary
| Severity | Count |
|---|---|
| Critical | 2 |
| Warning | 1 |
| Info | 1 |
| Manual checks | 4 |

## Critical Issues (Will Likely Cause Rejection)

### [CRITICAL] Guideline 4.8 — Login Services
**Confidence:** High
**Issue:** Google sign-in creates the primary account; no equivalent privacy-focused login is offered.
**Evidence:** `app/(auth)/login.tsx:23` — `Google.useAuthRequest({...})`; searched for expo-apple-authentication / AppleAuthentication — none.
**Fix:** npx expo install expo-apple-authentication, add the Apple button, set ios.usesAppleSignIn: true.

### [CRITICAL] Guideline 5.1.1 — Privacy manifest (ITMS-91053)
**Confidence:** High
**Issue:** The binary uses file-timestamp APIs, but no manifest declares NSPrivacyAccessedAPICategoryFileTimestamp.
**Evidence:** build inspection — `POSSIBLE ITMS-91053: main binary references NSPrivacyAccessedAPICategoryFileTimestamp APIs (_stat ...) but no applicable privacy manifest declares this category`
**Fix:** Add the category with reason C617.1 under expo.ios.privacyManifests in app.json.

## Warnings (May Cause Rejection)

### [WARNING] Guideline 5.1.1(i) — Privacy policy link inside the app
**Confidence:** Medium
...

## Manual Check Required
- [ ] Demo account for the Supabase login in App Review Information
- [ ] Privacy nutrition label: crash data (Sentry), product interaction (PostHog)
- [ ] Describe the Remote Config–gated "Studio" feature in Notes for Review (2.3.1(a))
- [ ] Screenshots / creative assets follow 2.3.3 and 2.3.14

## Final Verdict
**HIGH RISK**: fix Sign in with Apple and the privacy manifest first; both are automatic rejections.

Run /appstore-review --fix to apply the safe fixes automatically (2 available).
```
</details>

<details>
<summary><b>Kotlin project (Google Play)</b></summary>

```
# Google Play Policy Compliance Report

## Project Summary
- App Name: MyApp   Application ID: com.example.myapp
- Framework: Native Kotlin   Target SDK / Min SDK: 35 / 24
- Declared Permissions: 9 (2 restricted)   Build inspected: yes (app-release.aab)

## Critical Issues (Will Likely Cause Rejection/Removal)

### [CRITICAL] Policy: Permissions — QUERY_ALL_PACKAGES Without Qualifying Use Case
**Confidence:** High
**Issue:** The merged manifest declares QUERY_ALL_PACKAGES; the app only opens two partner apps.
**Evidence:** `app/src/main/AndroidManifest.xml:12` — `<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"/>`
**Fix:** Replace it with a <queries> element listing the two packages.

### [CRITICAL] Policy: User Data — Account Deletion
**Confidence:** High
**Issue:** Firebase Auth sign-up exists, but there is no in-app or web account deletion.
**Evidence:** `auth/SignUpActivity.kt:41` — `createUserWithEmailAndPassword(...)`; searched for currentUser.delete, "delete account" — none.
**Fix:** Add a Delete account flow in Settings and the web deletion URL in the Data safety form.

## Declarations Required in Play Console
- [ ] Data safety: Firebase Analytics (app interactions, device IDs)
- [ ] Location permissions declaration (ACCESS_FINE_LOCATION, required for API 37+)

## Final Verdict
**HIGH RISK**: two critical issues must be resolved before submission.
```
</details>

## Policy Coverage & Versions

| Skill | Source | Version |
|-------|--------|---------|
| `/appstore-review`, `/appstore-rejection` | [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), Sections 1–5 (verbatim, split by section) | October 16, 2026 |
| `/playstore-review`, `/playstore-rejection` | [Google Play Developer Program Policies](https://play.google/developer-content-policy/), all policy areas (summary) | July 2026 + October 29, 2026 update |

Apple and Google update these policies several times a year. If you spot a mismatch, please open an issue or PR.

## Contributing

PRs welcome. The most useful contributions:

- **[Share a rejection](https://github.com/devsemih/appstore-review-skill/issues/new?template=rejection-report.yml).** Real rejections become new checks and eval cases.
- **[Report a false positive](https://github.com/devsemih/appstore-review-skill/issues/new?template=false-positive.yml).** It helps keep reports quiet.
- **Add checks:** `skills/*/checks/*.md` (detection hints) plus an eval case in `evals/`.
- **Update policies:** `references/appstore/` and `references/playstore/`.

## License

MIT, see [LICENSE](LICENSE).

---

**Disclaimer:** This plugin checks against publicly available Apple and Google policies. It does not guarantee store approval. Always review the official [App Store guidelines](https://developer.apple.com/app-store/review/guidelines/) and [Google Play policies](https://play.google/developer-content-policy/) before submission.
