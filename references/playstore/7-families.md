# Google Play Developer Program Policies — 7. Families

> Summary of https://play.google/developer-content-policy/ (policy version: July 2026 + October 29, 2026 update), split by area for on-demand loading. Always verify exact wording in the Play Policy Center.

## 7. Families

> Sources: answer/9893335 (Families Policies), answer/9867159 (Target audience & content), answer/11043825 (Data practices)

### 7.1 Target Audience Declaration

- Every developer must complete **Target audience and content** in Play Console (age groups; ads declaration and app-access instructions first). Buckets: **children only**, **children and older users (mixed)**, **older users only**.
- Misrepresenting the target audience is a violation; Google may reassign the audience.

### 7.2 Requirements When Children Are in the Audience

- Content appropriate for declared age groups; accurate ratings; no adult themes.
- App **including all APIs, SDKs, and ads** must comply with **COPPA**, **GDPR**, and other child-privacy law.
- No collecting/transmitting personal or sensitive data from children without required notice and **verifiable parental consent**.
- Child-only apps may use only SDKs **approved for child-directed services**.
- AR apps need a launch safety warning; social/chat features carry additional safety obligations.
- **Neutral age screen** for mixed audiences: neutral date-of-birth entry, no hints ("must be 13+"), no adult defaults; children and unknown-age users get the child-directed experience.
- **Designed for Families (DFF):** opt-in program with stricter content/ads/data requirements; prerequisite for the **Teacher Approved** badge (curated review by US teachers).

### 7.3 Families Data Practices

- **"Transmit"** = any off-device network send, including to the developer's own servers.
- Child-only apps must **not transmit the AAID (Advertising ID)**; mixed apps must not transmit AAID from children/unknown-age users. Child-only apps targeting API 33+ must use the Play services mechanism that zeroes AAID.
- Apps with children in the audience must not transmit: **SIM serial, build serial, BSSID, MAC address, SSID, IMEI, IMSI, phone number** from children/unknown-age users.
- No accessing/sharing **precise location** of children.

### 7.4 Families Ads & Monetization

- Applies to ALL commercial content shown to children: ads, cross-promotion, IAP offers.
- Only **Families Self-Certified Ads SDKs** (see 4.4); ads contextual only — **no interest-based ads or remarketing to children**.
- Ad content appropriate for children; no non-dismissible ads, no ads posing as system notifications, no ads imitating app UI/buttons, no designs causing inadvertent clicks by children.
- IAP: no deceptive purchase prompts or pressure on children; clearly distinguish virtual currency from real money. Play **re-authenticates before every IAP** in DFF apps.
- **No real or simulated gambling** in kids apps, nor gambling ads.

---

## Update (announced October 29, 2026; compliance window ≥ 30 days)

- **Families Self-Certified Ads SDK Program:** open to new applicants; check participating SDKs and certified versions in the Help Center and SDK Index.
- **Play Age Signals API:** new privacy-friendly API to tailor features, content and safety settings by age (available globally).
