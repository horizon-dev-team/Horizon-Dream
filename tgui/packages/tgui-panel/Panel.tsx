/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @edit 2026 KOCMOHABT
 * @license MIT
 */

import { useAtom, useAtomValue } from 'jotai';
import { useCallback, useEffect, useRef } from 'react';
import { Pane } from 'tgui/layouts';
import { Button, Icon, Section, Stack } from 'tgui-core/components';
import { visibleAtom } from './audio/atoms';
import { NowPlayingWidget } from './audio/NowPlayingWidget';
import { ChatPanel } from './chat/ChatPanel';
import { ChatTabs } from './chat/ChatTabs';
import {
  cancelChatStripCollapse,
  expandChatFromStrip,
  isChatStripCollapsed,
  requestChatStripExpand,
  scheduleChatStripCollapse,
  setChatStripCombat,
  setChatStripEdge,
  setChatStripMode,
  setStripChromeHovered,
  startChatStripPeekResize,
} from './chat/chat-hover-strip';
import { useChatPersistence } from './chat/use-chat-persistence';
import { useChatPlacement } from './chat/use-chat-placement';
import { chatRenderer } from './chat/renderer';
import { gameAtom } from './game/atoms';
import { useKeepAlive } from './game/use-keep-alive';
import { Notifications } from './Notifications';
import { PingIndicator } from './ping/PingIndicator';
import { ReconnectButton } from './reconnect';
import { settingsVisibleAtom } from './settings/atoms';
import { SettingsPanel } from './settings/SettingsPanel';
import { useSettings } from './settings/use-settings';
import { ResizeHandles, startChatMove, startPopupMove } from './chat/ResizeHandles';
import { CommandBar } from './verbs/CommandBar';

const CHAT_BODY_CLASSES = [
  'frameless',
  'frameless-visible',
  'chat-message-bg',
  'chat-top',
  'chat-stripmode',
  'chat-panels-open',
];

function clearChatBodyClasses(body: HTMLElement) {
  body.classList.remove(...CHAT_BODY_CLASSES);
}

export function Panel(props) {
  const [audioVisible, setAudioVisible] = useAtom(visibleAtom);
  const game = useAtomValue(gameAtom);
  const { settings, updateSettings } = useSettings();
  const [settingsVisible, setSettingsVisible] = useAtom(settingsVisibleAtom);
  useChatPersistence();
  const { isOnMap, isPopup, chatCorner } = useChatPlacement();
  useKeepAlive();

  const frameless = isOnMap && settings.chatFrameless;
  const chatTop = frameless && chatCorner.startsWith('top');
  const messageBg = frameless && settings.chatMessageBg;
  const hoverStrip = frameless && settings.chatHoverStrip;
  const combatStrip = hoverStrip && !!settings.chatCombatStrip;

  const settingsVisibleRef = useRef(settingsVisible);
  useEffect(() => {
    settingsVisibleRef.current = settingsVisible;
  }, [settingsVisible]);

  useEffect(() => {
    const body = document.body;
    if (!frameless) {
      clearChatBodyClasses(body);
      chatRenderer.setFrameless(false);
      return;
    }
    body.classList.add('frameless');
    chatRenderer.setFrameless(true);
    return () => {
      clearChatBodyClasses(body);
      chatRenderer.setFrameless(false);
    };
  }, [frameless]);

  useEffect(() => {
    const body = document.body;
    body.classList.toggle('chat-message-bg', frameless && !!messageBg);
    body.classList.toggle('chat-top', frameless && chatTop);
    body.classList.toggle('chat-stripmode', frameless && hoverStrip);
    body.classList.toggle(
      'chat-panels-open',
      frameless && (settingsVisible || audioVisible),
    );
    body.classList.toggle(
      'frameless-visible',
      frameless &&
        (hoverStrip
          ? settingsVisible ||
            (body.matches(':hover') && !isChatStripCollapsed())
          : body.matches(':hover') || settingsVisible),
    );
  }, [
    frameless,
    messageBg,
    chatTop,
    hoverStrip,
    settingsVisible,
    audioVisible,
  ]);

  useEffect(() => {
    if (!frameless) {
      return;
    }
    const body = document.body;
    const show = () => {
      const wasCollapsed = isChatStripCollapsed();
      if (hoverStrip) {
        requestChatStripExpand();
        if (wasCollapsed) {
          return;
        }
      } else {
        body.classList.add('frameless-visible');
      }
      if (wasCollapsed) {
        chatRenderer.scrollToBottom();
      }
    };
    const hide = () => {
      if (!settingsVisibleRef.current) {
        body.classList.remove('frameless-visible');
      }
      if (hoverStrip) {
        scheduleChatStripCollapse();
      }
    };
    body.addEventListener('mouseenter', show);
    body.addEventListener('mouseleave', hide);
    return () => {
      body.removeEventListener('mouseenter', show);
      body.removeEventListener('mouseleave', hide);
    };
  }, [frameless, hoverStrip]);

  useEffect(() => {
    setChatStripEdge(chatTop);
    setChatStripCombat(combatStrip);
    chatRenderer.setReversed(frameless && chatTop);
    if (!frameless) {
      setChatStripMode(false);
      return;
    }
    setChatStripMode(hoverStrip);
    return () => {
      setChatStripMode(false);
      setChatStripCombat(false);
      chatRenderer.setReversed(false);
    };
  }, [frameless, chatTop, hoverStrip, combatStrip]);

  useEffect(() => {
    if (!frameless || !hoverStrip) {
      return;
    }
    if (settingsVisible) {
      if (isChatStripCollapsed()) {
        expandChatFromStrip();
      }
    } else {
      scheduleChatStripCollapse();
    }
  }, [frameless, hoverStrip, settingsVisible]);

  const onHeaderDrag = useCallback((e: React.PointerEvent) => {
    if (
      (e.target as HTMLElement).closest(
        'button, a, input, [role="button"], .Button, .Tab, .Dropdown',
      )
    ) {
      return;
    }
    startChatMove(e);
  }, []);

  return (
    <>
      {isOnMap && (hoverStrip || chatTop) && (
        <div
          className={`ChatHoverStrip${chatTop ? ' ChatHoverStrip--top' : ''}`}
          onMouseEnter={() => {
            setStripChromeHovered(true);
            requestChatStripExpand();
          }}
          onMouseLeave={() => {
            setStripChromeHovered(false);
          }}
          onClick={() => {
            cancelChatStripCollapse();
            expandChatFromStrip();
          }}
          onPointerDown={startChatMove}
        >
          <Icon name={chatTop ? 'chevron-down' : 'chevron-up'} />
          <span className="ChatHoverStrip__ping" />
        </div>
      )}

      {isOnMap && hoverStrip && !combatStrip && (
        <div
          className={`ChatPeekEdge${chatTop ? ' ChatPeekEdge--top' : ''}`}
          title="Drag to set how much of the chat stays visible"
          onMouseEnter={() => {
            setStripChromeHovered(true);
            requestChatStripExpand();
          }}
          onMouseLeave={() => {
            setStripChromeHovered(false);
          }}
          onPointerDown={startChatStripPeekResize}
        >
          <span className="ChatPeekEdge__pill" />
        </div>
      )}
      <Pane theme={settings.theme} canSuspend={false}>
        {isOnMap && <ResizeHandles corner={chatCorner} />}
        {isPopup && (
          <>
            <ResizeHandles allEdges target="tgui_panel_popup" />
            <div className="PanelDragBar" onPointerDown={startPopupMove} />
          </>
        )}
        <Stack fill vertical className="Panel__stack">
          <Stack.Item>
            <Section fitted className="Panel__header">
              <div
                onPointerDown={isOnMap ? onHeaderDrag : undefined}
                style={isOnMap ? { cursor: 'grab' } : undefined}
              >
                <Stack mr={1} align="center">
                  <Stack.Item grow>
                    <ChatTabs />
                  </Stack.Item>
                  <Stack.Item>
                    <PingIndicator />
                  </Stack.Item>
                <Stack.Item>
                  <Button
                    color="transparent"
                    icon={isOnMap ? 'window-maximize' : 'columns'}
                    tooltip={isOnMap ? 'Switch to window' : 'Switch to overlay'}
                    tooltipPosition="bottom-start"
                    onClick={() => {
                      Byond.sendMessage('panel/toggle_layout');
                    }}
                  />
                </Stack.Item>
                {isOnMap && (
                  <Stack.Item>
                    <Button
                      color="transparent"
                      icon={settings.chatFrameless ? 'eye-slash' : 'eye'}
                      tooltip={
                        settings.chatFrameless
                          ? 'Show chat frame'
                          : 'Hide chat frame'
                      }
                      tooltipPosition="bottom-start"
                      onClick={() =>
                        updateSettings({
                          chatFrameless: !settings.chatFrameless,
                        })
                      }
                    />
                  </Stack.Item>
                )}
                <Stack.Item>
                  <Button
                    color="grey"
                    selected={audioVisible}
                    icon="music"
                    tooltip="Music player"
                    tooltipPosition="bottom-start"
                    onClick={() => setAudioVisible((v) => !v)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon={settingsVisible ? 'times' : 'cog'}
                    selected={settingsVisible}
                    tooltip={settingsVisible ? 'Close settings' : 'Open settings'}
                    tooltipPosition="bottom-start"
                    onClick={() => setSettingsVisible((v) => !v)}
                  />
                </Stack.Item>
              </Stack>
              </div>
            </Section>
          </Stack.Item>
          {audioVisible && (
            <Stack.Item>
              <Section>
                <NowPlayingWidget />
              </Section>
            </Stack.Item>
          )}
          {settingsVisible && (
            <Stack.Item className="Panel__settings">
              <SettingsPanel />
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section fill fitted position="relative">
              <Pane.Content scrollable id="chat-pane">
                <ChatPanel lineHeight={settings.lineHeight} />
              </Pane.Content>
              <Notifications>
                {game.connectionLostAt && (
                  <Notifications.Item rightSlot={<ReconnectButton />}>
                    You are either AFK, experiencing lag or the connection has
                    closed.
                  </Notifications.Item>
                )}
                {game.roundRestartedAt && (
                  <Notifications.Item>
                    The connection has been closed because the server is
                    restarting. Please wait while you automatically reconnect.
                  </Notifications.Item>
                )}
              </Notifications>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <CommandBar />
          </Stack.Item>
        </Stack>
      </Pane>
    </>
  );
}
