import { useAtomValue } from 'jotai';
import { useEffect, useState } from 'react';
import { panelLayoutAtom } from '../events/handlers/layout';
import { settingsAtom, settingsLoadedAtom } from '../settings/atoms';
import type { ChatCorner } from '../settings/constants';
import {
  isChatStripCollapsed,
  refreshCombatBase,
  stripState,
  anchorsForRect,
  winsetChatRectClamped,
} from './chat-hover-strip';
import {
  loadChatRatio,
  saveChatRatioRect,
  type ChatRatio,
} from './chat-ratio';
import { chatRenderer } from './renderer';

const DEFAULT_W_RATIO = 1 / 3;
const DEFAULT_H_RATIO = 1 / 3;

const EDGE_PADDING = 10;

function defaultPosition(
  corner: ChatCorner,
  screenX: number,
  screenY: number,
  browserW: number,
  browserH: number,
): { x: number; y: number } {
  switch (corner) {
    case 'top-left':
      return { x: EDGE_PADDING, y: 0 };
    case 'bottom-left':
      return { x: EDGE_PADDING, y: screenY - browserH };
    case 'bottom-right':
      return {
        x: screenX - (browserW + EDGE_PADDING),
        y: screenY - browserH,
      };
    case 'top-right':
    default:
      return {
        x: screenX - (browserW + EDGE_PADDING),
        y: 0,
      };
  }
}

function setAnchors(
  browserX: number,
  browserY: number,
  browserW: number,
  browserH: number,
  mapW: number,
  mapH: number,
) {
  Byond.winset(
    'browseroutput',
    anchorsForRect(browserX, browserY, browserW, browserH, mapW, mapH),
  );
}

let initialCorner: ChatCorner | null = null;

export function useChatPlacement() {
  const [isOnMap, setIsOnMap] = useState(false);
  const [isPopup, setIsPopup] = useState(false);
  const settings = useAtomValue(settingsAtom);
  const settingsLoaded = useAtomValue(settingsLoadedAtom);
  const panelLayout = useAtomValue(panelLayoutAtom);
  const chatCorner = (settings.chatCorner || 'top-right') as ChatCorner;
  const chatOpacity = settings.chatOpacity ?? 0.45;

  useEffect(() => {
    document.body.style.setProperty('--chat-opacity', `${chatOpacity}`);
  }, [chatOpacity]);

  useEffect(() => {
    if (!settingsLoaded) {
      return;
    }

    const settingChanged =
      initialCorner !== null && initialCorner !== chatCorner;
    initialCorner = chatCorner;

    const markOnMap = () => {
      document.body.classList.add('onmap');
      document.body.style.backgroundColor = 'transparent';
      setIsOnMap(true);
    };

    const place = () => {
      loadChatRatio()
        .then((saved) =>
          Promise.all([
            saved,
            Byond.winget('mapwindow', ['size']) as Promise<{
              size: { x: number; y: number };
            }>,
          ]),
        )
        .then(([saved, map]) => {
          const screenX = map.size.x;
          const screenY = map.size.y;
          if (!screenX || !screenY) {
            return;
          }

          let browserW: number;
          let browserH: number;
          let browserX: number;
          let browserY: number;

          if (saved) {
            browserW = Math.round(screenX * saved.w);
            browserH = Math.round(screenY * saved.h);
            browserX = Math.round(screenX * saved.x);
            browserY = Math.round(screenY * saved.y);
          } else {
            browserW = Math.round(screenX * DEFAULT_W_RATIO);
            browserH = Math.round(screenY * DEFAULT_H_RATIO);
            const pos = defaultPosition(
              chatCorner,
              screenX,
              screenY,
              browserW,
              browserH,
            );
            browserX = pos.x;
            browserY = pos.y;
          }

          Byond.winset('browseroutput', {
            size: `${browserW}x${browserH}`,
            pos: `${browserX},${browserY}`,
          });
          setAnchors(browserX, browserY, browserW, browserH, screenX, screenY);

          markOnMap();
        });
    };

    const placeAtCorner = () => {
      Promise.all([
        Byond.winget('browseroutput', ['size']),
        Byond.winget('mapwindow', ['size']),
      ]).then(([browser, map]) => {
        const screenX = map.size.x;
        const screenY = map.size.y;
        if (!screenX || !screenY) {
          return;
        }
        const stripW = browser.size.x;
        const stripH = browser.size.y;
        const collapsed = isChatStripCollapsed();
        let fullW = stripW;
        let fullH = stripH;
        if (collapsed && stripState.fullRect) {
          fullW = Math.round(stripState.fullRect.w * screenX);
          fullH = Math.round(stripState.fullRect.h * screenY);
        }
        const pos = defaultPosition(
          chatCorner,
          screenX,
          screenY,
          fullW,
          fullH,
        );
        const atTop = chatCorner.startsWith('top');
        const y = collapsed && !atTop ? pos.y + fullH - stripH : pos.y;
        Byond.winset('browseroutput', {
          pos: `${pos.x},${y}`,
        });
        setAnchors(pos.x, y, stripW, stripH, screenX, screenY);
        const ratio: ChatRatio = {
          x: pos.x / screenX,
          y: pos.y / screenY,
          w: fullW / screenX,
          h: fullH / screenY,
        };
        if (collapsed) {
          stripState.fullRect = ratio;
          void refreshCombatBase();
          const cssH = window.innerHeight;
          const scale = cssH > 0 && stripH > 0 ? stripH / cssH : 1;
          chatRenderer.setViewportShift(
            atTop ? 0 : (stripH - fullH) / scale,
          );
        }
        saveChatRatioRect(ratio);
        markOnMap();
      });
    };

    Byond.winget('browseroutput', 'parent').then((browserParent) => {
      if (browserParent === 'mapwindow') {
        if (settingChanged) {
          placeAtCorner();
        } else {
          place();
        }
      } else if (browserParent === 'output_browser') {
        document.body.classList.remove('onmap');
        setIsOnMap(false);
        setIsPopup(false);
        Byond.winget('output_browser', ['size']).then(
          (outputBrowserWindowProperties) => {
            Byond.winset('browseroutput', {
              size: `${outputBrowserWindowProperties.size.x}x${outputBrowserWindowProperties.size.y}`,
            });
          },
        );
      } else if (browserParent === 'tgui_panel_popup') {
        document.body.classList.remove('onmap');
        setIsOnMap(false);
        setIsPopup(true);
      }
    });
  }, [chatCorner, settingsLoaded, panelLayout]);

  useEffect(() => {
    if (!isOnMap) {
      return;
    }
    let timer: ReturnType<typeof setTimeout> | undefined;
    const check = () => {
      timer = undefined;
      if (stripState.dragging) {
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
        const { x, y } = browser.pos;
        const w = browser.size.x;
        const h = browser.size.y;
        const outside =
          x < -1 || y < -1 || x + w > mapW + 1 || y + h > mapH + 1;
        if (outside) {
          winsetChatRectClamped(x, y, w, h);
        }
      });
    };
    const schedule = () => {
      if (timer !== undefined) {
        clearTimeout(timer);
      }
      timer = setTimeout(check, 250);
    };
    window.addEventListener('resize', schedule);
    return () => {
      window.removeEventListener('resize', schedule);
      if (timer !== undefined) {
        clearTimeout(timer);
      }
    };
  }, [isOnMap]);

  return { isOnMap, isPopup, chatCorner };
}
