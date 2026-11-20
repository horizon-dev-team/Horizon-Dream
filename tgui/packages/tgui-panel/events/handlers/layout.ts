import { atom } from 'jotai';
import { store } from '../store';

export const panelLayoutAtom = atom<string | null>(null);

export function panelLayoutChanged(payload: { layout?: string } | undefined) {
  if (typeof payload?.layout === 'string') {
    store.set(panelLayoutAtom, payload.layout);
  }
}
