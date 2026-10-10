import { useState } from 'react';
import {
  Button,
  Collapsible,
  Divider,
  Input,
  LabeledList,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { capitalize } from 'tgui-core/string';
import { chatRenderer } from '../chat/renderer';
import { FONTS, THEMES } from './constants';
import { resetPaneSplitters, setEditPaneSplitters } from './scaling';
import { exportChatSettings, importChatSettings } from './settingsImExport';
import { useSettings } from './use-settings';

export function SettingsGeneral() {
  const { settings, updateSettings } = useSettings();
  const [freeFont, setFreeFont] = useState(false);

  const [editingPanes, setEditingPanes] = useState(false);

  const chatCorner = settings.chatCorner || 'top-right';
  const chatVertical = chatCorner.startsWith('top') ? 'top' : 'bottom';
  const chatHorizontal = chatCorner.endsWith('left') ? 'left' : 'right';

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Theme">
          {THEMES.map((THEME) => (
            <Button
              key={THEME}
              selected={settings.theme === THEME}
              color="transparent"
              onClick={() =>
                updateSettings({
                  theme: THEME,
                })
              }
            >
              {capitalize(THEME)}
            </Button>
          ))}
        </LabeledList.Item>
        {document.body.classList.contains('onmap') && (
          <>
            <LabeledList.Item label="Chat position">
              <Stack align="center">
                <Stack.Item>
                  <Button
                    selected={chatVertical === 'top'}
                    color="transparent"
                    tooltip="Pin the chat to the top edge (reversed log)"
                    onClick={() =>
                      updateSettings({ chatCorner: `top-${chatHorizontal}` })
                    }
                  >
                    Top
                  </Button>
                  <Button
                    selected={chatVertical === 'bottom'}
                    color="transparent"
                    tooltip="Pin the chat to the bottom edge"
                    onClick={() =>
                      updateSettings({ chatCorner: `bottom-${chatHorizontal}` })
                    }
                  >
                    Bottom
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Divider vertical />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    selected={chatHorizontal === 'left'}
                    color="transparent"
                    tooltip="Pin the chat to the left edge"
                    onClick={() =>
                      updateSettings({ chatCorner: `${chatVertical}-left` })
                    }
                  >
                    Left
                  </Button>
                  <Button
                    selected={chatHorizontal === 'right'}
                    color="transparent"
                    tooltip="Pin the chat to the right edge"
                    onClick={() =>
                      updateSettings({ chatCorner: `${chatVertical}-right` })
                    }
                  >
                    Right
                  </Button>
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Chat opacity">
              <Slider
                minValue={0.1}
                maxValue={1}
                step={0.05}
                value={settings.chatOpacity}
                format={(v) => `${Math.round(v * 100)}%`}
                onChange={(e, value) => updateSettings({ chatOpacity: value })}
              />
            </LabeledList.Item>
            {settings.chatFrameless && (
              <LabeledList.Item label="Message backdrop">
                <Button
                  selected={settings.chatMessageBg}
                  color="transparent"
                  icon={settings.chatMessageBg ? 'square' : 'square-xmark'}
                  onClick={() =>
                    updateSettings({ chatMessageBg: !settings.chatMessageBg })
                  }
                >
                  {settings.chatMessageBg ? 'Enabled' : 'Disabled'}
                </Button>
              </LabeledList.Item>
            )}
            {settings.chatFrameless && (
              <LabeledList.Item label="Collapse to peek strip">
                <Button
                  selected={settings.chatHoverStrip}
                  color="transparent"
                  icon={
                    settings.chatHoverStrip ? 'toggle-on' : 'toggle-off'
                  }
                  onClick={() =>
                    updateSettings({ chatHoverStrip: !settings.chatHoverStrip })
                  }
                >
                  {settings.chatHoverStrip ? 'Enabled' : 'Disabled'}
                </Button>
              </LabeledList.Item>
            )}
            {settings.chatFrameless && settings.chatHoverStrip && (
              <LabeledList.Item label="Combat strip">
                <Button
                  selected={settings.chatCombatStrip}
                  color="transparent"
                  icon={
                    settings.chatCombatStrip ? 'toggle-on' : 'toggle-off'
                  }
                  onClick={() =>
                    updateSettings({
                      chatCombatStrip: !settings.chatCombatStrip,
                    })
                  }
                >
                  {settings.chatCombatStrip ? 'Enabled' : 'Disabled'}
                </Button>
              </LabeledList.Item>
            )}
          </>
        )}
        <LabeledList.Item label="UI sizes">
          <Stack>
            <Stack.Item>
              <Button
                onClick={() =>
                  setEditingPanes((val) => {
                    setEditPaneSplitters(!val);
                    return !val;
                  })
                }
                color={editingPanes ? 'red' : undefined}
                icon={editingPanes ? 'save' : undefined}
              >
                {editingPanes ? 'Save' : 'Adjust UI Sizes'}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={resetPaneSplitters} icon="refresh" color="red">
                Reset
              </Button>
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Font style">
          <Stack.Item>
            {!freeFont ? (
              <Collapsible
                title={settings.fontFamily}
                width="100%"
                buttons={
                  <Button
                    icon={freeFont ? 'lock-open' : 'lock'}
                    color={freeFont ? 'good' : 'bad'}
                    onClick={() => {
                      setFreeFont(!freeFont);
                    }}
                  >
                    Custom font
                  </Button>
                }
              >
                {FONTS.map((FONT) => (
                  <Button
                    key={FONT}
                    fontFamily={FONT}
                    selected={settings.fontFamily === FONT}
                    color="transparent"
                    onClick={() =>
                      updateSettings({
                        fontFamily: FONT,
                      })
                    }
                  >
                    {FONT}
                  </Button>
                ))}
              </Collapsible>
            ) : (
              <Stack>
                <Input
                  fluid
                  value={settings.fontFamily}
                  onBlur={(value) =>
                    updateSettings({
                      fontFamily: value,
                    })
                  }
                />
                <Button
                  ml={0.5}
                  icon={freeFont ? 'lock-open' : 'lock'}
                  color={freeFont ? 'good' : 'bad'}
                  onClick={() => {
                    setFreeFont(!freeFont);
                  }}
                >
                  Custom font
                </Button>
              </Stack>
            )}
          </Stack.Item>
        </LabeledList.Item>
        <LabeledList.Item label="Font size" verticalAlign="middle">
          <Stack textAlign="center">
            <Stack.Item grow>
              <Slider
                width="100%"
                step={1}
                stepPixelSize={20}
                minValue={8}
                maxValue={18}
                value={settings.fontSize}
                unit="px"
                format={(value) => toFixed(value)}
                onChange={(e, value) => updateSettings({ fontSize: value })}
              />
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Line height">
          <Slider
            width="100%"
            step={0.01}
            minValue={0.8}
            maxValue={3}
            value={settings.lineHeight}
            format={(value) => toFixed(value, 2)}
            onChange={(e, value) =>
              updateSettings({
                lineHeight: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Command bar">
          <Button.Checkbox
            checked={settings.eagerCommandBarSuggestions}
            color="transparent"
            onClick={() =>
              updateSettings({
                eagerCommandBarSuggestions:
                  !settings.eagerCommandBarSuggestions,
              })
            }
          >
            Show suggestions while typing
          </Button.Checkbox>
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Stack fill>
        <Stack.Item mt={0.15}>
          <Button
            icon="compact-disc"
            tooltip="Export chat settings"
            onClick={exportChatSettings}
          >
            Export settings
          </Button>
        </Stack.Item>
        <Stack.Item mt={0.15}>
          <Button.File
            accept=".json"
            tooltip="Import chat settings"
            icon="arrow-up-from-bracket"
            onSelectFiles={importChatSettings}
          >
            Import settings
          </Button.File>
        </Stack.Item>
        <Stack.Item grow mt={0.15}>
          <Button
            icon="save"
            tooltip="Export current tab history into HTML file"
            onClick={() => chatRenderer.saveToDisk()}
          >
            Save chat log
          </Button>
        </Stack.Item>
        <Stack.Item mt={0.15}>
          <Button.Confirm
            icon="trash"
            tooltip="Erase current tab history"
            onClick={() => chatRenderer.clearChat()}
          >
            Clear chat
          </Button.Confirm>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
