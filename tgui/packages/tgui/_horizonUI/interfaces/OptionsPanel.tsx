import { useState, type FC } from 'react';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import { Window } from '../../layouts';

interface MuteStates {
  ic: boolean;
  ooc: boolean;
  pray: boolean;
  adminhelp: boolean;
  deadchat: boolean;
  webreq: boolean;
}

interface PlayerData {
  characterName: string;
  ckey: string;
  ipAddress: string;
  CID: string;
  gameState: string;
  dbLink: string;
  byondVersion: string;
  mobType: string;
  relatedByCid: string;
  relatedByIp: string;
  firstSeen: string;
  accountRegistered: string;
  adminRights: string;
  muteStates: MuteStates;
}

interface BackendData {
  Data: PlayerData;
}

const DEFAULT_PLAYER_DATA: PlayerData = {
  characterName: 'Unknown',
  ckey: '',
  ipAddress: '0.0.0.0',
  CID: 'NO_CID',
  gameState: 'Unknown',
  dbLink: '',
  byondVersion: '0.0.0',
  mobType: 'null',
  relatedByCid: '',
  relatedByIp: '',
  firstSeen: 'Never',
  accountRegistered: 'Unknown',
  adminRights: '',
  muteStates: {
    ic: false,
    ooc: false,
    pray: false,
    adminhelp: false,
    deadchat: false,
    webreq: false,
  },
};

const isMobType = (currentType: string, checkType: string): boolean => {
  const types = {
    ghost: ['ghost', 'dead', 'observer'],
    human: ['human', 'carbon'],
    monkey: ['monkey', 'primate'],
    cyborg: ['cyborg', 'robot', 'borg'],
    ai: ['ai', 'artificial intelligence'],
  };
  return (
    types[checkType]?.some((type) =>
      currentType.toLowerCase().includes(type),
    ) || false
  );
};

// Page registry - CM13-style PAGES array
type PageDef = {
  title: string;
  icon: string;
  color: string;
  component: () => FC<PageProps>;
  canAccess?: (playerData: PlayerData) => boolean;
};

const PAGES: PageDef[] = [
  {
    title: 'General',
    icon: 'tools',
    color: 'green',
    component: () => GeneralPage,
  },
  {
    title: 'Message',
    icon: 'comment',
    color: 'blue',
    component: () => MessagePage,
  },
  {
    title: 'Punish',
    icon: 'gavel',
    color: 'red',
    component: () => PunishPage,
  },
  {
    title: 'Movement',
    icon: 'running',
    color: 'average',
    component: () => MovementPage,
  },
  {
    title: 'Transform',
    icon: 'exchange-alt',
    color: 'orange',
    component: () => TransformPage,
    canAccess: (d) => d.adminRights.toLowerCase().includes('spawn'),
  },
  {
    title: 'Fun',
    icon: 'laugh',
    color: 'yellow',
    component: () => FunPage,
  },
];

// Page props (shared by all page components)
type PageProps = {
  playerData: PlayerData;
  onAction: (action: string, params?: Record<string, unknown>) => void;
  isButtonAllowed: (right: string) => boolean;
  hasCkey: () => boolean;
};

// Main component
export const OptionsPanel = (_props: unknown) => {
  const { data, act } = useBackend<BackendData>();
  const [pageIndex, setPageIndex] = useState(0);

  const playerData: PlayerData = {
    ...DEFAULT_PLAYER_DATA,
    ...data?.Data,
    adminRights: data?.Data?.adminRights ?? '',
    muteStates: {
      ...DEFAULT_PLAYER_DATA.muteStates,
      ...data?.Data?.muteStates,
    },
  };

  const handleAction = (
    action: string,
    params: Record<string, unknown> = {},
  ) => {
    act(action, { selectedPlayerCkey: playerData.ckey, ...params });
  };

  const isButtonAllowed = (checkRight: string): boolean => {
    return playerData.adminRights.toLowerCase().includes(checkRight);
  };

  const hasCkey = (): boolean => {
    return playerData.ckey !== '' && playerData.ckey !== 'Unknown';
  };

  // Error display if critical data is missing
  if (!playerData.ckey) {
    return (
      <Window title="Options Panel - Error" width={520} height={360}>
        <Window.Content>
          <Section title="Error">
            <Box color="red">
              No valid player data found. Please refresh or select a valid
              player.
            </Box>
            <Button
              icon="sync"
              content="Refresh"
              onClick={() => act('refresh')}
            />
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const accessiblePages = PAGES.filter(
    (p) => !p.canAccess || p.canAccess(playerData),
  );
  const safeIndex = Math.min(pageIndex, accessiblePages.length - 1);
  const ActivePage = accessiblePages[safeIndex]?.component();

  const pageProps: PageProps = {
    playerData,
    onAction: handleAction,
    isButtonAllowed,
    hasCkey,
  };

  return (
    <Window
      theme="ntos_darkmode"
      title={`Options Panel - ${playerData.ckey}`}
      width={520}
      height={360}
    >
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <PlayerHeader
              playerData={playerData}
              onAction={handleAction}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item>
                <Section fitted fill>
                  <Tabs vertical>
                    {accessiblePages.map((page, i) => (
                      <Tabs.Tab
                        key={page.title}
                        color={page.color}
                        icon={page.icon}
                        selected={i === safeIndex}
                        onClick={() => setPageIndex(i)}
                      >
                        {page.title}
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                </Section>
              </Stack.Item>
              <Stack.Item position="relative" grow basis={0} ml={1}>
                <Section fill scrollable>
                  {ActivePage && <ActivePage {...pageProps} />}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// Header - always visible at top, compact player identity summary
const PlayerHeader = ({
  playerData,
  onAction,
}: {
  playerData: PlayerData;
  onAction: (action: string, params?: Record<string, unknown>) => void;
}) => {
  const [hideIP, setIP] = useState(false);
  const [hideCID, setCID] = useState(false);

  return (
    <Section>
      <Stack align="center">
        <Stack.Item grow>
          <Box bold fontSize="14px">{playerData.characterName}</Box>
          <Box color="label" fontSize="11px">
            {playerData.ckey} · {playerData.mobType}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="sync"
            content="Refresh"
            onClick={() => onAction('refresh')}
          />
        </Stack.Item>
      </Stack>
      <Table mt={1}>
        <Table.Row>
          <Table.Cell bold color="label">
            CID:
          </Table.Cell>
          <Table.Cell>
            <Button color="green" compact onClick={() => setCID(!hideCID)}>
              {hideCID ? playerData.CID : 'Hidden'}
            </Button>
          </Table.Cell>
          <Table.Cell bold color="label">
            Byond:
          </Table.Cell>
          <Table.Cell>{playerData.byondVersion}</Table.Cell>
          <Table.Cell bold color="label">
            State:
          </Table.Cell>
          <Table.Cell>{playerData.gameState}</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold color="label">
            IP:
          </Table.Cell>
          <Table.Cell>
            <Button color="green" compact onClick={() => setIP(!hideIP)}>
              {hideIP ? playerData.ipAddress : 'Hidden'}
            </Button>
          </Table.Cell>
          <Table.Cell bold color="label">
            First Seen:
          </Table.Cell>
          <Table.Cell>{playerData.firstSeen}</Table.Cell>
          <Table.Cell bold color="label">
            Account:
          </Table.Cell>
          <Table.Cell>{playerData.accountRegistered}</Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

// Helper - gated button with consistent tooltip behaviour
type GatedButtonProps = {
  icon?: string;
  color?: string;
  content: string;
  action: string;
  onAction: (action: string, params?: Record<string, unknown>) => void;
  isButtonAllowed: (right: string) => boolean;
  hasCkey: () => boolean;
  requiredRight?: string;
  params?: Record<string, unknown>;
};

const GatedButton = ({
  icon,
  color,
  content,
  action,
  onAction,
  isButtonAllowed,
  hasCkey,
  requiredRight,
  params,
}: GatedButtonProps) => {
  const noCkey = !hasCkey();
  const noRight = requiredRight ? !isButtonAllowed(requiredRight) : false;
  const disabled = noCkey || noRight;
  let tooltip: string | undefined;
  if (noCkey) tooltip = 'NO CKEY';
  else if (noRight) tooltip = `Requires ${requiredRight!.toUpperCase()}`;
  const button = (
    <Button
      fluid
      icon={icon}
      color={color}
      content={content}
      disabled={disabled}
      onClick={disabled ? undefined : () => onAction(action, params)}
    />
  );
  return tooltip ? (
    <Tooltip content={tooltip}>{button}</Tooltip>
  ) : (
    button
  );
};

// Page: General - info / inspection / lookup actions
const GeneralPage = ({
  onAction,
  isButtonAllowed,
  hasCkey,
}: PageProps) => {
  return (
    <>
      <Section title="Inspection">
        <Stack>
          <Stack.Item grow>
            <GatedButton
              icon="book"
              content="LOGS"
              action="logs"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
            />
            <GatedButton
              icon="clipboard"
              content="NOTES"
              action="notes"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
            />
            <GatedButton
              icon="code"
              content="VV"
              action="vv"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
            />
          </Stack.Item>
          <Stack.Item grow>
            <GatedButton
              icon="user-secret"
              content="TRAITOR PANEL"
              action="tp"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
            />
            <GatedButton
              icon="eye"
              content="PLAYTIME"
              action="playtime"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="admin"
            />
            <GatedButton
              icon="language"
              content="LANGUAGE"
              action="language"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="admin"
            />
          </Stack.Item>
        </Stack>
      </Section>

      <Section title="Lookup">
        <Stack>
          <Stack.Item grow>
            <GatedButton
              icon="database"
              content="CENTCOM DB"
              action="dblink"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
            />
          </Stack.Item>
          <Stack.Item grow>
            <GatedButton
              icon="link"
              content="RELATED BY CID"
              action="relatedbycid"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
            />
          </Stack.Item>
          <Stack.Item grow>
            <GatedButton
              icon="link"
              content="RELATED BY IP"
              action="relatedbyip"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
            />
          </Stack.Item>
        </Stack>
      </Section>

      <Section title="Player Setup">
        <Stack>
          <Stack.Item grow>
            <GatedButton
              icon="user-edit"
              content="APPLY CLIENT QUIRKS"
              action="applyquirks"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="admin"
            />
          </Stack.Item>
          <Stack.Item grow>
            <GatedButton
              icon="brain"
              content="SKILLS"
              action="skills"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="admin"
            />
          </Stack.Item>
        </Stack>
      </Section>
    </>
  );
};

// Page: Message
const MessagePage = ({
  onAction,
  isButtonAllowed,
  hasCkey,
}: PageProps) => {
  return (
    <>
      <Section title="Direct">
        <Stack>
          <Stack.Item grow>
            <GatedButton
              icon="comment"
              content="PM"
              action="pm"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
            />
            <GatedButton
              icon="user-secret"
              content="SM"
              action="sm"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="admin"
            />
            <GatedButton
              icon="comment-alt"
              content="NARRATE"
              action="narrate"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="admin"
            />
          </Stack.Item>
          <Stack.Item grow>
            <GatedButton
              icon="comment"
              content="FORCESAY"
              action="forcesay"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="fun"
            />
            <GatedButton
              icon="music"
              content="PLAY SOUND TO"
              action="playsoundto"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="sound"
            />
          </Stack.Item>
        </Stack>
      </Section>

      <Section title="Faction Reply">
        <Stack>
          <Stack.Item grow>
            <GatedButton
              icon="satellite-dish"
              content="CENTCOM REPLY"
              action="centcom_reply"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="admin"
            />
          </Stack.Item>
          <Stack.Item grow>
            <GatedButton
              icon="skull"
              content="SYNDICATE REPLY"
              action="syndicate_reply"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="admin"
            />
          </Stack.Item>
        </Stack>
      </Section>
    </>
  );
};

// Page: Punish - KICK / BAN / SMITE / PRISON / UNPRISON + Mute Controls
const PunishPage = ({
  playerData,
  onAction,
  isButtonAllowed,
  hasCkey,
}: PageProps) => {
  return (
    <>
      <Section title="Punishment">
        <Stack>
          <Stack.Item grow>
            <GatedButton
              icon="times"
              color="red"
              content="KICK"
              action="kick"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
            />
            <GatedButton
              icon="ban"
              color="red"
              content="BAN"
              action="ban"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="ban"
            />
          </Stack.Item>
          <Stack.Item grow>
            <GatedButton
              icon="bolt"
              color="red"
              content="SMITE"
              action="smite"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="fun"
            />
            <GatedButton
              color="red"
              content="PRISON"
              action="prison"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="admin"
            />
            <GatedButton
              color="red"
              content="UNPRISON"
              action="unprison"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={hasCkey}
              requiredRight="admin"
            />
          </Stack.Item>
        </Stack>
      </Section>

      <Section title="Mute Controls">
        <MuteGrid
          playerData={playerData}
          onAction={onAction}
          hasCkey={hasCkey}
        />
      </Section>
    </>
  );
};

const MuteGrid = ({
  playerData,
  onAction,
  hasCkey,
}: Pick<PageProps, 'playerData' | 'onAction' | 'hasCkey'>) => {
  const m = playerData.muteStates;
  const toggleMute = (type: string) => {
    if (!hasCkey()) return;
    onAction('toggleMute', { type });
  };
  const toggleAllMutes = () => {
    if (!hasCkey()) return;
    onAction('toggleAllMutes');
  };
  return (
    <Stack>
      <Stack.Item grow>
        <Button.Checkbox
          fluid
          checked={m.ic}
          onClick={() => toggleMute('ic')}
          content="IC"
          color={!m.ic ? 'green' : 'red'}
        />
        <Button.Checkbox
          fluid
          checked={m.ooc}
          onClick={() => toggleMute('ooc')}
          content="OOC"
          color={!m.ooc ? 'green' : 'red'}
        />
        <Button.Checkbox
          fluid
          checked={m.pray}
          onClick={() => toggleMute('pray')}
          content="PRAY"
          color={!m.pray ? 'green' : 'red'}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Button.Checkbox
          fluid
          checked={m.adminhelp}
          onClick={() => toggleMute('adminhelp')}
          content="ADMINHELP"
          color={!m.adminhelp ? 'green' : 'red'}
        />
        <Button.Checkbox
          fluid
          checked={m.deadchat}
          onClick={() => toggleMute('deadchat')}
          content="DEADCHAT"
          color={!m.deadchat ? 'green' : 'red'}
        />
        <Button.Checkbox
          fluid
          checked={m.webreq}
          onClick={() => toggleMute('webreq')}
          content="WEBREQ"
          color={!m.webreq ? 'green' : 'red'}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          content="Toggle All"
          onClick={toggleAllMutes}
          disabled={!hasCkey()}
          tooltip={!hasCkey() ? 'NO CKEY' : undefined}
        />
      </Stack.Item>
    </Stack>
  );
};

// Page: Movement
const MovementPage = ({
  onAction,
  isButtonAllowed,
  hasCkey,
}: PageProps) => {
  return (
    <Section title="Movement">
      <Stack>
        <Stack.Item grow>
          <GatedButton
            icon="eye"
            content="FLW"
            action="flw"
            onAction={onAction}
            isButtonAllowed={isButtonAllowed}
            hasCkey={hasCkey}
          />
          <GatedButton
            icon="running"
            content="JUMPTO"
            action="jumpto"
            onAction={onAction}
            isButtonAllowed={isButtonAllowed}
            hasCkey={hasCkey}
            requiredRight="admin"
          />
          <GatedButton
            icon="download"
            content="GET"
            action="get"
            onAction={onAction}
            isButtonAllowed={isButtonAllowed}
            hasCkey={hasCkey}
            requiredRight="admin"
          />
        </Stack.Item>
        <Stack.Item grow>
          <GatedButton
            icon="paper-plane"
            content="SEND"
            action="send"
            onAction={onAction}
            isButtonAllowed={isButtonAllowed}
            hasCkey={hasCkey}
            requiredRight="admin"
          />
          <GatedButton
            icon="sign-out-alt"
            content="LOBBY"
            action="lobby"
            onAction={onAction}
            isButtonAllowed={isButtonAllowed}
            hasCkey={hasCkey}
            requiredRight="admin"
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

// Page: Transform - mob type swaps + health actions
const TransformPage = ({
  playerData,
  onAction,
  isButtonAllowed,
}: PageProps) => {
  return (
    <>
      <Section title="Transformation">
        <Stack>
          <Stack.Item grow>
            <Button
              fluid
              icon="ghost"
              content="MAKE GHOST"
              color={isMobType(playerData.mobType, 'ghost') ? 'good' : ''}
              onClick={() => onAction('makeghost')}
            />
            <Button
              fluid
              icon="user"
              content="MAKE HUMAN"
              color={isMobType(playerData.mobType, 'human') ? 'good' : ''}
              onClick={() => onAction('makehuman')}
            />
            <Button
              fluid
              icon="paw"
              content="MAKE MONKEY"
              color={isMobType(playerData.mobType, 'monkey') ? 'good' : ''}
              onClick={() => onAction('makemonkey')}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              icon="robot"
              content="MAKE CYBORG"
              color={isMobType(playerData.mobType, 'cyborg') ? 'good' : ''}
              onClick={() => onAction('makeborg')}
            />
            <Button
              fluid
              icon="microchip"
              content="MAKE AI"
              color={isMobType(playerData.mobType, 'ai') ? 'good' : ''}
              onClick={() => onAction('makeai')}
            />
          </Stack.Item>
        </Stack>
      </Section>

      <Section title="Health">
        <Stack>
          <Stack.Item grow>
            <Button
              fluid
              icon="heart"
              content="HEALTHSCAN"
              onClick={() => onAction('healthscan')}
            />
            <Button
              fluid
              content="CHEMSCAN"
              onClick={() => onAction('chemscan')}
            />
            <GatedButton
              content="CURE ALL BAD DISEASES"
              action="cureAllDiseases"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={() => true}
              requiredRight="admin"
            />
          </Stack.Item>
          <Stack.Item grow>
            <GatedButton
              icon="plus"
              content="AHEAL"
              action="aheal"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={() => true}
              requiredRight="admin"
            />
            <GatedButton
              content="MODIFY TRAITS"
              action="modifytraits"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={() => true}
              requiredRight="admin"
            />
            <GatedButton
              content="GIVE DISEASE"
              action="giveDisease"
              onAction={onAction}
              isButtonAllowed={isButtonAllowed}
              hasCkey={() => true}
              requiredRight="admin"
            />
          </Stack.Item>
        </Stack>
      </Section>
    </>
  );
};

// Page: Fun - thunderdome / commend / cookie
const FunPage = ({
  onAction,
  isButtonAllowed,
  hasCkey,
}: PageProps) => {
  return (
    <Section title="Fun">
      <Stack>
        <Stack.Item grow>
          <GatedButton
            icon="gavel"
            content="THUNDERDOME 1"
            action="thunderdome1"
            onAction={onAction}
            isButtonAllowed={isButtonAllowed}
            hasCkey={hasCkey}
            requiredRight="fun"
          />
          <GatedButton
            icon="gavel"
            content="THUNDERDOME 2"
            action="thunderdome2"
            onAction={onAction}
            isButtonAllowed={isButtonAllowed}
            hasCkey={hasCkey}
            requiredRight="fun"
          />
          <GatedButton
            icon="gavel"
            content="THUNDERDOME ADMIN"
            action="thunderdomeadmin"
            onAction={onAction}
            isButtonAllowed={isButtonAllowed}
            hasCkey={hasCkey}
            requiredRight="fun"
          />
        </Stack.Item>
        <Stack.Item grow>
          <GatedButton
            icon="eye"
            content="THUNDERDOME OBSERVER"
            action="thunderdomeobserve"
            onAction={onAction}
            isButtonAllowed={isButtonAllowed}
            hasCkey={hasCkey}
            requiredRight="fun"
          />
          <GatedButton
            icon="star"
            content="COMMEND"
            action="commend"
            onAction={onAction}
            isButtonAllowed={isButtonAllowed}
            hasCkey={hasCkey}
            requiredRight="admin"
          />
          <GatedButton
            icon="cookie"
            content="SPAWN COOKIE"
            action="spawncookie"
            onAction={onAction}
            isButtonAllowed={isButtonAllowed}
            hasCkey={hasCkey}
            requiredRight="fun"
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export default OptionsPanel;
