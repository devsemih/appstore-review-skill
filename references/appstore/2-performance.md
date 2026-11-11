# App Store Review Guidelines — 2. Performance

> Source: https://developer.apple.com/app-store/review/guidelines/ (Last Updated: October 16, 2026). Verbatim text, split by section for on-demand loading. Relative links are relative to https://developer.apple.com. `![ASR & NR]` marks guidelines that also apply to Notarization review.

## 2. Performance

- **2.1 App Completeness**

- **(a)** ![ASR & NR] Submissions to App Review, including apps you make available for pre-order, should be final versions with all necessary metadata and fully functional URLs included; placeholder text, empty websites, and other temporary content should be scrubbed before submission. Make sure your app has been tested on-device for bugs and stability before you submit it, and include demo account info (and turn on your back-end service!) if your app includes a login. If you are unable to provide a demo account due to legal or security obligations, you may include a built-in demo mode in lieu of a demo account with prior approval by Apple. Ensure the demo mode exhibits your app’s full features and functionality. We will reject incomplete app bundles and binaries that crash or exhibit obvious technical problems.

- **(b)** If you offer in-app purchases in your app, make sure they are complete, up-to-date, visible to the reviewer and functional. If any configured in-app purchase items cannot be found or reviewed in your app, explain the reason in your review notes.

- **2.2 Beta Testing**

Demos, betas, and trial versions of your app don’t belong on the App Store – use TestFlight instead. Any app submitted for beta distribution via TestFlight should be intended for public distribution and should comply with the App Review Guidelines. Note, however, that apps using TestFlight cannot be distributed to testers in exchange for compensation of any kind, including as a reward for crowd-sourced funding. Significant updates to your beta build should be submitted to TestFlight App Review before being distributed to your testers. To learn more, visit the [TestFlight Beta Testing](/testflight/) page.

- **2.3 ![ASR & NR] Accurate Metadata**

Customers should know what they’re getting when they download or buy your app, so make sure all your app metadata, including privacy information, your app description, screenshots, and previews accurately reflect the app’s core experience and remember to keep them up-to-date with new versions.

- **2.3.1**

- **(a)** ![ASR & NR] All new features, functionality, and product changes must be described with specificity in the Notes for Review section of App Store Connect (generic descriptions will be rejected) and accessible for review. Similarly, marketing your app in a misleading way, such as by promoting content or services that it does not actually offer (such as iOS-based virus and malware scanners) or promoting a false price, whether within or outside of the App Store, is grounds for removal of your app from the App Store or a block from installing via alternative distribution and termination of your developer account.

- **(b)** Egregious or repeated behavior is grounds for removal from the Apple Developer Program. We work hard to make the App Store a trustworthy ecosystem and expect our app developers to follow suit; if you’re dishonest, we don’t want to do business with you.

- **2.3.2** If your app includes in-app purchases, make sure your app description, screenshots, and previews clearly indicate whether any featured items, levels, subscriptions, etc. require additional purchases. If you decide to promote in-app purchases on the App Store, ensure that the in-app purchase Display Name, Screenshot and Description are appropriate for a public audience, that you follow the guidance found in [Promoting Your In-App Purchases](/app-store/promoting-in-app-purchases/), and that your app properly handles the [SKPaymentTransactionObserver method](/documentation/storekit/skpaymenttransactionobserver/2877502-paymentqueue) so that customers can seamlessly complete the purchase when your app launches.

- **2.3.3** Screenshots should show the app in use, and not merely the title art, login page, or splash screen. They may also include text and image overlays (for example, to demonstrate input mechanisms, such as an animated touch point or Apple Pencil) and show extended functionality on device, such as Touch Bar. Learn more about [showing your app in use in screenshots](/help/app-review/guideline-reference/2-3-3-screenshots).

- **2.3.4** Previews are a great way for customers to see what your app looks like and what it does. To ensure people understand what they’ll be getting with your app, previews may only use video screen captures of the app itself. Stickers and iMessage extensions may show the user experience in the Messages app. You can add narration and video or textual overlays to help explain anything that isn’t clear from the video alone.

- **2.3.5** ![ASR & NR] Select the most appropriate category for your app, and check out the [App Store Category Definitions](/app-store/categories/) if you need help. If you’re way off base, we may change the category for you.

- **2.3.6** ![ASR & NR] Answer the age rating questions in App Store Connect honestly so that your app aligns properly with parental controls. If your app is mis-rated, customers might be surprised by what they get, or it could trigger an inquiry from government regulators. If your app includes media that requires the display of content ratings or warnings (such as films, music, games, etc.), you are responsible for complying with local requirements in each territory where your app is available.

- **2.3.7** ![ASR & NR] Choose a unique app name, assign keywords that accurately describe your app, and don’t try to pack any of your metadata with trademarked terms, popular app names, pricing information, or other irrelevant phrases just to game the system. App names must be limited to 30 characters. Metadata such as app names, subtitles, screenshots, and previews should not include prices, terms, or descriptions that are not specific to the metadata type. App subtitles are a great way to provide additional context for your app; they must follow our standard metadata rules and should not include inappropriate content, reference other apps, or make unverifiable product claims. Apple may modify inappropriate keywords at any time or take other appropriate steps to prevent abuse.

- **2.3.8** ![ASR & NR] Metadata should be appropriate for all audiences, so make sure your app and in-app purchase icons, screenshots, and previews adhere to a 4+ age rating even if your app is rated higher. For example, if your app is a game that includes violence, select images that don’t depict a gruesome death or a gun pointed at a specific character. Use of terms like “For Kids” and “For Children” in app metadata is reserved in the App Store for the Kids Category. Remember to ensure your metadata, including app name and icons (small, large, Apple Watch app, alternate icons, etc.), are similar to avoid creating confusion.

- **2.3.9** You are responsible for securing the rights to use all materials in your app icons, screenshots, and previews, and you should display fictional account information instead of data from a real person.

- **2.3.10** Make sure your app is focused on the experience of the Apple platforms it supports, and don’t include names, icons, or imagery of other mobile platforms or alternative app marketplaces in your app or metadata, unless there is specific, approved interactive functionality. Make sure your app metadata is focused on the app itself and its experience. Don’t include irrelevant information.

- **2.3.11** Apps you submit for pre-order on the App Store must be complete and deliverable as submitted. Ensure that the app you ultimately release is not materially different from what you advertise while the app is in a pre-order state. If you make material changes to the app (such as changing business models), you should restart your pre-order sales.

- **2.3.12** Apps must clearly describe new features and product changes in their “What’s New” text. Simple bug fixes, security updates, and performance improvements may rely on a generic description, but more significant changes must be listed in the notes.

- **2.3.13** In-app events are timely events that happen within your app. To feature your event on the App Store, it must fall within an event type provided in App Store Connect. All event metadata must be accurate and pertain to the event itself, rather than the app more generally. Events must happen at the times and dates you select in App Store Connect, including across multiple storefronts. You may monetize your event so long as you follow the rules set forth in Section 3 on Business. And your event deep link must direct users to the proper destination within your app. Read [In-App Events](/app-store/in-app-events/) for detailed guidance on acceptable event metadata and event deep links.

- **2.3.14** Creative assets allow you to highlight the value of your app in new ways compared to app-in-use screenshots and preview videos, and can be used across the App Store, including the product page header and in search results. Creative assets must pertain to your app’s content and functionality or overarching brand, follow standard metadata guidelines, and be appropriate for all audiences. They should not include inappropriate content, references to other apps with an intent to mislead, unverifiable product claims, or specific or discounted pricing information. Read [App Store asset best practices](/app-store/asset-best-practices/#asset-guidelines) for detailed guidance on acceptable recommendations.

- **2.4 Hardware Compatibility**

- **2.4.1** To ensure people get the most out of your app, iPhone apps should run on iPad whenever possible. We encourage you to consider building apps so customers can use them on [all of their devices](https://developer.apple.com/documentation/xcode/configuring-a-multiplatform-app-target).

- **2.4.2** ![ASR & NR] Design your app to use power efficiently and be used in a way that does not risk damage to the device. Apps should not rapidly drain battery, generate excessive heat, or put unnecessary strain on device resources. For example, apps should not encourage placing the device under a mattress or pillow while charging or perform excessive write cycles to the solid state drive. Apps, including any third-party advertisements displayed within them, may not run unrelated background processes, such as cryptocurrency mining.

- **2.4.3** People should be able to use your Apple TV app without the need for hardware inputs beyond the Siri remote or third-party game controllers, but feel free to provide enhanced functionality when other peripherals are connected. If you require a game controller, make sure you clearly explain that in your metadata so customers know they need additional equipment to play.

- **2.4.4** ![ASR & NR] Apps should never suggest or require a restart of the device or modifications to system settings unrelated to the core functionality of the app. For example, don’t encourage users to turn off Wi-Fi, disable security features, etc.

- **2.4.5** Apps distributed via the Mac App Store have some additional requirements to keep in mind:

- **(i)** They must be appropriately sandboxed, and follow [macOS File System Documentation](/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/Introduction/Introduction.html#apple_ref/doc/uid/TP40010672/). They should also only use the appropriate macOS APIs for modifying user data stored by other apps (such as bookmarks, Address Book, or Calendar entries).

- **(ii)** They must be packaged and submitted using technologies provided in Xcode; no third-party installers allowed. They must also be self-contained, single app installation bundles and cannot install code or resources in shared locations.

- **(iii)** They may not auto-launch or have other code run automatically at startup or login without consent nor spawn processes that continue to run without consent after a user has quit the app. They should not automatically add their icons to the Dock or leave shortcuts on the user desktop.

- **(iv)** They may not download or install standalone apps, kexts, additional code, or resources to add functionality or significantly change the app from what we see during the review process.

- **(v)** They may not request escalation to root privileges or use setuid attributes.

- **(vi)** They may not present a license screen at launch, require license keys, or implement their own copy protection.

- **(vii)** They must use the Mac App Store to distribute updates; other update mechanisms are not allowed.

- **(viii)** Apps should run on the currently shipping OS and may not use deprecated or optionally installed technologies (such as Java).

- **(ix)** Apps must contain all language and localization support in a single app bundle.

- **2.5 Software Requirements**

- **2.5.1** ![ASR & NR] Apps may only use public APIs and must run on the currently shipping OS. Learn more about [public APIs](/documentation/). Keep your apps up-to-date and make sure you phase out any deprecated features, frameworks or technologies that will no longer be supported in future versions of an OS. Apps should use APIs and frameworks for their intended purposes and indicate that integration in their app description. For example, the HomeKit framework should provide home automation services; and HealthKit should be used for health and fitness purposes and integrate with the Health app.

- **2.5.2** ![ASR & NR] Apps should be self-contained in their bundles, and may not read or write data outside the designated container area, nor may they download, install, or execute code which introduces or changes features or functionality of the app, including other apps. Educational apps designed to teach, develop, or allow students to test executable code may, in limited circumstances, download code provided that such code is not used for other purposes. Such apps must make the source code provided by the app completely viewable and editable by the user.

- **2.5.3** ![ASR & NR] Apps that transmit viruses, files, computer code, or programs that may harm or disrupt the normal operation of the operating system and/or hardware features, including Push Notifications and Game Center, will be rejected. Egregious violations and repeat behavior will result in removal from the Apple Developer Program.

- **2.5.4** ![ASR & NR] Multitasking apps may only use background services for their intended purposes: VoIP, audio playback, location, task completion, local notifications, etc.

- **2.5.5** Apps must be fully functional on IPv6-only networks.

- **2.5.6** ![ASR & NR] Apps that browse the web must use the appropriate WebKit framework and WebKit JavaScript. You may apply for an entitlement to use an alternative web browser engine in your app. [Learn more about these entitlements](/support/alternative-browser-engines/) for the EU and Japan.

- **2.5.7** Intentionally omitted.

- **2.5.8** Apps that create alternate desktop/home screen environments will be rejected.

- **2.5.9** ![ASR & NR] Apps that alter or disable the functions of standard switches, such as the Volume Up/Down and Ring/Silent switches, or other native user interface elements or behaviors will be rejected. For example, apps should not block links out to other apps or other features that users would expect to work a certain way.

- **2.5.10** Intentionally omitted.

- **2.5.11** ![ASR & NR] SiriKit and Shortcuts

- **(i)** Apps integrating SiriKit and Shortcuts should only sign up for intents they can handle without the support of an additional app and that users would expect from the stated functionality. For example, if your app is a meal planning app, you should not incorporate an intent to start a workout, even if the app shares integration with a fitness app.

- **(ii)** Ensure that the vocabulary and phrases in your plist pertains to your app and the Siri functionality of the intents the app has registered for. Aliases must relate directly to your app or company name and should not be generic terms or include third-party app names or services.

- **(iii)** Resolve the Siri request or Shortcut in the most direct way possible and do not insert ads or other marketing between the request and its fulfillment. Only request a disambiguation when required to complete the task (such as asking the user to specify a particular type of workout).

- **2.5.12** ![ASR & NR] Apps using CallKit or including an SMS Fraud Extension should only block phone numbers that are confirmed spam. Apps that include call-, SMS-, and MMS- blocking functionality or spam identification must clearly identify these features in their marketing text and explain the criteria for their blocked and spam lists. You may not use the data accessed via these tools for any purpose not directly related to operating or improving your app or extension (for example, you may not use, share, or sell it for tracking purposes, create user profiles, etc.).

- **2.5.13** ![ASR & NR] Apps using facial recognition for account authentication must use [LocalAuthentication](/documentation/localauthentication) (and not ARKit or other facial recognition technology) where possible, and must use an alternate authentication method for users under 13 years old.

- **2.5.14** ![ASR & NR] Apps must request explicit user consent and provide a clear visual and/or audible indication when recording, logging, or otherwise making a record of user activity. This includes any use of the device camera, microphone, screen recordings, or other user inputs.

- **2.5.15** Apps that enable users to view and select files should include items from the Files app and the user’s iCloud documents.

- **2.5.16** ![ASR & NR] Widgets, extensions, and notifications should be related to the content and functionality of your app.

- **(a)** Additionally, all App Clip features and functionality must be included in the main app binary. App Clips cannot contain advertising.

- **2.5.17** ![ASR & NR] Apps that support Matter must use Apple’s support framework for Matter to initiate pairing. In addition, if you choose to use any Matter software component in your app other than the Matter SDK provided by Apple, the software component must be certified by the [Connectivity Standards Alliance](https://csa-iot.org/) for the platform it runs on.

- **2.5.18** ![ASR & NR] Display advertising should be limited to your main app binary, and should not be included in extensions, App Clips, widgets, notifications, keyboards, watchOS apps, etc. Ads displayed in an app must be appropriate for the app’s age rating, allow the user to see all information used to target them for that ad (without requiring the user to leave the app), and may not engage in targeted or behavioral advertising based on sensitive user data such as health/medical data (such as from the HealthKit APIs), school and classroom data (such as from ClassKit), or from kids (such as from apps in the App Store’s Kids Category), etc. Interstitial ads or ads that interrupt or block the user experience must clearly indicate that they are an ad, must not manipulate or trick users into tapping into them, and must provide easily accessible and visible close/skip buttons large enough for people to easily dismiss the ad. Apps that contain ads must also include the ability for users to report any inappropriate or age-inappropriate ads.

- **2.5.19** ![ASR & NR] Don’t include any hidden, dormant, or undocumented features in your app; your app’s functionality should be clear to end users and App Review. Attempting to hide undocumented features in your app binary, such as through code obfuscation or other methods, is grounds for removal of your app from the App Store and termination of your developer account.
