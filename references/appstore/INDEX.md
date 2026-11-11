# App Store Review Guidelines — Index

Guidelines version: **October 16, 2026** (source: https://developer.apple.com/app-store/review/guidelines/).

Load only the file(s) you need. Every guideline number maps to exactly one file by its first digit: `1.x` → `1-safety.md`, `2.x` → `2-performance.md`, `3.x` → `3-business.md`, `4.x` → `4-design.md`, `5.x` → `5-legal.md`. Sub-items like 2.1(a) or 5.1.1(v) live under their parent guideline.

| File | Section | Words | Guidelines |
|---|---|---|---|
| `0-intro-before-you-submit.md` | Introduction & Before You Submit | 1,022 | — |
| `1-safety.md` | 1. Safety | 1,638 | 1.1, 1.1.1, 1.1.2, 1.1.3, 1.1.4, 1.1.5, 1.1.6, 1.1.7, 1.2, 1.2.1, 1.3, 1.4, 1.4.1, 1.4.2, 1.4.3, 1.4.4, 1.4.5, 1.5, 1.6, 1.7 |
| `2-performance.md` | 2. Performance | 3,073 | 2.1, 2.2, 2.3, 2.3.1, 2.3.2, 2.3.3, 2.3.4, 2.3.5, 2.3.6, 2.3.7, 2.3.8, 2.3.9, 2.3.10, 2.3.11, 2.3.12, 2.3.13, 2.3.14, 2.4, 2.4.1, 2.4.2, 2.4.3, 2.4.4, 2.4.5, 2.5, 2.5.1, 2.5.2, 2.5.3, 2.5.4, 2.5.5, 2.5.6, 2.5.7, 2.5.8, 2.5.9, 2.5.10, 2.5.11, 2.5.12, 2.5.13, 2.5.14, 2.5.15, 2.5.16, 2.5.17, 2.5.18, 2.5.19 |
| `3-business.md` | 3. Business | 2,911 | 3.1, 3.1.1, 3.1.1(a), 3.1.2, 3.1.2(a), 3.1.2(b), 3.1.2(c), 3.1.3, 3.1.3(a), 3.1.3(b), 3.1.3(c), 3.1.3(d), 3.1.3(e), 3.1.3(f), 3.1.3(g), 3.1.4, 3.1.5, 3.2, 3.2.1, 3.2.2 |
| `4-design.md` | 4. Design | 2,575 | 4.1, 4.2, 4.2.1, 4.2.2, 4.2.3, 4.2.4, 4.2.5, 4.2.6, 4.2.7, 4.3, 4.4, 4.4.1, 4.4.2, 4.4.3, 4.5, 4.5.1, 4.5.2, 4.5.3, 4.5.4, 4.5.5, 4.5.6, 4.6, 4.7, 4.7.1, 4.7.2, 4.7.3, 4.7.4, 4.7.5, 4.8, 4.9, 4.10 |
| `5-legal.md` | 5. Legal | 3,660 | 5.1, 5.1.1, 5.1.2, 5.1.3, 5.1.4, 5.1.5, 5.2, 5.2.1, 5.2.2, 5.2.3, 5.2.4, 5.2.5, 5.3, 5.3.1, 5.3.2, 5.3.3, 5.3.4, 5.4, 5.5, 5.6, 5.6.1, 5.6.2, 5.6.3, 5.6.4 |
| `6-after-you-submit.md` | After You Submit | 475 | — |

## Changes in the October 16, 2026 revision

- **Before You Submit / After You Submit:** links to additional App Review Help documentation.
- **1.2 User-Generated Content:** now explicitly covers any app where users create, generate, upload or share content — including social media and **AI content creation apps** — and nonconsensual intimate imagery. Failing to implement safeguards or to remediate violations after notice can be treated as a Developer Code of Conduct violation.
- **2.3.14 (new):** creative assets (product page header, search) must follow metadata rules, be all-audience appropriate, no misleading references, unverifiable claims, or specific/discounted prices.
- **2.5.19 (new):** hidden, dormant, or undocumented features — moved out of 2.3.1(a); obfuscating undocumented features in the binary is grounds for removal.
- **3.1.1(a):** Music Streaming Services Entitlement folded into the StoreKit External Purchase Link Entitlement bullet; links may go to a "permitted destination".
- **4.3 Spam:** rewritten — multiple Bundle IDs of the same app and "indistinguishable" copycat apps in saturated categories (dating, flashlight, sound effects, etc.).
- **4.5.3:** Live Activities added to Apple services that must not be used for spam.
- **4.8:** login-service examples updated ("Log in with X").
- **5 Legal:** apps found to facilitate human trafficking and/or child exploitation are removed and blocked from alternative distribution.
