
import {
  restickAfterNextResize,
  winsetChatRectClamped,
} from './chat-strip-geometry';
import { combatState, stripState } from './chat-strip-state';
import { chatRenderer } from './renderer';

export const COMBAT_MIN_HEIGHT = 24;
const FIT_DEADBAND = 6;
const FIT_SHRINK_DELAY = 500;
const FIT_EPSILON = 12;
const SHRINK_MIN_RECOVERY = 36;
const COMBAT_CHROME_FALLBACK_CSS = 46;

let shrinkTimer: ReturnType<typeof setTimeout> | undefined;
let fitRaf: number | undefined;
let tailObserver: MutationObserver | null = null;

function litTailBounds(): { top: number; bottom: number } | null {
  const lit = document.querySelectorAll(
    '#chat-pane .ChatMessage--recent, #chat-pane .ChatMessage--fading',
  );
  let top = Infinity;
  let bottom = -Infinity;
  for (const node of lit) {
    const el = node as HTMLElement;
    const rect = el.getBoundingClientRect();
    if (rect.height <= 0) {
      continue;
    }
    top = Math.min(top, rect.top);
    bottom = Math.max(bottom, rect.bottom);
  }
  return bottom > top ? { top, bottom } : null;
}

export function measureCombatOverheadCss(): number {
  const pane = document.getElementById('chat-pane');
  if (pane) {
    const rect = pane.getBoundingClientRect();
    const cs = window.getComputedStyle(pane);
    const padTop = parseFloat(cs.paddingTop) || 0;
    const padBottom = parseFloat(cs.paddingBottom) || 0;
    const overhead =
      Math.max(0, rect.top) +
      Math.max(0, window.innerHeight - rect.bottom) +
      padTop +
      padBottom;
    if (overhead > 0) {
      return overhead;
    }
  }
  return COMBAT_CHROME_FALLBACK_CSS;
}

export function combatTargetH(fullH: number): number {
  const base = combatState.base;
  if (!base) {
    return fullH;
  }
  const bounds = litTailBounds();
  const chrome =
    combatState.chrome ?? Math.round(COMBAT_MIN_HEIGHT * base.scale);
  const spanSkin = bounds
    ? Math.ceil((bounds.bottom - bounds.top) * base.scale)
    : 0;
  const target = spanSkin + chrome + FIT_EPSILON;
  return Math.min(Math.max(target, COMBAT_MIN_HEIGHT), fullH);
}

function applyCombatHeight(h: number): void {
  const base = combatState.base;
  if (!base || !stripState.collapsed) {
    return;
  }
  const prev = combatState.stripH ?? base.h;
  if (h === prev) {
    return;
  }
  combatState.stripH = h;
  const y = stripState.stripAtTop ? base.y : base.y + base.h - h;
  if (!stripState.stripAtTop && h < prev) {
    chatRenderer.setViewportShift((h - prev) / base.scale);
  } else {
    chatRenderer.setViewportShift(0);
  }
  winsetChatRectClamped(base.x, y, base.w, h);
  restickAfterNextResize();
}

export function scheduleCombatFit(): void {
  if (
    !combatState.active ||
    !stripState.collapsed ||
    !combatState.base ||
    stripState.dragging
  ) {
    return;
  }
  if (fitRaf !== undefined) {
    return;
  }
  fitRaf = requestAnimationFrame(() => {
    fitRaf = undefined;
    const base = combatState.base;
    if (
      !combatState.active ||
      !stripState.collapsed ||
      !base ||
      stripState.dragging
    ) {
      return;
    }
    const fold = litTailBounds() === null;
    const target = combatTargetH(base.h);
    const current = combatState.stripH ?? base.h;
    if (target >= base.h) {
      applyCombatHeight(target);
      return;
    }
    if (target > current) {
      if (target - current < FIT_DEADBAND) {
        return;
      }
      applyCombatHeight(target);
      return;
    }
    if (!fold && current - target < SHRINK_MIN_RECOVERY) {
      return;
    }
    if (shrinkTimer !== undefined) {
      clearTimeout(shrinkTimer);
    }
    shrinkTimer = setTimeout(() => {
      shrinkTimer = undefined;
      const settled = combatState.base;
      if (
        !combatState.active ||
        !stripState.collapsed ||
        !settled ||
        stripState.dragging
      ) {
        return;
      }
      const shrinkTo = combatTargetH(settled.h);
      if (shrinkTo < (combatState.stripH ?? settled.h)) {
        applyCombatHeight(shrinkTo);
      }
    }, FIT_SHRINK_DELAY);
  });
}

export function startTailObserver(): void {
  const pane = document.getElementById('chat-pane');
  if (!pane || typeof MutationObserver === 'undefined') {
    return;
  }
  stopTailObserver();
  tailObserver = new MutationObserver(() => {
    scheduleCombatFit();
  });
  tailObserver.observe(pane, {
    subtree: true,
    attributes: true,
    attributeFilter: ['class'],
  });
}

export function stopTailObserver(): void {
  tailObserver?.disconnect();
  tailObserver = null;
}

export function clearCombatState(): void {
  if (shrinkTimer !== undefined) {
    clearTimeout(shrinkTimer);
    shrinkTimer = undefined;
  }
  if (fitRaf !== undefined) {
    cancelAnimationFrame(fitRaf);
    fitRaf = undefined;
  }
  stopTailObserver();
  chatRenderer.setViewportShift(0);
  combatState.stripH = null;
  combatState.chrome = null;
  combatState.base = null;
}

export async function refreshCombatBase(): Promise<void> {
  if (!stripState.fullRect) {
    return;
  }
  const map = await Byond.winget('mapwindow', ['size']);
  const mapW = map.size.x;
  const mapH = map.size.y;
  if (!mapW || !mapH || !stripState.fullRect) {
    return;
  }
  combatState.base = {
    x: Math.round(stripState.fullRect.x * mapW),
    y: Math.round(stripState.fullRect.y * mapH),
    w: Math.round(stripState.fullRect.w * mapW),
    h: Math.round(stripState.fullRect.h * mapH),
    mapW,
    mapH,
    scale: combatState.base?.scale ?? 1,
  };
}

export function setCombatActive(active: boolean): void {
  if (active) {
    if (stripState.collapsed) {
      const base = combatState.base;
      if (base) {
        startTailObserver();
        scheduleCombatFit();
      } else {
        refreshCombatBase().then(() => {
          if (
            combatState.active &&
            stripState.collapsed &&
            combatState.base
          ) {
            combatState.chrome = Math.round(
              measureCombatOverheadCss() * combatState.base.scale,
            );
            combatState.stripH = Math.min(
              stripState.peekHeight,
              combatState.base.h,
            );
            scheduleCombatFit();
            startTailObserver();
          }
        });
      }
    }
    return;
  }
  stopTailObserver();
  if (shrinkTimer !== undefined) {
    clearTimeout(shrinkTimer);
    shrinkTimer = undefined;
  }
  if (fitRaf !== undefined) {
    cancelAnimationFrame(fitRaf);
    fitRaf = undefined;
  }
  const base = combatState.base;
  if (stripState.collapsed && base) {
    const h = Math.min(stripState.peekHeight, base.h);
    const prev = combatState.stripH ?? base.h;
    const y = stripState.stripAtTop ? base.y : base.y + base.h - h;
    if (!stripState.stripAtTop && h < prev) {
      chatRenderer.setViewportShift((h - prev) / base.scale);
    } else {
      chatRenderer.setViewportShift(0);
    }
    winsetChatRectClamped(base.x, y, base.w, h);
    restickAfterNextResize();
  }
  combatState.stripH = null;
  combatState.chrome = null;
  combatState.base = null;
}
