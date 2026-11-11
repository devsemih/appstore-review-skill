# Checks B — Business (Section 3) & Design (Section 4)

Check instructions for one slice of the `/appstore-review` audit. Use with the **Project Facts** you were given and the guideline text in `3-business.md, 4-design.md` (under the plugin's `references/appstore/`). Report findings in the exact finding format and evidence rules you were given. These are *detection hints*, not verdicts: a grep hit is only a finding once you have read the surrounding code and confirmed it applies.

## Business Checks (Section 3)

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

**Guideline 3.1.1(a) — Links to Other Purchase Methods (updated October 2026):**
- Detect external purchase links: `ExternalPurchaseLink` / `ExternalPurchase` StoreKit APIs, `com.apple.developer.storekit.external-purchase*` entitlements, buy buttons opening web checkout (`Linking.openURL`, `SFSafariViewController`, `UIApplication.open`) near paywalls.
- If present → read the current 3.1.1(a) text: links must go to a *permitted destination* and use the right entitlement for the storefront (the Music Streaming Services Entitlement is now part of the External Purchase Link bullet; US storefront rules differ). Storefront/entitlement setup is a Manual Check Required item — don't mark it CRITICAL unless digital goods are sold externally with no IAP and no entitlement at all.

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

## Design Checks (Section 4)

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

**Guideline 4.3 — Spam (rewritten October 2026):**
- **(4.3a)** Detect white-label / multi-bundle setups producing near-identical apps: multiple Xcode targets or schemes with different bundle IDs but shared code, Flutter flavors, Expo `app.config.js` variants driven by env (`APP_VARIANT`, per-city/team/brand configs), multiple `eas.json` profiles with different `bundleIdentifier`s. Flag as WARNING with advice to ship one app with in-app variations.
- **(4.3b)** If the app is in a saturated category (dating, flashlight, sound effects, wallpaper, simple timer, fortune telling) → WARNING: needs a meaningfully different experience; note it in Manual Check Required. Drinking games, Kama Sutra, fart/burp apps → HIGH RISK.
- Detect app-builder/template markers (see 4.2.6).

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
- **(4.5.3)** Scan for bulk push notification patterns, Game Center spam, and **Live Activities** (ActivityKit / push-to-start tokens) used for promotions or marketing rather than an ongoing user-initiated activity
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
- **If ANY third-party/social login sets up the primary account → verify an equivalent privacy-focused login is offered** (limits data to name + email, allows private email, no ad tracking without consent). Sign in with Apple satisfies this and is the usual fix; report the guideline accurately rather than claiming Sign in with Apple is the only option.
- Login services listed in the guideline include Facebook Login, Google Sign-In, **Log in with X**, Sign In with LinkedIn, Login with Amazon, WeChat Login.
- Check for `AuthenticationServices` framework
- Exceptions (read the full list under 4.8 in `4-design.md`): app uses only the developer's own account system; alternative-marketplace distribution; education/enterprise accounts; government/industry citizen ID or e-ID; client for a specific third-party service (e.g. a mail/social client using that service's login). If an exception plausibly applies, downgrade to Manual Check Required.

**Guideline 4.9 — Apple Pay:**
- Detect: Native `PassKit`, `PKPaymentAuthorizationViewController` | Flutter: `pay` | RN/Expo: `@stripe/stripe-react-native` Apple Pay, `react-native-payments`
- If found, verify recurring payment disclosures in UI

**Guideline 4.10 — Monetizing Built-In Capabilities:**
- Search for paywalls/IAP gates around native device features (camera, push, gyroscope, iCloud, Screen Time)
