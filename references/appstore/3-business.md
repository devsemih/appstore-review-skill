# App Store Review Guidelines — 3. Business

> Source: https://developer.apple.com/app-store/review/guidelines/ (Last Updated: October 16, 2026). Verbatim text, split by section for on-demand loading. Relative links are relative to https://developer.apple.com. `![ASR & NR]` marks guidelines that also apply to Notarization review.

## 3. Business

There are many ways to monetize your app on the App Store. If your business model isn’t obvious, make sure to explain in its metadata and App Review notes. If we can’t understand how your app works or your in-app purchases aren’t immediately obvious, it will delay your review and may trigger a rejection. And while pricing is up to you, we won’t distribute apps and in-app purchase items that are clear rip-offs. We’ll reject expensive apps that try to cheat users with irrationally high prices.

If we find that you have attempted to manipulate reviews, inflate your chart rankings with paid, incentivized, filtered, or fake feedback, or engage with third-party services to do so on your behalf, we will take steps to preserve the integrity of the App Store, which may include expelling you from the Apple Developer Program.

- **3.1 Payments**

- **3.1.1 In-App Purchase:**

- If you want to unlock features or functionality within your app, (by way of example: subscriptions, in-game currencies, game levels, access to premium content, or unlocking a full version), you must use in-app purchase. Apps may not use their own mechanisms to unlock content or functionality, such as license keys, augmented reality markers, QR codes, cryptocurrencies and cryptocurrency wallets, etc.

- Apps may use in-app purchase currencies to enable customers to “tip” the developer or digital content providers in the app.

- Any credits or in-game currencies purchased via in-app purchase may not expire, and you should make sure you have a restore mechanism for any restorable in-app purchases.

- Apps may enable gifting of items that are eligible for in-app purchase to others. Such gifts may only be refunded to the original purchaser and may not be exchanged.

- Apps distributed via the Mac App Store may host plug-ins or extensions that are enabled with mechanisms other than the App Store.

- Apps offering “loot boxes” or other mechanisms that provide randomized virtual items for purchase must disclose the odds of receiving each type of item to customers prior to purchase.

- Digital gift cards, certificates, vouchers, and coupons which can be redeemed for digital goods or services can only be sold in your app using in-app purchase. Physical gift cards that are sold within an app and then mailed to customers may use payment methods other than in-app purchase.

- Non-subscription apps may offer a free time-based trial period before presenting a full unlock option by setting up a Non-Consumable IAP item at Price Tier 0 that follows the naming convention: “XX-day Trial.” Prior to the start of the trial, your app must clearly identify its duration, the content or services that will no longer be accessible when the trial ends, and any downstream charges the user would need to pay for full functionality. Learn more about managing content access and the duration of the trial period using [Receipts](/documentation/storekit/original_api_for_in-app_purchase/choosing_a_receipt_validation_technique) and [DeviceCheck](/documentation/devicecheck).

- Apps may use in-app purchase to sell and sell services related to non-fungible tokens (NFTs), such as minting, listing, and transferring. Apps may allow users to view their own NFTs, provided that NFT ownership does not unlock features or functionality within the app. Apps may allow users to browse NFT collections owned by others, provided that, except for apps on the United States storefront, the apps may not include buttons, external links, or other calls to action that direct customers to purchasing mechanisms other than in-app purchase.

- **3.1.1(a) Link to Other Purchase Methods:** Developers may apply for entitlements to provide a link in their app to a permitted destination in order to purchase digital content or services. These entitlements are not required for developers to include buttons, external links, or other calls to action in their United States storefront apps. Please see additional details below.

- StoreKit External Purchase Link Entitlements: apps on the App Store in specific regions may offer in-app purchases and also use a StoreKit External Purchase Link Entitlement or, where permitted, a Music Streaming Services Entitlement to include a link to a permitted destination that informs users of other ways to purchase digital goods or services. Approved destinations may vary by region. Learn more about these [entitlements](/documentation/storekit/external_purchase). In accordance with the entitlement agreements, the link may inform users about where and how to purchase those in-app purchase items, and the fact that such items may be available for a comparatively lower price. The entitlements are limited to use only in specific storefronts of the App Store, and only on certain platforms in each of those storefronts. In all other storefronts, except for the United States storefront, where this prohibition does not apply, apps and their metadata may not include buttons, external links, or other calls to action that direct customers to purchasing mechanisms other than in-app purchase.

- If your app engages in misleading marketing practices, scams, or fraud in relation to the entitlement, your app will be removed from the App Store and you may be removed from the Apple Developer Program.

- **3.1.2 Subscriptions:** Apps may offer auto-renewable in-app purchase subscriptions, regardless of category on the App Store. When incorporating auto-renewable subscriptions into your app, be sure to follow the guidelines below.

- **3.1.2(a) Permissible uses:** If you offer an auto-renewable subscription, you must provide ongoing value to the customer, and the subscription period must last at least seven days and be available across all of the user’s devices. While the following list is not exhaustive, examples of appropriate subscriptions include: new game levels; episodic content; multiplayer support; apps that offer consistent, substantive updates; access to large collections of, or continually updated, media content; software as a service (“SAAS”); and cloud support. In addition:

- Subscriptions may be offered alongside à la carte offerings (for example, you may offer a subscription to an entire library of films as well the purchase or rental of a single movie).

- Games offered in a streaming game service subscription may offer a single subscription that is shared across third-party apps and services; however, they must be downloaded directly from the App Store, must be designed to avoid duplicate payment by a subscriber, and should not disadvantage non-subscriber customers.

- Subscriptions must work on all of the user’s devices where the app is available. Learn more about [sharing a subscription across your apps](/documentation/storekit/in-app_purchase/offering_a_subscription_across_multiple_apps).

- As with all apps, those offering subscriptions should allow a user to get what they’ve paid for without performing additional tasks, such as posting on social media, uploading contacts, checking in to the app a certain number of times, etc.

- Subscriptions may include consumable credits, gems, in-game currencies, etc., and you may offer subscriptions that include access to discounted consumable goods (such as a platinum membership that exposes gem-packs for a reduced price).

- If you are changing your existing app to a subscription-based business model, you should not take away the primary functionality existing users have already paid for. For example, let customers who have already purchased a “full game unlock” continue to access the full game after you introduce a subscription model for new customers.

- Auto-renewable subscription apps may offer a free trial period to customers by providing the relevant information set forth in App Store Connect. [Learn more about providing subscription offers.](/app-store/subscriptions/#providing-subscription-offers)

- Apps that attempt to scam users will be removed from the App Store. This includes apps that attempt to trick users into purchasing a subscription under false pretenses or engage in bait-and-switch and scam practices; these will be removed from the App Store and you may be removed from the Apple Developer Program.

- Cellular carrier apps may include auto-renewable music and video subscriptions when purchased in bundles with new cellular data plans, with prior approval by Apple. Other auto-renewable subscriptions may also be included in bundles when purchased with new cellular data plans, with prior approval by Apple, if the cellular carrier apps support in-app purchase for users. Such subscriptions cannot include access to or discounts on consumable items, and the subscriptions must terminate coincident with the cellular data plan.

- **3.1.2(b) Upgrades and Downgrades:** Users should have a seamless upgrade/downgrade experience and should not be able to inadvertently subscribe to multiple variations of the same thing. Review [best practices](/app-store/subscriptions/) on managing your subscription upgrade and downgrade options.

- **3.1.2(c) Subscription Information:** Before asking a customer to subscribe, you should clearly describe what the user will get for the price. How many issues per month? How much cloud storage? What kind of access to your service? Ensure you clearly communicate the requirements described in [Schedule 2 of the Apple Developer Program License Agreement](https://developer.apple.com/support/terms/apple-developer-program-license-agreement/#S2).

- **3.1.3 Other Purchase Methods:** The following apps may use purchase methods other than in-app purchase. Apps in this section cannot, within the app, encourage users to use a purchasing method other than in-app purchase, except for apps on the United States storefront and as set forth in 3.1.1(a) and 3.1.3(a). Developers can send communications outside of the app to their user base about purchasing methods other than in-app purchase.

- **3.1.3(a) “Reader” Apps:** Apps may allow a user to access previously purchased content or content subscriptions (specifically: magazines, newspapers, books, audio, music, and video). Reader apps may offer account creation for free tiers, and account management functionality for existing customers. Reader app developers may apply for the External Link Account Entitlement to provide an informational link in their app to a web site the developer owns or maintains responsibility for in order to create or manage an account. This entitlement is not required for developers to include buttons, external links, or other calls to action in their United States storefront apps. Learn more about the [External Link Account Entitlement](/support/reader-apps/).

- **3.1.3(b) Multiplatform Services:** Apps that operate across multiple platforms may allow users to access content, subscriptions, or features they have acquired in your app on other platforms or your web site, including consumable items in multi-platform games, provided those items are also available as [in-app purchases within the app](#in-app-purchase).

- **3.1.3(c) Enterprise Services:** If your app is only sold directly by you to organizations or groups for their employees or students (for example professional databases and classroom management tools), you may allow enterprise users to access previously-purchased content or subscriptions. Consumer, single user, or family sales must use in-app purchase.

- **3.1.3(d) Person-to-Person Services:** If your app enables the purchase of real-time person-to-person services between two individuals (for example tutoring students, medical consultations, real estate tours, or fitness training), you may use purchase methods other than in-app purchase to collect those payments. One-to-few and one-to-many real-time services must use in-app purchase.

- **3.1.3(e) Goods and Services Outside of the App:** If your app enables people to purchase physical goods or services that will be consumed outside of the app, you must use purchase methods other than in-app purchase to collect those payments, such as Apple Pay or traditional credit card entry.

- **3.1.3(f) Free Stand-alone Apps:** Free apps acting as a stand-alone companion to a paid web-based tool for VoIP, Cloud Storage, Email Services, or Web Hosting do not need to use in-app purchase, provided there is no purchasing inside the app, or calls to action for purchase outside of the app.

- **3.1.3(g) Advertising Management Apps:** Apps for the sole purpose of allowing advertisers (persons or companies that advertise a product, service, or event) to purchase and manage advertising campaigns across media types (television, outdoor, websites, apps, etc.) do not need to use in-app purchase. These apps are intended for campaign management purposes and do not display the advertisements themselves. Digital purchases for content that is experienced or consumed in an app, including buying advertisements to display in the same app (such as sales of “boosts” for posts in a social media app) must use in-app purchase.

- **3.1.4 Hardware-Specific Content:** In limited circumstances, such as when features are dependent upon specific hardware to function, the app may unlock that functionality without using in-app purchase (such as an astronomy app that adds features when synced with a telescope). App features that work in combination with an approved physical product (such as a toy) on an *optional* basis may unlock functionality without using in-app purchase, provided that an in-app purchase option is available as well. You may not, however, require users to purchase unrelated products or engage in advertising or marketing activities to unlock app functionality.

- **3.1.5 Cryptocurrencies:**

- **(i)** Wallets: Apps may facilitate virtual currency storage, provided they are offered by developers enrolled as an organization.

- **(ii)** Mining: Apps may not mine for cryptocurrencies unless the processing is performed off device (such as cloud-based mining).

- **(iii)** Exchanges: Apps may facilitate transactions or transmissions of cryptocurrency on an approved exchange, provided they are offered only in countries or regions where the app has appropriate licensing and permissions to provide a cryptocurrency exchange.

- **(iv)** Initial Coin Offerings: Apps facilitating Initial Coin Offerings (“ICOs”), cryptocurrency futures trading, and other crypto-securities or quasi-securities trading must come from established banks, securities firms, futures commission merchants (“FCM”), or other approved financial institutions and must comply with all applicable law.

- **(v)** Cryptocurrency apps may not offer currency for completing tasks, such as downloading other apps, encouraging other users to download, posting to social networks, etc.

- **3.2 Other Business Model Issues**

The lists below are not exhaustive, and your submission may trigger a change or update to our policies, but here are some additional dos and don’ts to keep in mind:

- **3.2.1 Acceptable**

- **(i)** Displaying your own apps for purchase or promotion within your app, provided the app is not merely a catalog of your apps.

- **(ii)** Displaying or recommending a collection of third-party apps that are designed for a specific approved need (such as health management, aviation, accessibility). Your app should provide robust editorial content so that it doesn’t seem like a mere storefront.

- **(iii)** Disabling access to specific approved rental content (such as films, television programs, music, books) after the rental period has expired; all other items and services may not expire.

- **(iv)** Wallet passes can be used to make or receive payments, transmit offers, or offer identification (such as movie tickets, coupons, and VIP credentials). Other uses may result in the rejection of the app and the revocation of Wallet credentials.

- **(v)** Insurance apps must be free, in legal compliance in the regions distributed, and cannot use in-app purchase.

- **(vi)** Approved nonprofits may fundraise directly within their own apps or third-party apps, provided those fundraising campaigns adhere to all App Review Guidelines and offer Apple Pay support. These apps must disclose how the funds will be used, abide by all required local and federal laws, and ensure appropriate tax receipts are available to donors. Additional information shall be provided to App Review upon request. Nonprofit platforms that connect donors to other nonprofits must ensure that every nonprofit listed in the app has also gone through the nonprofit approval process. Learn more about becoming an [approved nonprofit](/apple-pay/nonprofits/).

- **(vii)** Apps may enable individual users to give a monetary gift to another individual without using in-app purchase, provided that (a) the gift is a completely optional choice by the giver, and (b) 100% of the funds go to the receiver of the gift. However, a gift that is connected to or associated at any point in time with receiving digital content or services must use in-app purchase.

- **(viii)** Apps used for financial trading, investing, or money management should be submitted by the financial institution performing such services and must have necessary licensing and permissions in the locations where you make them available.

- **3.2.2 Unacceptable**

- **(i)** Creating an interface for displaying third-party apps, extensions, or plug-ins similar to the App Store or as a general-interest collection.

- **(ii)** Intentionally omitted.

- **(iii)** Artificially increasing the number of impressions or click-throughs of ads, as well as apps that are designed predominantly for the display of ads.

- **(iv)** Unless you are an approved nonprofit or otherwise permitted under Section 3.2.1 (vi) above, collecting funds within the app for charities and fundraisers. Apps that seek to raise money for such causes must be free on the App Store and may only collect funds outside of the app, such as via Safari or SMS.

- **(v)** Arbitrarily restricting who may use the app, such as by location or carrier.

- **(vi)** Intentionally omitted.

- **(vii)** Artificially manipulating a user’s visibility, status, or rank on other services unless permitted by that service’s Terms and Conditions.

- **(viii)** Apps that facilitate binary options trading are not permitted on the App Store. Consider a web app instead. Apps that facilitate trading in contracts for difference (“CFDs”) or other derivatives (such as FOREX) must be properly licensed in all jurisdictions where the service is available.

- **(ix)** Apps offering personal loans must clearly and conspicuously disclose all loan terms, including but not limited to equivalent maximum Annual Percentage Rate (APR) and payment due date. Loan apps may not charge a maximum APR higher than 36%, including costs and fees, and may not require repayment in full in 60 days or less.

- **(x)** Apps must not force users to rate the app, review the app, download other apps, or other store-related actions in order to access functionality, content, or use of the app. Apps may otherwise incentivize users to take specific actions within apps (such as by completing a level or watching an ad).
