# Changelog

All notable changes to this plugin. Versions follow [SemVer](https://semver.org/).

## [2.0.0] - 2026-11-11

### Added
- `/appstore-rejection` takes an App Review rejection (text, file or screenshot), maps each cited guideline or ITMS error to the rule, finds the root cause in the code with `file:line` evidence, proposes fixes and drafts a Resolution Center reply. It drafts an App Review Board appeal only when the rejection looks mistaken.
- `/playstore-rejection` does the same for Google Play policy rejections, removals and suspensions. It recommends fixing or appealing, lists the Play Console forms to update and drafts the appeal.
- `--build` option for both review commands. `scripts/inspect-ios-build.sh` checks `.ipa`, `.xcarchive` and `.app` files for likely ITMS-91053, ITMS-91061 and ITMS-90683 problems, purpose strings, entitlements and ATS settings. `scripts/inspect-android-build.sh` reads the merged manifest of `.aab` and `.apk` files, including permissions added by SDKs, `targetSdk`, `debuggable`, cleartext traffic, foreground service types and 16 KB page alignment.
- `--fix` option. Safe, mechanical fixes are applied directly (purpose strings, ATS exceptions, privacy manifest, `.gitignore` entries, unused permissions, cleartext and debuggable flags). Larger changes such as account deletion, Sign in with Apple, restore purchases, the Photo Picker or a `targetSdk` bump are proposed first and need confirmation.
- `evals/` with four fixture apps containing planted violations and decoys, run with `claude plugin eval`.
- Issue templates for rejection reports, false positives and bugs or ideas.
- `assets/demo.gif` and the script that renders it.

### Changed
- Apple guidelines updated to the October 16, 2026 revision. Checks were added or updated for 1.2 (AI content creation apps, nonconsensual imagery), 2.3.14 (creative assets, new), 2.5.19 (hidden features, moved from 2.3.1(a)), 3.1.1(a) (external purchase links), 4.3 (rewritten spam rules), 4.5.3 (Live Activities) and 4.8.
- Google Play policies updated with the October 29, 2026 announcement: Local Network and Manage Contacts permissions, the location button and fine location declaration (mandatory January 27, 2027), eligibility-based subscription discounts, AppFunctions, review manipulation, SMS and Call Log changes.
- The reference documents are split by section into `references/appstore/` and `references/playstore/`, each with an `INDEX.md`, and loaded only when needed. Before, one file of about 100 KB was read on every run.
- Both review commands collect project facts once and then run three subagents in parallel, one per group of guidelines. Every critical finding is checked again before it is reported.
- Findings include a confidence level (High, Medium, Low) and `file:line` evidence. Low confidence findings are never marked critical. Common false positives are excluded: platform checks in code under 2.3.10, publishable API keys, `console.log`, feature flags on their own, test folders.
- Reports have a summary table and a Manual Check Required section for App Store Connect and Play Console items. The verdict is now LOW RISK, NEEDS FIXES or HIGH RISK. "READY" was removed because static analysis can't guarantee approval.
- 4.8 findings describe the actual rule (an equivalent privacy-focused login, which Sign in with Apple satisfies) and its exceptions.

### Removed
- `references/guidelines-summary.md` and `references/play-policy-summary.md`, replaced by the per-section files.

## [1.2.0] - 2026-07-13
### Added
- `/playstore-review` for the Google Play Developer Program Policies, with a policy reference document and coverage of age-restricted content.

## [1.1.0] - 2026-03-03
### Added
- Packaged as a Claude Code plugin with marketplace support (`/plugin install`).
- Coverage of all applicable App Store guidelines in sections 1 to 5.
### Fixed
- A shell parsing error caused by a backtick-quoted exclamation mark in SKILL.md.

## [1.0.0] - 2026-03-02
- First release of `/appstore-review`.
