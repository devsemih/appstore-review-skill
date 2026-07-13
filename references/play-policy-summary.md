# Google Play Developer Program Policies — Summary

> Source: https://play.google/developer-content-policy/ (Google Play Developer Policy Center)
> Policy snapshot: July 2026. Individual policy pages live under https://support.google.com/googleplay/android-developer/ — canonical answer IDs are cited per section.
>
> **How Play policies differ from Apple's guidelines:** Play policies are organized by **named policy areas**, not numbered sections. Many requirements are enforced through **Play Console declarations and forms** (Data safety, Permissions Declaration, Financial Features, Health apps, Target audience & content, gambling application) rather than only through binary review. Enforcement covers the app, its metadata, its ads, all third-party SDKs inside it, AND the developer account with its whole catalog.

## Policy Coverage & Enforcement

> Sources: answer/10146128 (Policy Coverage), answer/9899234 (Enforcement Process), answer/9899142 (Appeals)

- Policies apply to: app content and functionality, **store listing metadata** (title, icon, description, screenshots, promo assets), **ads and third-party code/SDKs** inside the app, and the developer's **account information and conduct**, including violation history.
- Coverage extends to the developer account and **all apps in the catalog** — a violation anywhere can trigger action anywhere; enforcement notices "may not indicate each and every policy violation."
- Escalating enforcement actions:
  - **Rejection** — submitted app/update not published until fixed
  - **Removal** — app taken off Play until a compliant update is submitted; multiple removals may lead to suspension
  - **Suspension** — for egregious or repeated violations; counts as a **strike** against account standing
  - **Account termination** — for repeated or egregious violations (malware, fraud, user/device harm): all apps removed, publishing blocked, and **related/associated accounts permanently suspended**. Creating new accounts to evade termination is itself a violation.
- Google notifies actions by email with appeal instructions; **one appeal per enforcement action**.

---

## 1. Restricted Content

### 1.1 Child Endangerment

> Sources: answer/9878809; Child Safety Standards: answer/14747720

- Content that **sexualizes minors** → immediate removal; CSAM is reported to **NCMEC**; developer account may be terminated.
- Prohibited: child grooming, sexualization of a minor, sextortion, child trafficking, promotion of predatory behavior toward children.
- Apps that fail to prevent users from creating/uploading content facilitating child exploitation face immediate removal.
- Apps that target or appeal to children must not contain adult themes (violence, harmful activities, sexual content, body-shaming cosmetic features).
- **Child Safety Standards policy** (in effect since 2025) — required for **Social and Dating** category apps:
  1. Publish externally accessible standards against child sexual abuse and exploitation (CSAE)
  2. Provide an **in-app user feedback/reporting mechanism**
  3. Have a process to report confirmed CSAM to NCMEC or the relevant regional authority
  4. Designate a **child safety point of contact** in Play Console
  5. Self-certify compliance with child safety laws

### 1.2 Inappropriate Content

> Source: answer/9878810

- **Sexual content:** No pornography or content/services "intended to be sexually gratifying." Nudity allowed only for **educational, documentary, scientific, or artistic (EDSA)** purposes and not gratuitous. "Compensated dating" / sugar-dating apps are violations.
- **Hate speech:** No content promoting violence or inciting hatred against protected groups (race, ethnicity, religion, disability, age, nationality, veteran status, sexual orientation, gender, gender identity, caste, immigration status). No hate-group promotion or paraphernalia.
- **Violence:** No gratuitous violence — realistic violence against real people, terrorism instruction, self-harm/suicide promotion, violent threats, animal cruelty.
- **Terrorist content / violent extremism:** No planning, preparing, glorifying, recruiting, or celebrating violence against civilians. EDSA exception, must not be gratuitous.
- **Sensitive events** (civil emergencies, natural disasters, public health emergencies, conflicts, deaths): apps must not capitalize on, lack sensitivity toward, or profit from them (e.g., price gouging during an emergency, event denial). Awareness/EDSA content allowed.
- **Bullying and harassment:** No content facilitating threats, harassment, or bullying, including tragedy denial or claiming victims are actors.
- **Dangerous products:** No facilitating the sale of **firearms, accessories enabling simulated automatic fire (bump stocks, conversion kits), ammunition, or explosives**; no manufacturing instructions for weapons.
- **Marijuana:** No facilitating the **sale** of marijuana or THC products **regardless of legality** (no in-app shopping cart, delivery arrangement, or sales assistance). Informational/educational content is allowed.
- **Tobacco and alcohol:** No facilitating tobacco sales (including e-cigarettes/vapes); no encouraging use by minors; no portraying excessive drinking favorably.

### 1.3 Financial Services

> Sources: answer/9876821; declarations: answer/13849271

- Core principle: no apps exposing users to deceptive or harmful financial products/services.
- **Binary options: flat ban.** "We do not allow apps that provide users with the ability to trade binary options."
- **Cryptocurrency:** no **on-device mining** (remote mining management allowed). Exchanges and **custodial** wallets must hold required licenses per distribution region — **US:** FinCEN MSB registration or state money transmitter license; **EU:** CASP authorization under **MiCA**. **Non-custodial wallets are out of scope** of the licensing requirement. Declare in the **Financial Features Declaration**.
- **Personal loans** (direct lenders, lead generators, and connectors to third-party lenders):
  - Metadata must disclose: **minimum and maximum repayment period**, **maximum APR** (all fees included), and a representative total-cost example.
  - **No loans requiring repayment in full in 60 days or less.**
  - **US: no personal loans with APR ≥ 36%**; maximum APR must be displayed, calculated per the **Truth in Lending Act (TILA)**.
  - Personal loan apps **may not access user contacts or photos** (external storage images); permitted sensitive permissions are narrow (e.g., camera for KYC).
  - **Personal Loan App Declaration** required, with country-specific license documentation (India: RBI/regulated-entity list; Indonesia: OJK; Philippines: SEC; Nigeria: FCCPC; Kenya: CBK; Pakistan: SECP — one lending app per NBFC; Thailand: BoT/MoF for 15%+ interest).
- **Daily fantasy sports:** treated under the gambling framework — must comply with local law and complete Google's application process.
- Any app with financial features must complete the **Financial Features Declaration** in Play Console.

### 1.4 Real-Money Gambling, Games, and Contests

> Sources: answer/9877032; country allowances: answer/12256011

Real-money gambling apps (casino, lottery, sports betting, daily fantasy sports) are allowed only when ALL of the following hold:

1. Developer completed and was accepted through Google's **gambling application form**
2. Valid **gambling license for every country/state** where distributed
3. App **geo-gates** access from unlicensed regions
4. App **age-gates** — prevents underage users (under 18 or local legal age) from registering/using
5. App is **free to download** and **must NOT use Google Play's billing system** — real-money transactions happen outside Play billing
6. Rated **AO (Adult Only)** or IARC equivalent
7. Displays **responsible gambling** information clearly (e.g., on the landing/sign-in screen)

- Only allowed in countries on Google's allowance list (UK, Ireland, France, Brazil, US, Germany, Japan, Spain, and others per the country pages).
- **Loyalty programs:** in **games**, gamified/variable loyalty rewards are not allowed (fixed ratio and schedule only); non-game apps may run chance-based loyalty outcomes under conditions.
- **Simulated gambling** (social casino) is allowed with accurate content rating and no real-money prizes. Gambling ads must never target minors.

### 1.5 Illegal Activities

> Source: answer/9878877

- Broad catch-all: no apps that facilitate or promote illegal activities. Examples: sale of illegal drugs or prescription drugs without prescription; depicting/encouraging drug, alcohol, or tobacco use by minors; instructions for growing/manufacturing illegal drugs.
- Developers are responsible for verifying legality in every targeted locale.

### 1.6 User Generated Content (UGC)

> Sources: answer/9876937; moderation guidance: answer/12923286

Apps hosting or providing access to UGC must:

- Require **user acceptance of terms of service** defining objectionable content/behaviors
- **Moderate UGC** in a way reasonable and consistent with the UGC type (robust, ongoing enforcement; proactive moderation may be required for e.g. sexual UGC)
- Provide an **in-app system for reporting objectionable UGC and users**, and take timely action
- Apps with **publicly accessible UGC** (social networks, blogs) must implement in-app **report AND block** functionality
- UGC enabling **1:1 interaction** (DMs, tagging, mentions) must provide **in-app user blocking**
- **Monetized UGC:** safeguards so in-app monetization doesn't encourage objectionable behavior (tips/gifts must not incentivize sexual or harassing content)
- **AR UGC:** reporting must account for objectionable AR content AND sensitive AR anchoring locations (military bases, private property)
- Apps whose primary purpose (or primary actual use) is objectionable UGC are removed

### 1.7 Health Content and Services

> Sources: answer/16679511; health permissions: answer/12991134; COVID: answer/9889712

- **Health misinformation prohibited:** misleading/harmful health claims contradicting medical consensus (anti-vaccine misinformation, unapproved treatments, conversion therapy).
- **Medical functionality:** apps regulated as **medical devices must declare it** and provide proof of approval/clearance (FDA, CE) on request. Other health apps must include a disclaimer that the app "is not a medical device and does not diagnose, treat, cure, or prevent any medical condition"; symptom checkers need clearly visible in-app disclaimers.
- Health/medical apps must complete the **Health apps declaration form** in Play Console (policy update effective August 28, 2025) and post a privacy policy covering health data.
- **Health Connect data** is personal & sensitive data with extra restrictions: access limited to approved use cases (fitness & wellness, rewards, coaching, corporate wellness, medical care, health research, games). **Prohibited:** selling/transferring health data to ad platforms, data brokers, resellers; **using it for ads including personalized advertising**; using it for creditworthiness, insurance, employment, or lending decisions; sharing publicly without explicit informed consent. Background health-data reads require justification.
- **COVID-19 apps:** only if published/commissioned/authorized by a government entity or public health organization.

### 1.8 Blockchain-based Content

> Sources: answer/13607354; exchanges/wallets: answer/16329703

- Apps that are crypto exchanges/software wallets, or that sell or let users earn tokenized digital assets (crypto, NFTs), must declare it in the **Financial Features Declaration**.
- Exchanges and custodial wallets: licensing per region (see Financial Services). Non-custodial wallets exempt.
- **No on-device cryptomining.**
- **NFT anti-gambling rules:** users must not wager/stake NFTs for a chance at prizes of real monetary value, and the app must not accept anything of monetary value in exchange for a chance to obtain an **NFT of unknown value** (loot-box NFTs). Such mechanics reclassify the app as gambling (full gambling requirements apply).
- No promoting or glamorizing potential earnings from trading/holding tokenized assets.
- In-app purchases of tokenized assets follow standard Play Billing rules where applicable.

### 1.9 Age-Restricted Content and Functionality

> Sources: answer/16302250; incidental dating features: answer/16838200; US app-store bills: answer/16569691; Age Signals API: https://developer.android.com/google/play/age-signals/overview

Apps in covered categories **must block minors (under 18)** using Play Console tools:

- **Covered:** real-money gambling/games/contests apps, and apps whose **core functionality** is dating or matchmaking.
- **Mechanism — "Restrict Minor Access":** in Play Console → Target audience and content, declare **"18 and over" as the sole target age group** and enable the restriction. Users Google determines to be under 18 (declared account age or Google's signals) cannot search for, download, or purchase the app; existing installs keep working but cannot renew subscriptions or make new purchases.
- **Incidental dating carve-out (since April 15, 2026):** apps where dating/matchmaking is an incidental (non-core) feature need not block minors app-wide, **provided they implement effective alternative age-gating** preventing minors from reaching those specific features. Google doesn't mandate a specific technology — it must "reasonably prevent" minor access (neutral age screens are the established model).
- **Enforcement:** policy announced October 30, 2025; in force since **January 28, 2026** for RMG and core-dating apps.
- **Play Age Signals API (beta):** `com.google.android.play:age-signals` — returns `userStatus` (VERIFIED/DECLARED/SUPERVISED/…) and age-range bands, but **only in jurisdictions where Play is legally required to provide them** (Brazil Digital ECA since March 2026; Texas SB 2420 from January 2026 with phased signals; Utah May 2026; Louisiana July 2026). Signals may be used **only** for age-appropriate experiences — use for advertising, marketing, profiling, or analytics is prohibited and can trigger suspension. "Significant changes" (new data collection, rating change, new monetization, material UX change) require notifying Play via the Age signals page so supervised users' parents can re-approve.
- **Interaction with Families:** this policy is the inverse of Families — Families obligations attach when children are IN the target audience; this policy forces covered adult-only apps OUT of minors' reach. A covered app declaring a mixed/teen audience is a violation. UK Online Safety Act "highly effective age assurance" duties fall on the app itself — Play's store-level tools alone don't satisfy Ofcom.

### 1.10 AI-Generated Content

> Sources: answer/13985936; best practices: answer/16353813

- **Scope:** apps generating content from text/voice/image prompts — AI chatbots (where chat is a central feature), AI image/voice/video generators. Apps merely hosting AI content, or using AI only for summarization/productivity, fall under UGC or other policies instead.
- Generative AI apps must **prevent generation of restricted content**: anything under Inappropriate Content, **CSAE content**, and deceptive content (fake official documents, non-consensual intimate imagery/deepfakes, election misinformation).
- **Required in-app feature:** a mechanism for users to **report or flag offensive AI-generated content without leaving the app**; feedback should inform content filtering/moderation.
- Developers are responsible for model outputs; must test across scenarios and safeguard against **prompt injection/jailbreaks** (Google red-teams during review).
- Marketing must accurately represent AI capabilities.

---

## 2. Impersonation and Intellectual Property

### 2.1 Impersonation

> Source: answer/9888374

- No apps that mislead users by impersonating another developer, company, organization, or app — regardless of intent. Covers icons, titles, descriptions, developer names, and in-app elements.
- No implying a relationship with or authorization by an entity when none exists (e.g., developer name "Google Inc.", national emblems implying government affiliation, copied business logos, "Official" claims without rights).

### 2.2 Intellectual Property

> Sources: answer/9888072; reporting: answer/1085703

- No infringement of copyright, trademark, patent, trade secret, or other proprietary rights, and no apps that **encourage or induce infringement** (piracy streaming, download-from-YouTube tools).
- **Modifying copyrighted content is not a defense.** Google processes **DMCA** notices; trademark owners can file complaint forms; counterfeit sales are banned.
- Documented permission from rights holders should be available on request.

---

## 3. Privacy, Deception and Device Abuse

### 3.1 User Data

> Sources: answer/10144311; prominent disclosure: answer/11150561

- Be transparent about access, collection, use, handling, and sharing of **personal and sensitive user data**: PII, financial/payment info, authentication info, phonebook/contacts, device location, SMS/call data, health data, Health Connect data, **inventory of other installed apps**, microphone, camera, and other sensitive device/usage data.
- Collection must be limited to what is **directly necessary for features promoted in the store listing**. Selling personal and sensitive user data is **prohibited**.
- Data must be transmitted securely with **modern cryptography (HTTPS)**.
- **Developers are responsible for third-party SDKs' data handling** inside their app.

**Prominent disclosure & consent** (required when collection/transmission is unrelated to prominently described functionality — classic trigger: background collection):
- Must be **in-app** (not only in the store listing, website, privacy policy, or ToS), shown during normal usage without menu navigation
- Must describe the data collected and how it will be used/shared, and not be bundled with unrelated disclosures
- Format example: *"[This app] collects/transmits/syncs/stores [data type] to enable [feature], [in what scenario]."*
- The consent dialog must require **affirmative user action** (tap/checkbox); navigating away, auto-dismissing messages, or expiring messages do NOT constitute consent; consent must precede collection AND the runtime permission prompt

**Privacy policy** — required for ALL apps (even ones collecting no data):
- Linked in **both** the Play Console store listing field **and inside the app**
- Active, publicly accessible, non-geofenced URL (not a PDF, not editable)
- Must name the entity, be labeled as a privacy policy, comprehensively describe collection/use/sharing, and cover retention and deletion

### 3.2 Data Safety Section

> Source: answer/10787469

- Every app must complete the **Data safety form** (Play Console → App content) covering data handled by the app **and every SDK in it**.
- Declared per data type (Location, Personal info, Financial info, Health & fitness, Messages, Photos & videos, Audio, Files, Calendar, Contacts, App activity, Web browsing, App info & performance, Device or other IDs):
  - **Collected?** ("collected" = transmitted off device; ephemeral processing and E2EE have carve-outs)
  - **Shared?** (exceptions: service providers, legal purposes, user-initiated transfers, anonymized data)
  - **Purposes** (app functionality, analytics, developer communications, advertising/marketing, fraud prevention/security, personalization, account management)
  - Optional vs. required; encrypted in transit; deletion request availability
- Developers are **solely responsible for accuracy**; divergence between app behavior and the form → corrections required, update blocks, or removal.

### 3.3 Account Deletion Requirement

> Source: answer/13327111

If the app **enables account creation in-app**, it must offer account deletion:

1. **In-app** — a readily discoverable path to initiate deletion, AND
2. **Web resource** — a URL where users (including those who uninstalled) can request deletion; declared in the Data safety form and shown on the store listing

- Deleting the account must delete associated user data. Deactivation/freezing does **not** qualify.
- Data retained for legitimate reasons (security, fraud, compliance) is allowed but must be disclosed.
- The web link must load without error, prominently feature the deletion pathway, and reference the app/developer name as listed. Fully enforced since April/May 2024.

### 3.4 Permissions and APIs that Access Sensitive Information

> Sources: answer/9888170 (main); per-permission pages cited inline

**General rules:** request only permissions needed for **current, implemented, promoted** features; request in context at runtime; never sell data from sensitive permissions; if a narrower alternative (picker, intent, `<queries>`) exists, it **must** be used. Restricted permissions require the **Permissions Declaration Form**.

- **SMS & Call Log** (answer/10208820): `READ_SMS`, `SEND_SMS`, `RECEIVE_SMS`, `RECEIVE_WAP_PUSH`, `RECEIVE_MMS`, `READ_CALL_LOG`, `WRITE_CALL_LOG`, `PROCESS_OUTGOING_CALLS` — only for the user's **default SMS/Phone/Assistant handler**, or narrow declared exceptions (device automation, companion apps, cross-device sync, SMS-based financial transactions, backup/restore, enterprise archival, carrier services, anti-fraud). **Not permitted:** OTP/account verification (use **SMS Retriever API / SMS User Consent API**), content sharing, contact prioritization. Deriving equivalent data by other means is also banned.
- **QUERY_ALL_PACKAGES / package visibility** (answer/10158779): installed-app inventory is sensitive data. Broad visibility only when core user-facing functionality requires it (device search, antivirus, banking security, file managers, browsers, digital wallets, device management, accessibility). Otherwise use `<queries>`. Declaration required; app inventory may never be sold or shared for analytics/ads.
- **MANAGE_EXTERNAL_STORAGE / All files access** (answer/10467955): only when SAF/MediaStore cannot serve the core need (file managers, antivirus, backup, device migration). Declaration required; the feature must be prominent in the listing.
- **Accessibility API** (answer/10964491): tools for people with disabilities set `isAccessibilityTool="true"`. Any **non-accessibility use** requires the Play Console declaration + prominent disclosure + affirmative consent, and only where no narrower API exists. Banned: changing settings without permission, preventing disable/uninstall, working around privacy controls, **remote call audio recording**. Stricter enforcement from January 28, 2026.
- **Exact alarms:** `USE_EXACT_ALARM` (install-time, non-revocable) only for **alarm clock, timer, or calendar** apps. Everyone else: `SCHEDULE_EXACT_ALARM` (user-revocable, denied by default on Android 14+ new installs) with graceful degradation.
- **Foreground services (targetSdk 34+)** (answer/13392821): every `<service>` needs `android:foregroundServiceType` + the matching `FOREGROUND_SERVICE_<TYPE>` permission; FGS must be a **user-initiated, perceptible task**. Play Console declaration per FGS type: functionality description, user impact if deferred, and a **demo video link**. `SPECIAL_USE` needs justification for why no other type fits.
- **Full-screen intent (targetSdk 34+):** `USE_FULL_SCREEN_INTENT` auto-granted only to **calling and alarm** apps; others must request the special access at runtime. Play Console declaration required; default revocation enforced since January 22, 2025.
- **VpnService** (answer/12564964): only apps with VPN as core functionality or powering core features (parental control, usage tracking, device security, network tools, browsers, carrier services). Banned: collecting sensitive data via VPN without disclosure+consent, **redirecting/manipulating other apps' traffic for monetization**, manipulating ads. Must document VPN use in the listing and **encrypt device-to-endpoint**.
- **Photo and Video permissions** (answer/14115180): `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` only for apps needing **broad/persistent** media access as core functionality (galleries, editors). **One-time/infrequent** use (avatar upload, attachments, check deposits) must use the **Android photo picker** or `ACTION_GET_CONTENT`/SAF. Declaration enforced since January 22, 2025.
- **Location** (answer/9799150): fine/coarse location only for promoted features. **`ACCESS_BACKGROUND_LOCATION`** additionally requires: core functionality with clear user benefit, foreground access (incl. foreground service while in use) being insufficient, **prominent disclosure + consent** ("even when the app is closed or not in use"), and the **location declaration in Play Console** with case-by-case approval.
- **REQUEST_INSTALL_PACKAGES** (answer/12085295): only for apps whose core functionality includes **user-initiated** package install/send/receive (browsers, messaging with attachments, file managers, enterprise management, backup/migration). May not be used for **self-updates**, modifying other apps, or installing bundled APKs (except device management). Play-distributed apps must update only via Play.

### 3.5 Device and Network Abuse

> Source: answer/9888379 (consolidated: answer/16559646)

- No interfering with, disrupting, damaging, or accessing in an unauthorized manner the device, other apps, servers, networks, or services. No blocking other apps' ads/monetization. No gaming cheats affecting other apps. No ToS-violating automation.
- **Proxying:** turning the device into a proxy node for third parties is allowed only as the disclosed **core purpose** with informed consent; undisclosed proxying = abuse/MUwS.
- **Executable code / dynamic loading:** a Play-distributed app **may not update itself by any method other than Play's update mechanism** and **may not download executable code (dex, JAR, .so) from outside Google Play**. Exception: code running in a VM or interpreter with only indirect Android API access (e.g., JavaScript in a WebView). Runtime-loaded interpreted code (JS, Python, Lua) must not get direct Android API access and must not enable policy violations or evade review.
- WebViews with `JavascriptInterface` must not load untrusted content (`http://`) or unverified URLs.
- **Ad fraud** strictly prohibited: hidden/stacked ads, auto-clicking, faked attribution, ads outside the app.
- No **on-device crypto mining** (remote mining management OK).

### 3.6 Deceptive Behavior

> Source: answer/9888077

- No false/misleading claims anywhere (description, title, icon, screenshots): fake antivirus results, functionally impossible features, fake government functions, unfounded health/medical claims.
- **Device settings changes** require user knowledge & consent, and must be easily reversible; no modifying browser settings/homepage/shortcuts for third parties or ads; no encouraging removal/disabling of third-party apps except as a verifiable security service.
- **Enabling dishonest behavior banned:** fake ID/passport/diploma/credit-card generators, exam cheating, fake calls/SMS as deception tools.
- **Manipulated media ("deepfakes"):** no promoting misleading imagery/video/audio that could cause harm re: sensitive events, politics, public interest; apps that alter media must clearly disclose/watermark non-obvious alterations.
- **Behavior transparency:** no hidden, dormant, or undocumented features; no obfuscation to evade review.

### 3.7 Misrepresentation

> Source: answer/9888689

- No misrepresenting or concealing ownership or primary purpose; no coordinated activity to mislead users (esp. political/social/public-concern content); no concealing country of origin while targeting users elsewhere.

### 3.8 Mobile Unwanted Software (MUwS) & Malware

> Sources: answer/9970222 (MUwS), answer/9888380 (Malware)

- Apps must be transparent, deliver the promised value, not trick users into installing, disclose all principal functions, not affect the system unexpectedly, and not collect/transmit private information without user knowledge.
- **Malware categories:** backdoors, billing fraud (SMS/call/toll), commercial spyware/stalkerware, denial of service, hostile downloaders, phishing, privilege abuse, ransomware, rooting, spam, spyware, trojans.
- **Stalkerware:** monitoring apps must be transparent, show a persistent notification and unique icon, use the `IsMonitoringTool` manifest metadata flag; only parental/enterprise monitoring is permitted — never covert partner/adult tracking.

---

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

## 5. Store Listing and Promotion

### 5.1 Metadata

> Source: answer/9898842

- No misleading, improperly formatted, non-descriptive, irrelevant, excessive, or inappropriate metadata.
- No **keyword stuffing** (repetitive/unrelated keywords, keyword blocks, testimonial quoting for keywords).
- No **emoji/emoticons/repeated special characters** in title, icon, or developer name; no ALL CAPS unless it's the brand.
- **Title ≤ 30 characters**; no performance/price/promo words in title, icon, or developer name ("top", "#1", "best", "free", "no ads", "sale").
- Icons must not use badges/text suggesting ranking, deals, or Play program participation.
- Screenshots/videos must show actual app functionality; no "Download now"-style CTAs or time-sensitive taglines; no inappropriate imagery.

### 5.2 User Ratings, Reviews, and Installs

> Source: answer/9898684

- No manipulation of Play placement: **no fraudulent or incentivized ratings, reviews, or installs** (money, goods, in-app perks in exchange).
- No posing as users, review exchanges, or bought installs. No soliciting reviews containing affiliate links/coupons/codes.
- You may ask users to rate — but not with an incentive and not pre-filtered to happy users only.

### 5.3 Content Ratings (IARC)

> Source: answer/9898843

- All apps must complete the **IARC rating questionnaire** accurately; ratings generated per territory (ESRB, PEGI, USK…). Misrepresentation → rejection, removal, or termination. Ads must fit the declared rating.

### 5.4 News Apps

> Source: answer/10523915

- News-declared apps must provide verifiable ownership info and publisher contact (email or phone — social links insufficient) reachable in-app and declared in Play Console; show each article's source/author (or be the original publisher); keep content fresh (not only static content older than ~3 months); avoid significant spelling/grammar errors.

### 5.5 App Promotion

> Source: answer/9899004

- No deceptive install tactics: no ads mimicking system notifications/warnings, no redirects or downloads without informed user action, no unsolicited SMS promotion. Developers are responsible for their ad networks and affiliates.

---

## 6. Spam and Minimum Functionality

> Source: answer/9898783

- **Broken functionality banned:** crashing, force-closing, freezing, failing to install/load; no placeholder/unfinished "coming soon" shells.
- **Minimum functionality:** stable, responsive, engaging experience with basic utility (banned: single-wallpaper apps, text/PDF-only apps, near-empty apps).
- **Webview/affiliate spam:** apps that are just a webview wrapper of a site (without the owner's permission or without meaningful app functionality) or exist to drive affiliate traffic → removed. Site owners may ship webview apps only with engaging app functionality added.
- **Repetitive content:** no duplicating existing Play content, no clone farms, no many near-identical template apps from one account.
- **Made-for-ads:** apps whose primary purpose is serving ads are prohibited.
- **Message spam:** no unsolicited messages on the user's behalf (SMS, email, social) without knowledge and confirmation.

---

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

## 8. Technical Requirements

### 8.1 Target API Level

> Sources: answer/11926878; https://developer.android.com/google/play/requirements/target-sdk

- **Current (mid-2026):** new apps and updates must target **API 35 (Android 15)** or higher; Wear OS / Android TV / Automotive: API 34+.
- **From August 31, 2026:** new apps and updates must target **API 36 (Android 16)**; existing apps must target ≥ API 35 to remain available to new users on Android 16+ devices.
- General rule: target within **one year** of the latest major Android release; existing non-updated apps must stay within two years to remain discoverable to new users. Extensions can be requested in Play Console.

### 8.2 Play Console Declarations Checklist

Requirements enforced through Play Console forms (not code review alone):

| Declaration | When Required |
|-------------|---------------|
| **Data safety form** | Every app |
| **Target audience & content** | Every app |
| **Content rating (IARC)** | Every app |
| **Account deletion URL** | Apps with in-app account creation |
| **Permissions Declaration Form** | SMS/Call Log, QUERY_ALL_PACKAGES, MANAGE_EXTERNAL_STORAGE, Accessibility (non-a11y use), etc. |
| **Location permissions declaration** | ACCESS_BACKGROUND_LOCATION |
| **Photo & video permissions declaration** | READ_MEDIA_IMAGES / READ_MEDIA_VIDEO |
| **Foreground service declarations** (+ demo video) | Each FGS type, targetSdk 34+ |
| **Full-screen intent declaration** | USE_FULL_SCREEN_INTENT |
| **Financial Features Declaration** | Loans, crypto exchanges/wallets, tokenized assets, other financial features |
| **Personal Loan App Declaration** | Loan apps (with country licenses) |
| **Health apps declaration** | Health/medical apps |
| **Gambling application** | Real-money gambling apps |
| **Child safety standards declaration** | Social & Dating category apps |
| **Restrict Minor Access (18+ target audience)** | Real-money gambling apps and core-dating/matchmaking apps |
| **News declaration** | News apps |

---

## Verification Note

This summary was compiled from the official Play policy pages (answer IDs cited per section) in July 2026. Google updates these policies several times a year — before shipping compliance-critical guidance, re-verify thresholds (APR caps, API levels, enforcement dates) against the live pages at https://play.google/developer-content-policy/.
