# Answer key: expo-subscription-app ("Fitloop")

Expo SDK 52 managed workflow (no `ios/` folder), Supabase auth, RevenueCat subscriptions.
This file stays in the case directory. `scaffold.sh` copies only `project/` into the run workspace.

## Planted violations (should be reported)

| # | Grader | Guideline | Where | What |
|---|--------|-----------|-------|------|
| 1 | `recall-sign-in-with-apple` | 4.8 | `app/(auth)/login.tsx`, `package.json` | "Continue with Google" via `expo-auth-session/providers/google`; no `expo-apple-authentication` / Apple button |
| 2 | `recall-account-deletion` | 5.1.1(v) | `lib/supabase.ts`, `app/(auth)/signup.tsx`, `app/settings.tsx` | `supabase.auth.signUp` exists; settings only has Sign out, no delete account |
| 3 | `recall-restore-purchases` | 3.1.2 (restore) | `app/paywall.tsx`, `lib/purchases.ts` | RevenueCat paywall; `Purchases.restorePurchases()` never called, no Restore button |
| 4 | `recall-subscription-terms` | 3.1.2(c) | `app/paywall.tsx` | CTA "Start Premium" with no price, period, auto-renew/cancel terms or EULA link |
| 5 | `recall-camera-usage-description` | 5.1.1 / 2.3 purpose strings | `app.json` | `"expo-camera"` plugin with no `cameraPermission`, no `NSCameraUsageDescription` in `infoPlist`, so the purpose string is the generic default |
| 6 | `recall-ats-arbitrary-loads` | 1.6 / ATS | `app.json` | `ios.infoPlist.NSAppTransportSecurity.NSAllowsArbitraryLoads: true` |
| 7 | `recall-hardcoded-secret` | 1.6 | `lib/partners.ts` | `STRIPE_SECRET_KEY = 'sk_live_EVALFIXTURE_...'` in the client bundle. The value is fake and written so push-protection secret scanners don't match it |
| 8 | `recall-debug-staging` | 2.1 / 2.2 | `lib/api.ts` | `API_BASE_URL = 'https://staging-api.fitloop.app/v1'` (+ TODO), `console.log` of API responses |

Severity check (`critical-severity-core-issues`): at least 2 of #1, #2, #3 should be rated CRITICAL.
Verdict check (`verdict-not-low-risk`): verdict must be NEEDS FIXES or HIGH RISK.

## Decoys (must NOT be CRITICAL/WARNING)

| Grader | What | Why it's fine |
|--------|------|---------------|
| `no-fp-platform-os-android` | `Platform.OS === 'android'` in `lib/purchases.ts` and `app/(auth)/login.tsx` | 2.3.10 covers user-facing references to other platforms. Code branching doesn't count |
| `no-fp-photo-library-description` | `NSPhotoLibraryUsageDescription` in `app.json` | Present and specific |

## Neutral (not graded either way)

- `lib/partners.ts` uses Stripe for in-person training invoices (a physical service, which 3.1.3(e) allows outside IAP). Its only graded problem is the hardcoded secret.
- Supabase anon key in `lib/supabase.ts` is a public key by design.
- `app.json` references icon files that are not in the fixture (binaries are left out on purpose).
- `ios.privacyManifests` declares only the UserDefaults reason (`CA92.1`). A WARNING that it lacks collected data types or RN/Expo required-reason APIs is reasonable.
- Paywall features aren't gated on the `premium` entitlement in the client (2.1(b)). The progress-photo screen has a weak no-camera-permission path. Both are fair extra findings.
