import { storage } from 'common/storage';
import { store } from '../events/store';
import { settingsVisibleAtom } from '../settings/atoms';
import { saveChatRatioRect } from './chat-ratio';
import { chatRenderer } from './renderer';

export type RectRatio = {
  x: number;
  y: number;
  w: number;
  h: number;
};

export type RectPx = {
  x: number;
  y: number;
  w: number;
  h: number;
};

export type CollapseBase = {
  x: number;
  y: number;
  w: number;
  h: number;
  mapW: number;
  mapH: number;
  scale: number;
};

export const DEFAULT_PEEK_HEIGHT = 140;

export const stripState = {
  mode: false,
  collapsed: false,
  stripAtTop: false,
  dragging: false,
  pendingExpand: false,
  settling: false,
  chromeHovered: false,
  peekHeight: DEFAULT_PEEK_HEIGHT,
  fullRect: null as RectRatio | null,
};

export const combatState = {
  active: false,
  base: null as CollapseBase | null,
  chrome: null as number | null,
  stripH: null as number | null,
};

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

const COLLAPSE_DELAY = 300;
const SELECT_RETRY_DELAY = 500;
const SELECT_MAX_RETRIES = 8;
const EXPAND_DEFER = 140;
const EXPAND_SETTLE_FALLBACK_MS = 250;
const PEEK_HEIGHT_KEY = 'chat-peek-height';
const MIN_PEEK_HEIGHT = 100;
const PING_MIN_INTERVAL = 1600;

let collapseTimer: ReturnType<typeof setTimeout> | undefined;
let selectRetries = 0;
let focusedBeforeCollapse: HTMLElement | null = null;
let paneObserver: ResizeObserver | null = null;
let paneObserverNode: HTMLElement | null = null;
let expandTimer: ReturnType<typeof setTimeout> | undefined;
let lastPingAt = 0;

export function isChatStripCollapsed(): boolean {
  return stripState.collapsed;
}

function loadPeekHeight(): void {
  storage
    .get(PEEK_HEIGHT_KEY)
    .then((value: unknown) => {
      if (typeof value === 'number' && value >= MIN_PEEK_HEIGHT) {
        stripState.peekHeight = value;
      }
    })
    .catch(() => undefined);
}

loadPeekHeight();

function hasUnsentInput(): boolean {
  const node = document.activeElement;
  if (node instanceof HTMLInputElement) {
    return node.value.length > 0;
  }
  if (
    node instanceof HTMLTextAreaElement ||
    (node instanceof HTMLElement && node.isContentEditable)
  ) {
    return true;
  }
  return false;
}

function isSelecting(): boolean {
  const selection = window.getSelection();
  return !!selection && !selection.isCollapsed;
}

function blockedFromCollapsing(bypassHover = false): boolean {
  if (stripState.dragging) {
    return true;
  }
  if (store.get(settingsVisibleAtom)) {
    return true;
  }
  if (hasUnsentInput()) {
    return true;
  }
  if (!bypassHover && document.body.matches(':hover')) {
    return true;
  }
  return false;
}

function observePaneForRestick(): void {
  const pane = document.getElementById('chat-pane');
  if (!pane || typeof ResizeObserver === 'undefined') {
    return;
  }
  if (paneObserver && paneObserverNode === pane) {
    return;
  }
  paneObserver?.disconnect();
  paneObserverNode = pane;
  paneObserver = new ResizeObserver(() => {
    if (!stripState.collapsed) {
      return;
    }
    chatRenderer.scrollToBottom();
    if (combatState.active) {
      refreshCombatBase().then(() => scheduleCombatFit());
    }
  });
  paneObserver.observe(pane);
}

export function collapseChatToStrip(bypassHover = false): void {
  if (!stripState.mode || stripState.collapsed || stripState.dragging) {
    return;
  }
  if (blockedFromCollapsing(bypassHover)) {
    return;
  }
  Byond.winget('browseroutput', 'parent').then((parent) => {
    if (parent !== 'mapwindow' || !stripState.mode || stripState.collapsed) {
      return;
    }
    Promise.all([
      Byond.winget('browseroutput', ['pos', 'size']),
      Byond.winget('mapwindow', ['size']),
    ]).then(([browser, map]) => {
      if (!stripState.mode || stripState.collapsed) {
        return;
      }
      const x = browser.pos.x;
      const y = browser.pos.y;
      const w = browser.size.x;
      const h = browser.size.y;
      const mapW = map.size.x;
      const mapH = map.size.y;
      if (
        !mapW ||
        !mapH ||
        w <= 0 ||
        h <= (combatState.active ? COMBAT_MIN_HEIGHT : stripState.peekHeight)
      ) {
        return;
      }
      stripState.fullRect = clampedRectRatio(x, y, w, h, mapW, mapH);
      const scale = window.innerHeight > 0 ? h / window.innerHeight : 1;
      if (combatState.active) {
        combatState.base = { x, y, w, h, mapW, mapH, scale };
      }
      stripState.collapsed = true;
      focusedBeforeCollapse =
        document.activeElement instanceof HTMLElement
          ? document.activeElement
          : null;
      document.body.classList.add('chat-hover-collapsed');
      chatRenderer.scrollToBottom();
      let stripH: number;
      if (combatState.active) {
        combatState.chrome = Math.round(measureCombatOverheadCss() * scale);
        stripH = combatTargetH(h);
        combatState.stripH = stripH;
      } else {
        stripH = Math.min(stripState.peekHeight, h);
      }
      const stripY = stripState.stripAtTop ? y : y + h - stripH;
      if (!stripState.stripAtTop) {
        chatRenderer.setViewportShift((stripH - h) / scale);
      }
      winsetChatRect(x, stripY, w, stripH, mapW, mapH);
      observePaneForRestick();
      chatRenderer.scrollToBottom();
      restickAfterNextResize();
      if (combatState.active) {
        startTailObserver();
      }
    });
  });
}

export function expandChatFromStrip(): void {
  if (!stripState.collapsed) {
    return;
  }
  if (stripState.dragging || stripState.settling) {
    stripState.pendingExpand = true;
    return;
  }
  Byond.winget('browseroutput', 'parent').then((parent) => {
    if (parent !== 'mapwindow') {
      stripState.collapsed = false;
      stripState.pendingExpand = false;
      clearCombatState();
      document.body.classList.remove('chat-hover-collapsed');
      return;
    }
    Byond.winget('mapwindow', ['size']).then((map) => {
      stripState.collapsed = false;
      stripState.pendingExpand = false;
      clearCombatState();
      const full = stripState.fullRect;
      if (!full) {
        document.body.classList.remove('chat-hover-collapsed');
        return;
      }
      const mapW = map.size.x;
      const mapH = map.size.y;
      if (!mapW || !mapH) {
        document.body.classList.remove('chat-hover-collapsed');
        return;
      }
      const x = Math.round(full.x * mapW);
      const y = Math.round(full.y * mapH);
      const w = Math.round(full.w * mapW);
      const h = Math.round(full.h * mapH);
      winsetChatRect(x, y, w, h, mapW, mapH);
      afterNextResize(() => {
        if (!stripState.collapsed) {
          document.body.classList.remove('chat-hover-collapsed');
          chatRenderer.scrollToBottom();
          if (
            stripState.mode &&
            (document.body.matches(':hover') ||
              store.get(settingsVisibleAtom))
          ) {
            document.body.classList.add('frameless-visible');
          }
          const restore = focusedBeforeCollapse;
          focusedBeforeCollapse = null;
          if (restore && document.contains(restore)) {
            restore.focus();
          }
        }
      }, EXPAND_SETTLE_FALLBACK_MS);
    });
  });
}

export function cancelChatStripCollapse(): void {
  if (collapseTimer !== undefined) {
    clearTimeout(collapseTimer);
    collapseTimer = undefined;
  }
}

export function scheduleChatStripCollapse(): void {
  if (!stripState.mode || stripState.collapsed) {
    return;
  }
  cancelChatStripCollapse();
  selectRetries = 0;
  const fire = () => {
    collapseTimer = undefined;
    if (!stripState.mode || stripState.collapsed) {
      return;
    }
    if (isSelecting() && selectRetries++ < SELECT_MAX_RETRIES) {
      collapseTimer = setTimeout(fire, SELECT_RETRY_DELAY);
      return;
    }
    if (blockedFromCollapsing()) {
      return;
    }
    collapseChatToStrip();
  };
  collapseTimer = setTimeout(fire, COLLAPSE_DELAY);
}

export function requestChatStripExpand(): void {
  if (!stripState.mode) {
    return;
  }
  cancelChatStripCollapse();
  if (combatState.active && stripState.collapsed) {
    return;
  }
  if (!stripState.collapsed) {
    document.body.classList.add('frameless-visible');
    return;
  }
  if (expandTimer !== undefined) {
    clearTimeout(expandTimer);
  }
  expandTimer = setTimeout(() => {
    expandTimer = undefined;
    if (
      !stripState.mode ||
      stripState.collapsed ||
      stripState.chromeHovered
    ) {
      return;
    }
    expandChatFromStrip();
  }, EXPAND_DEFER);
}

export function setStripChromeHovered(value: boolean): void {
  stripState.chromeHovered = value;
  if (value && expandTimer !== undefined) {
    clearTimeout(expandTimer);
    expandTimer = undefined;
    return;
  }
  if (
    !value &&
    stripState.mode &&
    stripState.collapsed &&
    document.body.matches(':hover')
  ) {
    requestChatStripExpand();
  }
}

export function setChatStripMode(active: boolean): void {
  stripState.mode = active;
  if (!active) {
    cancelChatStripCollapse();
    if (expandTimer !== undefined) {
      clearTimeout(expandTimer);
      expandTimer = undefined;
    }
    clearCombatState();
    if (stripState.collapsed) {
      stripState.pendingExpand = false;
      expandChatFromStrip();
    } else {
      document.body.classList.remove('chat-hover-collapsed');
    }
    paneObserver?.disconnect();
    paneObserver = null;
    paneObserverNode = null;
    return;
  }
  collapseChatToStrip();
}

export function setChatStripCombat(active: boolean): void {
  if (combatState.active === active) {
    return;
  }
  combatState.active = active;
  if (!stripState.mode) {
    return;
  }
  setCombatActive(active);
}

export function setChatStripEdge(atTop: boolean): void {
  stripState.stripAtTop = atTop;
}

export function settleChatStripAfterDrag(): void {
  if (!stripState.collapsed || !stripState.fullRect) {
    return;
  }
  stripState.settling = true;
  Promise.all([
    Byond.winget('browseroutput', ['pos', 'size']),
    Byond.winget('mapwindow', ['size']),
  ]).then(([browser, map]) => {
    stripState.settling = false;
    if (!stripState.collapsed || !stripState.fullRect) {
      return;
    }
    const mapW = map.size.x;
    const mapH = map.size.y;
    if (!mapW || !mapH) {
      return;
    }
    const fullW = stripState.fullRect.w;
    const fullH = stripState.fullRect.h;
    const stripBottom = browser.pos.y + browser.size.y;
    const pxY = stripState.stripAtTop
      ? browser.pos.y
      : stripBottom - Math.round(fullH * mapH);
    let x = browser.pos.x / mapW;
    let y = pxY / mapH;
    x = Math.min(Math.max(x, 0), Math.max(1 - fullW, 0));
    y = Math.min(Math.max(y, 0), Math.max(1 - fullH, 0));
    const rect: RectRatio = { x, y, w: fullW, h: fullH };
    stripState.fullRect = rect;
    saveChatRatioRect(rect);
    if (combatState.active) {
      void refreshCombatBase();
    }
    if (stripState.pendingExpand) {
      stripState.pendingExpand = false;
      if (document.body.matches(':hover')) {
        expandChatFromStrip();
      }
    }
  });
}

export function setChatStripDragging(value: boolean): void {
  stripState.dragging = value;
  if (value || !stripState.mode) {
    return;
  }
  if (stripState.collapsed) {
    if (stripState.pendingExpand) {
      stripState.pendingExpand = false;
      if (document.body.matches(':hover')) {
        expandChatFromStrip();
      }
    }
    return;
  }
  scheduleChatStripCollapse();
}

export function startChatStripPeekResize(e: React.PointerEvent): void {
  if (!stripState.collapsed) {
    return;
  }
  e.preventDefault();
  e.stopPropagation();
  setChatStripDragging(true);
  const target = e.currentTarget as HTMLElement;
  const { pointerId } = e;
  const startScreenY = e.screenY;
  let startPosX = 0;
  let startPosY = 0;
  let startSizeH = 0;
  let startWidth = 0;
  let mapW = 0;
  let mapH = 0;
  let maxHeight = Infinity;
  let skinPerCss = window.devicePixelRatio ?? 1;
  let ready = false;
  let latest: PointerEvent | null = null;
  let finished = false;
  let appliedH = stripState.peekHeight;

  const heightAt = (screenY: number): number => {
    const dy = (screenY - startScreenY) * skinPerCss;
    return startSizeH + (stripState.stripAtTop ? dy : -dy);
  };

  const applyHeight = (newH: number) => {
    if (!ready) {
      return;
    }
    const h = Math.max(MIN_PEEK_HEIGHT, Math.min(newH, maxHeight));
    appliedH = h;
    const stripBottom = startPosY + startSizeH;
    const y = stripState.stripAtTop ? startPosY : stripBottom - h;
    if (mapW && mapH) {
      winsetChatRect(startPosX, y, startWidth, h, mapW, mapH);
    } else {
      Byond.winset('browseroutput', {
        pos: `${startPosX},${y}`,
        size: `${startWidth}x${h}`,
      });
    }
  };

  const handleMove = (ev: PointerEvent) => {
    if (ev.pointerId !== pointerId) {
      return;
    }
    ev.preventDefault();
    latest = ev;
    applyHeight(heightAt(ev.screenY));
  };

  const finish = (ev: PointerEvent) => {
    if (finished || ev.pointerId !== pointerId) {
      return;
    }
    finished = true;
    if (latest) {
      applyHeight(heightAt(latest.screenY));
    }
    target.removeEventListener('pointermove', handleMove);
    target.removeEventListener('pointerup', finish);
    target.removeEventListener('pointercancel', finish);
    target.removeEventListener('lostpointercapture', finish);
    try {
      target.releasePointerCapture(pointerId);
    } catch {
    }
    stripState.peekHeight = appliedH;
    storage.set(PEEK_HEIGHT_KEY, appliedH);
    setChatStripDragging(false);
  };

  try {
    target.setPointerCapture(pointerId);
  } catch {
  }
  target.addEventListener('pointermove', handleMove);
  target.addEventListener('pointerup', finish);
  target.addEventListener('pointercancel', finish);
  target.addEventListener('lostpointercapture', finish);

  Promise.all([
    Byond.winget('browseroutput', ['pos', 'size']),
    Byond.winget('mapwindow', ['size']),
  ]).then(([browser, map]) => {
    if (finished) {
      return;
    }
    startPosX = browser.pos.x;
    startPosY = browser.pos.y;
    startSizeH = browser.size.y;
    startWidth = browser.size.x;
    mapW = map.size.x;
    mapH = map.size.y;
    const cssH = window.innerHeight;
    if (cssH > 0 && startSizeH > 0) {
      skinPerCss = startSizeH / cssH;
    }
    ready = true;
    maxHeight = stripState.fullRect
      ? Math.round(stripState.fullRect.h * mapH)
      : Infinity;
    if (latest) {
      applyHeight(heightAt(latest.screenY));
    }
  });
}

chatRenderer.events.on('batchProcessed', () => {
  if (!stripState.collapsed) {
    return;
  }
  const now = Date.now();
  if (now - lastPingAt >= PING_MIN_INTERVAL) {
    lastPingAt = now;
    const strip = document.querySelector('.ChatHoverStrip');
    if (strip instanceof HTMLElement) {
      strip.classList.remove('ChatHoverStrip--ping');
      void strip.offsetWidth;
      strip.classList.add('ChatHoverStrip--ping');
    }
  }
  if (combatState.active) {
    scheduleCombatFit();
  }
});
