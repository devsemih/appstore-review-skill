# App Store Review Guidelines — 5. Legal

> Source: https://developer.apple.com/app-store/review/guidelines/ (Last Updated: October 16, 2026). Verbatim text, split by section for on-demand loading. Relative links are relative to https://developer.apple.com. `![ASR & NR]` marks guidelines that also apply to Notarization review.

## 5. ![ASR & NR] Legal

Apps must comply with all legal requirements in any location where you make them available (if you’re not sure, check with a lawyer). We know this stuff is complicated, but it is your responsibility to understand and make sure your app conforms with all local laws, not just the guidelines below. And of course, apps that solicit, promote, or encourage criminal or clearly reckless behavior will be rejected. In extreme cases, such as apps that are found to facilitate human trafficking and/or the exploitation of children, appropriate authorities will be notified and the apps will be removed from the App Store and blocked from alternative distribution.

- **5.1 ![ASR & NR] Privacy**

Protecting user privacy is paramount in the Apple ecosystem, and you should use care when handling personal data to ensure you’ve complied with [privacy best practices](/documentation/uikit/protecting_the_user_s_privacy), applicable laws, and the terms of the [Apple Developer Program License Agreement](/support/terms/), not to mention customer expectations. More particularly:

- **5.1.1 ![ASR & NR] Data Collection and Storage**

- **(i) Privacy Policies:** All apps must include a link to their privacy policy in the App Store Connect metadata field and within the app in an easily accessible manner. The privacy policy must clearly and explicitly:

- Identify what data, if any, the app/service collects, how it collects that data, and all uses of that data.

- Confirm that any third party with whom an app shares user data (in compliance with these Guidelines)—such as analytics tools, advertising networks and third-party SDKs, as well as any parent, subsidiary or other related entities that will have access to user data—will provide the same or equal protection of user data as stated in the app’s privacy policy and required by these Guidelines.

- Explain its data retention/deletion policies and describe how a user can revoke consent and/or request deletion of the user’s data.

- **(ii) Permission:** Apps that collect user or usage data must secure user consent for the collection, even if such data is considered to be anonymous at the time of or immediately following collection. Paid functionality must not be dependent on or require a user to grant access to this data. Apps must also provide the customer with an easily accessible and understandable way to withdraw consent. Ensure your purpose strings clearly and completely describe your use of the data. Learn more about [writing clear purpose strings](/help/app-review/guideline-reference/5-1-1-purpose-strings). Apps that collect data for a legitimate interest without consent by relying on the terms of the European Union’s General Data Protection Regulation (“GDPR”) or similar statute must comply with all terms of that law. Learn more about [Requesting Permission](/documentation/uikit/protecting_the_user_s_privacy).

- **(iii) Data Minimization:** Apps should only request access to data relevant to the core functionality of the app and should only collect and use data that is required to accomplish the relevant task. Where possible, use the out-of-process picker or a share sheet rather than requesting full access to protected resources like Photos or Contacts.

- **(iv) Access:** Apps must respect the user’s permission settings and not attempt to manipulate, trick, or force people to consent to unnecessary data access. For example, apps that include the ability to post photos to a social network must not also require microphone access before allowing the user to upload photos. Where possible, provide alternative solutions for users who don’t grant consent. For example, if a user declines to share Location, offer the ability to manually enter an address.

- **(v) Account Sign-In:** If your app doesn’t include significant account-based features, let people use it without a login. If your app supports account creation, you must also [offer account deletion within the app](/help/app-review/guideline-reference/5-1-1-account-deletion). Apps may not require users to enter personal information to function, except when directly relevant to the core functionality of the app or required by law. If your core app functionality is not related to a specific social network (such as Facebook, WeChat, Weibo, X, etc.), you must provide access without a login or via another mechanism. Pulling basic profile information, sharing to the social network, or inviting friends to use the app are not considered core app functionality. The app must also include a mechanism to revoke social network credentials and disable data access between the app and social network from within the app. An app may not store credentials or tokens to social networks off of the device and may only use such credentials or tokens to directly connect to the social network from the app itself while the app is in use.

- **(vi)** Developers that use their apps to surreptitiously discover passwords or other private data will be removed from the Apple Developer Program.

- **(vii)** SafariViewController must be used to visibly present information to users; the controller may not be hidden or obscured by other views or layers. Additionally, an app may not use SafariViewController to track users without their knowledge and consent.

- **(viii)** Apps that compile personal information from any source that is not directly from the user or without the user’s explicit consent, even public databases, are not permitted on the App Store or alternative distribution.

- **(ix)** Apps that provide services in highly regulated fields (such as banking and financial services, healthcare, gambling, legal cannabis use, air travel and crypto exchanges) or that require sensitive user information should be submitted by a legal entity that provides the services, and not by an individual developer. Apps that facilitate the legal sale of cannabis must be geo-restricted to the corresponding legal jurisdiction.

- **(x)** Apps may request basic contact information (such as name and email address) so long as the request is optional for the user, features and services are not conditional on providing the information, and it complies with all other provisions of these guidelines, including limitations on collecting information from kids.

- **5.1.2 ![ASR & NR] Data Use and Sharing**

- **(i)** Unless otherwise permitted by law, you may not use, transmit, or share someone’s personal data without first obtaining their permission. You must provide access to information about how and where the data will be used. You must clearly disclose where personal data will be shared with third parties, including with third-party AI, and obtain explicit permission before doing so. Data collected from apps may only be shared with third parties to improve the app or serve advertising (in compliance with the [Apple Developer Program License Agreement](/support/terms/)). You must receive explicit permission from users via the App Tracking Transparency APIs to track their activity. Learn more about [tracking](/app-store/user-privacy-and-data-use/). Your app may not require users to enable system functionalities (such as push notifications, location services, tracking) in order to access functionality, content, use the app, or receive monetary or other compensation, including but not limited to gift cards and codes. Apps that share user data without user consent or otherwise complying with data privacy laws may be removed from sale and may result in your removal from the Apple Developer Program.

- **(ii)** Data collected for one purpose may not be repurposed without further consent unless otherwise explicitly permitted by law.

- **(iii)** Apps should not attempt to surreptitiously build a user profile based on collected data and may not attempt, facilitate, or encourage others to identify anonymous users or reconstruct user profiles based on data collected from Apple-provided APIs or any data that you say has been collected in an “anonymized,” “aggregated,” or otherwise non-identifiable way.

- **(iv)** Do not use information from Contacts, Photos, or other APIs that access user data to build a contact database for your own use or for sale/distribution to third parties, and don’t collect information about which other apps are installed on a user’s device for the purposes of analytics or advertising/marketing.

- **(v)** Do not contact people using information collected via a user’s Contacts or Photos, except at the explicit initiative of that user on an individualized basis; do not include a Select All option or default the selection of all contacts. You must provide the user with a clear description of how the message will appear to the recipient before sending it (for example, What will the message say? Who will appear to be the sender?).

- **(vi)** Data gathered from the HomeKit API, HealthKit, Clinical Health Records API, MovementDisorder APIs, ClassKit or from depth and/or facial mapping tools (such as ARKit, Camera APIs, or Photo APIs) may not be used for marketing, advertising or use-based data mining, including by third parties. Learn more about best practices for implementing [CallKit](/documentation/callkit), [HealthKit](/documentation/healthkit), [ClassKit](/documentation/classkit), and [ARKit](/documentation/arkit).

- **(vii)** Apps using Apple Pay may only share user data acquired via Apple Pay with third parties to facilitate or improve delivery of goods and services.

- **5.1.3 ![ASR & NR] Health and Health Research**

Health, fitness, and medical data are especially sensitive and apps in this space have some additional rules to make sure customer privacy is protected:

- **(i)** Apps may not use or disclose to third parties data gathered in the health, fitness, and medical research context—including from the Clinical Health Records API, HealthKit API, Motion and Fitness, MovementDisorder APIs, or health-related human subject research—for advertising, marketing, or other use-based data mining purposes other than improving health management, or for the purpose of health research, and then only with permission. Apps may, however, use a user’s health or fitness data to provide a benefit directly to that user (such as a reduced insurance premium), provided that the app is submitted by the entity providing the benefit, and the data is not shared with a third party. You must disclose the specific health data that you are collecting from the device.

- **(ii)** Apps must not write false or inaccurate data into HealthKit or any other medical research or health management apps, and may not store personal health information in iCloud.

- **(iii)** Apps conducting health-related human subject research must obtain consent from participants or, in the case of minors, their parent or guardian. Such consent must include the (a) nature, purpose, and duration of the research; (b) procedures, risks, and benefits to the participant; (c) information about confidentiality and handling of data (including any sharing with third parties); (d) a point of contact for participant questions; and (e) the withdrawal process.

- **(iv)** Apps conducting health-related human subject research must secure approval from an independent ethics review board. Proof of such approval must be provided upon request.

- **5.1.4 Kids**

**(a)** ![ASR & NR] For many reasons, it is critical to use care when dealing with personal data from kids, and we encourage you to carefully review all the requirements for complying with laws like the Children’s Online Privacy Protection Act (“COPPA”), the European Union’s General Data Protection Regulation (“GDPR”), and any other applicable regulations or laws.

Apps may ask for birthdate and parental contact information only for the purpose of complying with these statutes, but must include some useful functionality or entertainment value regardless of a person’s age.

Apps intended primarily for kids should not include third-party analytics or third-party advertising. This provides a safer experience for kids.

**(b)** In limited cases, third-party analytics and third-party advertising may be permitted provided that the services adhere to the same terms set forth in [Guideline 1.3](#1.3).

Moreover, apps in the Kids Category or those that collect, transmit, or have the capability to share personal information (such as name, address, email, location, photos, videos, drawings, the ability to chat, other personal data, or persistent identifiers used in combination with any of the above) from a minor must include a privacy policy and must comply with all applicable children’s privacy statutes. For the sake of clarity, the [parental gate requirement](#kids-category) for the Kid’s Category is generally not the same as securing parental consent to collect personal data under these privacy statutes.

As a reminder, [Guideline 2.3.8](#2.3.8) requires that use of terms like “For Kids” and “For Children” in app metadata is reserved for the Kids Category. Apps not in the Kids Category cannot include any terms in app name, subtitle, icon, screenshots or description that imply the main audience for the app is children.

- **5.1.5 ![ASR & NR] Location Services**

Use Location Services in your app only when it is directly relevant to the features and services provided by the app. Location-based APIs shouldn’t be used to provide emergency services or autonomous control over vehicles, aircraft, and other devices, except for small devices such as lightweight drones and toys, or remote control car alarm systems, etc. Ensure that you notify and obtain consent before collecting, transmitting, or using location data. If your app uses Location Services, be sure to explain the purpose in your app; refer to the [Human Interface Guidelines](/design/human-interface-guidelines/patterns/accessing-private-data/) for best practices for doing so.

- **5.2 Intellectual Property**

Make sure your app only includes content that you created or that you have a license to use. Your app may be removed if you’ve stepped over the line and used content without permission. Of course, this also means someone else’s app may be removed if they’ve “borrowed” from your work. If you believe your intellectual property has been infringed by another developer on the App Store, submit a claim via our [web form](https://www.apple.com/legal/intellectual-property/dispute-forms/index.html). Laws differ in different countries and regions, but at the very least, make sure to avoid the following common errors:

- **5.2.1 Generally:** Don’t use protected third-party material such as trademarks, copyrighted works, or patented ideas in your app without permission, and don’t include misleading, false, or copycat representations, names, or metadata in your app bundle or developer name. Apps should be submitted by the person or legal entity that owns or has licensed the intellectual property and other relevant rights.

- **5.2.2 Third-Party Sites/Services:** If your app uses, accesses, monetizes access to, or displays content from a third-party service, ensure that you are specifically permitted to do so under the service’s terms of use. Authorization must be provided upon request.

- **5.2.3 Audio/Video Downloading:** Apps should not facilitate illegal file sharing or include the ability to save, convert, or download media from third-party sources (such as Apple Music, YouTube, SoundCloud, Vimeo, etc.) without explicit authorization from those sources. Streaming of audio/video content may also violate Terms of Use, so be sure to check before your app accesses those services. Authorization must be provided upon request.

- **5.2.4 Apple Endorsements:**

- **(a)** ![ASR & NR] Don’t suggest or imply that Apple is a source or supplier of the App, or that Apple endorses any particular representation regarding quality or functionality.

- **(b)** If your app is selected as an “Editor’s Choice,” Apple will apply the badge automatically.

- **5.2.5 ![ASR & NR] Apple Products:** Don’t create an app that appears confusingly similar to an existing Apple product, interface (such as Finder), app (such as the App Store, iTunes Store, or Messages) or advertising theme. Apps and extensions, including third-party keyboards and Sticker packs, may not include Apple emoji. Music from iTunes and Apple Music previews may not be used for their entertainment value (such as as the background music to a photo collage or the soundtrack to a game) or in any other unauthorized manner. If you provide music previews from iTunes or Apple Music, you must display a link to the corresponding music in iTunes or Apple Music. If your app displays Activity rings, they should not visualize Move, Exercise, or Stand data in a way that resembles the Activity control. The [Human Interface Guidelines](/design/human-interface-guidelines/patterns/workouts/#activity-rings) have more information on how to use Activity rings. If your app displays Apple Weather data, it should follow the attribution requirements provided in the [WeatherKit documentation](/weatherkit/get-started/#attribution-requirements).

- **5.3 Gaming, Gambling, and Lotteries**

Gaming, gambling, and lotteries can be tricky to manage and tend to be one of the most regulated offerings on the App Store. Only include this functionality if you’ve fully vetted your legal obligations everywhere you make your app available and are prepared for extra time during the review process. Some things to keep in mind:

- **5.3.1** Sweepstakes and contests must be sponsored by the developer of the app.

- **5.3.2** Official rules for sweepstakes, contests, and raffles must be presented in the app and make clear that Apple is not a sponsor or involved in the activity in any manner.

- **5.3.3** Apps may not use in-app purchase to purchase credit or currency for use in conjunction with real money gaming of any kind.

- **5.3.4** Apps that offer real money gaming (such as sports betting, poker, casino games, horse racing) or lotteries must have necessary licensing and permissions in the locations where the app is used, must be geo-restricted to those locations, and must be free on the App Store. Illegal gambling aids, including card counters, are not permitted on the App Store. Lottery apps must have consideration, chance, and a prize.

- **5.4 ![ASR & NR] VPN Apps**

Apps offering VPN services must utilize the [NEVPNManager API](/documentation/networkextension/nevpnmanager) and may only be offered by developers enrolled as an organization. You must make a clear declaration of what user data will be collected and how it will be used on an app screen prior to any user action to purchase or otherwise use the service. Apps offering VPN services may not sell, use, or disclose to third parties any data for any purpose, and must commit to this in their privacy policy. VPN apps must not violate local laws, and if you choose to make your VPN app available in a territory that requires a VPN license, you must provide your license information in the App Review Notes field. Parental control, content blocking, and security apps, among others, from approved providers may also use the NEVPNManager API. Apps that do not comply with this guideline will be removed from the App Store and blocked from installing via alternative distribution and you may be removed from the Apple Developer Program.

- **5.5 ![ASR & NR] Mobile Device Management**

Mobile Device Management Apps that offer Mobile Device Management (MDM) services must request this capability from Apple. Such apps may only be offered by commercial enterprises, educational institutions, or government agencies, and in limited cases, companies using MDM for parental control services or device security. You must make a clear declaration of what user data will be collected and how it will be used on an app screen prior to any user action to purchase or otherwise use the service. MDM apps must not violate any applicable laws. Apps offering MDM services may not sell, use, or disclose to third parties any data for any purpose, and must commit to this in their privacy policy. In limited cases, third-party analytics may be permitted provided that the services only collect or transmit data about the performance of the developer’s MDM app, and not any data about the user, the user’s device, or other apps used on that device. Apps offering configuration profiles must also adhere to these requirements. Apps that do not comply with this guideline will be removed from the App Store and blocked from installing via alternative distribution and you may be removed from the Apple Developer Program.

- **5.6 ![ASR & NR] Developer Code of Conduct**

Please treat everyone with respect, whether in your responses to App Store reviews, customer support requests, or when communicating with Apple, including your responses in App Store Connect. Do not engage in harassment of any kind, discriminatory practices, intimidation, bullying, and don’t encourage others to engage in any of the above. Repeated manipulative or misleading behavior or other fraudulent conduct will lead to your removal from the Apple Developer Program.

Customer trust is a cornerstone of the App ecosystem. Apps should never prey on users or attempt to rip off customers, trick them into making unwanted purchases, force them to share unnecessary data, raise prices in a tricky manner, charge for features or content that are not delivered, or engage in any other manipulative practices within or outside of the app.

Your Developer Program account will be terminated if you engage in activities or actions that are not in accordance with the Developer Code of Conduct. To restore your account, you may provide a written statement detailing the improvements you plan to make. If your plan is approved by Apple and we confirm the changes have been made, your account may be restored.

- **5.6.1 App Store Reviews**

App Store customer reviews can be an integral part of the app experience, so you should treat customers with respect when responding to their comments. Keep your responses targeted to the user’s comments and do not include personal information, spam, or marketing in your response.

Use the provided API to prompt users to review your app; this functionality allows customers to provide an App Store rating and review without the inconvenience of leaving your app, and we will disallow custom review prompts.

- **5.6.2 ![ASR & NR] Developer Identity**

Providing verifiable information to Apple and customers is critical to customer trust. Your representation of yourself, your business, and your offerings on the App Store or alternative distribution must be accurate. The information you provide must be truthful, relevant, and up-to-date so that Apple and customers understand who they are engaging with and can contact you regarding any issues.

- **5.6.3 Discovery Fraud**

Participating in the App Store requires integrity and a commitment to building and maintaining customer trust. Manipulating any element of the App Store customer experience such as charts, search, reviews, or referrals to your app erodes customer trust and is not permitted.

- **5.6.4 App Quality**

Customers expect the highest quality from the App Store, and maintaining high quality content, services, and experiences promotes customer trust. Indications that this expectation is not being met include excessive customer reports about concerns with your app, such as negative customer reviews, and excessive refund requests. Inability to maintain high quality may be a factor in deciding whether a developer is abiding by the Developer Code of Conduct.
