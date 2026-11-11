# Google Play Developer Program Policies — 4. Monetization and Ads

> Summary of https://play.google/developer-content-policy/ (policy version: July 2026 + October 29, 2026 update), split by area for on-demand loading. Always verify exact wording in the Play Policy Center.

## 4. Monetization and Ads

### 4.1 Payments (Google Play's Billing System)

> Sources: answer/9858738, answer/10281818

**Play billing REQUIRED** for in-app purchases of **digital goods or services consumed in the app**:
- Virtual game items (currencies, extra lives, items, characters)
- Subscriptions (fitness, dating, education, music, video, etc.)
- App functionality/content (ad-free versions, unlocked features)
- Cloud software and services (storage, productivity, financial management software)

**Play billing must NOT be used** for:
- Physical goods (groceries, clothing, electronics)
- Physical services (rideshare, cleaning, airfare, gym memberships, food delivery, event tickets)
- Bill payments / remittance, peer-to-peer payments, online gambling

**Other rules:**
- Exemption: digital content consumable **only outside** the app
- **Alternative billing:** in 35+ eligible markets (EEA, UK, US, India, Japan, South Korea, etc.), enrolled developers may offer user-choice billing or (in some regions) alternative billing without user choice (~4% fee reduction). US apps gained expanded external-link abilities post Epic v. Google. Outside these programs, apps must not steer users to non-Play payment for in-app digital purchases.
- Prices shown in-app must match the Play billing interface; paid features mentioned in the listing must be flagged as paid.
- **Virtual currency** may only be used inside the app/game where purchased.
- **Loot boxes:** odds of receiving randomized items must be disclosed **before and in close proximity to** the purchase.

### 4.2 Subscriptions

> Source: answer/9900533

- No misleading users about subscription services/content.
- Must clearly disclose **in-app** (not only in the listing or behind links): offer terms, cost, billing frequency, auto-renewal terms, whether a subscription is required.
- Intro/promo pricing must not hide what the user will be charged after the intro period.
- **Free trials:** before signup, clearly state trial duration, post-trial price, when billing starts, and how to cancel before conversion.
- **Easy cancellation:** apps must disclose how to manage/cancel and include access to an easy, **online** cancellation method (e.g., in-app link to the Play subscription center).
- No dark patterns; grace-period/account-hold mechanics must follow Play billing rules (no entitlements during account hold).

### 4.3 Ads

> Sources: answer/9857753; ad fraud: answer/9969955; Better Ads: answer/12271244

- **Ads are app content:** ads and their landing offers must comply with all policies and fit the app's **content rating**.
- **Disruptive ads banned:** unexpected full-screen ads (during a phone call, unlocking, GPS navigation), ads without a clear dismissal, forced-click deception, ads obscuring controls.
- **Lockscreen:** no ads or monetization on the locked screen unless the app's exclusive purpose is a lockscreen.
- **Ads must run in-context:** only within the app serving them — no home-screen/out-of-app ads.
- **Ad fraud:** hidden ads, auto-clicks, stacked/pixel ads, fake attribution, ads while the app isn't in use → severe enforcement.
- **Rewarded ads:** allowed with explicit opt-in via a clear prompt describing the reward.
- **Better Ads Experiences:**
  - No unexpected full-screen interstitials — e.g., during gameplay, at level start, or before the app's loading screen
  - Interstitials before a reward/score screen are OK when expected; opt-in interstitials OK
  - All full-screen ads must be **closable within 15 seconds** (except opted-in rewarded ads)
- Apps targeting children: no inappropriate ad content; gambling ads never to under-18s (see Families).

### 4.4 Families Self-Certified Ads SDKs

> Sources: answer/9900633, answer/12918983

- Apps targeting **only children** must exclusively use ads SDK versions **self-certified** for Families compliance; mixed-audience apps must serve children (and users of unknown age) only via self-certified SDKs.
- Self-certified SDKs must: prohibit objectionable ad content/behavior, rate creatives by age group (min. "Everyone" and "Mature"), **disable personalized/interest-based ads and remarketing** for child-directed treatment, and pass child-directed signals through mediation to (only) other certified SDKs.
- Exceptions: in-house cross-promotion and direct advertiser deals where the SDK only manages inventory.

---

## Update (announced October 29, 2026; compliance window ≥ 30 days)

- **Subscriptions with ongoing eligibility-based discounts (updated):** e.g. student plans must clearly disclose eligibility criteria, the verification process, and post-eligibility pricing/benefit changes.
- **Payments:** additional guidance on digital purchases facilitated through AI / agentic experiences (Play Billing rules still apply).
