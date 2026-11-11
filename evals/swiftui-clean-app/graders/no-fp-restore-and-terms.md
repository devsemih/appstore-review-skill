---
type: llm
---
You are grading the final report of an automated App Store Review Guidelines compliance audit that was run on a small fixture app. This grader checks for ONE false positive and ignores everything else in the report.

Decoy (compliant on purpose): StoreKit 2 subscriptions with a Restore Purchases button (AppStore.sync() in Store/StoreManager.swift, shown on the paywall and in Settings), plus price, period, auto-renewal and cancellation terms and Terms of Use / Privacy links directly above the Subscribe button in Store/PaywallView.swift. Periods are P1M and P1Y.
Why it is not a violation: This satisfies Guideline 3.1.2 (restore, clear terms before purchase, periods of at least 7 days).

PASS if the report does NOT present this as a blocking or likely-rejection problem. It is fine if the report never mentions it, describes it as compliant or passing, or mentions it only as a low-priority recommendation, info note, or optional manual check.

FAIL if any finding labelled CRITICAL or WARNING (or listed under critical issues / warnings / "will likely cause rejection" / "may cause rejection") claims that Restore Purchases is missing, or subscription price/period/renewal terms or EULA/Terms links are missing.
