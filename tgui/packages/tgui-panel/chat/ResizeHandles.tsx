import type { ChatCorner } from '../settings/constants';
import { anchorsForRect } from './chat-strip-geometry';
import {
  isChatStripCollapsed,
  setChatStripDragging,
  settleChatStripAfterDrag,
} from './chat-hover-strip';
import { saveChatRatio } from './chat-ratio';

const MIN_WIDTH = 200;
const MIN_HEIGHT = 100;

type Point = [number, number];
type WinsetGeometry = { pos?: string; size?: string };

let winsetTarget = 'browseroutput';
let pendingWinset: WinsetGeometry = {};
let dragBounds: Point | null = null;
let winsetRaf: number | undefined;

function flushWinset() {
  winsetRaf = undefined;
  if (pendingWinset.pos || pendingWinset.size) {
    Byond.winset(winsetTarget, pendingWinset);
    pendingWinset = {};
  }
}

function scheduleWinset() {
  if (winsetRaf === undefined) {
    winsetRaf = requestAnimationFrame(flushWinset);
  }
}

function updateAnchors() {
  if (winsetTarget !== 'browseroutput') {
    return;
  }
  Promise.all([
    Byond.winget('browseroutput', ['pos', 'size']),
    Byond.winget('mapwindow', ['size']),
  ]).then(([browser, map]) => {
    const mapW = map.size.x;
    const mapH = map.size.y;
    if (!mapW || !mapH) {
      return;
    }
    Byond.winset(
      'browseroutput',
      anchorsForRect(
        browser.pos.x,
        browser.pos.y,
        browser.size.x,
        browser.size.y,
        mapW,
        mapH,
      ),
    );
  });
}

function endDragBatch() {
  if (winsetRaf !== undefined) {
    cancelAnimationFrame(winsetRaf);
    winsetRaf = undefined;
  }
  flushWinset();
  if (winsetTarget === 'browseroutput') {
    const stripDrag = isChatStripCollapsed();
    updateAnchors();
    if (stripDrag) {
      settleChatStripAfterDrag();
    } else {
      saveChatRatio();
    }
  }
  setChatStripDragging(false);
}

function clampToMap(
  x: number,
  y: number,
  w: number,
  h: number,
  mapW: number,
  mapH: number,
  move: boolean,
): [number, number, number, number] {
  const clampAxis = (start: number, len: number, max: number) => {
    if (move) {
      const clampedLen = Math.min(len, max);
      return [Math.min(Math.max(start, 0), max - clampedLen), clampedLen] as const;
    }
    const lo = Math.max(start, 0);
    const hi = Math.min(start + len, max);
    return [lo, Math.max(hi - lo, 0)] as const;
  };
  const [cx, cw] = clampAxis(x, w, mapW);
  const [cy, ch] = clampAxis(y, h, mapH);
  return [cx, cy, cw, ch];
}

function applyGeometry(pos: string, size: string, move = false) {
  if (dragBounds) {
    const [x, y] = pos.split(',').map(Number);
    const [w, h] = size.split('x').map(Number);
    const [cx, cy, cw, ch] = clampToMap(
      x,
      y,
      w,
      h,
      dragBounds[0],
      dragBounds[1],
      move,
    );
    pos = `${cx},${cy}`;
    size = `${cw}x${ch}`;
  }
  pendingWinset.pos = pos;
  pendingWinset.size = size;
  scheduleWinset();
}

function startDrag(
  e: React.PointerEvent,
  onMove: (dx: number, dy: number, startPos: Point, startSize: Point) => void,
  target: string,
) {
  e.preventDefault();
  winsetTarget = target;
  setChatStripDragging(true);
  const captureTarget = e.currentTarget as HTMLElement;
  const { pointerId } = e;
  const startScreenX = e.screenX;
  const startScreenY = e.screenY;
  let skinPerCss = window.devicePixelRatio ?? 1;

  let startPos: Point | null = null;
  let startSize: Point | null = null;
  let latest: PointerEvent | null = null;
  let finished = false;

  try {
    captureTarget.setPointerCapture(pointerId);
  } catch {
  }

  const apply = (ev: PointerEvent) => {
    if (!startPos || !startSize) {
      return;
    }
    onMove(
      (ev.screenX - startScreenX) * skinPerCss,
      (ev.screenY - startScreenY) * skinPerCss,
      startPos,
      startSize,
    );
  };

  const handleMove = (ev: PointerEvent) => {
    if (ev.pointerId !== pointerId) {
      return;
    }
    ev.preventDefault();
    latest = ev;
    apply(ev);
  };

  const finish = (ev: PointerEvent) => {
    if (finished || ev.pointerId !== pointerId) {
      return;
    }
    finished = true;
    if (latest) {
      apply(latest);
    }
    captureTarget.removeEventListener('pointermove', handleMove);
    captureTarget.removeEventListener('pointerup', finish);
    captureTarget.removeEventListener('pointercancel', finish);
    captureTarget.removeEventListener('lostpointercapture', finish);
    try {
      captureTarget.releasePointerCapture(pointerId);
    } catch {
    }
    endDragBatch();
  };

  captureTarget.addEventListener('pointermove', handleMove);
  captureTarget.addEventListener('pointerup', finish);
  captureTarget.addEventListener('pointercancel', finish);
  captureTarget.addEventListener('lostpointercapture', finish);

  dragBounds = null;
  const onMap = winsetTarget === 'browseroutput';
  Promise.all([
    Byond.winget(winsetTarget, ['pos', 'size']),
    onMap ? Byond.winget('mapwindow', ['size']) : Promise.resolve(null),
  ]).then(([props, map]) => {
    if (finished) {
      return;
    }
    if (map?.size.x && map?.size.y) {
      dragBounds = [map.size.x, map.size.y];
    }
    startPos = [props.pos.x, props.pos.y];
    startSize = [props.size.x, props.size.y];
    const cssH = window.innerHeight;
    if (cssH > 0 && props.size.y > 0) {
      skinPerCss = props.size.y / cssH;
    }
    if (latest) {
      apply(latest);
    }
  });
}

function resizeLeft(dx: number, startPos: Point, startSize: Point) {
  const newW = Math.max(startSize[0] - dx, MIN_WIDTH);
  return {
    pos: `${startPos[0] + (startSize[0] - newW)},${startPos[1]}`,
    size: `${newW}x${startSize[1]}`,
  };
}

function resizeRight(dx: number, startPos: Point, startSize: Point) {
  return { size: `${Math.max(startSize[0] + dx, MIN_WIDTH)}x${startSize[1]}` };
}

function resizeTop(dy: number, startPos: Point, startSize: Point) {
  const newH = Math.max(startSize[1] - dy, MIN_HEIGHT);
  return {
    pos: `${startPos[0]},${startPos[1] + (startSize[1] - newH)}`,
    size: `${startSize[0]}x${newH}`,
  };
}

function resizeBottom(dy: number, startPos: Point, startSize: Point) {
  return { size: `${startSize[0]}x${Math.max(startSize[1] + dy, MIN_HEIGHT)}` };
}

type EdgeResizer = (
  delta: number,
  startPos: Point,
  startSize: Point,
) => WinsetGeometry & { size: string };

function makeEdgeHandler(
  resize: EdgeResizer,
  axis: 'x' | 'y',
  target: string,
) {
  return (e: React.PointerEvent) =>
    startDrag(
      e,
      (dx, dy, startPos, startSize) => {
        const result = resize(axis === 'x' ? dx : dy, startPos, startSize);
        applyGeometry(
          result.pos ?? `${startPos[0]},${startPos[1]}`,
          result.size,
        );
      },
      target,
    );
}

function makeCornerHandler(
  horizontal: EdgeResizer,
  vertical: EdgeResizer,
  target: string,
) {
  return (e: React.PointerEvent) =>
    startDrag(
      e,
      (dx, dy, startPos, startSize) => {
        const hResult = horizontal(dx, startPos, startSize);
        const vResult = vertical(dy, startPos, startSize);
        const newX = hResult.pos?.split(',')[0] ?? `${startPos[0]}`;
        const newY = vResult.pos?.split(',')[1] ?? `${startPos[1]}`;
        applyGeometry(
          `${newX},${newY}`,
          `${hResult.size.split('x')[0]}x${vResult.size.split('x')[1]}`,
        );
      },
      target,
    );
}

export function startPopupMove(e: React.PointerEvent) {
  startDrag(
    e,
    (dx, dy, startPos, startSize) => {
      applyGeometry(
        `${startPos[0] + dx},${startPos[1] + dy}`,
        `${startSize[0]}x${startSize[1]}`,
      );
    },
    'tgui_panel_popup',
  );
}

export function startChatMove(e: React.PointerEvent) {
  startDrag(
    e,
    (dx, dy, startPos, startSize) => {
      applyGeometry(
        `${startPos[0] + dx},${startPos[1] + dy}`,
        `${startSize[0]}x${startSize[1]}`,
        true,
      );
    },
    'browseroutput',
  );
}

type Props = {
  corner?: ChatCorner;
  target?: string;
  allEdges?: boolean;
};

export function ResizeHandles({
  corner,
  target = 'browseroutput',
  allEdges = false,
}: Props) {

  if (allEdges) {
    return (
      <>
        <div
          className="ResizeHandle ResizeHandle--left"
          onPointerDown={makeEdgeHandler(resizeLeft, 'x', target)}
        />
        <div
          className="ResizeHandle ResizeHandle--right"
          onPointerDown={makeEdgeHandler(resizeRight, 'x', target)}
        />
        <div
          className="ResizeHandle ResizeHandle--top"
          onPointerDown={makeEdgeHandler(resizeTop, 'y', target)}
        />
        <div
          className="ResizeHandle ResizeHandle--bottom"
          onPointerDown={makeEdgeHandler(resizeBottom, 'y', target)}
        />
        <div
          className="ResizeHandle ResizeHandle--top-left"
          style={{ cursor: 'nwse-resize' }}
          onPointerDown={makeCornerHandler(resizeLeft, resizeTop, target)}
        />
        <div
          className="ResizeHandle ResizeHandle--top-right"
          style={{ cursor: 'nesw-resize' }}
          onPointerDown={makeCornerHandler(resizeRight, resizeTop, target)}
        />
        <div
          className="ResizeHandle ResizeHandle--bottom-left"
          style={{ cursor: 'nesw-resize' }}
          onPointerDown={makeCornerHandler(resizeLeft, resizeBottom, target)}
        />
        <div
          className="ResizeHandle ResizeHandle--bottom-right"
          style={{ cursor: 'nwse-resize' }}
          onPointerDown={makeCornerHandler(resizeRight, resizeBottom, target)}
        />
      </>
    );
  }

  const isLeft = corner?.includes('left') ?? false;
  const isTop = corner?.includes('top') ?? true;
  const hEdge = isLeft ? 'right' : 'left';
  const vEdge = isTop ? 'bottom' : 'top';
  const diagonalCursor =
    (isTop && isLeft) || (!isTop && !isLeft) ? 'nwse-resize' : 'nesw-resize';

  return (
    <>
      <div
        className={`ResizeHandle ResizeHandle--${hEdge}`}
        onPointerDown={makeEdgeHandler(
          isLeft ? resizeRight : resizeLeft,
          'x',
          target,
        )}
      />
      <div
        className={`ResizeHandle ResizeHandle--${vEdge}`}
        onPointerDown={makeEdgeHandler(
          isTop ? resizeBottom : resizeTop,
          'y',
          target,
        )}
      />
      <div
        className={`ResizeHandle ResizeHandle--${vEdge}-${hEdge}`}
        style={{ cursor: diagonalCursor }}
        onPointerDown={makeCornerHandler(
          isLeft ? resizeRight : resizeLeft,
          isTop ? resizeBottom : resizeTop,
          target,
        )}
      />
    </>
  );
}
