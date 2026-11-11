# Google Play Developer Program Policies — 1. Restricted Content

> Summary of https://play.google/developer-content-policy/ (policy version: July 2026 + October 29, 2026 update), split by area for on-demand loading. Always verify exact wording in the Play Policy Center.

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

## Update (announced October 29, 2026; compliance window ≥ 30 days)

- **Cryptocurrency:** Hong Kong licensing now also accepts the Virtual Asset Trading Platform license; new "Additional Options" section for apps qualifying for local regulatory exemptions.
- **AppFunctions API (new):** AppFunctions must comply with all Play policies and must never deceive or manipulate AI agents, bypass security controls, or interfere with other apps.
