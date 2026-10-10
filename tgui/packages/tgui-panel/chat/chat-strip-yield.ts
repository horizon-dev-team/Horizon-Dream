import { rectsOverlap } from './chat-strip-geometry';
import { RectPx, stripState, yieldState } from './chat-strip-state';

type StripYieldDeps = {
  isStripMode: () => boolean;
  isChromeHovered: () => boolean;
  collapse: (bypassHover?: boolean) => void;
  requestExpand: () => void;
};

let deps: StripYieldDeps | null = null;
let yieldTimers: ReturnType<typeof setTimeout>[] = [];

export function configureStripYield(d: StripYieldDeps): void {
  deps = d;
}

async function chatRectForYield(): Promise<RectPx | null> {
  const parent = await Byond.winget('browseroutput', 'parent');
  if (parent !== 'mapwindow') {
    return null;
  }
  const [main, map, browser, mapSize] = await Promise.all([
    Byond.winget('mainwindow', ['pos']).catch(() => null),
    Byond.winget('mapwindow', ['pos']),
    Byond.winget('browseroutput', ['pos', 'size']),
    Byond.winget('mapwindow', ['size']),
  ]);
  const mapW = mapSize.size.x;
  const mapH = mapSize.size.y;
  if (!mapW || !mapH) {
    return null;
  }
  const originX = main ? main.pos.x : 0;
  const originY = main ? main.pos.y : 0;
  if (stripState.collapsed && stripState.fullRect) {
    return {
      x: originX + map.pos.x + Math.round(stripState.fullRect.x * mapW),
      y: originY + map.pos.y + Math.round(stripState.fullRect.y * mapH),
      w: Math.round(stripState.fullRect.w * mapW),
      h: Math.round(stripState.fullRect.h * mapH),
    };
  }
  return {
    x: originX + map.pos.x + browser.pos.x,
    y: originY + map.pos.y + browser.pos.y,
    w: browser.size.x,
    h: browser.size.y,
  };
}

async function windowRect(id: string): Promise<RectPx | null> {
  try {
    const win = await Byond.winget(id, ['pos', 'size']);
    if (!win || !win.pos || !win.size) {
      return null;
    }
    return {
      x: win.pos.x,
      y: win.pos.y,
      w: win.size.x,
      h: win.size.y,
    };
  } catch {
    return null;
  }
}

async function runYieldCheck(): Promise<void> {
  if (!deps || !deps.isStripMode()) {
    return;
  }
  const chatRect = await chatRectForYield();
  if (!chatRect) {
    yieldState.displaced = false;
    return;
  }
  let anyOverlap = false;
  for (const id of yieldState.windows) {
    const rect = await windowRect(id);
    if (rect && rectsOverlap(chatRect, rect)) {
      anyOverlap = true;
      break;
    }
  }
  if (anyOverlap) {
    yieldState.displaced = true;
    deps.collapse(true);
    return;
  }
  if (yieldState.displaced) {
    yieldState.displaced = false;
    if (document.body.matches(':hover') && !deps.isChromeHovered()) {
      deps.requestExpand();
    }
  }
}

export function scheduleYieldCheck(): void {
  for (const timer of yieldTimers) {
    clearTimeout(timer);
  }
  yieldTimers = [];
  yieldTimers.push(setTimeout(() => void runYieldCheck(), 250));
  yieldTimers.push(setTimeout(() => void runYieldCheck(), 900));
}

export function clearYieldTracking(): void {
  for (const timer of yieldTimers) {
    clearTimeout(timer);
  }
  yieldTimers = [];
  yieldState.windows.clear();
  yieldState.displaced = false;
}

export function onPanelWindowOpened(id: string): void {
  if (!deps || !deps.isStripMode() || !id) {
    return;
  }
  yieldState.windows.add(id);
  scheduleYieldCheck();
}

export function onPanelWindowClosed(id: string): void {
  if (!id) {
    return;
  }
  yieldState.windows.delete(id);
  if (yieldState.windows.size === 0) {
    scheduleYieldCheck();
  }
}
