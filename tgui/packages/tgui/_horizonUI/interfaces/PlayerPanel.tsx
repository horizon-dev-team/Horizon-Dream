import { ComponentProps, useEffect, useState } from 'react';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  Table,
  TextArea,
} from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';

type PlayerRights = {
  admin: boolean;
  ban: boolean;
  fun: boolean;
};

type PlayerData = {
  ckey: string;
  name?: string | null;
  real_name?: string | null;
  old_name?: string | null;
  previous_names?: string[] | null;
  job?: string | null;
  mob_type?: string | null;
  species?: string | null;
  byond_version?: string | null;
  first_seen?: string | null;
  register_date?: string | null;
  ip?: string | null;
  cid?: string | null;
  related_accounts_ip?: string | null;
  related_accounts_cid?: string | null;
  living_playtime?: number | null;
  last_ip?: string | null;
  is_antagonist: boolean;
  has_mind: boolean;
  is_cyborg: boolean;
  is_living: boolean;
  connected: boolean;
  position?: string | null;
  oxydam?: number;
  toxdam?: number;
  burndam?: number;
  brutedam?: number;
  health?: number;
  health_max?: number;
  ref: string;
};

type BackendData = {
  players: PlayerData[];
  search_text?: string | null;
  update_interval: number;
  show_all_mobs: boolean;
  rights: PlayerRights;
  exp_tracking: boolean;
  centcom_enabled: boolean;
};

type SortKey = 'ckey' | 'name' | 'job' | 'playtime';

const DEFAULT_RIGHTS: PlayerRights = {
  admin: false,
  ban: false,
  fun: false,
};

const TextOrNA = (
  props: { text?: string | null } & ComponentProps<typeof Box>,
) => {
  const { text, ...rest } = props;
  const color = !text ? 'grey' : null;
  return (
    <Box inline color={color} {...rest}>
      {text || 'N/A'}
    </Box>
  );
};

const NameWithReal = (props: {
  name?: string | null;
  real_name?: string | null;
}) => {
  const { name, real_name } = props;
  const displayName = name || null;
  const displayReal = real_name || null;
  if (!displayName && !displayReal) {
    return <Box inline color="grey">N/A</Box>;
  }
  if (!displayName) {
    return <Box inline>{displayReal}</Box>;
  }
  if (!displayReal || displayReal === displayName) {
    return <Box inline>{displayName}</Box>;
  }
  return (
    <Box inline>
      {displayName}{' '}
      <Box inline color="grey">
        ({displayReal})
      </Box>
    </Box>
  );
};

const PlayerVitals = (props: { player: PlayerData }) => {
  const { player } = props;
  if (player.oxydam !== undefined) {
    return (
      <Box inline>
        <Box inline style={{ color: '#ff3333' }}>
          {player.brutedam}
        </Box>{' / '}
        <Box inline style={{ color: '#ff9933' }}>
          {player.burndam}
        </Box>{' / '}
        <Box inline style={{ color: '#00cc66' }}>
          {player.toxdam}
        </Box>{' / '}
        <Box inline style={{ color: '#00cccc' }}>
          {player.oxydam}
        </Box>
      </Box>
    );
  }
  if (player.health !== undefined) {
    return (
      <Box inline color={player.health <= 0 ? 'red' : null}>
        {player.health}/{player.health_max}
      </Box>
    );
  }
  return null;
};

const comparePlayers = (a: PlayerData, b: PlayerData, key: SortKey): number => {
  switch (key) {
    case 'playtime':
      return (a.living_playtime ?? -1) - (b.living_playtime ?? -1);
    default: {
      const aValue = (a[key] || '').toLowerCase();
      const bValue = (b[key] || '').toLowerCase();
      return aValue.localeCompare(bValue);
    }
  }
};

const SortableCell = (props: {
  label: string;
  sortKey: SortKey;
  activeKey: SortKey;
  direction: number;
  onSort: (key: SortKey) => void;
}) => {
  const { label, sortKey, activeKey, direction, onSort } = props;
  return (
    <Table.Cell
      bold
      textAlign="center"
      style={{ cursor: 'pointer' }}
      onClick={() => onSort(sortKey)}
    >
      {label}
      {activeKey === sortKey && (
        <Icon name={direction === 1 ? 'chevron-up' : 'chevron-down'} ml={0.5} />
      )}
    </Table.Cell>
  );
};

const PlayerRowActions = (props: {
  player: PlayerData;
  rights: PlayerRights;
  onAction: (action: string, ckey?: string) => void;
}) => {
  const { player, rights, onAction } = props;
  const act = (action: string) => onAction(action, player.ckey);
  return (
    <>
      <Button
        compact
        icon="comment"
        tooltip="Private message"
        onClick={() => act('sendPrivateMessage')}
      />
      <Button
        compact
        icon="eye"
        tooltip="Follow"
        onClick={() => act('follow')}
      />
      <Button
        compact
        icon="bolt"
        color="red"
        tooltip="Smite"
        onClick={() => act('smite')}
      />
      {!!player.has_mind && (
        <Button
          compact
          icon="user-secret"
          tooltip="Traitor panel"
          onClick={() => act('openTraitorPanel')}
        />
      )}
      <Button
        compact
        icon="book"
        tooltip="Logs"
        onClick={() => act('openLogs')}
      />
      <Button
        compact
        icon="clipboard"
        tooltip="Notes"
        onClick={() => act('openNotes')}
      />
      <Button
        compact
        icon="external-link"
        tooltip="Player Options Panel"
        onClick={() => act('openAdditionalPanel')}
      />

    </>
  );
};

const PlayerRow = (props: {
  player: PlayerData;
  rights: PlayerRights;
  selected: boolean;
  showPlaytime: boolean;
  onSelect: (ckey: string) => void;
  onAction: (action: string, ckey?: string) => void;
}) => {
  const { player, rights, selected, showPlaytime, onSelect, onAction } = props;

  return (
    <Table.Row className="candystripe">
      <Table.Cell collapsing textAlign="center" verticalAlign="middle">
        <Button
          compact
          icon="circle"
          color={selected ? 'green' : null}
          tooltip="Select player"
          onClick={() => onSelect(selected ? '' : player.ckey)}
        />
      </Table.Cell>
      <Table.Cell verticalAlign="middle" textAlign="center">
        <Button
          compact
          color="transparent"
          content={player.ckey}
          tooltip={
            player.connected
              ? 'Select player'
              : 'Offline — the player left the server'
          }
          onClick={() => onSelect(player.ckey)}
        />
        {!player.connected && (
          <Box inline color="grey" ml={0.5} fontSize="0.85em">
            offline
          </Box>
        )}
      </Table.Cell>
      <Table.Cell verticalAlign="middle" textAlign="center">
        <TextOrNA text={player.name} />
      </Table.Cell>
      <Table.Cell verticalAlign="middle" textAlign="center">
        <TextOrNA text={player.job} />
      </Table.Cell>
      <Table.Cell verticalAlign="middle" textAlign="center">
        <TextOrNA text={player.position} />
      </Table.Cell>
      {!!showPlaytime && (
        <Table.Cell verticalAlign="middle" textAlign="center">
          {player.living_playtime !== undefined &&
          player.living_playtime !== null ? (
            `${player.living_playtime}h`
          ) : (
            <TextOrNA />
          )}
        </Table.Cell>
      )}
      <Table.Cell verticalAlign="middle" textAlign="center">
        <PlayerVitals player={player} />
      </Table.Cell>
      <Table.Cell verticalAlign="middle" textAlign="center">
        <PlayerRowActions player={player} rights={rights} onAction={onAction} />
      </Table.Cell>
    </Table.Row>
  );
};

const PlayerDetails = (props: {
  player: PlayerData;
  rights: PlayerRights;
  data: BackendData;
  onAction: (action: string, ckey?: string) => void;
  onOpenOptions: () => void;
  onDeselect: () => void;
}) => {
  const { player, data, onOpenOptions, onDeselect } = props;
  const [hideSensitive, setHideSensitive] = useState(true);

  const renderSensitiveValue = (value: string | null | undefined) => {
    if (hideSensitive) {
      return (
        <Box inline color="grey">
          Hidden
        </Box>
      );
    }
    return <TextOrNA text={value} />;
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <PlayerDetailsHeader
          player={player}
          onOpenOptions={onOpenOptions}
          onDeselect={onDeselect}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow basis={0}>
            <Section fill scrollable title="Player">
              <LabeledList>
                <LabeledList.Item label="Job">
                  <TextOrNA text={player.job} />
                </LabeledList.Item>
                <LabeledList.Item label="Species">
                  <TextOrNA text={player.species} />
                </LabeledList.Item>
                <LabeledList.Item label="First seen">
                  <TextOrNA text={player.first_seen} />
                </LabeledList.Item>
                <LabeledList.Item label="Registered">
                  <TextOrNA text={player.register_date} />
                </LabeledList.Item>
                <LabeledList.Item label="BYOND">
                  <TextOrNA text={player.byond_version} />
                </LabeledList.Item>
                {!!data.exp_tracking && (
                  <LabeledList.Item label="Playtime">
                    {player.living_playtime !== undefined &&
                    player.living_playtime !== null
                      ? `${player.living_playtime}h`
                      : 'N/A'}
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Antag">
                  <Box inline color={player.is_antagonist ? 'red' : 'green'}>
                    {player.is_antagonist ? 'Yes' : 'No'}
                  </Box>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Section
              fill
              scrollable
              title="CKEY data"
              buttons={
                <Button
                  compact
                  icon={hideSensitive ? 'eye' : 'eye-slash'}
                  color={hideSensitive ? 'green' : 'default'}
                  content={hideSensitive ? 'Show all' : 'Hide all'}
                  onClick={() => setHideSensitive(!hideSensitive)}
                />
              }
            >
              <LabeledList>
                <LabeledList.Item label="IP">
                  {renderSensitiveValue(player.ip)}
                </LabeledList.Item>
                <LabeledList.Item label="CID">
                  {renderSensitiveValue(player.cid)}
                </LabeledList.Item>
                <LabeledList.Item label="Accounts (IP)">
                  {renderSensitiveValue(player.related_accounts_ip)}
                </LabeledList.Item>
                <LabeledList.Item label="Accounts (CID)">
                  {renderSensitiveValue(player.related_accounts_cid)}
                </LabeledList.Item>
                <LabeledList.Item label="Last IP">
                  {renderSensitiveValue(player.last_ip)}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Section fill scrollable title="Previous names" textAlign="center">
              {player.previous_names?.length ? (
                player.previous_names.map((name) => (
                  <Box key={name} color="label" textAlign="center" mb={0.5}>
                    {name}
                  </Box>
                ))
              ) : (
                <Box color="grey" textAlign="center">
                  None
                </Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const PlayerDetailsHeader = (props: {
  player: PlayerData;
  onOpenOptions: () => void;
  onDeselect: () => void;
}) => {
  const { player, onOpenOptions, onDeselect } = props;
  return (
    <Section>
      <Stack align="baseline">
        <Stack.Item grow>
          <Box bold fontSize="14px">
            <NameWithReal name={player.name} real_name={player.real_name} />
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="external-link"
            content="Options Panel"
            tooltip="Open player options panel"
            onClick={onOpenOptions}
          />
          <Button icon="times" content="Deselect" ml={1} onClick={onDeselect} />
        </Stack.Item>
      </Stack>
      <Box color="label" fontSize="11px" mt={0.5}>
        {player.ckey} · {player.mob_type || 'null'}
        {!!player.job && ` · ${player.job}`}
      </Box>
    </Section>
  );
};

const AdminHelpers = () => {
  const { act } = useBackend<BackendData>();
  return (
    <Stack>
      <Stack.Item grow>
        <Button
          fluid
          my={0.5}
          content="All Verb Panel"
          onClick={() => act('allVerbsPanel')}
        />
        <Button
          fluid
          my={0.5}
          content="Game Panel"
          onClick={() => act('gamePanel')}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          my={0.5}
          content="Check Players"
          onClick={() => act('checkPlayers')}
        />
        <Button
          fluid
          my={0.5}
          content="Check Antags"
          onClick={() => act('checkAntags')}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          my={0.5}
          content="Fax Panel"
          onClick={() => act('faxPanel')}
        />
        <Button
          fluid
          my={0.5}
          content="Create Command Report"
          onClick={() => act('createCommandReport')}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          my={0.5}
          content="Toggle Admin AI Interact"
          onClick={() => act('adminaiinteract')}
        />
        <Button fluid my={0.5} content="Old PP" onClick={() => act('oldPP')} />
      </Stack.Item>
    </Stack>
  );
};

export const PlayerPanel = () => {
  const { data, act } = useBackend<BackendData>();
  const players: PlayerData[] = data?.players ?? [];
  const rights: PlayerRights = data?.rights ?? DEFAULT_RIGHTS;

  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCkey, setSelectedCkey] = useState('');
  const [sortKey, setSortKey] = useState<SortKey>('job');
  const [sortDir, setSortDir] = useState(1);

  useEffect(() => {
    const timer = setTimeout(() => {
      act('set_search_text', {
        text: searchTerm,
        selectedPlayerCkey: selectedCkey,
      });
    }, 250);
    return () => clearTimeout(timer);
  }, [act, searchTerm, selectedCkey]);

  const selectedPlayer = players.find((player) => player.ckey === selectedCkey);
  const sortedPlayers = [...players].sort(
    (a, b) => comparePlayers(a, b, sortKey) * sortDir,
  );

  const handleSort = (key: SortKey) => {
    if (key === sortKey) {
      setSortDir(-sortDir);
      return;
    }
    setSortKey(key);
    setSortDir(1);
  };

  const handleAction = (action: string, ckey?: string) => {
    const target = ckey || selectedCkey;
    if (ckey && ckey !== selectedCkey) {
      setSelectedCkey(ckey);
    }
    act(action, { selectedPlayerCkey: target });
  };

  const sortProps = {
    activeKey: sortKey,
    direction: sortDir,
    onSort: handleSort,
  };

  return (
    <Window
      title="Player Panel"
      theme="ntos_darkmode"
      width={1000}
      height={700}
    >
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title="Admin helpers"
              buttons={
                <Stack>
                  <Stack.Item>
                    <Box inline color="label" mr={1}>
                      Auto-update
                    </Box>
                    <NumberInput
                      value={data?.update_interval ?? 5}
                      minValue={0}
                      maxValue={120}
                      step={1}
                      unit="s"
                      width="60px"
                      onChange={(value) =>
                        act('set_update_interval', { value })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="users"
                      selected={!!data?.show_all_mobs}
                      tooltip="Show every character that has a ckey, including players who left the server and their bodies"
                      onClick={() => act('toggle_all_mobs')}
                    >
                      All Characters
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <TextArea
                      autoFocus
                      placeholder="Search by name, old name, job, or ckey"
                      value={searchTerm}
                      onChange={setSearchTerm}
                      height="2rem"
                      width="380px"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="sync"
                      content="Refresh"
                      onClick={() => act('refresh')}
                    />
                  </Stack.Item>
                </Stack>
              }
            >
              <AdminHelpers />
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Section
              title={`Players (${sortedPlayers.length})`}
              fill
              scrollable
            >
              <Table>
                <Table.Row header>
                  <Table.Cell collapsing textAlign="center">
                    Sel
                  </Table.Cell>
                  <SortableCell label="Ckey" sortKey="ckey" {...sortProps} />
                  <SortableCell
                    label="Char Name"
                    sortKey="name"
                    {...sortProps}
                  />
                  <SortableCell label="Job" sortKey="job" {...sortProps} />
                  <Table.Cell textAlign="center">Location</Table.Cell>
                  {!!data?.exp_tracking && (
                    <SortableCell
                      label="Hrs"
                      sortKey="playtime"
                      {...sortProps}
                    />
                  )}
                  <Table.Cell textAlign="center">Vitals</Table.Cell>
                  <Table.Cell textAlign="center">Actions</Table.Cell>
                </Table.Row>
                {sortedPlayers.map((player) => (
                  <PlayerRow
                    key={player.ckey}
                    player={player}
                    rights={rights}
                    selected={player.ckey === selectedCkey}
                    showPlaytime={!!data?.exp_tracking}
                    onSelect={(ckey) => setSelectedCkey(ckey)}
                    onAction={handleAction}
                  />
                ))}
              </Table>
            </Section>
          </Stack.Item>

          {!!selectedPlayer && (
            <Stack.Item height="230px">
              <Section fill>
                <PlayerDetails
                  player={selectedPlayer}
                  rights={rights}
                  data={data}
                  onAction={handleAction}
                  onOpenOptions={() =>
                    handleAction('openAdditionalPanel', selectedPlayer.ckey)
                  }
                  onDeselect={() => setSelectedCkey('')}
                />
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
