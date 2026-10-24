import { storage } from 'common/storage';
import { store } from '../events/store';
import { settingsVisibleAtom } from '../settings/atoms';
import { saveChatRatioRect } from './chat-ratio';
import {
  afterNextResize,
  clampedRectRatio,
  restickAfterNextResize,
  winsetChatRect,
} from './chat-strip-geometry';
import {
  clearCombatState,
  COMBAT_MIN_HEIGHT,
  combatTargetH,
  measureCombatOverheadCss,
  refreshCombatBase,
  scheduleCombatFit,
  setCombatActive,
  startTailObserver,
} from './chat-strip-combat';
import {
  clearYieldTracking,
  configureStripYield,
  scheduleYieldCheck,
} from './chat-strip-yield';
import { combatState, RectRatio, stripState, yieldState } from './chat-strip-state';
import { chatRenderer } from './renderer';

export { onPanelWindowOpened, onPanelWindowClosed } from './chat-strip-yield';

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
  if (yieldState.displaced) {
    scheduleYieldCheck();
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
      stripState.chromeHovered ||
      yieldState.displaced
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
    clearYieldTracking();
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

configureStripYield({
  isStripMode: () => stripState.mode,
  isChromeHovered: () => stripState.chromeHovered,
  collapse: (bypassHover?: boolean) => collapseChatToStrip(bypassHover),
  requestExpand: () => requestChatStripExpand(),
});
