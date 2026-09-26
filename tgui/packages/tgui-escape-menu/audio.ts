import { assetMap } from './assets';

let ambientAudio: HTMLAudioElement | null = null;
let currentUiVolume = 0.8;

export function setUiVolume(volume: number) {
  if (typeof volume === 'number') {
    currentUiVolume = Math.max(0, Math.min(1, volume));
  }
}

function getAssetUrl(name: string): string | null {
  return assetMap[name] ?? null;
}

function playOneShot(name: string) {
  const url = getAssetUrl(name);
  if (!url) return;
  const audio = new Audio(url);
  audio.volume = currentUiVolume;
  audio.play().catch(() => {});
}

function startAmbient(name: string) {
  stopAmbient();
  const url = getAssetUrl(name);
  if (!url) return;
  ambientAudio = new Audio(url);
  ambientAudio.volume = currentUiVolume;
  ambientAudio.play().catch(() => {});
}

function stopAmbient() {
  if (ambientAudio) {
    const audio = ambientAudio;
    ambientAudio = null;
    audio.pause();
  }
}

export function playOpenSounds() {
  playOneShot('esc_open.ogg');
  startAmbient('esc_middle.ogg');
}

export function playCloseSounds() {
  stopAmbient();
  playOneShot('esc_close.ogg');
}
