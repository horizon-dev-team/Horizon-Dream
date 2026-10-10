import { storage } from 'common/storage';

const STORAGE_KEY = 'chat-placement-ratio';

export type ChatRatio = {
  x: number;
  y: number;
  w: number;
  h: number;
};

export async function loadChatRatio(): Promise<ChatRatio | null> {
  try {
    return await storage.get(STORAGE_KEY);
  } catch {
    return null;
  }
}

export function saveChatRatio(): void {
  Byond.winget('browseroutput', ['pos', 'size']).then((browser) => {
    Byond.winget('mapwindow', ['size']).then((map) => {
      const mapW = map.size.x;
      const mapH = map.size.y;
      if (!mapW || !mapH) return;
      const ratio: ChatRatio = {
        x: browser.pos.x / mapW,
        y: browser.pos.y / mapH,
        w: browser.size.x / mapW,
        h: browser.size.y / mapH,
      };
      storage.set(STORAGE_KEY, ratio);
    });
  });
}

export function saveChatRatioRect(ratio: ChatRatio): void {
  storage.set(STORAGE_KEY, ratio);
}
