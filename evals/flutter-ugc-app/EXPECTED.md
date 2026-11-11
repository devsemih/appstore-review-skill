# Answer key: flutter-ugc-app ("Huddle")

Flutter chat app: Firebase Auth (email/password only), Firestore chat rooms, AdMob banner, geolocator, flutter_stripe.

## Planted violations (should be reported)

| # | Grader | Guideline | Where | What |
|---|--------|-----------|-------|------|
| 1 | `recall-ugc-report-block` | 1.2 | `lib/screens/chat_screen.dart` | Public Firestore chat with no report, block or filtering |
| 2 | `recall-att-missing` | 5.1.2 | `pubspec.yaml`, `lib/main.dart`, `ios/Runner/Info.plist` | `google_mobile_ads` initialized; no `app_tracking_transparency`, no `NSUserTrackingUsageDescription` |
| 3 | `recall-background-location` | 2.5.4 / 5.1.5 | `ios/Runner/Info.plist`, `lib/services/location_service.dart` | `UIBackgroundModes: location` + Always request + vague "Huddle uses your location."; background streaming only for "nearby" presence, indicator hidden |
| 4 | `recall-stripe-digital-coins` | 3.1.1 | `lib/screens/coin_shop_screen.dart` | Virtual coins (gifts/boosts) sold through Stripe PaymentSheet |
| 5 | `recall-privacy-manifest-missing` | 5.1.1 / 5.1.2 | `ios/Runner/` | No `PrivacyInfo.xcprivacy` |

Verdict check (`verdict-not-low-risk`): NEEDS FIXES or HIGH RISK.

## Decoys (must NOT be CRITICAL/WARNING)

| Grader | What | Why it's fine |
|--------|------|---------------|
| `no-fp-account-deletion` | `lib/screens/settings_screen.dart` deletes the Firestore doc + `user.delete()` | Deletion exists (5.1.1(v)) |
| `no-fp-sign-in-with-apple` | Email/password is the only login | 4.8 applies only with third-party login |

## Neutral (not graded)

- `pk_live_EVALFIXTURE_...` Stripe **publishable** key in `lib/main.dart` (public by design. Flagging it is noise but isn't graded).
- Test AdMob IDs (`ca-app-pub-3940256099942544...`).
