---
type: llm
---
You are grading the final report of an automated App Store Review Guidelines compliance audit that was run on a small fixture app with deliberately planted problems. Grade exactly ONE planted problem and ignore every other finding in the report.

Planted problem: ios/Runner/Info.plist declares UIBackgroundModes 'location' and requests Always location (NSLocationAlwaysAndWhenInUseUsageDescription is just 'Huddle uses your location.'); lib/services/location_service.dart streams the user's position to Firestore in the background (allowBackgroundLocationUpdates: true, showBackgroundLocationIndicator: false) only to keep 'nearby' presence fresh. There is no feature that justifies continuous background location and the purpose string does not explain it.

What counts as identifying it: the report questions or flags the background location usage (UIBackgroundModes location / Always permission) as unjustified, or flags the Always/background location purpose string as vague/insufficient. Citing Guideline 2.5.4, 5.1.5, 5.1.1 or 2.3 (purpose strings) is enough, and so is a clear plain-language description of the problem without any number. Headings, formatting, severity labels and exact wording do not matter.

PASS if the report tells the developer that THIS app has this problem (or names this exact problem as a specific item to verify), at any severity: critical issue, warning, recommendation/info, or a specific manual-check item.

FAIL if the problem is not mentioned, appears only as a generic checklist line that does not say this app has the problem, or the report states this area is compliant.
