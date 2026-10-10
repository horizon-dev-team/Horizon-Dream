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

export const yieldState = {
  displaced: false,
  windows: new Set<string>(),
};
