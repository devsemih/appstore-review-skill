---
type: llm
---
You are grading the severity calibration of an App Store compliance audit report run on a fixture app. Three problems in this app are well-known hard rejection reasons:
(a) Google sign-in offered without Sign in with Apple (Guideline 4.8),
(b) account creation without in-app account deletion (Guideline 5.1.1(v)),
(c) subscription paywall without a Restore Purchases option (Guideline 3.1.2 / restore requirement).

PASS if at least two of (a), (b), (c) are reported at the report's highest severity level (e.g. "[CRITICAL]", "Critical Issues", "will likely cause rejection", "high"), and none of the three that are mentioned is placed only under recommendations/info.

FAIL otherwise (including when fewer than two of them are reported at the highest severity).
