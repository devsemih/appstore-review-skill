import { useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, Text, View, StyleSheet } from 'react-native';
import { router } from 'expo-router';
import { PurchasesPackage } from 'react-native-purchases';
import { buyPackage, getCurrentOffering } from '@/lib/purchases';

const FEATURES = [
  'Unlimited workout plans',
  'Advanced progress analytics',
  'Coach-designed programs',
];

export default function PaywallScreen() {
  const [pkg, setPkg] = useState<PurchasesPackage | null>(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    getCurrentOffering().then((offering) => setPkg(offering?.annual ?? offering?.availablePackages[0] ?? null));
  }, []);

  const onSubscribe = async () => {
    if (!pkg) return;
    setBusy(true);
    try {
      const unlocked = await buyPackage(pkg);
      if (unlocked) router.back();
    } finally {
      setBusy(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Go Premium</Text>
      <Text style={styles.subtitle}>Train smarter with everything Fitloop has to offer.</Text>
      {FEATURES.map((f) => (
        <Text key={f} style={styles.feature}>✓ {f}</Text>
      ))}
      <Pressable style={styles.cta} onPress={onSubscribe} disabled={!pkg || busy}>
        {busy ? <ActivityIndicator color="white" /> : <Text style={styles.ctaText}>Start Premium</Text>}
      </Pressable>
      <Pressable onPress={() => router.back()}>
        <Text style={styles.close}>Not now</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 28, justifyContent: 'center', gap: 10 },
  title: { fontSize: 34, fontWeight: '800' },
  subtitle: { fontSize: 16, color: '#555', marginBottom: 16 },
  feature: { fontSize: 17 },
  cta: { backgroundColor: '#ff5722', padding: 18, borderRadius: 14, alignItems: 'center', marginTop: 28 },
  ctaText: { color: 'white', fontSize: 18, fontWeight: '700' },
  close: { textAlign: 'center', color: '#888', marginTop: 12 },
});
