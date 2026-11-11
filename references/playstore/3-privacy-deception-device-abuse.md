# Google Play Developer Program Policies — 3. Privacy, Deception and Device Abuse

> Summary of https://play.google/developer-content-policy/ (policy version: July 2026 + October 29, 2026 update), split by area for on-demand loading. Always verify exact wording in the Play Policy Center.

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

## Update (announced October 29, 2026; compliance window ≥ 30 days)

- **Local Network Permission (new):** restricted to apps needing it for core functionality when device pickers are insufficient. Apps targeting Android 17+ (API 37+) must submit a Play Console declaration.
- **Manage Contacts Permission (new):** restricted to core-functionality use when system pickers are insufficient; requires a Play Console declaration. Everyone else must use narrowly scoped platform intents.
- **Location Permission (mandatory January 27, 2027):** use the minimum location scope. Apps targeting Android 17 (API 37+) must use the Android location button for one-time/infrequent requests. `ACCESS_FINE_LOCATION` requires a Play Console declaration justifying why coarse location or the location button is insufficient.
- **All Files Access (`MANAGE_EXTERNAL_STORAGE`):** minimum-scope principles reiterated.
- **Accessibility API:** clarified `isAccessibilityTool` flag usage and disclosure requirements.
- **SMS / Call Log:** government or authorized carrier apps may use `READ_CALL_LOG` for Quality of Service reporting; backup-and-restore exception must demonstrate restoring to the default handler; SMS User Consent API added as an alternative for account verification. From **January 27, 2027** phone-call account verification is no longer a permitted `READ_CALL_LOG` use case.
- **Deceptive Behavior:** manipulating the app review process is explicitly prohibited.
