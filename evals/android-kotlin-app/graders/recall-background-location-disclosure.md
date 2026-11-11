---
type: llm
---
You are grading the final report of an automated Google Play Developer Program Policy compliance audit that was run on a small fixture app with deliberately planted problems. Grade exactly ONE planted problem and ignore every other finding in the report.

Planted problem: ACCESS_BACKGROUND_LOCATION is declared and requested right after foreground location in settings/SettingsActivity.kt with no prominent in-app disclosure dialog first, while LocationSampleWorker collects location every 15 minutes even when the app is closed.

What counts as identifying it: the report flags background location as needing a prominent disclosure/consent before the request (and/or Play Console declaration), or says the disclosure is missing. Citing the Location Permissions / background location / Prominent Disclosure policy is enough, and so is a clear plain-language description of the problem without any number. Headings, formatting, severity labels and exact wording do not matter.

PASS if the report tells the developer that THIS app has this problem (or names this exact problem as a specific item to verify), at any severity: critical issue, warning, recommendation/info, or a specific manual-check item.

FAIL if the problem is not mentioned, appears only as a generic checklist line that does not say this app has the problem, or the report states this area is compliant.
