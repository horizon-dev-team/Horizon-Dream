import { RectRatio, stripState } from './chat-strip-state';
import { chatRenderer } from './renderer';

export function anchorsForRect(
  x: number,
  y: number,
  w: number,
  h: number,
  mapW: number,
  mapH: number,
): { anchor1: string; anchor2: string } {
  const a1x = (x / mapW) * 100;
  const a1y = (y / mapH) * 100;
  const a2x = ((x + w) / mapW) * 100;
  const a2y = ((y + h) / mapH) * 100;
  return {
    anchor1: `${a1x.toFixed(2)},${a1y.toFixed(2)}`,
    anchor2: `${a2x.toFixed(2)},${a2y.toFixed(2)}`,
  };
}

export function winsetChatRect(
  x: number,
  y: number,
  w: number,
  h: number,
  mapW: number,
  mapH: number,
): void {
  Byond.winset('browseroutput', {
    pos: `${x},${y}`,
    size: `${w}x${h}`,
    ...anchorsForRect(x, y, w, h, mapW, mapH),
  });
}

export function clampedRectRatio(
  x: number,
  y: number,
  w: number,
  h: number,
  mapW: number,
  mapH: number,
): RectRatio {
  const right = Math.min(Math.max(x + w, 1), mapW);
  const bottom = Math.min(Math.max(y + h, 1), mapH);
  const left = Math.min(Math.max(x, 0), right - 1);
  const top = Math.min(Math.max(y, 0), bottom - 1);
  return {
    x: left / mapW,
    y: top / mapH,
    w: (right - left) / mapW,
    h: (bottom - top) / mapH,
  };
}

export function winsetChatRectClamped(
  x: number,
  y: number,
  w: number,
  h: number,
): void {
  Byond.winget('mapwindow', ['size']).then((map) => {
    const mapW = map.size.x;
    const mapH = map.size.y;
    if (!mapW || !mapH) {
      return;
    }
    const cw = Math.max(1, Math.min(w, mapW));
    const ch = Math.max(1, Math.min(h, mapH));
    const cx = Math.min(Math.max(x, 0), mapW - cw);
    const cy = Math.min(Math.max(y, 0), mapH - ch);
    winsetChatRect(cx, cy, cw, ch, mapW, mapH);
  });
}

export function rectsOverlap(
  a: { x: number; y: number; w: number; h: number },
  b: { x: number; y: number; w: number; h: number },
): boolean {
  return (
    a.x < b.x + b.w && a.x + a.w > b.x && a.y < b.y + b.h && a.y + a.h > b.y
  );
}

export function afterNextResize(fn: () => void, fallbackMs: number): void {
  let done = false;
  let clearTimer: ReturnType<typeof setTimeout> | undefined;
  const run = () => {
    if (done) {
      return;
    }
    done = true;
    window.removeEventListener('resize', run);
    if (clearTimer !== undefined) {
      clearTimeout(clearTimer);
    }
    fn();
  };
  window.addEventListener('resize', run);
  clearTimer = setTimeout(run, fallbackMs);
}

export const RESTICK_FALLBACK_MS = 150;

export function restickAfterNextResize(): void {
  afterNextResize(() => {
    if (stripState.collapsed) {
      chatRenderer.scrollToBottom();
    }
    chatRenderer.setViewportShift(0);
  }, RESTICK_FALLBACK_MS);
}
