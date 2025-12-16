import preferences from '@ohos.data.preferences';

let prefs: preferences.Preferences;

async function getPreferences() {
  if (!prefs) {
    prefs = await preferences.getPreferences(globalThis.getContext(), 'app_config');
  }
  return prefs;
}

export async function saveHomeUrl(page_url: string) {
  const store = await getPreferences();
  await store.put('homepage_url', page_url);
  await store.flush(); 
}

export async function getHomeUrl(): Promise<string> {
  const store = await getPreferences();
  return String(await store.get('homepage_url', ''));

}
