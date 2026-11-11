# App Store Review Guidelines — 4. Design

> Source: https://developer.apple.com/app-store/review/guidelines/ (Last Updated: October 16, 2026). Verbatim text, split by section for on-demand loading. Relative links are relative to https://developer.apple.com. `![ASR & NR]` marks guidelines that also apply to Notarization review.

## 4. Design

Apple customers place a high value on products that are simple, refined, innovative, and easy to use, and that’s what we want to see on the App Store. Coming up with a great design is up to you, but the following are minimum standards for approval to the App Store. And remember that even after your app has been approved, you should update your app to ensure it remains functional and engaging to new and existing customers. Apps that stop working or offer a degraded experience may be removed from the App Store at any time.

- **4.1 Copycats**

- **(a)** Come up with your own ideas. We know you have them, so make yours come to life. Don’t simply copy the latest popular app on the App Store, or make some minor changes to another app’s name or UI and pass it off as your own. In addition to risking an intellectual property infringement claim, it makes the App Store harder to navigate and just isn’t fair to your fellow developers.

- **(b)** ![ASR & NR] Submitting apps which impersonate other apps or services is considered a violation of the Developer Code of Conduct and may result in removal from the Apple Developer Program.

- **(c)** You cannot use another developer’s icon, brand, or product name in your app’s icon or name, without approval from the developer.

Learn more about [preventing copycat and impersonation rejections](/help/app-review/guideline-reference/4-1-prevent-copycat-rejection).

- **4.2 Minimum Functionality**

Your app should include features, content, and UI that elevate it beyond a repackaged website. If your app is not particularly useful, unique, or “app-like,” it doesn’t belong on the App Store. If your App doesn’t provide some sort of lasting entertainment value or adequate utility, it may not be accepted. Apps that are simply a song or movie should be submitted to the iTunes Store. Apps that are simply a book or game guide should be submitted to the Apple Books Store.

- **4.2.1** Apps using ARKit should provide rich and integrated augmented reality experiences; merely dropping a model into an AR view or replaying animation is not enough.

- **4.2.2** Other than catalogs, apps shouldn’t primarily be marketing materials, advertisements, web clippings, content aggregators, or a collection of links.

- **4.2.3**

- **(i)** Your app should work on its own without requiring installation of another app to function.

- **(ii)** If your app needs to download additional resources in order to function on initial launch, disclose the size of the download and prompt users before doing so.

- **4.2.4** Intentionally omitted.

- **4.2.5** Intentionally omitted.

- **4.2.6** Apps created from a commercialized template or app generation service will be rejected unless they are submitted directly by the provider of the app’s content. These services should not submit apps on behalf of their clients and should offer tools that let their clients create customized, innovative apps that provide unique customer experiences. Another acceptable option for template providers is to create a single binary to host all client content in an aggregated or “picker” model, for example as a restaurant finder app with separate customized entries or pages for each client restaurant, or as an event app with separate entries for each client event.

- **4.2.7 Remote Desktop Clients:** If your remote desktop app acts as a mirror of specific software or services rather than a generic mirror of the host device, it must comply with the following:

- **(a)** The app must only connect to a user-owned host device that is a personal computer or dedicated game console owned by the user, and both the host device and client must be connected on a local and LAN-based network.

- **(b)** Any software or services appearing in the client are fully executed on the host device, rendered on the screen of the host device, and may not use APIs or platform features beyond what is required to stream the Remote Desktop.

- **(c)** All account creation and management must be initiated from the host device.

- **(d)** The UI appearing on the client does not resemble an iOS or App Store view, does not provide a store-like interface, or include the ability to browse, select, or purchase software not already owned or licensed by the user. For the sake of clarity, transactions taking place within mirrored software do not need to use in-app purchase, provided the transactions are processed on the host device.

- **(e)** Thin clients for cloud-based apps are not appropriate for the App Store.

- **4.3 Spam**

- **(a)** ![ASR & NR] Don’t create multiple Bundle IDs of the same app (for example, submitting a separate map app for every city in the world instead of a single worldwide map that allows users to search any city). This practice results in unnecessary apps, which makes it hard for users to find the apps they want. If your app has different versions for specific locations, sports teams, universities, etc., consider submitting a single app and providing the variations using in-app purchase.

- **(b)** Don’t submit apps that are indistinguishable from what's already widely available. Opportunistically creating variants of existing app categories or popular apps degrades App Store discovery, reduces overall app quality, and harms both users and developers. Certain kinds of apps, such as dating, flashlight, sound effects, wallpaper, simple timers, and fortune telling, are well established on the App Store and we will not accept new submissions unless they offer a meaningfully different or improved experience. We may remove these apps from the App Store going forward if they are not updated, improved, or do not attract customers. Other kinds of apps, such as drinking games, Kama Sutra, fart, and burp apps, are mediocre, low-quality, or low-effort and do not add value to the App Store. Repeated submissions of this kind may lead to removal from the Apple Developer Program.

- **4.4 ![ASR & NR] Extensions**

Apps hosting or containing extensions must comply with the [App Extension Programming Guide](/library/archive/documentation/General/Conceptual/ExtensibilityPG/index.html#apple_ref/doc/uid/TP40014214/), the [Safari app extensions documentation](/documentation/safariservices/safari_app_extensions), or the [Safari web extensions documentation](/documentation/safariservices/safari_web_extensions) and should include some functionality, such as help screens and settings interfaces where possible. You should clearly and accurately disclose what extensions are made available in the app’s marketing text, and the extensions may not include marketing, advertising, or in-app purchases.

- **4.4.1** ![ASR & NR] Keyboard extensions have some additional rules.

They must:

- Provide keyboard input functionality (such as typed characters);

- Follow Sticker guidelines if the keyboard includes images or emoji;

- Provide a method for progressing to the next keyboard;

- Remain functional without full network access and without requiring full access;

- Collect user activity only to enhance the functionality of the user’s keyboard extension on the iOS device.

They must not:

- Launch other apps besides Settings; or

- Repurpose keyboard buttons for other behaviors (such as holding down the “return” key to launch the camera).

- **4.4.2** ![ASR & NR] Safari extensions must run on the current version of Safari on the relevant Apple operating system. They may not interfere with System or Safari UI elements and must never include malicious or misleading content or code. Violating this rule will lead to removal from the Apple Developer Program. Safari extensions should not claim access to more websites than strictly necessary to function.

- **4.4.3** Intentionally omitted.

- **4.5 ![ASR & NR] Apple Sites and Services**

- **4.5.1** ![ASR & NR] Apps may use approved Apple RSS feeds such as the iTunes Store RSS feed, but may not scrape any information from Apple sites (such as apple.com, the iTunes Store, App Store, App Store Connect, developer portal, etc.) or create rankings using this information.

- **4.5.2** ![ASR & NR] Apple Music

- **(i)** MusicKit on iOS lets users play Apple Music and their local music library natively from your apps and games. When a user provides permission to their Apple Music account, your app can create playlists, add songs to their library, and play any of the millions of songs in the Apple Music catalog. Users must initiate the playback of an Apple Music stream and be able to navigate using standard media controls such as “play,” “pause,” and “skip.” Moreover, your app may not require payment or indirectly monetize access to the Apple Music service (such as in-app purchase, advertising, requesting user info, etc.). Do not download, upload, or enable sharing of music files sourced from the MusicKit APIs, except as explicitly permitted in [MusicKit](/musickit/) documentation.

- **(ii)** Using the MusicKit APIs is not a replacement for securing the licenses you might need for a deeper or more complex music integration. For example, if you want your app to play a specific song at a particular moment, or to create audio or video files that can be shared to social media, you’ll need to contact rights-holders directly to get their permission (such as synchronization or adaptation rights) and assets. Cover art and other metadata may only be used in connection with music playback or playlists (including screenshots displaying your app’s functionality), and should not be used in any marketing or advertising without getting specific authorization from rights-holders. Make sure to follow the [Apple Music Identity Guidelines](https://marketing.services.apple/apple-music-identity-guidelines) when integrating Apple Music services in your app.

- **(iii)** Apps that access Apple Music user data, such as playlists and favorites, must clearly disclose this access in the purpose string. Any data collected may not be shared with third parties for any purpose other than supporting or improving the app experience. This data may not be used to identify users or devices, or to target advertising.

- **4.5.3** ![ASR & NR] Do not use Apple Services to spam, phish, or send unsolicited messages to customers, including Game Center, Push Notifications, Live Activities, etc. Do not attempt to reverse lookup, trace, relate, associate, mine, harvest, or otherwise exploit Player IDs, aliases, or other information obtained through Game Center, or you will be removed from the Apple Developer Program.

- **4.5.4** ![ASR & NR] Push Notifications must not be required for the app to function, and should not be used to send sensitive personal or confidential information. Push Notifications should not be used for promotions or direct marketing purposes unless customers have explicitly opted in to receive them via consent language displayed in your app’s UI, and you provide a method in your app for a user to opt out from receiving such messages. Abuse of these services may result in revocation of your privileges.

- **4.5.5** ![ASR & NR] Only use Game Center Player IDs in a manner approved by the Game Center terms and do not display them in the app or to any third party.

- **4.5.6** ![ASR & NR] Apps may use Unicode characters that render as Apple emoji in their app and app metadata. Apple emoji may not be used on other platforms or embedded directly in your app binary.

- **4.6** Intentionally omitted.

- **4.7 ![ASR & NR] Mini apps, mini games, streaming games, chatbots, plug-ins, and game emulators**

Apps may offer certain software that is not embedded in the binary, specifically HTML5 and JavaScript mini apps and mini games, streaming games, chatbots, and plug-ins. Additionally, retro game console and PC emulator apps can offer to download games. You are responsible for all such software offered in your app, including ensuring that such software complies with these Guidelines and all applicable laws. Software that does not comply with one or more guidelines will lead to the rejection of your app. You must also ensure that the software adheres to the additional rules that follow in 4.7.1 through 4.7.5. These additional rules are important to preserve the experience that App Store customers expect, and to help ensure user safety.

- **4.7.1** Software offered in apps under this rule must:

- follow all privacy guidelines, including but not limited to the rules set forth in Guideline 5.1 concerning collection, use, and sharing of data, and sensitive data (such as health and personal data from kids);

- include a method for filtering objectionable material, a mechanism to report content and timely responses to concerns, and the ability to block abusive users; and

- follow Guideline 3.1 in order to offer digital goods or services to end users.

- **4.7.2** ![ASR & NR] Your app may not extend or expose native platform APIs or technologies to the software without prior permission from Apple.

- **4.7.3** ![ASR & NR] Your app may not share data or privacy permissions to any individual software offered in your app without explicit user consent in each instance.

- **4.7.4** You must provide an index of software and metadata available in your app. It must include universal links that lead to all of the software offered in your app.

- **4.7.5** ![ASR & NR] Your app must provide a way for users to identify software that exceeds the app’s age rating, and use an age restriction mechanism based on verified or declared age to limit access by underage users.

- **4.8 ![ASR & NR] Login Services**

Apps that use a third-party or social login service (such as Facebook Login, Google Sign-In, Log in with X, Sign In with LinkedIn, Login with Amazon, or WeChat Login) to set up or authenticate the user’s primary account with the app must also offer as an equivalent option another login service with the following features:

- the login service limits data collection to the user’s name and email address;

- the login service allows users to keep their email address private as part of setting up their account; and

- the login service does not collect interactions with your app for advertising purposes without consent.

A user’s primary account is the account they establish with your app for the purposes of identifying themselves, signing in, and accessing your features and associated services.

Another login service is not required if:

- Your app exclusively uses your company’s own account setup and sign-in systems.

- Your app is an alternative app marketplace, or an app distributed from an alternative app marketplace, that uses a marketplace-specific login for account, download, and commerce features.

- Your app is an education, enterprise, or business app that requires the user to sign in with an existing education or enterprise account.

- Your app uses a government or industry-backed citizen identification system or electronic ID to authenticate users.

- Your app is a client for a specific third-party service and users are required to sign in to their mail, social media, or other third-party account directly to access their content.

- **4.9 ![ASR & NR] Apple Pay**

Apps using Apple Pay must provide all material purchase information to the user prior to sale of any good or service and must use Apple Pay branding and user interface elements correctly, as described in the Apple Pay Marketing Guidelines and Human Interface Guidelines. Apps using Apple Pay to offer recurring payments must, at a minimum, disclose the following information:

- The length of the renewal term and the fact that it will continue until canceled

- What will be provided during each period

- The actual charges that will be billed to the customer

- How to cancel

- **4.10 ![ASR & NR] Monetizing Built-In Capabilities**

You may not monetize built-in capabilities provided by the hardware or operating system, such as Push Notifications, the camera, or the gyroscope; or Apple services and technologies, such as Apple Music access, iCloud storage, or Screen Time APIs.
