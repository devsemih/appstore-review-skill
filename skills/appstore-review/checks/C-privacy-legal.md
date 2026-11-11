# Checks C — Privacy & Legal (Section 5)

Check instructions for one slice of the `/appstore-review` audit. Use with the **Project Facts** you were given and the guideline text in `5-legal.md` (under the plugin's `references/appstore/`). Report findings in the exact finding format and evidence rules you were given. These are *detection hints*, not verdicts: a grep hit is only a finding once you have read the surrounding code and confirmed it applies.

## Privacy & Legal Checks (Section 5)

**Build inspection (when provided):** If the orchestrator passed you output from `scripts/inspect-ios-build.sh`, treat `POSSIBLE ITMS-91053:` (required-reason API used without declaration), `POSSIBLE ITMS-91061:` (listed third-party SDK without privacy manifest) and `POSSIBLE ITMS-90683:` (API referenced without purpose string) lines as strong evidence for 5.1.1 privacy-manifest findings (Confidence: High when the symbol and the missing declaration are both shown). Also cross-check the built Info.plist usage strings and entitlements against source config — the build is what Apple reviews.

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
