---
type: llm
---
You are grading the final report of an automated App Store Review Guidelines compliance audit that was run on a small fixture app with deliberately planted problems. Grade exactly ONE planted problem and ignore every other finding in the report.

Planted problem: The RevenueCat paywall (app/paywall.tsx, lib/purchases.ts) has no Restore Purchases button; Purchases.restorePurchases() is never called anywhere.

What counts as identifying it: the report says a restore purchases mechanism/button is missing. Citing Guideline 3.1.2 (or 3.1.1 restore requirement) is enough, and so is a clear plain-language description of the problem without any number. Headings, formatting, severity labels and exact wording do not matter.

PASS if the report tells the developer that THIS app has this problem (or names this exact problem as a specific item to verify), at any severity: critical issue, warning, recommendation/info, or a specific manual-check item.

FAIL if the problem is not mentioned, appears only as a generic checklist line that does not say this app has the problem, or the report states this area is compliant.
