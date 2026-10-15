import { type MouseEvent, type ReactNode, useEffect, useRef, useState } from 'react';
import { storage } from 'common/storage';
import { Box, Button, Modal, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import {
  loadSoundsEnabled,
  playLoadSound,
  playSelectSound,
  setSoundsEnabled,
} from './audio';

export type ServerState = {
  gamePhase: 'startup' | 'pregame' | 'setting_up' | 'playing' | 'postgame';
  isReady: boolean;
  canReady: boolean;
  canJoin: boolean;
  canObserve: boolean;
  assetsReady: boolean;
  countdown: string;
  playerCount: number;
  readyCount: number;
  adminReadyCount: number;
  adminCount: number;
  mapName: string;
  shiftTime: string;
  isAdmin: boolean;
  isLocalhost: boolean;
  hasNewPoll: boolean;
  canPoll: boolean;
  transparent: boolean;
  characterName: string | null;
  preferenceIssues: string[];
  backgroundUrl: string | null;
  videoUrl: string | null;
  previewUrls: Record<string, string> | null;
};

type LobbyTheme = 'blue' | 'orange';

const FILTER_STORAGE_KEY = 'lobby-filter-disabled';
const THEME_STORAGE_KEY = 'lobby-theme';
const VIDEO_STORAGE_KEY = 'lobby-video-enabled';

const ANIMATION_DISABLE_MS = 10_000;
const LOAD_SOUND_DELAY_MS = 250;
const PREVIEW_DIRS = ['south', 'east', 'north', 'west'] as const;
const PREVIEW_IMG_RETRIES = 12;
const PREVIEW_IMG_RETRY_MS = 400;

const GAME_PHASE_TEXT: Record<ServerState['gamePhase'], string> = {
  startup: 'Starting up',
  pregame: 'Pre-game',
  setting_up: 'Setting up',
  playing: 'Round in progress',
  postgame: 'Round ended',
};

function sendAction(action: string, payload?: Record<string, unknown>) {
  Byond.sendMessage('action', { action, ...payload });
}

/** Paints the page backdrop; the browser element behind it is made see-through by the server when needed */
function applyBackdrop(transparent: boolean) {
  const background = transparent ? 'transparent' : '#000';
  document.documentElement.style.setProperty('--lobby-bg', background);
  document.documentElement.style.backgroundColor = background;
  document.body.style.backgroundColor = background;
}

export function LobbyMenu() {
  const [ss, setSs] = useState<ServerState | null>(null);
  const [fadingOut, setFadingOut] = useState(false);
  const [animationsDisabled, setAnimationsDisabled] = useState(false);
  const [theme, setTheme] = useState<LobbyTheme | undefined>();
  const [filterDisabled, setFilterDisabled] = useState<boolean | undefined>();
  const [videoEnabled, setVideoEnabled] = useState(true);
  const [soundsOn, setSoundsOn] = useState(true);
  const [hidden, setHidden] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    Byond.subscribeTo('init', (payload: ServerState) => {
      setSs(payload);
      setFadingOut(false);
      applyBackdrop(!!payload.transparent);
      videoRef.current?.play()?.catch(() => {});
    });

    Byond.subscribeTo('state', (payload: Partial<ServerState>) => {
      setSs((prev) =>
        prev ? { ...prev, ...payload } : (payload as ServerState),
      );
    });

    // The server makes the browser element see-through right after this, so
    // dropping the page backdrop at the same time cross-fades into the game
    Byond.subscribeTo('fadeOut', () => {
      setFadingOut(true);
      applyBackdrop(true);
    });

    Byond.sendMessage('ready');
  }, []);

  useEffect(() => {
    storage.get(FILTER_STORAGE_KEY).then((val) => setFilterDisabled(!!val));
    storage
      .get(THEME_STORAGE_KEY)
      .then((val) => setTheme(val === 'orange' ? 'orange' : 'blue'));
    storage.get(VIDEO_STORAGE_KEY).then((val) => {
      setVideoEnabled(val === undefined || val === null ? true : !!val);
    });
    loadSoundsEnabled().then((enabled) => {
      setSoundsOn(enabled);
      if (enabled) {
        setTimeout(() => playLoadSound(), LOAD_SOUND_DELAY_MS);
      }
    });
    const timer = setTimeout(
      () => setAnimationsDisabled(true),
      ANIMATION_DISABLE_MS,
    );
    return () => clearTimeout(timer);
  }, []);

  useEffect(() => {
    videoRef.current?.play()?.catch(() => {});
  }, [ss?.videoUrl, videoEnabled, ss?.transparent]);

  if (!ss || theme === undefined || filterDisabled === undefined) {
    return null;
  }

  const crtFilter = !filterDisabled;
  const pregame = ss.gamePhase === 'pregame' || ss.gamePhase === 'startup';
  const typingDelay = (index: number) =>
    animationsDisabled ? '0s' : `${1.5 + index * 0.2}s`;

  return (
    <div
      className={classes([
        'LobbyScreen',
        `LobbyScreen--${theme}`,
        crtFilter && 'filterEnabled',
        animationsDisabled && 'noAnimation',
        fadingOut && 'lobbyFadeOut',
        ss.transparent && 'LobbyScreen--transparent',
      ])}
    >
      {!ss.transparent && ss.backgroundUrl && (
        <div
          className="bgBackground bgLoad"
          style={{ backgroundImage: `url(${ss.backgroundUrl})` }}
        />
      )}

      {!ss.transparent && videoEnabled && ss.videoUrl && (
        <video
          ref={videoRef}
          className="bgVideo"
          src={ss.videoUrl}
          autoPlay
          loop
          muted
          playsInline
        />
      )}

      {crtFilter && !ss.transparent && <div className="crt" />}

      <Stack vertical height="100%" justify="space-around" align="center">
        <Stack.Item>
          <Section
            p={3}
            className="sectionLoad"
            style={{ opacity: hidden ? '0' : '1' }}
          >
            <Stack vertical>
              <Stack.Item>
                <Stack vertical align="center" className="welcomeHolder">
                  <Stack.Item>
                    <Box className="typeEffect styledText">Welcome,</Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Box
                      className="typeEffect styledText"
                      style={{ animationDelay: '1.4s' }}
                    >
                      {ss.characterName || 'Guest'}
                    </Box>
                  </Stack.Item>
                </Stack>
              </Stack.Item>

              <Stack.Item>
                <div className="dividerEffect" />
              </Stack.Item>

              <LobbyButton
                delay={typingDelay(1)}
                icon="file-lines"
                disabled={!ss.assetsReady}
                onClick={() => sendAction('character_setup')}
              >
                Setup Character
              </LobbyButton>

              <LobbyButton
                delay={typingDelay(2)}
                icon="gear"
                disabled={!ss.assetsReady}
                onClick={() => sendAction('settings')}
              >
                Game Preferences
              </LobbyButton>

              <LobbyButton
                delay={typingDelay(3)}
                icon="check-to-slot"
                onClick={() => sendAction('crew_manifest')}
              >
                Crew Manifest
              </LobbyButton>

              <LobbyButton
                delay={typingDelay(4)}
                icon="list-ul"
                onClick={() => sendAction('changelog')}
              >
                Changelog
              </LobbyButton>

              <Stack.Item>
                <div className="dividerEffect" />
              </Stack.Item>

              <LobbyButton
                delay={typingDelay(5)}
                icon="eye"
                disabled={!ss.canObserve}
                onClick={() => sendAction('observe')}
              >
                Observe
              </LobbyButton>

              {!!ss.canReady && (
                <LobbyButton
                  delay={typingDelay(6)}
                  icon={ss.isReady ? 'check' : 'xmark'}
                  selected={ss.isReady}
                  onClick={() => sendAction('ready_toggle')}
                >
                  {ss.isReady ? 'Unready' : 'Ready'}
                </LobbyButton>
              )}

              {!ss.canReady && !!ss.canJoin && (
                <LobbyButton
                  delay={typingDelay(6)}
                  icon="users"
                  onClick={() => sendAction('join')}
                >
                  Join Game
                </LobbyButton>
              )}

              {!!ss.canPoll && (
                <LobbyButton
                  delay={typingDelay(7)}
                  icon="clipboard-list"
                  badge={ss.hasNewPoll ? 'New poll!' : null}
                  onClick={() => sendAction('poll')}
                >
                  Polls
                </LobbyButton>
              )}

              {!!ss.isLocalhost && (
                <LobbyButton
                  delay={typingDelay(8)}
                  icon="forward"
                  onClick={() => sendAction('start_now')}
                >
                  Start Now
                </LobbyButton>
              )}

              <Stack.Item>
                <Button
                  fluid
                  className="hideButton"
                  icon="eye-slash"
                  onClick={() => {
                    playSelectSound();
                    setHidden(true);
                  }}
                >
                  <span className="styledText">Hide Menu</span>
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>

      {hidden && (
        <Box position="absolute" top="10px" left="10px" className="floating">
          <Button
            icon="check"
            onClick={() => {
              playSelectSound();
              setHidden(false);
            }}
          />
        </Box>
      )}

      <CharacterPreview ss={ss} />

      <StatsPanel ss={ss} pregame={pregame} />

      <PreferenceIssues issues={ss.preferenceIssues} />

      <LobbySettings
        ss={ss}
        filterDisabled={filterDisabled}
        setFilterDisabled={setFilterDisabled}
        theme={theme}
        setTheme={setTheme}
        videoEnabled={videoEnabled}
        setVideoEnabled={setVideoEnabled}
        soundsOn={soundsOn}
        setSoundsOn={setSoundsOn}
      />
    </div>
  );
}

function LobbyButton(props: {
  delay: string;
  icon?: string;
  selected?: boolean;
  disabled?: boolean;
  badge?: string | null;
  onClick?: (e: MouseEvent<HTMLButtonElement>) => void;
  children: ReactNode;
}) {
  const { delay, icon, selected, disabled, badge, onClick, children } = props;
  return (
    <Stack.Item className="buttonEffect" style={{ animationDelay: delay }}>
      <Button
        fluid
        className="distinctButton"
        icon={icon}
        selected={selected}
        disabled={disabled}
        onClick={(e) => {
          if (disabled) {
            return;
          }
          playSelectSound();
          onClick?.(e);
        }}
      >
        <span className="styledText">{children}</span>
        {!!badge && <span className="badgeNotification">{badge}</span>}
      </Button>
    </Stack.Item>
  );
}

/** Character preview with client-side direction cycling */
function CharacterPreview({ ss }: { ss: ServerState }) {
  const [dirIndex, setDirIndex] = useState(0);
  const [imgRetry, setImgRetry] = useState(0);

  const urls = ss.previewUrls;
  const dir = PREVIEW_DIRS[dirIndex % PREVIEW_DIRS.length];
  const url = urls ? (urls[dir] ?? Object.values(urls)[0]) : null;

  useEffect(() => {
    setImgRetry(0);
  }, [url]);

  if (!urls || !url) {
    return null;
  }

  return (
    <div className="lobby__preview">
      <div className="lobby__panel-title">Character</div>
      <div className="lobby__preview-body">
        <img
          key={`${url}-${imgRetry}`}
          className="lobby__preview-img"
          src={url}
          alt=""
          onError={() => {
            // The asset may still be in transit right after login; remount
            // the img until the file arrives in the client cache
            if (imgRetry < PREVIEW_IMG_RETRIES) {
              setTimeout(
                () => setImgRetry((n) => n + 1),
                PREVIEW_IMG_RETRY_MS,
              );
            }
          }}
        />
      </div>
      <Stack className="lobby__preview-buttons">
        <Stack.Item grow>
          <Button
            fluid
            compact
            icon="rotate"
            onClick={() => {
              playSelectSound();
              setDirIndex((index) => (index + 1) % PREVIEW_DIRS.length);
            }}
          >
            Rotate
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            compact
            icon="arrows-rotate"
            onClick={() => {
              playSelectSound();
              sendAction('refresh_preview');
            }}
          >
            Refresh
          </Button>
        </Stack.Item>
      </Stack>
    </div>
  );
}

function StatsRow({ label, value }: { label: string; value: string | null }) {
  return (
    <div className="lobby__stats-row">
      <span className="lobby__stats-label">{label}</span>
      <span className="lobby__stats-value">{value || '—'}</span>
    </div>
  );
}

/** Round/server statistics panel on the right edge */
function StatsPanel({ ss, pregame }: { ss: ServerState; pregame: boolean }) {
  return (
    <div className="lobby__stats-holder">
      <div className="lobby__stats">
        <div className="lobby__panel-title">Server</div>
        <StatsRow label="Map" value={ss.mapName} />
        <StatsRow label="Status" value={GAME_PHASE_TEXT[ss.gamePhase]} />
        {pregame ? (
          <StatsRow label="Time left" value={ss.countdown} />
        ) : (
          <StatsRow label="Shift time" value={ss.shiftTime} />
        )}
        <StatsRow label="Players" value={String(ss.playerCount)} />
        <StatsRow label="Ready" value={String(ss.readyCount)} />
        <StatsRow
          label="Admins"
          value={`${ss.adminReadyCount} / ${ss.adminCount}`}
        />
      </div>
    </div>
  );
}

/** CM13-style warnings about the player's current preferences */
function PreferenceIssues({ issues }: { issues: string[] }) {
  if (!issues || issues.length === 0) {
    return null;
  }
  return (
    <div className="messageHolder">
      <Stack vertical justify="flex-end" fill>
        {issues.map((issue, index) => (
          <Section key={index} className="sectionLoad issueSection">
            <Box className="issueText">{issue}</Box>
          </Section>
        ))}
      </Stack>
    </div>
  );
}

/** Settings button (bottom right) and its popup */
function LobbySettings({
  ss,
  filterDisabled,
  setFilterDisabled,
  theme,
  setTheme,
  videoEnabled,
  setVideoEnabled,
  soundsOn,
  setSoundsOn,
}: {
  ss: ServerState;
  filterDisabled: boolean;
  setFilterDisabled: (value: boolean) => void;
  theme: LobbyTheme;
  setTheme: (value: LobbyTheme) => void;
  videoEnabled: boolean;
  setVideoEnabled: (value: boolean) => void;
  soundsOn: boolean;
  setSoundsOn: (value: boolean) => void;
}) {
  const [open, setOpen] = useState(false);

  const pickTheme = (next: LobbyTheme) => {
    playSelectSound();
    setTheme(next);
    storage.set(THEME_STORAGE_KEY, next);
  };

  return (
    <>
      <Box
        position="absolute"
        bottom="10px"
        right="10px"
        className="settingsHolder"
      >
        <Button
          icon="cog"
          onClick={() => {
            playSelectSound();
            setOpen(true);
          }}
        />
      </Box>

      {open && (
        <Modal>
          <Section
            p={3}
            className="settingsModal"
            title="Lobby Settings"
            buttons={
              <Button
                icon="xmark"
                onClick={() => {
                  playSelectSound();
                  setOpen(false);
                }}
              />
            }
          >
            <Stack vertical>
              <SettingsRow label="Theme">
                <Button
                  selected={theme === 'blue'}
                  onClick={() => pickTheme('blue')}
                >
                  Blue
                </Button>
                <Button
                  selected={theme === 'orange'}
                  onClick={() => pickTheme('orange')}
                >
                  Orange
                </Button>
              </SettingsRow>

              <SettingsRow label="CRT filter">
                <Button
                  selected={!filterDisabled}
                  onClick={() => {
                    playSelectSound();
                    const next = !filterDisabled;
                    setFilterDisabled(next);
                    storage.set(FILTER_STORAGE_KEY, next);
                  }}
                >
                  {filterDisabled ? 'Off' : 'On'}
                </Button>
              </SettingsRow>

              <SettingsRow label="Interface sounds">
                <Button
                  selected={soundsOn}
                  onClick={() => {
                    const next = !soundsOn;
                    setSoundsEnabled(next);
                    setSoundsOn(next);
                    if (next) {
                      playSelectSound();
                    }
                  }}
                >
                  {soundsOn ? 'On' : 'Off'}
                </Button>
              </SettingsRow>

              {!!ss.videoUrl && (
                <SettingsRow label="Video background">
                  <Button
                    selected={videoEnabled}
                    onClick={() => {
                      playSelectSound();
                      const next = !videoEnabled;
                      setVideoEnabled(next);
                      storage.set(VIDEO_STORAGE_KEY, next);
                    }}
                  >
                    {videoEnabled ? 'On' : 'Off'}
                  </Button>
                </SettingsRow>
              )}

              <Stack.Item>
                <Button
                  fluid
                  onClick={() => {
                    playSelectSound();
                    setOpen(false);
                  }}
                >
                  Close
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Modal>
      )}
    </>
  );
}

function SettingsRow({
  label,
  children,
}: {
  label: string;
  children: ReactNode;
}) {
  return (
    <Stack.Item>
      <Stack justify="space-between" align="center">
        <Stack.Item className="settingsLabel">{label}</Stack.Item>
        <Stack.Item>
          <Stack>{children}</Stack>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
}
