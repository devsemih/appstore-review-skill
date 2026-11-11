import { useEffect, useState } from 'react';
import { FlatList, Pressable, Text, View, StyleSheet } from 'react-native';
import { Link } from 'expo-router';
import { fetchWorkouts, Workout } from '@/lib/api';

export default function HomeScreen() {
  const [workouts, setWorkouts] = useState<Workout[]>([]);

  useEffect(() => {
    fetchWorkouts().then(setWorkouts).catch(() => setWorkouts([]));
  }, []);

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Your workouts</Text>
        <Link href="/settings">Settings</Link>
      </View>
      <FlatList
        data={workouts}
        keyExtractor={(w) => w.id}
        renderItem={({ item }) => (
          <View style={styles.row}>
            <Text style={styles.rowTitle}>{item.title}</Text>
            <Text>{item.durationMin} min</Text>
          </View>
        )}
        ListEmptyComponent={<Text style={styles.empty}>Log your first workout to start your streak.</Text>}
      />
      <Link href="/workout/photo" asChild>
        <Pressable style={styles.fab}><Text style={styles.fabText}>+ Progress photo</Text></Pressable>
      </Link>
      <Link href="/paywall" style={styles.upsell}>Unlock Fitloop Premium</Link>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, paddingTop: 64 },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  title: { fontSize: 28, fontWeight: '700' },
  row: { paddingVertical: 14, borderBottomWidth: StyleSheet.hairlineWidth },
  rowTitle: { fontWeight: '600' },
  empty: { marginTop: 40, textAlign: 'center', color: '#666' },
  fab: { backgroundColor: '#101418', padding: 16, borderRadius: 28, alignItems: 'center', marginTop: 12 },
  fabText: { color: 'white', fontWeight: '600' },
  upsell: { textAlign: 'center', marginTop: 16, color: '#2962ff' },
});
