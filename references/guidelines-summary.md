# Apple App Store Review Guidelines - Quick Reference

> Last updated based on Apple's published guidelines. Always verify against the
> latest version at https://developer.apple.com/app-store/review/guidelines/

## Section 1: Safety

| Guideline | Topic | Key Requirement |
|-----------|-------|-----------------|
| 1.1 | Objectionable Content | No offensive, discriminatory, violent, sexual, or misleading content |
| 1.1.6 | False Information | No fake functionality, anonymous prank calls/SMS |
| 1.2 | User-Generated Content | Must have filtering, reporting, blocking, and contact info |
| 1.2.1 | Creator Content | Must moderate; age restriction mechanisms required |
| 1.3 | Kids Category | No third-party analytics/ads; no personal info collection |
| 1.4.1 | Medical Apps | Cannot measure vitals with sensors alone; need disclaimers |
| 1.4.3 | Substance Content | No tobacco/vape/drug/alcohol encouragement |
| 1.5 | Developer Info | Must include accessible contact information |
| 1.6 | Data Security | Implement proper security measures for user data |

## Section 2: Performance

| Guideline | Topic | Key Requirement |
|-----------|-------|-----------------|
| 2.1 | Completeness | App must be final, functional, no placeholders |
| 2.2 | Beta Testing | Use TestFlight, not App Store |
| 2.3.1 | Hidden Features | No undocumented features |
| 2.3.6 | Age Rating | Must be accurate |
| 2.3.7 | Metadata | Unique name ≤30 chars; no keyword stuffing |
| 2.4.1 | iPad Support | iPhone apps should run on iPad |
| 2.4.2 | Power Efficiency | No battery drain, excessive heat, crypto mining |
| 2.5.1 | Public APIs Only | No private APIs; run on current OS |
| 2.5.2 | Self-Contained | No downloading executable code |
| 2.5.4 | Background Services | Only for VoIP, audio, location, task completion |
| 2.5.5 | IPv6 | Must work on IPv6-only networks |
| 2.5.6 | Web Browsers | Must use WebKit (or apply for alternative engine entitlement) |
| 2.5.14 | Recording Consent | Explicit consent + visual/audible indicator |
| 2.5.18 | Advertising | Only in main app binary; age-appropriate; allow reporting |

## Section 3: Business

| Guideline | Topic | Key Requirement |
|-----------|-------|-----------------|
| 3.1.1 | In-App Purchase | Digital goods/features must use IAP |
| 3.1.1 | Loot Boxes | Must disclose odds before purchase |
| 3.1.2 | Subscriptions | Must provide ongoing value; ≥7 day periods |
| 3.1.2(c) | Sub Info | Clearly describe what users get before purchase |
| 3.1.3(a) | Reader Apps | Can access previously purchased content |
| 3.1.3(d) | P2P Services | Person-to-person can use external payment |
| 3.1.3(e) | Physical Goods | Must use non-IAP payment |
| 3.1.5 | Crypto | Wallets OK (org enrolled); no on-device mining |
| 3.2.2(iii) | Ad Fraud | No artificial impressions/clicks |
| 3.2.2(ix) | Loans | Max 36% APR; no ≤60 day repayment |
| 3.2.2(x) | Forced Actions | Cannot force rating/reviewing/downloading |

## Section 4: Design

| Guideline | Topic | Key Requirement |
|-----------|-------|-----------------|
| 4.1 | Copycats | Must be original; no impersonation |
| 4.2 | Min Functionality | More than a repackaged website |
| 4.2.6 | Templates | No template-generated apps (unless from content provider) |
| 4.3 | Spam | Single bundle ID per app concept |
| 4.7 | Mini Apps/Emulators | Must follow privacy, content moderation, and payment rules |
| 4.8 | Login Services | Sign in with Apple required if third-party login exists |
| 4.9 | Apple Pay | Disclose recurring payment terms |
| 4.10 | Built-in Capabilities | Cannot monetize OS features |

## Section 5: Legal / Privacy

| Guideline | Topic | Key Requirement |
|-----------|-------|-----------------|
| 5.1.1(i) | Privacy Policy | Required in App Store Connect and in-app |
| 5.1.1(ii) | Consent | Must get user consent for data collection |
| 5.1.1(iii) | Data Minimization | Only collect what's needed |
| 5.1.1(v) | Account Deletion | Must offer if account creation exists |
| 5.1.2(i) | Tracking | ATT required; no tracking without permission |
| 5.1.3 | Health Data | Cannot use for ads/marketing; extra consent rules |
| 5.1.4 | Kids Privacy | COPPA/GDPR compliance; parental gates |
| 5.1.5 | Location | Must explain purpose; consent required |
| 5.2.1 | IP Rights | No unauthorized trademarks/copyrights |
| 5.2.3 | Downloads | No illegal file sharing |

## Top 10 Rejection Reasons (Common)

1. **Guideline 2.1** — App not complete / crashes / bugs
2. **Guideline 2.3** — Inaccurate or incomplete metadata
3. **Guideline 4.2** — Minimum functionality not met (web wrapper)
4. **Guideline 5.1.1** — Missing or inadequate privacy policy
5. **Guideline 5.1.1(v)** — Missing account deletion
6. **Guideline 4.8** — Missing Sign in with Apple
7. **Guideline 2.5.1** — Use of private APIs
8. **Guideline 3.1.1** — Digital purchases not using IAP
9. **Guideline 2.3.7** — Keyword stuffing or misleading metadata
10. **Guideline 5.1.2** — Missing ATT for tracking/advertising

## Privacy Manifest Required API Categories

Apps must declare reasons for using these API categories in `PrivacyInfo.xcprivacy`:

1. **File timestamp APIs** — `NSFileCreationDate`, `NSFileModificationDate`, etc.
2. **System boot time APIs** — `systemUptime`, `mach_absolute_time`
3. **Disk space APIs** — `volumeAvailableCapacityKey`, `FileManager` disk queries
4. **Active keyboards API** — `UITextInputMode.activeInputModes`
5. **User defaults APIs** — `UserDefaults` (when accessed by third-party SDKs)
