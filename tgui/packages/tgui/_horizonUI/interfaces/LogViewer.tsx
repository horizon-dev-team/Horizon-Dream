import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Icon,
  Input,
  Section,
} from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';

type LogType = {
  name: string;
  flag: number;
};

type LogEntry = {
  time: string;
  timestamp?: number;
  type_flag?: number;
  state?: string | null;
  who: string;
  what: string;
  where: string;
  type: string;
  health: string | null;
  color?: string | null;
  target_name: string | null;
  target_key: string | null;
};

type Data = {
  logs: LogEntry[];
  target_name: string | null;
  target_ckey: string | null;
  source_type: string;
  filter_text: string;
  target_filter: string;
  zone_filter: string;
  viewing_type: number;
  log_types: LogType[];
  source_options: string[];
  ckeys_list: string[];
};

type Act = (action: string, payload?: Record<string, unknown>) => void;

const SHOW_ALL_LABEL = 'Show All';

const TYPE_LABELS: Record<string, string> = {
  RadioEmote: 'Radio Emote',
};

const SOURCE_INFO: Record<string, { label: string; tooltip: string }> = {
  Ckey: {
    label: 'All bodies',
    tooltip: 'Persistent log across every mob played by this ckey',
  },
  Mob: {
    label: 'Current body',
    tooltip: 'Log of the currently selected mob only',
  },
};

/** CSS modifier carrying the type colour, e.g. `LogViewer__type--radioemote`. */
const typeModifier = (type: string) =>
  `LogViewer__type--${type.toLowerCase().replace(/[^a-z0-9]/g, '')}`;

const stripHtml = (text: string | null | undefined) =>
  text
    ? String(text)
        .replace(/<[^>]*>/g, '')
        .trim()
    : '';

/** `log_message()` prefixes some messages with a type tag that the viewer already shows in its own column. */
const TYPE_PREFIX = /^\((?:EMOTE|WHISPER|OOC|ASAY|RADIOEMOTE)\)\s+/i;

/** Deadchat is logged with a `DEAD` tag; the type column already says Deadchat, so drop it. */
const DEAD_PREFIX = /^\(DEAD\)\s+/i;

const formatMessage = (entry: LogEntry) =>
  stripHtml(entry.what).replace(TYPE_PREFIX, '').replace(DEAD_PREFIX, '');

const STATE_BADGES: Record<string, string> = {
  dead: 'DEAD',
  critical: 'CRIT',
};

const COMMON_LANGUAGE = 'Galactic Common';

type LanguageParts = {
  message: string;
  language: string;
};

/**
 * `log_talk()` appends `(language: X)` to speech made in a non-standard
 * language, so the badge is rendered next to the message instead of the raw
 * text. Only `Say` and `Whisper` reach this path; radio entries carry their own
 * language marker inside the telecomms payload.
 */
const extractLanguage = (text: string): LanguageParts => {
  const match = text.match(/\s*\(language:\s*([^)]+)\)\s*$/i);
  if (!match) {
    return { message: text, language: '' };
  }
  return {
    message: text.slice(0, match.index ?? text.length).trim(),
    language: match[1].trim(),
  };
};

type TelecommsParts = {
  frequency: string;
  language: string;
  message: string;
};

/**
 * Telecomms entries are logged as `[145.9] (spans: robot ) "text" (language: X)`.
 * The spans section is debug noise, so it is dropped; the frequency and the
 * language are pulled out of the text and rendered as separate markers.
 */
const parseTelecomms = (text: string): TelecommsParts | null => {
  const frequency = text.match(/^\[([^\]]+)\]\s*/);
  if (!frequency) {
    return null;
  }

  const rest = text
    .slice(frequency[0].length)
    .replace(/^\(spans:[^)]*\)\s*/i, '')
    .trim();
  const parsed = extractLanguage(rest);

  return {
    frequency: frequency[1],
    language: parsed.language,
    message: parsed.message,
  };
};

type ReagentPart = { name: string; volume: string; purity: string };

type ChemTransferParts = {
  action: string;
  reagents: ReagentPart[];
  rest: string;
};

const WHICH_HAD = ' which had ';

/** `log_combat()` logs every moved reagent as `/datum/reagent/<path> (<volume>u, <purity> purity)`. */
const REAGENT_ENTRY =
  /\/datum\/reagent\/([a-z0-9_/]+)\s*\(([\d.]+)u,\s*([\d.]+)\s*purity\)/gi;

const prettyReagentName = (path: string) => {
  const leaf = path.slice(path.lastIndexOf('/') + 1);
  return leaf
    .replace(/_/g, ' ')
    .replace(/\b[a-z]/g, (letter) => letter.toUpperCase());
};

/**
 * Reagent transfers are logged as a wall of type paths:
 * `transferred reagents to [beaker] with the beaker which had /datum/reagent/x (75u, 1 purity)`.
 * Every reagent becomes a readable chip, and whatever the pattern did not
 * recognise (`(NEWHP: 85)`, unknown formats) is kept in `rest` so nothing is lost.
 */
const parseChemTransfer = (text: string): ChemTransferParts | null => {
  if (!text.startsWith('transferred reagents to ')) {
    return null;
  }
  const split = text.indexOf(WHICH_HAD);
  if (split < 0) {
    return null;
  }

  const tail = text.slice(split + WHICH_HAD.length).trim();
  const reagents: ReagentPart[] = [];
  for (const entry of tail.matchAll(REAGENT_ENTRY)) {
    reagents.push({
      name: prettyReagentName(entry[1]),
      volume: entry[2],
      purity: entry[3],
    });
  }

  if (!reagents.length) {
    return null;
  }

  const rest = tail
    .replace(REAGENT_ENTRY, ' ')
    .replace(/\band\b/gi, ' ')
    .replace(/[,\s]+/g, ' ')
    .trim();

  return { action: text.slice(0, split).trim(), reagents, rest };
};

type Location = { area: string; coords: string };

/** Split `(Central Primary Hallway (122,145,2))` into a clickable area and coordinates. */
const parseLocation = (where: string | null | undefined): Location | null => {
  const raw = stripHtml(where);
  if (!raw) return null;
  const match = raw.match(/^\(?(.+?)\s*\((\d+),\s*(\d+),\s*(\d+)\)\)?$/);
  if (!match) {
    return { area: raw.replace(/^\((.*)\)$/, '$1'), coords: '' };
  }
  return {
    area: match[1].trim(),
    coords: `(${match[2]}, ${match[3]}, ${match[4]})`,
  };
};

/** `ckey/(Character Name) (tag)` -> `Character Name`. */
const formatWho = (who: string | null | undefined) => {
  if (!who) return 'unknown';
  const name = who
    .slice(who.lastIndexOf('/') + 1)
    .replace(/\s+\([^()]*\)$/, '')
    .replace(/^\((.*)\)$/, '$1');
  return name || who;
};

const healthModifier = (health: string) => {
  const value = Number(health);
  if (!Number.isFinite(value)) return '';
  if (value <= 0) return ' LogViewer__hp--critical';
  if (value <= 25) return ' LogViewer__hp--low';
  return '';
};

/**
 * The backend hands entries over grouped by log type (OOC, Say, ...), so the
 * chronological order has to be restored on the client.
 * `timestamp` is `world.time` (deciseconds); `time` is the `HH:MM:SS` fallback
 * for entries that have no usable timestamp.
 */
const sortNewestFirst = (entries: LogEntry[]) => {
  const stamps = entries.map((entry) => entry.timestamp);
  const useTimestamps =
    stamps.every((stamp) => typeof stamp === 'number') &&
    new Set(stamps).size > 1;

  return entries.slice().sort((a, b) => {
    if (useTimestamps) {
      return (b.timestamp as number) - (a.timestamp as number);
    }
    return (b.time || '').localeCompare(a.time || '');
  });
};

const LogEntryRow = (props: { entry: LogEntry; act: Act }) => {
  const { entry, act } = props;
  const location = parseLocation(entry.where);
  const target = entry.target_name || entry.target_key;
  const targetFilter = entry.target_key || entry.target_name;
  const rawMessage = formatMessage(entry);
  const telecomms =
    entry.type === 'Telecomms' ? parseTelecomms(rawMessage) : null;
  const spoken =
    !telecomms && (entry.type === 'Say' || entry.type === 'Whisper')
      ? extractLanguage(rawMessage)
      : null;
  const chem =
    !telecomms && !spoken ? parseChemTransfer(rawMessage) : null;
  const message = telecomms
    ? telecomms.message
    : (spoken?.message ?? chem?.action ?? rawMessage);
  const language = telecomms?.language || spoken?.language || '';
  const state =
    entry.state && STATE_BADGES[entry.state] ? entry.state : '';

  return (
    <Box
      className={`LogViewer__entry ${typeModifier(entry.type || 'Misc')}`}
    >
      <Flex className="LogViewer__line">
        <Box className="LogViewer__time">{entry.time || '--:--:--'}</Box>
        <Box className="LogViewer__type">
          {TYPE_LABELS[entry.type] || entry.type || 'Misc'}
        </Box>
        <Box className="LogViewer__msg" color={entry.color || undefined}>
          {!!telecomms && (
            <Box as="span" className="LogViewer__freq">
              {telecomms.frequency}
            </Box>
          )}
          {!!chem && (
            <Box as="span" className="LogViewer__chem">
              CHEM
            </Box>
          )}
          {message}
          {!!chem && (
            <>
              {' '}
              {chem.reagents.map((reagent, index) => (
                <Box
                  as="span"
                  className="LogViewer__reagent"
                  key={`${reagent.name}-${reagent.volume}-${index}`}
                >
                  {reagent.name} {reagent.volume}u
                  {reagent.purity !== '1' ? ` · ${reagent.purity}` : ''}
                </Box>
              ))}
              {chem.rest ? ` ${chem.rest}` : ''}
            </>
          )}
          {!!language && language !== COMMON_LANGUAGE && (
            <Box as="span" className="LogViewer__lang">
              {language}
            </Box>
          )}
        </Box>
        <Box className="LogViewer__who">
          {!!state && (
            <Box
              as="span"
              className={`LogViewer__state LogViewer__state--${state}`}
            >
              {STATE_BADGES[state]}
            </Box>
          )}
          {formatWho(entry.who)}
        </Box>
      </Flex>
      {(location || !!entry.health || !!target) && (
        <Flex className="LogViewer__meta">
          {location && (
            <Box as="span" className="LogViewer__metaItem">
              <Icon name="map-marker" className="LogViewer__metaIcon" />
              <Box
                as="span"
                className="LogViewer__where"
                onClick={() => act('set_zone_filter', { text: location.area })}
              >
                {location.area}
              </Box>
              {!!location.coords && (
                <Box as="span" className="LogViewer__coords">
                  {location.coords}
                </Box>
              )}
            </Box>
          )}
          {!!entry.health && (
            <Box
              as="span"
              className={`LogViewer__hp${healthModifier(entry.health)}`}
            >
              HP: {entry.health}
            </Box>
          )}
          {!!target && (
            <Box
              as="span"
              className="LogViewer__target"
              onClick={() => act('set_target_filter', { text: targetFilter })}
            >
              <Icon name="crosshairs" className="LogViewer__metaIcon" />
              {target}
            </Box>
          )}
        </Flex>
      )}
    </Box>
  );
};

export const LogViewer = () => {
  const { act, data } = useBackend<Data>();
  const [autoRefresh, setAutoRefresh] = useState(true);

  useEffect(() => {
    if (!autoRefresh) return;
    const id = setInterval(() => act('refresh'), 3000);
    return () => clearInterval(id);
  }, [autoRefresh, act]);

  const logs: LogEntry[] = Array.isArray(data.logs) ? data.logs : [];
  const logTypes: LogType[] = Array.isArray(data.log_types)
    ? data.log_types
    : [];
  const sourceOptions: string[] = Array.isArray(data.source_options)
    ? data.source_options
    : [];
  const ckeys: string[] = Array.isArray(data.ckeys_list)
    ? data.ckeys_list
    : [];

  // "Show All" is the OR of every individual flag, so we do not have to
  // depend on its (localised) display name coming from the backend.
  const showAllFlag = logTypes.reduce((acc, lt) => acc | lt.flag, 0);
  const isShowAll = showAllFlag > 0 && data.viewing_type === showAllFlag;
  const hasFilters =
    !!data.filter_text || !!data.target_filter || !!data.zone_filter;

  const handleTypeClick = (flag: number) => {
    if (flag === showAllFlag) {
      act('set_viewing_type', { type: showAllFlag });
      return;
    }
    if (isShowAll) {
      act('set_viewing_type', { type: flag });
      return;
    }
    act('set_viewing_type', {
      type: data.viewing_type ^ flag || showAllFlag,
    });
  };

  return (
    <Window
      title={data.target_ckey ? `Log Viewer - ${data.target_ckey}` : 'Log Viewer'}
      theme="ntos_darkmode"
      width={1100}
      height={700}
    >
      <Window.Content scrollable className="LogViewer__body">
        <Section>
          <Flex direction="column" gap={0.5}>
            <Flex align="center" gap={0.5}>
              <Box className="LogViewer__label">Player</Box>
              <Flex.Item grow={1}>
                <Dropdown
                  fluid
                  searchInput
                  styledInput
                  placeholder="Select player..."
                  displayText={data.target_ckey || undefined}
                  selected={data.target_ckey || undefined}
                  options={ckeys}
                  onSelected={(ckey: string) => act('select_ckey', { ckey })}
                />
              </Flex.Item>
              <Button
                icon="external-link"
                color="transparent"
                content={data.target_name || 'None'}
                tooltip="Open options panel"
                disabled={!data.target_ckey}
                onClick={() => act('open_pp')}
              />
            </Flex>

            <Flex align="center" gap={0.5} wrap>
              <Box className="LogViewer__label">Source</Box>
              {sourceOptions.map((src) => {
                const info = SOURCE_INFO[src];
                return (
                  <Button
                    key={src}
                    compact
                    content={info?.label || src}
                    tooltip={info?.tooltip}
                    selected={data.source_type === src}
                    onClick={() => act('set_source', { source: src })}
                  />
                );
              })}
              <Flex.Item grow={1} />
              <Input
                width="200px"
                placeholder="Search text..."
                value={data.filter_text}
                expensive
                onChange={(value: string) =>
                  act('set_filter', { text: value })
                }
              />
              <Input
                width="200px"
                placeholder="Other player..."
                value={data.target_filter}
                expensive
                onChange={(value: string) =>
                  act('set_target_filter', { text: value })
                }
              />
            </Flex>

            <Flex align="center" gap={0.5} wrap>
              <Box className="LogViewer__label">Type</Box>
              {logTypes.map((lt) => {
                const isShowAllOption = lt.flag === showAllFlag;
                const isSelected = isShowAllOption
                  ? isShowAll
                  : !isShowAll && !!(data.viewing_type & lt.flag);
                return (
                  <Button
                    key={lt.flag}
                    className={
                      isShowAllOption
                        ? 'LogViewer__filter'
                        : `LogViewer__filter ${typeModifier(lt.name)}`
                    }
                    compact
                    content={isShowAllOption ? SHOW_ALL_LABEL : lt.name}
                    selected={isSelected}
                    onClick={() => handleTypeClick(lt.flag)}
                  />
                );
              })}
            </Flex>

            {hasFilters && (
              <Box className="LogViewer__chips">
                <Box as="span">Filters:</Box>
                {!!data.filter_text && (
                  <Box
                    as="span"
                    className="LogViewer__chip LogViewer__chip--yellow"
                    onClick={() => act('set_filter', { text: '' })}
                  >
                    text: {data.filter_text} ×
                  </Box>
                )}
                {!!data.target_filter && (
                  <Box
                    as="span"
                    className="LogViewer__chip LogViewer__chip--yellow"
                    onClick={() => act('set_target_filter', { text: '' })}
                  >
                    target: {data.target_filter} ×
                  </Box>
                )}
                {!!data.zone_filter && (
                  <Box
                    as="span"
                    className="LogViewer__chip LogViewer__chip--green"
                    onClick={() => act('set_zone_filter', { text: '' })}
                  >
                    zone: {data.zone_filter} ×
                  </Box>
                )}
              </Box>
            )}
          </Flex>
        </Section>

        <Section
          title={`Logs (${logs.length})`}
          buttons={
            <Flex align="center" gap={0.5}>
              <Button.Checkbox
                content="Auto"
                checked={autoRefresh}
                tooltip="Auto refresh every 3 seconds"
                onClick={() => setAutoRefresh((value) => !value)}
              />
              <Button
                icon="sync"
                content="Refresh"
                onClick={() => act('refresh')}
              />
            </Flex>
          }
        >
          {!data.target_ckey ? (
            <Box className="LogViewer__empty">
              <Icon name="chevron-circle-up" mr={1} />
              Select a player from the list above.
            </Box>
          ) : logs.length === 0 ? (
            <Box className="LogViewer__empty">
              <Icon name="search" mr={1} />
              {hasFilters
                ? 'No logs match the current filters.'
                : 'No logs found.'}
            </Box>
          ) : (
            sortNewestFirst(logs).map((entry) => (
              <LogEntryRow
                key={[
                  entry.timestamp ?? entry.time,
                  entry.type_flag ?? entry.type,
                  entry.who,
                  entry.where,
                  entry.target_key,
                  entry.what,
                ].join('|')}
                entry={entry}
                act={act}
              />
            ))
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
