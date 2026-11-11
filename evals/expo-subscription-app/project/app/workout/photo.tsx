import { useRef, useState } from 'react';
import { Image, Pressable, Text, View, StyleSheet } from 'react-native';
import { CameraView, useCameraPermissions } from 'expo-camera';
import * as ImagePicker from 'expo-image-picker';
import { saveWorkout } from '@/lib/api';

export default function ProgressPhotoScreen() {
  const [permission, requestPermission] = useCameraPermissions();
  const cameraRef = useRef<CameraView>(null);
  const [uri, setUri] = useState<string | null>(null);

  const takePhoto = async () => {
    const photo = await cameraRef.current?.takePictureAsync({ quality: 0.7 });
    if (photo) setUri(photo.uri);
  };

  const pickFromLibrary = async () => {
    const result = await ImagePicker.launchImageLibraryAsync({ mediaTypes: ['images'], quality: 0.7 });
    if (!result.canceled) setUri(result.assets[0].uri);
  };

  const save = async () => {
    if (!uri) return;
    await saveWorkout({ title: 'Progress photo', durationMin: 0, photoUri: uri, createdAt: new Date().toISOString() });
  };

  if (!permission?.granted) {
    return (
      <View style={styles.center}>
        <Text style={styles.copy}>Take a progress photo to track how far you've come.</Text>
        <Pressable style={styles.button} onPress={requestPermission}><Text style={styles.buttonText}>Enable camera</Text></Pressable>
        <Pressable onPress={pickFromLibrary}><Text style={styles.link}>Choose from library instead</Text></Pressable>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {uri ? <Image source={{ uri }} style={styles.preview} /> : <CameraView ref={cameraRef} style={styles.preview} facing="front" />}
      <View style={styles.actions}>
        <Pressable style={styles.button} onPress={takePhoto}><Text style={styles.buttonText}>Capture</Text></Pressable>
        <Pressable style={styles.button} onPress={pickFromLibrary}><Text style={styles.buttonText}>Library</Text></Pressable>
        <Pressable style={styles.button} onPress={save} disabled={!uri}><Text style={styles.buttonText}>Save</Text></Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 24, gap: 16 },
  copy: { textAlign: 'center', fontSize: 16 },
  preview: { flex: 1 },
  actions: { flexDirection: 'row', justifyContent: 'space-around', padding: 16 },
  button: { backgroundColor: '#101418', paddingVertical: 12, paddingHorizontal: 20, borderRadius: 10 },
  buttonText: { color: 'white', fontWeight: '600' },
  link: { color: '#2962ff' },
});
