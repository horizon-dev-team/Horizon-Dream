import { useBackend } from 'tgui/backend';
import { Box, Button, Section, Slider, Stack, Tooltip } from 'tgui-core/components';
import { features } from './preferences/features';
import { FeatureValueInput } from './preferences/features/base';
import type { Channel, PreferencesMenuData } from './types';

const SOUND_OPTIONS = [
  'sound_combatmode',
  'sound_achievement',
  'sound_ghost_poll_prompt',
  'sound_ghost_poll_prompt_volume',
  'sound_tts',
  'sound_tts_radio',
  'sound_tts_hear_self_radio',
];

const groupChannelsByCategory = (channels: Channel[]) => {
  return channels.reduce<Record<string, Channel[]>>((groups, ch) => {
    const category = ch.category || 'General';
    groups[category] = groups[category] || [];
    groups[category].push(ch);
    return groups;
  }, {});
};

export const VolumeMixerPage = () => {
  const { data, act } = useBackend<PreferencesMenuData>();
  const { channels = [] } = data;
  const gamePreferences = data.character_preferences?.game_preferences ?? {};

  const globalMaster = channels.find((c) => c.name === 'Master Volume');
  const otherChannels = channels.filter((c) => c.name !== 'Master Volume');

  const groupedChannels = groupChannelsByCategory(otherChannels);

  const categories = Object.keys(groupedChannels).sort((a, b) => {
    const countA = groupedChannels[a].length;
    const countB = groupedChannels[b].length;

    if (countA !== countB) {
      return countB - countA;
    }

    return a.localeCompare(b);
  });

  const halfIndex = Math.ceil(SOUND_OPTIONS.length / 2);
  const leftOptions = SOUND_OPTIONS.slice(0, halfIndex);
  const rightOptions = SOUND_OPTIONS.slice(halfIndex);

  const renderSoundOption = (optionId: string) => {
    const feature = features[optionId];
    const value = gamePreferences[optionId];
    if (!feature || value === undefined) {
      return null;
    }
    return (
      <Stack.Item key={optionId} mb={1}>
        <Stack align="center">
          <Stack.Item grow={1} pr={2}>
            <Tooltip content={feature.description} position="bottom-start">
              <Box as="span" fontSize="0.85rem">
                {feature.name}
              </Box>
            </Tooltip>
          </Stack.Item>
          <Stack.Item style={{ minWidth: 160, width: 180 }}>
            <FeatureValueInput
              feature={feature}
              featureId={optionId}
              value={value}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    );
  };

  return (
    <Section fill scrollable overflow="auto">
      {globalMaster && (
        <Box mb={2}>
          <Box fontSize="1rem" color="label" mb={1}>Global Master Volume</Box>
          <Stack align="center">
            <Stack.Item grow={1}>
              <Slider
                minValue={0}
                maxValue={100}
                stepPixelSize={8}
                value={globalMaster.volume}
                onChange={(_, value) =>
                  act('volume', { channel: globalMaster.num, volume: Math.round(value) })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                color="transparent"
                icon="play"
                tooltip="Test"
                onClick={() => act('test_sound', { channel: globalMaster.num })}
              />
              <Button
                compact
                color="transparent"
                icon="arrow-rotate-right"
                tooltip="Reset"
                onClick={() => act('volume', { channel: globalMaster.num, volume: 100 })}
              />
            </Stack.Item>
          </Stack>
        </Box>
      )}

      <Stack wrap>
        {categories.map((category) => {
          return (
            <Stack.Item
              key={category}
              grow={1}
              basis="48%"
              style={{ minWidth: '250px' }}
            >
              <Box
                fontSize="0.95rem"
                bold
                color="label"
                mt="6px"
                style={{ borderBottom: '1px solid rgba(255, 255, 255, 0.2)' }}
              >
                {category}
              </Box>

              <Stack align="start" direction="row" wrap>
                {groupedChannels[category].map((channel) => (
                  <Stack.Item key={channel.num} width={17} style={{ margin: '2px' }}>
                    <VolumeSlider channel={channel} />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          );
        })}
      </Stack>

      <Box
        fontSize="0.95rem"
        bold
        color="label"
        mb={1}
        style={{ borderBottom: '1px solid rgba(255, 255, 255, 0.2)', marginTop: '10px' }}
      >
        Sound Options
      </Box>

      <Stack wrap>
        <Stack.Item grow={1} basis="48%" style={{ minWidth: '250px' }}>
          <Stack direction="column">
            {leftOptions.map(renderSoundOption)}
          </Stack>
        </Stack.Item>

        <Stack.Item grow={1} basis="48%" style={{ minWidth: '250px' }}>
          <Stack direction="column">
            {rightOptions.map(renderSoundOption)}
          </Stack>
        </Stack.Item>
      </Stack>

      <Box mt="15px" textAlign="center">
        <Button
          icon="volume-xmark"
          color="bad"
          onClick={() => act('stop_all_sounds')}
        >
          Stop Test Sound
        </Button>
        <Button
          icon="arrow-rotate-right"
          ml={2}
          onClick={() => act('reset_all_volumes')}
        >
          Reset All to Default
        </Button>
      </Box>
    </Section>
  );
};

const VolumeSlider = (props: { channel: Channel }) => {
  const { act } = useBackend<PreferencesMenuData>();
  const { channel } = props;

  return (
    <Box backgroundColor="rgba(0, 0, 0, 0.15)" style={{ padding: '3px 5px', borderRadius: '3px' }}>
      <Tooltip position="bottom" content={channel.desc}>
        <Box
          fontSize="0.75rem"
          mb="2px"
          as="span"
          style={{ borderBottom: '1px dotted rgba(255, 255, 255, 0.5)' }}
        >
          {channel.name}
        </Box>
      </Tooltip>
      <Stack align="center">
        <Stack.Item grow={1}>
          <Slider
            value={channel.volume}
            minValue={0}
            maxValue={100}
            fontSize="0.65rem"
            stepPixelSize={2}
            onChange={(_, value) => act('volume', {channel: channel.num, volume: Math.round(value)})}
          />
        </Stack.Item>
        <Stack.Item ml="2px">
          <Button
            compact
            color="transparent"
            icon="play"
            tooltip="Test"
            tooltipPosition="bottom"
            onClick={() => act('test_sound', { channel: channel.num })}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};
