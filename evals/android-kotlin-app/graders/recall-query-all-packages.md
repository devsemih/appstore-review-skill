---
type: llm
---
You are grading the final report of an automated Google Play Developer Program Policy compliance audit that was run on a small fixture app with deliberately planted problems. Grade exactly ONE planted problem and ignore every other finding in the report.

Planted problem: AndroidManifest.xml requests QUERY_ALL_PACKAGES (with tools:ignore) only to check whether Strava is installed (tracking/PartnerApps.kt uses getInstalledApplications).

What counts as identifying it: the report flags QUERY_ALL_PACKAGES as a restricted permission that is not justified here and/or recommends a <queries> element for the specific package. Citing the Package (App) Visibility / QUERY_ALL_PACKAGES policy is enough, and so is a clear plain-language description of the problem without any number. Headings, formatting, severity labels and exact wording do not matter.

PASS if the report tells the developer that THIS app has this problem (or names this exact problem as a specific item to verify), at any severity: critical issue, warning, recommendation/info, or a specific manual-check item.

FAIL if the problem is not mentioned, appears only as a generic checklist line that does not say this app has the problem, or the report states this area is compliant.
