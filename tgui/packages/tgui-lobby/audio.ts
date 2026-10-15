import { storage } from 'common/storage';
import { assetMap } from './assets';

const SOUNDS_STORAGE_KEY = 'lobby-sounds-enabled';

let soundsEnabled = true;

export function setSoundsEnabled(enabled: boolean) {
  soundsEnabled = enabled;
  storage.set(SOUNDS_STORAGE_KEY, enabled);
}

export function loadSoundsEnabled(): Promise<boolean> {
  return storage.get(SOUNDS_STORAGE_KEY).then((val) => {
    soundsEnabled = val === undefined || val === null ? true : !!val;
    return soundsEnabled;
  });
}

function playOneShot(name: string, volume = 0.6) {
  if (!soundsEnabled) return;
  const url = assetMap[name];
  if (!url) return;
  const audio = new Audio(url);
  audio.volume = volume;
  audio.play().catch(() => {});
}

export function playSelectSound() {
  playOneShot('ui_select1.ogg');
}

export function playLoadSound() {
  playOneShot('load.mp3', 0.5);
}
