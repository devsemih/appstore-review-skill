import { Linking, Pressable, Text, View, StyleSheet } from 'react-native';
import Constants from 'expo-constants';
import { signOut } from '@/lib/supabase';

const extra = Constants.expoConfig?.extra ?? {};

export default function SettingsScreen() {
  return (
    <View style={styles.container}>
      <Pressable style={styles.row} onPress={() => Linking.openURL(extra.privacyPolicyUrl)}>
        <Text>Privacy Policy</Text>
      </Pressable>
      <Pressable style={styles.row} onPress={() => Linking.openURL(extra.supportUrl)}>
        <Text>Help & Support</Text>
      </Pressable>
      <Pressable style={styles.row} onPress={signOut}>
        <Text style={styles.danger}>Sign out</Text>
      </Pressable>
      <Text style={styles.version}>Fitloop v{Constants.expoConfig?.version}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20 },
  row: { paddingVertical: 16, borderBottomWidth: StyleSheet.hairlineWidth },
  danger: { color: '#c62828' },
  version: { marginTop: 24, color: '#999', textAlign: 'center' },
});
