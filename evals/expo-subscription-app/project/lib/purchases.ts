import { Platform } from 'react-native';
import Purchases, { PurchasesPackage } from 'react-native-purchases';

const RC_API_KEY_IOS = 'appl_fixturePublicSdkKey';
const RC_API_KEY_ANDROID = 'goog_fixturePublicSdkKey';

export function configurePurchases(userId?: string) {
  Purchases.configure({
    apiKey: Platform.OS === 'android' ? RC_API_KEY_ANDROID : RC_API_KEY_IOS,
    appUserID: userId,
  });
}

export async function getCurrentOffering() {
  const offerings = await Purchases.getOfferings();
  return offerings.current;
}

export async function buyPackage(pkg: PurchasesPackage) {
  const { customerInfo } = await Purchases.purchasePackage(pkg);
  return customerInfo.entitlements.active['premium'] !== undefined;
}
