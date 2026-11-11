# Changelog

All notable changes to this plugin. Versions follow [SemVer](https://semver.org/).

## [2.0.0] — 2026-11-11

### Added
- **`/appstore-rejection`**: paste an App Review rejection (text, file, or screenshot). It maps each cited guideline or ITMS error to the exact rule, finds the root cause in your code with `file:line` evidence, proposes fixes, and drafts a Resolution Center reply. It drafts an App Review Board appeal only when the rejection looks genuinely mistaken.
- **`/playstore-rejection`**: the same for Google Play policy rejections, removals and suspension emails. It helps you decide between fixing and appealing, lists the Play Console forms to update, and drafts the appeal.
- **Build inspection (`--build`)**: `scripts/inspect-ios-build.sh` checks `.ipa`/`.xcarchive`/`.app` files for likely ITMS-91053 (required-reason APIs without a declaration) and ITMS-91061 (listed SDKs without a privacy manifest). It also reports usage strings, entitlements and ATS settings. `scripts/inspect-android-build.sh` reads the merged manifest of an `.aab`/`.apk`, including SDK-injected permissions, `targetSdk`, `debuggable`, cleartext traffic and foreground-service types.
- **Fix mode (`--fix`)**: applies safe, mechanical fixes directly, such as purpose strings, ATS exceptions, privacy manifest, `.gitignore` entries, unused permissions and cleartext/debuggable flags. Larger changes (account deletion, Sign in with Apple, restore purchases, Photo Picker, `targetSdk`) are planned first and need your confirmation.
- **Eval suite (`evals/`)**: fixture apps with planted violations and decoys. It measures recall and false positives with `claude plugin eval`.
- **Issue templates** for rejection reports, false positives and bugs/ideas.

### Changed
- **Apple guidelines updated to the October 16, 2026 revision**, which added 1.2 (now covering AI content creation apps and nonconsensual intimate imagery), new 2.3.14 (creative assets), new 2.5.19 (hidden features, moved out of 2.3.1(a)), 3.1.1(a) external purchase links, the rewritten 4.3 Spam, 4.5.3 (Live Activities) and 4.8. The checks now cover these changes.
- **Google Play policies now include the October 29, 2026 update**: Local Network and Manage Contacts permissions, the location button and fine-location declaration (mandatory January 27, 2027), eligibility-based subscription discounts, AppFunctions, the review-manipulation clarification and SMS/Call Log changes.
- **References are split by section** (`references/appstore/`, `references/playstore/`, each with an `INDEX.md`) and loaded on demand. Previously one ~100 KB file was loaded up front on every run.
- **Parallel audit**: both review skills discover project facts once, then run three subagents concurrently (one per guideline slice). The main session verifies every CRITICAL before reporting.
- **Fewer false positives**: every finding now carries a confidence level (`High`/`Medium`/`Low`) and `file:line` evidence, and Low confidence is never CRITICAL. A list of known false positives is excluded: platform-branching code under 2.3.10, publishable keys, `console.log`, feature flags on their own, and test folders.
- **Clearer reports**: added a severity summary table and a "Manual Check Required" section for App Store Connect / Play Console items. Verdicts are now `LOW RISK` / `NEEDS FIXES` / `HIGH RISK`; there is no more "READY", because static analysis can't guarantee approval.
- 4.8 findings now describe the actual rule (an equivalent privacy-focused login; Sign in with Apple satisfies it) and its exceptions.

### Removed
- `references/guidelines-summary.md` and `references/play-policy-summary.md`, replaced by the per-section files.

## [1.2.0] — 2026-07-13
### Added
- `/playstore-review`: a Google Play Developer Program Policies audit with a policy reference document and Age-Restricted Content coverage.

## [1.1.0] — 2026-03-03
### Added
- Packaged as a Claude Code plugin with marketplace support (`/plugin install`).
- Full coverage of the applicable App Store guidelines (Sections 1–5).
### Fixed
- Shell parsing error caused by backticks around `!` in SKILL.md.

## [1.0.0] — 2026-03-02
- Initial release: the `/appstore-review` App Store Review Guidelines checker.
