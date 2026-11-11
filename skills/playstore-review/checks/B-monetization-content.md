# Checks B — Monetization, Ads & Restricted Content

Check instructions for one slice of the `/playstore-review` audit. Use with the **Project Facts** you were given and the policy text in `4-monetization-ads.md, 1-restricted-content.md` (under the plugin's `references/playstore/`). Report findings in the exact finding format and evidence rules you were given. These are *detection hints*, not verdicts: a grep hit is only a finding once you have read the surrounding code / merged manifest context and confirmed it applies.

## Monetization & Ads Checks

**Payments — Google Play Billing (CRITICAL, mirror of Apple 3.1):**
- Detect billing:
  - Native: `com.android.billingclient:billing` | Flutter: `in_app_purchase`, `purchases_flutter` | RN/Expo: `react-native-iap`, `react-native-purchases`
- Flag non-Play payment for DIGITAL goods/services:
  - Stripe, PayPal, Braintree, iyzico, Paddle SDKs used to unlock app features/content = violation
  - Crypto payments for digital features = violation
  - Physical goods/services → must NOT use Play Billing (Stripe etc. is correct there)
- Check for external purchase links/webviews that bypass billing for digital content
- Loot boxes / randomized rewards → verify odds disclosure in UI

**Subscriptions:**
- If subscriptions exist, verify the paywall UI shows: price, billing period, renewal terms, and cancellation info BEFORE the purchase button
- Free trial / intro offer terms clearly stated (what happens when trial ends, when billing starts)
- Verify no misleading "free" claims for auto-converting trials
- **Eligibility-based discounts (October 2026 update):** student/teacher/military plans and similar ongoing discounts must disclose eligibility criteria, the verification process, and what happens to price/benefits when eligibility ends. Scan paywall strings for "student", "edu", "eligib", "verify" offers → verify all three disclosures
- **Agentic / AI purchases:** if an in-app AI agent or assistant can initiate purchases of digital goods, it must still go through Play Billing

**Ads policy:**
- Detect ad SDKs:
  - Flutter: `google_mobile_ads`, `applovin_max`, `unity_ads`, `ironsource_mediation`, `facebook_audience_network`
  - RN/Expo: `react-native-google-mobile-ads`, `react-native-applovin-max`, `expo-ads-admob` (legacy)
  - Native: GMA SDK, AppLovin, ironSource, Unity Ads, Vungle, Chartboost
- If interstitials: verify they are closeable **within 15 seconds**, not triggered unexpectedly (at app open/before splash, during gameplay, at level start, after every action), and don't interfere with navigation
- Flag lockscreen ads, out-of-app-context ads, notification ads
- Rewarded ads: verify explicit user opt-in before showing
- Ad SDK initialization before consent (UMP/CMP) → flag for GDPR regions; check for `UserMessagingPlatform` / consent SDK usage
- Hidden ads / ads rendered off-screen or in 0-size views → ad fraud, instant termination risk

**Play Integrity / no review manipulation:**
- Detect review prompts: `com.google.android.play:review` (In-App Review API), `in_app_review`, `react-native-in-app-review`
- Flag custom rating dialogs that filter (only send happy users to Play) or incentivized review patterns

## Restricted Content Checks

**Financial Services:**
- If loan features (search "loan", "APR", "credit", "borrow", "lending") → verify: APR disclosure, no personal loans with APR > 36% (US), repayment period ≥ 60 days, no access to contacts/photos permissions (prohibited for loan apps)
- Binary options → banned entirely
- Crypto exchanges/wallets → geo/licensing flags

**Real-Money Gambling:**
- Scan for: "bet", "wager", "casino", "poker", "lottery", "sweepstakes" in code/strings
- Real-money gambling requires Play application process, license, geo-restriction, age gate (21+/18+ per region), and must be free to download
- Simulated gambling → content rating must reflect it

**Age-Restricted Content and Functionality:**
- If the app is real-money gambling OR its core functionality is dating/matchmaking → "Restrict Minor Access" is REQUIRED: target audience must be declared "18 and over" only in Play Console (note as required declaration)
- Detect dating features: search for "dating", "match", "matchmaking", "swipe" in code/strings, dating SDKs, profile-browsing + chat combinations
- If dating/matchmaking is an **incidental** feature (not core) → verify an in-app age-gating mechanism exists that blocks minors from those specific features (neutral age screen, date-of-birth check)
- If `com.google.android.play:age-signals` (Play Age Signals API) is used → verify signals are NOT passed to ad/analytics/marketing SDKs (prohibited use → suspension risk)

**User Generated Content:**
- Detect UGC features (chat, comments, profiles, media upload):
  - Flutter: `firebase_core` + Firestore, `stream_chat_flutter` | RN/Expo: `react-native-gifted-chat`, Firebase | Any: Socket.IO, Supabase realtime
- If UGC exists, verify: content moderation/filtering, in-app report/flag mechanism, user blocking, terms of service
- If UGC can be monetized (tips, paid content) → stricter moderation requirements

**Health:**
- Detect health features: `health` (Flutter), `react-native-health`, Health Connect (`androidx.health.connect`), Google Fit APIs
- Health Connect data → restricted use policy: no ads, no selling data, declaration required
- Medical/diagnostic claims → verify disclaimers; misinformation checks in content

**Blockchain / NFT:**
- Detect: `web3dart`, `ethers`, `WalletConnect`, NFT references
- Tokenized assets must be declared in Play Console; no gambling-like NFT mechanics without gambling compliance; can't gate Play Billing bypass via NFT

**AI-Generated Content:**
- If the app generates AI content (chat, images — search for OpenAI/Gemini/Anthropic/Stability API usage), verify: in-app reporting/flagging mechanism for offensive AI content, and content safeguards
- AI apps must not generate prohibited content (CSAM, deceptive election content, etc.) — note as manual check

**Child Endangerment / Inappropriate Content:**
- Scan user-facing strings for sexual content, hate speech, violence glorification, dangerous products
- Sensitive events: scan for content capitalizing on disasters/conflicts
- **Child Safety Standards (Social & Dating apps):** if the app is a social or dating app, verify an in-app CSAE report mechanism exists and note the required Play Console items as manual checks (published CSAE standards URL, child safety contact, CSAM reporting process)
