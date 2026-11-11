# App Store Review Guidelines — 1. Safety

> Source: https://developer.apple.com/app-store/review/guidelines/ (Last Updated: October 16, 2026). Verbatim text, split by section for on-demand loading. Relative links are relative to https://developer.apple.com. `![ASR & NR]` marks guidelines that also apply to Notarization review.

## 1. Safety

When people install an app from the App Store, they want to feel confident that it’s safe to do so—that the app doesn’t contain upsetting or offensive content, won’t damage their device, and isn’t likely to cause physical harm from its use. We’ve outlined the major pitfalls below, but if you’re looking to shock and offend people, the App Store isn’t the right place for your app. Some of these rules are also included in Notarization for iOS and iPadOS apps.

- **1.1 Objectionable Content**

Apps should not include content that is offensive, insensitive, upsetting, intended to disgust, in exceptionally poor taste, or just plain creepy. Examples of such content include:

- **1.1.1** Defamatory, discriminatory, or mean-spirited content, including references or commentary about religion, race, sexual orientation, gender, national/ethnic origin, or other targeted groups, particularly if the app is likely to humiliate, intimidate, or harm a targeted individual or group. Professional political satirists and humorists are generally exempt from this requirement.

- **1.1.2** Realistic portrayals of people or animals being killed, maimed, tortured, or abused, or content that encourages violence. “Enemies” within the context of a game cannot solely target a specific race, culture, real government, corporation, or any other real entity.

- **1.1.3** Depictions that encourage illegal or reckless use of weapons and dangerous objects, or facilitate the purchase of firearms or ammunition.

- **1.1.4** Overtly sexual or pornographic material, defined as “explicit descriptions or displays of sexual organs or activities intended to stimulate erotic rather than aesthetic or emotional feelings.” This includes “hookup” apps and other apps that may include pornography or be used to facilitate prostitution, or human trafficking and exploitation.

- **1.1.5** Inflammatory religious commentary or inaccurate or misleading quotations of religious texts.

- **1.1.6** ![ASR & NR] False information and features, including inaccurate device data or trick/joke functionality, such as fake location trackers. Stating that the app is “for entertainment purposes” won’t overcome this guideline. Apps that enable anonymous or prank phone calls or SMS/MMS messaging will be rejected.

- **1.1.7** Harmful concepts which capitalize or seek to profit on recent or current events, such as violent conflicts, terrorist attacks, and epidemics.

- **1.2 User-Generated Content**

Apps that enable users to create, generate, upload, share, or otherwise contribute content present particular challenges, including intellectual property infringement, nonconsensual intimate imagery, and anonymous bullying. This includes social media, user-generated content platforms, and AI content creation apps. To prevent abuse, such apps must include:

- A method for filtering objectionable material from being posted to the app

- A mechanism to report offensive content and timely responses to concerns

- The ability to block abusive users from the service

- Published contact information so users can easily reach you

Apps with user-generated content or services that end up being used primarily for pornographic content, Chatroulette-style experiences, random or anonymous chat, objectification of real people (such as “hot-or-not” voting), making physical threats, or bullying do not belong on the App Store and may be removed without notice. If your app includes user-generated content from a web-based service, it may display incidental mature “NSFW” content, provided that the content is hidden by default and only displayed when the user turns it on via your website.

It is your responsibility to remove content that violates this guideline, your terms of service, or your community standards. Developers who fail to implement appropriate safeguards or fail to remediate identified violations after notice may be considered in violation of the Developer Code of Conduct. If we find such content, we will ask you to remove it, and provide a plan to improve your compliance with this guideline. Based on your response, your app may be removed from the App Store until you can demonstrate improvements that bring your app into compliance. Egregious or repeated behavior is grounds for immediate removal of your app from the App Store, and from the Apple Developer Program.

- **1.2.1 Creator Content**

Apps which feature content from a specific community of users called “creators” are a great opportunity if properly moderated. These apps present a singular, unified experience for customers to interact with various kinds of creator content. They offer tools and programs to help this community of non-developer creators to author, share, and monetize user-generated experiences. These experiences must not change the core features and functionality of the native app—rather, they add content to those structured experiences. These experiences are not native “apps” coded by developers—they are content within the app itself and are treated as user-generated content by App Review. Such creator content may include video, articles, audio, and even casual games. The App Store supports apps offering such user-generated content so long as they follow all Guidelines, including Guideline 1.2 for moderating user-generated content and Guideline 3.1.1 for payments and in-app purchases. You should communicate to users which content requires additional purchases.

- **(a)** ![ASR & NR] Creator apps must provide a way for users to identify content that exceeds the app’s age rating, and use an age restriction mechanism based on verified or declared age to limit access by underage users.

- **1.3 Kids Category**

The Kids Category is a great way for people to easily find apps that are designed for children. If you want to participate in the Kids Category, you should focus on creating a great experience specifically for younger users. These apps must not include links out of the app, purchasing opportunities, or other distractions to kids unless reserved for a designated area behind a parental gate. Keep in mind that once customers expect your app to follow the Kids Category requirements, it will need to continue to meet these guidelines in subsequent updates, even if you decide to deselect the category. Learn more about [parental gates](/app-store/kids-apps/).

You must comply with applicable privacy laws around the world relating to the collection of data from children online. Be sure to review the [Privacy section](#privacy) of these guidelines for more information. In addition, Kids Category apps may not send personally identifiable information or device information to third parties. Apps in the Kids Category should not include third-party analytics or third-party advertising. This provides a safer experience for kids. In limited cases, third-party analytics may be permitted provided that the services do not collect or transmit the IDFA or any identifiable information about children (such as name, date of birth, email address), their location, or their devices. This includes any device, network, or other information that could be used directly or combined with other information to identify users and their devices. Third-party contextual advertising may also be permitted in limited cases provided that the services have publicly documented practices and policies for Kids Category apps that include human review of ad creatives for age appropriateness.

- **1.4 ![ASR & NR] Physical Harm**

If your app behaves in a way that risks physical harm, we may reject it. For example:

- **1.4.1** ![ASR & NR] Medical apps that could provide inaccurate data or information, or that could be used for diagnosing or treating patients may be reviewed with greater scrutiny.

- Apps must clearly disclose data and methodology to support accuracy claims relating to health measurements, and if the level of accuracy or methodology cannot be validated, we will reject your app. For example, apps that claim to take x-rays, measure blood pressure, body temperature, blood glucose levels, or blood oxygen levels using only the sensors on the device are not permitted.

- Apps should remind users to check with a doctor in addition to using the app and before making medical decisions.

If your medical app has received regulatory clearance, please submit a link to that documentation with your app.

- **1.4.2** ![ASR & NR] Drug dosage calculators must come from the drug manufacturer, a hospital, university, health insurance company, pharmacy or other approved entity, or receive approval by the FDA or one of its international counterparts. Given the potential harm to patients, we need to be sure that the app will be supported and updated over the long term.

- **1.4.3** Apps that encourage consumption of tobacco and vape products, illegal drugs, or excessive amounts of alcohol are not permitted. Apps that encourage minors to consume any of these substances will be rejected. Facilitating the sale of controlled substances (except for licensed pharmacies and licensed or otherwise legal cannabis dispensaries), or tobacco is not allowed.

- **1.4.4** ![ASR & NR] Apps may only display DUI checkpoints that are published by law enforcement agencies, and should never encourage drunk driving or other reckless behavior such as excessive speed.

- **1.4.5** ![ASR & NR] Apps should not urge customers to participate in activities (like bets, challenges, etc.) or use their devices in a way that risks physical harm to themselves or others.

- **1.5 ![ASR & NR] Developer Information**

People need to know how to reach you with questions and support issues. Make sure your app and its Support URL include an easy way to contact you; this is particularly important for apps that may be used in the classroom. Failure to include accurate and up-to-date contact information not only frustrates customers, but may violate the law in some countries or regions. Also ensure that Wallet passes include valid contact information from the issuer and are signed with a dedicated certificate assigned to the brand or trademark owner of the pass.

- **1.6 ![ASR & NR] Data Security**

Apps should implement appropriate security measures to ensure proper handling of user information collected pursuant to the Apple Developer Program License Agreement and these Guidelines (see Guideline 5.1 for more information) and prevent its unauthorized use, disclosure, or access by third parties.

- **1.7 Reporting Criminal Activity**

Apps for reporting alleged criminal activity must involve local law enforcement, and can only be offered in countries or regions where such involvement is active.
