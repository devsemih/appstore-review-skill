# Answer key: swiftui-clean-app ("Pebble Journal")

A deliberately **compliant** native SwiftUI app (iOS 17, iPhone + iPad). It measures **false positives**: a good audit should give a low-risk verdict with no CRITICAL findings and at most a couple of minor warnings.

## Compliance features (each has a decoy grader)

| Area | Guideline | Implementation |
|------|-----------|----------------|
| Login | 4.8 | Sign in with Apple only (`Auth/SignInView.swift`, `Pebble.entitlements`). No third-party login, so nothing else is required |
| Account deletion | 5.1.1(v) | Settings → "Delete Account" + confirmation → `DELETE /account`; server revokes the SIWA token (`Auth/AuthService.swift`, `Settings/SettingsView.swift`) |
| Subscriptions | 3.1.1 / 3.1.2 | StoreKit 2 only (`Store/StoreManager.swift`). Restore Purchases (`AppStore.sync()`) on the paywall and in Settings. Price + period + auto-renew/cancel terms + Terms of Use (Apple EULA) and Privacy links shown above the Subscribe button (`Store/PaywallView.swift`). Periods P1M / P1Y (`Store/Pebble.storekit`) |
| Privacy manifest | 5.1.1 / 5.1.2 | `Pebble/PrivacyInfo.xcprivacy`: tracking false, collected types declared, UserDefaults `CA92.1` (used in `Security/AppLock.swift`) |
| Purpose strings | 5.1.1 | `NSFaceIDUsageDescription` (meaningful). `PhotosPicker` needs no photo-library string |
| Tracking | 5.1.2 | No ad/analytics SDKs, so no ATT needed |
| Security | 1.6 | HTTPS only, no ATS exceptions, session token in Keychain |
| Metadata | 2.3 | Display name "Pebble Journal" (14 chars), version/build set, `ITSAppUsesNonExemptEncryption` false |
| Support / privacy | 1.5 / 5.1.1(i) | Privacy, Terms, Support links in sign-in, paywall and Settings |

## Graders

- `no-critical-findings`: no CRITICAL items.
- `few-warnings`: at most 2 WARNING items.
- `verdict-low-risk`: verdict is LOW RISK (or READY).
- `no-fp-sign-in-with-apple`, `no-fp-restore-and-terms`, `no-fp-account-deletion`, `no-fp-privacy-manifest`, `no-fp-usage-descriptions-and-att`: these specific areas are not flagged as CRITICAL/WARNING.

## Acceptable observations (not penalised)

Manual-check items an auditor cannot verify from code are fine as recommendations or "Manual Check Required": App Store Connect privacy labels, the content of the hosted privacy policy, and whether the backend really revokes the Apple token. Journal entries are kept in memory in this fixture. A note about persistence/sync is fine as INFO.
