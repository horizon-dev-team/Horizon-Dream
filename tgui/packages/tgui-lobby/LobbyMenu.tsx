import {
  type CSSProperties,
  type MouseEvent,
  type ReactNode,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
} from 'react';
import { storage } from 'common/storage';
import { Box, Button, Modal, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import {
  loadSoundsEnabled,
  playLoadSound,
  playSelectSound,
  setSoundsEnabled,
} from './audio';
import { updateScaling } from './scaling';

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
  canStartNow: boolean;
  hasNewPoll: boolean;
  canPoll: boolean;
  transparent: boolean;
  characterName: string | null;
  preferenceIssues: string[];
  backgroundUrl: string | null;
  videoUrl: string | null;
  previewUrls: Record<string, string> | null;
  returning?: boolean;
};

type LobbyTheme = 'orange' | 'green' | 'blue';

const FILTER_STORAGE_KEY = 'lobby-filter-disabled';
const TINT_STORAGE_KEY = 'lobby-bg-tint-disabled';
const BG_STORAGE_KEY = 'lobby-bg-image-disabled';
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
  const [tintDisabled, setTintDisabled] = useState<boolean | undefined>();
  const [bgDisabled, setBgDisabled] = useState<boolean | undefined>();
  const [videoEnabled, setVideoEnabled] = useState(true);
  const [soundsOn, setSoundsOn] = useState(true);
  const [hidden, setHidden] = useState(false);
  const [themeFlash, setThemeFlash] = useState(false);
  const [bootEpoch, setBootEpoch] = useState(0);
  const [returnBoot, setReturnBoot] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);
  const [userSwapped, setUserSwapped] = useState(false);

  useLayoutEffect(() => {
    updateScaling();
    const onResize = () => updateScaling();
    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, []);

  useEffect(() => {
    Byond.subscribeTo('init', (payload: ServerState) => {
      setSs(payload);
      setFadingOut(false);
      if (payload.returning && !payload.transparent) {
        applyBackdrop(true);
        setHidden(false);
        setReturnBoot(true);
        setBootEpoch((epoch) => epoch + 1);
        setUserSwapped(false);
      } else {
        setReturnBoot(false);
        applyBackdrop(!!payload.transparent);
      }
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
    storage.get(TINT_STORAGE_KEY).then((val) => setTintDisabled(!!val));
    storage.get(BG_STORAGE_KEY).then((val) => setBgDisabled(!!val));
    storage.get(THEME_STORAGE_KEY).then((val) =>
      setTheme(
        val === 'blue' || val === 'green' || val === 'orange'
          ? val
          : 'orange',
      ),
    );
    storage.get(VIDEO_STORAGE_KEY).then((val) => {
      setVideoEnabled(val === undefined || val === null ? true : !!val);
    });
    loadSoundsEnabled().then((enabled) => {
      setSoundsOn(enabled);
      if (enabled) {
        setTimeout(() => playLoadSound(), LOAD_SOUND_DELAY_MS);
      }
    });
  }, []);

  useEffect(() => {
    setAnimationsDisabled(false);
    const timer = setTimeout(
      () => setAnimationsDisabled(true),
      ANIMATION_DISABLE_MS,
    );
    return () => clearTimeout(timer);
  }, [bootEpoch]);

  useEffect(() => {
    videoRef.current?.play()?.catch(() => {});
  }, [ss?.videoUrl, videoEnabled, ss?.transparent, bootEpoch]);

  useEffect(() => {
    const video = videoRef.current;
    if (!video || !ss?.videoUrl || !videoEnabled || ss?.transparent) {
      return;
    }
    const tryPlay = () => {
      video.play()?.catch(() => {});
    };
    const hardRestart = () => {
      try {
        video.load();
      } catch {
        // best-effort reset
      }
      tryPlay();
    };
    let seekBroken = false;
    let restartTimer: number | undefined;
    const restart = () => {
      if (seekBroken) {
        hardRestart();
        return;
      }
      try {
        video.currentTime = 0;
      } catch {
        seekBroken = true;
        hardRestart();
        return;
      }
      tryPlay();
      window.clearTimeout(restartTimer);
      restartTimer = window.setTimeout(() => {
        if (video.ended || (video.paused && !video.seeking)) {
          seekBroken = true;
          hardRestart();
        }
      }, 600);
    };
    const onEnded = () => restart();
    const onTimeUpdate = () => {
      if (video.ended) {
        restart();
      }
    };
    let lastTime = -1;
    let stalls = 0;
    const watchdog = window.setInterval(() => {
      if (document.hidden) {
        return;
      }
      if (video.ended) {
        restart();
        return;
      }
      if (
        video.paused &&
        !video.seeking &&
        video.currentTime > 0 &&
        (video.duration === 0 || !isFinite(video.duration) ||
          video.currentTime >= video.duration - 0.1)
      ) {
        restart();
        return;
      }
      if (video.paused || video.seeking) {
        stalls = 0;
      } else if (Math.abs(video.currentTime - lastTime) < 0.05) {
        stalls += 1;
        if (stalls >= 4) {
          stalls = 0;
          restart();
        }
      } else {
        stalls = 0;
      }
      lastTime = video.currentTime;
    }, 1000);
    video.addEventListener('ended', onEnded);
    video.addEventListener('timeupdate', onTimeUpdate);
    return () => {
      window.clearTimeout(restartTimer);
      window.clearInterval(watchdog);
      video.removeEventListener('ended', onEnded);
      video.removeEventListener('timeupdate', onTimeUpdate);
    };
  }, [ss?.videoUrl, videoEnabled, ss?.transparent]);

  if (
    !ss ||
    theme === undefined ||
    filterDisabled === undefined ||
    tintDisabled === undefined ||
    bgDisabled === undefined
  ) {
    return null;
  }

  const pickTheme = (next: LobbyTheme) => {
    playSelectSound();
    setTheme(next);
    storage.set(THEME_STORAGE_KEY, next);
    if (next !== theme) {
      setThemeFlash(true);
      window.setTimeout(() => setThemeFlash(false), 160);
    }
  };

  const toggleBgSetting = (next: boolean) => {
    setUserSwapped(true);
    setBgDisabled(next);
  };

  const toggleVideoSetting = (next: boolean) => {
    setUserSwapped(true);
    setVideoEnabled(next);
  };

  const crtFilter = !filterDisabled;
  const videoOn = !ss.transparent && videoEnabled;
  const bgVideoUrl = videoOn && ss.videoUrl ? ss.videoUrl : null;
  const bgImageUrl =
    !ss.transparent && !bgDisabled && !bgVideoUrl
      ? ss.backgroundUrl
      : null;
  const bgReveal = userSwapped ? 'bgSwap' : 'bgLoad';
  const pregame = ss.gamePhase === 'pregame' || ss.gamePhase === 'startup';
  const typingDelay = (index: number) =>
    animationsDisabled ? '0s' : `${1.5 + index * 0.2}s`;

  const panelBootDelay = (index: number) =>
    animationsDisabled ? '0s' : `${1.7 + (index - 1) * 0.25}s`;

  const collapsible = classes(['menuCollapsible', hidden && 'menuHidden']);

  return (
    <div
      key={bootEpoch}
      className={classes([
        'LobbyScreen',
        `LobbyScreen--${theme}`,
        crtFilter && 'filterEnabled',
        returnBoot && 'LobbyScreen--return',
        animationsDisabled && 'noAnimation',
        fadingOut && 'lobbyFadeOut',
        themeFlash && 'LobbyScreen--themeSwap',
        ss.transparent && 'LobbyScreen--transparent',
      ])}
    >
      {bgImageUrl && <BgImage url={bgImageUrl} reveal={bgReveal} />}

      {bgVideoUrl && (
        <BgVideo url={bgVideoUrl} reveal={bgReveal} videoRef={videoRef} />
      )}

      {!tintDisabled && !ss.transparent && <div className="bgTint" />}

      {crtFilter && !ss.transparent && (
        <>
          <div className="crt" />
          <div className="crtNoise" />
          <div className="crtVignette" />
        </>
      )}

      <Stack
        vertical
        height="100%"
        justify="space-around"
        align="center"
        className="menuHolder"
      >
        <Stack.Item className={collapsible}>
          <div className="brandLockup">
            <svg
              className="brandLockup__logo"
              viewBox="0 0 350 350"
              focusable="false"
            >
              <path d="M230.9 257.5h26.7v20.7h-68.7V71.8h68.7v20.7h-26.7c-7.1 0-12.8 5.7-12.8 12.8v139.5c0 7.1 5.7 12.8 12.8 12.8ZM92.4 71.8v20.7h26.7c7.1 0 12.8 5.7 12.8 12.8v139.5c0 7.1-5.7 12.8-12.8 12.8h-26.7v20.7h68.7V71.8H92.4ZM92.4 188.7v27.6H0v-27.6h92.4ZM257.6 188.7v27.6h92.4v-27.6h-92.4ZM0 133.4v27.9h92.4v-27.9H0ZM257.6 133.4v27.9h92.4v-27.9h-92.4Z" />
            </svg>
            <div className="brandLockup__name">Horizon-Dream</div>
            <div className="brandLockup__sub">Beyond the station</div>
          </div>
          <Section p={3} pt={1} className="sectionLoad">
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
                Settings
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
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>

      <div className="lobby__side-left">
        <CharacterPreview
          ss={ss}
          hidden={hidden}
          bootDelay={panelBootDelay(1)}
        />

        <PreferenceIssues
          issues={ss.preferenceIssues}
          hidden={hidden}
          bootDelay={panelBootDelay(3)}
        />
      </div>

      <StatsPanel
        ss={ss}
        pregame={pregame}
        hidden={hidden}
        bootDelay={panelBootDelay(2)}
        onStartNow={() => sendAction('start_now')}
      />

      {hidden && !ss.transparent && (
        <div className="brandWatermark floatingAppear">
          <svg
            className="brandWatermark__logo"
            viewBox="0 0 350 350"
            focusable="false"
          >
            <path d="M230.9 257.5h26.7v20.7h-68.7V71.8h68.7v20.7h-26.7c-7.1 0-12.8 5.7-12.8 12.8v139.5c0 7.1 5.7 12.8 12.8 12.8ZM92.4 71.8v20.7h26.7c7.1 0 12.8 5.7 12.8 12.8v139.5c0 7.1-5.7 12.8-12.8 12.8h-26.7v20.7h68.7V71.8H92.4ZM92.4 188.7v27.6H0v-27.6h92.4ZM257.6 188.7v27.6h92.4v-27.6h-92.4ZM0 133.4v27.9h92.4v-27.9H0ZM257.6 133.4v27.9h92.4v-27.9h-92.4Z" />
          </svg>
          <div className="brandWatermark__text">
            <div className="brandWatermark__name">Horizon-Dream</div>
            <div className="brandWatermark__sub">Beyond the station</div>
          </div>
        </div>
      )}

      <LobbySettings
        ss={ss}
        menuHidden={hidden}
        onShowMenu={() => setHidden(false)}
        onHideMenu={() => setHidden(true)}
        filterDisabled={filterDisabled}
        setFilterDisabled={setFilterDisabled}
        tintDisabled={tintDisabled}
        setTintDisabled={setTintDisabled}
        bgDisabled={bgDisabled}
        setBgDisabled={toggleBgSetting}
        theme={theme}
        pickTheme={pickTheme}
        videoEnabled={videoEnabled}
        setVideoEnabled={toggleVideoSetting}
        soundsOn={soundsOn}
        setSoundsOn={setSoundsOn}
      />
    </div>
  );
}

function BgImage({ url, reveal }: { url: string; reveal: string }) {
  const [mountedReveal] = useState(reveal);
  return (
    <div
      className={`bgBackground ${mountedReveal}`}
      style={{ backgroundImage: `url(${url})` }}
    />
  );
}

function BgVideo({
  url,
  reveal,
  videoRef,
}: {
  url: string;
  reveal: string;
  videoRef: { current: HTMLVideoElement | null };
}) {
  const [mountedReveal] = useState(reveal);
  return (
    <video
      ref={videoRef}
      className={`bgVideo ${mountedReveal}`}
      src={url}
      autoPlay
      loop
      muted
      playsInline
    />
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
function CharacterPreview({
  ss,
  hidden,
  bootDelay,
}: {
  ss: ServerState;
  hidden: boolean;
  bootDelay: string;
}) {
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
    <div
      className={classes([
        'lobby__preview',
        'panelBoot',
        'menuCollapsible',
        hidden && 'menuHidden',
      ])}
      style={{ '--panel-boot-delay': bootDelay } as CSSProperties}
    >
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
function StatsPanel({
  ss,
  pregame,
  hidden,
  bootDelay,
  onStartNow,
}: {
  ss: ServerState;
  pregame: boolean;
  hidden: boolean;
  bootDelay: string;
  onStartNow: () => void;
}) {
  return (
    <div
      className={classes([
        'lobby__stats-holder',
        'panelBoot',
        'menuCollapsible',
        hidden && 'menuHidden',
      ])}
      style={{ '--panel-boot-delay': bootDelay } as CSSProperties}
    >
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

      <StartNowButton
        visible={!!ss.canStartNow && pregame}
        onStartNow={onStartNow}
      />
    </div>
  );
}

function StartNowButton({
  visible,
  onStartNow,
}: {
  visible: boolean;
  onStartNow: () => void;
}) {
  const [mounted, setMounted] = useState(visible);
  const [fading, setFading] = useState(false);

  useEffect(() => {
    if (visible) {
      setMounted(true);
      setFading(false);
      return;
    }
    setFading(true);
    const timer = setTimeout(() => setMounted(false), 800);
    return () => clearTimeout(timer);
  }, [visible]);

  if (!mounted) {
    return null;
  }

  return (
    <div
      className={classes([
        'lobby__start-now',
        'buttonEffect',
        fading && 'lobby__start-now--out',
      ])}
    >
      <Button
        fluid
        className="distinctButton"
        icon="forward"
        onClick={() => {
          playSelectSound();
          onStartNow();
        }}
      >
        <span className="styledText">Start Now</span>
      </Button>
    </div>
  );
}

/** CM13-style warnings about the player's current preferences */
function PreferenceIssues({
  issues,
  hidden,
  bootDelay,
}: {
  issues: string[];
  hidden: boolean;
  bootDelay: string;
}) {
  if (!issues || issues.length === 0) {
    return null;
  }
  return (
    <div
      className={classes([
        'messageHolder',
        'panelBoot',
        'menuCollapsible',
        hidden && 'menuHidden',
      ])}
      style={{ '--panel-boot-delay': bootDelay } as CSSProperties}
    >
      <Stack vertical>
        {issues.map((issue, index) => (
          <Section key={index} className="sectionLoad issueSection">
            <Box className="issueText">{issue}</Box>
          </Section>
        ))}
      </Stack>
    </div>
  );
}

/** Settings corner (bottom right) and its popup */
function LobbySettings({
  ss,
  menuHidden,
  onShowMenu,
  onHideMenu,
  filterDisabled,
  setFilterDisabled,
  tintDisabled,
  setTintDisabled,
  bgDisabled,
  setBgDisabled,
  theme,
  pickTheme,
  videoEnabled,
  setVideoEnabled,
  soundsOn,
  setSoundsOn,
}: {
  ss: ServerState;
  menuHidden: boolean;
  onShowMenu: () => void;
  onHideMenu: () => void;
  filterDisabled: boolean;
  setFilterDisabled: (value: boolean) => void;
  tintDisabled: boolean;
  setTintDisabled: (value: boolean) => void;
  bgDisabled: boolean;
  setBgDisabled: (value: boolean) => void;
  theme: LobbyTheme;
  pickTheme: (value: LobbyTheme) => void;
  videoEnabled: boolean;
  setVideoEnabled: (value: boolean) => void;
  soundsOn: boolean;
  setSoundsOn: (value: boolean) => void;
}) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <Box
        position="absolute"
        bottom="10px"
        right="10px"
        className="settingsHolder"
      >
        {menuHidden ? (
          <Button
            icon="check"
            className="floatingAppear"
            onClick={() => {
              playSelectSound();
              onShowMenu();
            }}
          />
        ) : (
          <Button
            icon="eye-slash"
            className="floatingAppear"
            onClick={() => {
              playSelectSound();
              onHideMenu();
            }}
          />
        )}
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
                  selected={theme === 'orange'}
                  onClick={() => pickTheme('orange')}
                >
                  Orange
                </Button>
                <Button
                  selected={theme === 'green'}
                  onClick={() => pickTheme('green')}
                >
                  Green
                </Button>
                <Button
                  selected={theme === 'blue'}
                  onClick={() => pickTheme('blue')}
                >
                  Blue
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

              <SettingsRow label="Background tint">
                <Button
                  selected={!tintDisabled}
                  onClick={() => {
                    playSelectSound();
                    const next = !tintDisabled;
                    setTintDisabled(next);
                    storage.set(TINT_STORAGE_KEY, next);
                  }}
                >
                  {tintDisabled ? 'Off' : 'On'}
                </Button>
              </SettingsRow>

              {!!ss.backgroundUrl && (
                <SettingsRow label="Background image">
                  <Button
                    selected={!bgDisabled}
                    onClick={() => {
                      playSelectSound();
                      const next = !bgDisabled;
                      setBgDisabled(next);
                      storage.set(BG_STORAGE_KEY, next);
                    }}
                  >
                    {bgDisabled ? 'Off' : 'On'}
                  </Button>
                </SettingsRow>
              )}

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
