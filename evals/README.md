# Eval suite

Measures whether `/appstore-review` and `/playstore-review` find deliberately planted store-policy violations (**recall**) without flagging compliant code (**false positives**). It uses [`claude plugin eval`](https://code.claude.com/docs/en/plugin-evals.md) (Claude Code ≥ 2.1.269).

## Run it

From the repo root:

```bash
# Full suite: 4 cases × 3 runs, with plugin and no-plugin baseline arms
claude plugin eval . --scaffold --trust-plugin --judge-model sonnet

# Cheaper: one run per case, skip the baseline arm
claude plugin eval . --scaffold --trust-plugin --judge-model sonnet --runs 1 --ablation none

# One case, bounded spend, report kept local
claude plugin eval . --case expo-subscription-app --scaffold --trust-plugin \
  --runs 1 --ablation none --max-cost-usd 3 --no-publish

# Only the App Store cases, or only Play
claude plugin eval . --tag appstore --scaffold --trust-plugin
claude plugin eval . --tag playstore --scaffold --trust-plugin
```

**`--scaffold` is required.** Each run starts in an empty workspace, and the case's `scaffold.sh` copies its `project/` fixture into it. Without `--scaffold` the skill audits an empty directory and every recall grader fails. The script only runs `cp -R ./project/. .`.

Other flags:
- `--trust-plugin` skips the first-run trust prompt.
- `--judge-model sonnet` is recommended. The default judge (haiku) is more likely to misread long reports.
- `--json results.json` keeps machine-readable per-grader verdicts.
- `--concurrency 2` runs cases in parallel. All runs share one rate limit.

The `--build` and `--fix` modes are not exercised. Bash is not granted, so the skills audit source with Read/Grep/Glob and subagents.

Results go to `evals/results/<timestamp>/`, which is gitignored. The HTML report shows each grader's verdict and the judge's reasoning.

**Auth:** eval runs are `claude -p` child processes that use the CLI's own login. If every run ends with `Failed to authenticate ... 401`, run `claude auth login` in a terminal first.

## Layout

```
evals/<case>/
  case.yaml      # schema_version 1.1, runs, scaffold_script, max_turns/timeout, append_system_prompt
  prompt.md      # the user request, phrased the way a user would type it (no slash command)
  scaffold.sh    # copies ./project into the run workspace
  project/       # the fixture app: the only thing the agent sees
  EXPECTED.md    # answer key (stays in the case dir, never copied into the workspace)
  graders/*.md   # one check per file
```

Grader conventions:
- `skill-fired` is a `tool_used: Skill` check that the plugin's skill was invoked. In two-arm runs it is a plugin-fired indicator, not part of the score.
- `recall-*` are `llm` graders, one per planted issue. A grader passes if the report says this app has the problem, at any severity. Citing the guideline/policy or describing the problem in plain words is enough, so the graders don't depend on exact headings.
- `no-fp-*` are `llm` graders, one per decoy. A grader passes unless the decoy is reported as CRITICAL/WARNING. Not mentioning it, calling it compliant, or listing it as INFO is fine.
- `verdict-*` and `critical-severity-*`, plus `no-critical-findings`/`few-warnings` on the clean app, check severity calibration and the overall verdict.
- Each case appends a system prompt telling the main agent to reproduce the skill's report verbatim as its final reply. That way graders on `last_message` see the full report even if the skill hands off to subagents.

## Cases and answer key

| Case | Skill | Planted (recall graders) | Decoys / FP graders |
|------|-------|--------------------------|---------------------|
| `expo-subscription-app` | appstore | 8 | 2 decoys + severity + verdict |
| `flutter-ugc-app` | appstore | 5 | 2 decoys + verdict |
| `android-kotlin-app` | playstore | 7 | 1 decoy + verdict |
| `swiftui-clean-app` | appstore | 0 (compliant app) | 5 decoys + no-critical + few-warnings + low-risk verdict |
| **Total** | | **20 planted issues** | **10 decoys** |

### expo-subscription-app ("Fitloop", Expo SDK 52 managed, Supabase, RevenueCat)
Planted:
1. 4.8: Google sign-in via `expo-auth-session`, no Sign in with Apple.
2. 5.1.1(v): Supabase signup, no account deletion.
3. 3.1.2: RevenueCat paywall with no Restore Purchases.
4. 3.1.2(c): paywall CTA with no price, period or renewal terms.
5. `expo-camera` plugin with no `cameraPermission` text.
6. `NSAllowsArbitraryLoads: true` via `app.json`.
7. Hardcoded `sk_live_…` Stripe secret. The value is fake and contains underscores, so push-protection scanners don't match it.
8. `console.log` + staging API URL.

Decoys:
- `Platform.OS === 'android'` branches. Code only, so not 2.3.10.
- A specific `NSPhotoLibraryUsageDescription`.

### flutter-ugc-app ("Huddle", Firebase chat, AdMob, geolocator, Stripe)
Planted:
1. 1.2: Firestore chat with no report/block.
2. 5.1.2: `google_mobile_ads` with no ATT and no `NSUserTrackingUsageDescription`.
3. `UIBackgroundModes: location` + Always permission with a vague purpose string and no justifying feature.
4. 3.1.1: virtual coins sold through Stripe.
5. No `PrivacyInfo.xcprivacy`.

Decoys:
- Account deletion exists.
- Email-only login, so 4.8 doesn't apply.

### android-kotlin-app ("StrideClub", native Kotlin, for `/playstore-review`)
Planted:
1. `targetSdk = 33`.
2. `QUERY_ALL_PACKAGES` just to detect Strava.
3. `ACCESS_BACKGROUND_LOCATION` with no prominent disclosure.
4. `READ_MEDIA_IMAGES` for a one-off avatar pick (should use the photo picker).
5. Firebase signup with no account deletion.
6. `MobileAds.initialize()` + banner load before UMP consent.
7. `usesCleartextTraffic="true"`.

Decoy:
- `POST_NOTIFICATIONS` requested correctly at runtime after a rationale.

### swiftui-clean-app ("Pebble Journal", native SwiftUI, deliberately compliant)
The app has:
- Sign in with Apple only.
- StoreKit 2 with Restore Purchases and full terms + EULA above the CTA.
- In-app account deletion.
- A complete privacy manifest (UserDefaults `CA92.1`).
- `NSFaceIDUsageDescription`, with `PhotosPicker` (no photo permission needed).
- No ads, no tracking, HTTPS only.

The expected verdict is LOW RISK with no CRITICAL findings and at most 2 warnings.

Full per-file details are in each case's `EXPECTED.md`.

## Reporting numbers

- **Recall:** count passing `recall-*` graders across the three violation cases (max 20 per run).
- **False positives:** count failing `no-fp-*` graders across all cases (10 decoys), plus `no-critical-findings` on the clean app.

`--json` output has per-run grader verdicts under `cases[].arms.with[].graders[]`. For example:

```bash
jq -r '.cases[] | .name as $c | .arms.with[] | .graders[]
  | select(.name|startswith("recall-")) | [$c,.name,.passed] | @tsv' results.json
```

Report the mean over runs (e.g. "catches 19/20 planted issues, 0/10 decoys flagged, 3 runs, Sonnet judge") and the model shown in the report.
