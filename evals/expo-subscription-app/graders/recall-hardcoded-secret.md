---
type: llm
---
You are grading the final report of an automated App Store Review Guidelines compliance audit that was run on a small fixture app with deliberately planted problems. Grade exactly ONE planted problem and ignore every other finding in the report.

Planted problem: lib/partners.ts hardcodes a Stripe secret key (const STRIPE_SECRET_KEY = 'sk_live_...') in the client bundle.

What counts as identifying it: the report flags the hardcoded sk_live_ / Stripe secret key (or 'hardcoded secret/API key' pointing at lib/partners.ts) as something to remove from the app. Citing Guideline 1.6 / 2.5 or a security finding is enough, and so is a clear plain-language description of the problem without any number. Headings, formatting, severity labels and exact wording do not matter.

PASS if the report tells the developer that THIS app has this problem (or names this exact problem as a specific item to verify), at any severity: critical issue, warning, recommendation/info, or a specific manual-check item.

FAIL if the problem is not mentioned, appears only as a generic checklist line that does not say this app has the problem, or the report states this area is compliant.
