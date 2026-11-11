import { supabase } from './supabase';

// TODO: switch back to prod before release
export const API_BASE_URL = 'https://staging-api.fitloop.app/v1';

async function authHeaders() {
  const { data } = await supabase.auth.getSession();
  return { Authorization: `Bearer ${data.session?.access_token ?? ''}` };
}

export async function fetchWorkouts() {
  const res = await fetch(`${API_BASE_URL}/workouts`, { headers: await authHeaders() });
  const json = await res.json();
  console.log('workouts response', JSON.stringify(json));
  return json.items as Workout[];
}

export async function saveWorkout(workout: Omit<Workout, 'id'>) {
  const res = await fetch(`${API_BASE_URL}/workouts`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(await authHeaders()) },
    body: JSON.stringify(workout),
  });
  console.log('saved workout', res.status);
  return res.json();
}

export type Workout = {
  id: string;
  title: string;
  durationMin: number;
  photoUri?: string;
  createdAt: string;
};
