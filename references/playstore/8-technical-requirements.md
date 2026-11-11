# Google Play Developer Program Policies — 8. Technical Requirements

> Summary of https://play.google/developer-content-policy/ (policy version: July 2026 + October 29, 2026 update), split by area for on-demand loading. Always verify exact wording in the Play Policy Center.

## 8. Technical Requirements

### 8.1 Target API Level

> Sources: answer/11926878; https://developer.android.com/google/play/requirements/target-sdk

- **Current (since August 31, 2026):** new apps and updates must target **API 36 (Android 16)** or higher; existing apps must target ≥ API 35 to remain available to new users on Android 16+ devices. Wear OS / Android TV / Automotive have their own (lower) schedules.
- **Before August 31, 2026:** API 35 (Android 15).
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

## Update (announced October 29, 2026; compliance window ≥ 30 days)

- **Trader status:** from November 2026 developers must declare trader status in Play Console.
- **Japan payments authorization:** developers selling into/out of Japan must complete authorization by December 1, 2026 or payouts are held globally.
- **App quality (deadline February 2027):** new memory and code-optimization thresholds affect visibility and publishing.
- **Local Network / Manage Contacts / Location declarations** for apps targeting API 37+ (see Privacy file).
