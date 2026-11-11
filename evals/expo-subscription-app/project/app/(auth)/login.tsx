import { useEffect, useState } from 'react';
import { KeyboardAvoidingView, Platform, Pressable, Text, TextInput, View, StyleSheet } from 'react-native';
import * as Google from 'expo-auth-session/providers/google';
import * as WebBrowser from 'expo-web-browser';
import { Link, router } from 'expo-router';
import { signInWithEmail, signInWithGoogleIdToken } from '@/lib/supabase';

WebBrowser.maybeCompleteAuthSession();

export default function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);

  const [request, response, promptAsync] = Google.useIdTokenAuthRequest({
    iosClientId: '284019374651-fixtureios.apps.googleusercontent.com',
    androidClientId: '284019374651-fixtureandroid.apps.googleusercontent.com',
  });

  useEffect(() => {
    if (response?.type === 'success') {
      signInWithGoogleIdToken(response.params.id_token)
        .then(() => router.replace('/'))
        .catch((e) => setError(e.message));
    }
  }, [response]);

  const onEmailLogin = async () => {
    try {
      await signInWithEmail(email, password);
      router.replace('/');
    } catch (e: any) {
      setError(e.message);
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'android' ? 'height' : 'padding'}
    >
      <Text style={styles.title}>Welcome back to Fitloop</Text>
      <TextInput style={styles.input} placeholder="Email" autoCapitalize="none" value={email} onChangeText={setEmail} />
      <TextInput style={styles.input} placeholder="Password" secureTextEntry value={password} onChangeText={setPassword} />
      {error && <Text style={styles.error}>{error}</Text>}
      <Pressable style={styles.primary} onPress={onEmailLogin}>
        <Text style={styles.primaryText}>Log in</Text>
      </Pressable>
      <Pressable style={styles.google} disabled={!request} onPress={() => promptAsync()}>
        <Text style={styles.googleText}>Continue with Google</Text>
      </Pressable>
      <Link href="/(auth)/signup" style={styles.link}>New here? Create an account</Link>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', padding: 24, gap: 12 },
  title: { fontSize: 28, fontWeight: '700', marginBottom: 12 },
  input: { borderWidth: 1, borderColor: '#d0d4da', borderRadius: 12, padding: 14 },
  error: { color: '#c62828' },
  primary: { backgroundColor: '#101418', padding: 16, borderRadius: 12, alignItems: 'center' },
  primaryText: { color: 'white', fontWeight: '600' },
  google: { borderWidth: 1, borderColor: '#101418', padding: 16, borderRadius: 12, alignItems: 'center' },
  googleText: { fontWeight: '600' },
  link: { textAlign: 'center', marginTop: 8, color: '#2962ff' },
});
