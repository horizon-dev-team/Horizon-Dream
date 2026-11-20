import { useMemo } from 'react';
import { Box, Button, ImageButton, Input, NoticeBox, Section, Stack, Tabs } from 'tgui-core/components';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';

type BuildModeData = {
  current_category: string;
  selected_item: string | null;
  pixel_positioning: boolean;
  build_dir: number;
  categories: BuildModeCategory[];
};

type BuildModeCategory = {
  id: string;
  name: string;
  items: BuildModeItem[];
};

type BuildModeItem = {
  path: string;
  name: string;
  icon: string;
};

export function BuildMode() {
  const { act, data } = useBackend<BuildModeData>();
  const { current_category, selected_item, pixel_positioning, categories } =
    data;

  const currentItems = useMemo(() => {
    const currentCategory = categories.find((c) => c.id === current_category);
    return currentCategory?.items || [];
  }, [categories, current_category]);

  const currentCategoryName = useMemo(() => {
    const currentCategory = categories.find((c) => c.id === current_category);
    return currentCategory?.name || 'items';
  }, [categories, current_category]);

  const selectedItemData = useMemo(() => {
    if (!selected_item) return null;
    for (const currentCategory of categories) {
      const found = currentCategory.items.find((i) => i.path === selected_item);
      if (found) return found;
    }
    return null;
  }, [categories, selected_item]);

  const { query, setQuery, results } = useFuzzySearch({
    searchArray: currentItems,
    matchStrategy: 'smart',
    getSearchString: (item: BuildModeItem) => {
      return `${item.path} ${item.name || ''}`;
    },
  });

  const displayItems = query === '' ? currentItems : results;

  return (
    <Window height={600} title="Build Panel" width={740}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Box style={{ overflowX: 'auto', overflowY: 'hidden' }}>
              <Tabs style={{ minWidth: 'min-content' }}>
                {categories.map((currentCategory) => (
                  <Tabs.Tab
                    key={currentCategory.id}
                    selected={current_category === currentCategory.id}
                    onClick={() => act('select_category', { category: currentCategory.id })}
                    style={{ minWidth: 'min-content' }}
                  >
                    {currentCategory.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Box>
          </Stack.Item>

          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item grow>
                  <Input
                    placeholder={`Search ${currentCategoryName}...`}
                    value={query}
                    onChange={(value) => setQuery(value)}
                    fluid
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="crosshairs"
                    selected={pixel_positioning}
                    tooltip="Toggle pixel positioning mode"
                    onClick={() => act('toggle_pixel')}
                  >
                    Pixel
                  </Button>
                </Stack.Item>
                {selected_item && (
                  <Stack.Item>
                    <Button
                      icon="times"
                      color="bad"
                      tooltip="Clear selection"
                      onClick={() => act('clear_selection')}
                    >
                      Clear
                    </Button>
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>

          {selectedItemData && (
            <Stack.Item>
              <Section style={{ height: '4em' }}>
                <Stack align="center">
                  <Stack.Item>
                    <ImageButton
                      asset={['buildmode32x32', selectedItemData.icon]}
                      imageSize={32}
                      selected
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Stack vertical>
                      <Stack.Item bold>{selectedItemData.name}</Stack.Item>
                      <Stack.Item
                        italic
                        style={{ color: 'rgba(200, 200, 200, 0.7)' }}
                      >
                        {selectedItemData.path}
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}

          <Stack.Item grow>
            <Section fill scrollable>
              {displayItems.length === 0 ? (
                <NoticeBox textAlign="center" color="blue" width="100%">
                  {query === ''
                    ? `No items in this category`
                    : 'Nothing found'}
                </NoticeBox>
              ) : (
                <Stack wrap>
                  {displayItems.map((item) => {
                    const shortPath = item.path.split('/').pop();
                    return (
                      <Stack.Item key={item.path} mb={1}>
                        <Stack vertical align="center" textAlign="center" width="64px">
                          <Stack.Item>
                            <ImageButton
                              asset={['buildmode32x32', item.icon]}
                              imageSize={32}
                              selected={selected_item === item.path}
                              color="transparent"
                              tooltip={
                                <Box fontFamily="monospace" style={{ wordBreak: 'break-word' }}>
                                  <Box>{item.name}</Box>
                                  <Box mt={0.5} color="rgba(200, 200, 200, 0.5)">{item.path}</Box>
                                </Box>
                              }
                              tooltipPosition="bottom"
                              onClick={() => act('select_item', { path: item.path })}
                            />
                          </Stack.Item>
                          <Stack.Item>
                            <Box
                              fontSize="10px"
                              style={{
                                overflow: 'hidden',
                                textOverflow: 'ellipsis',
                                whiteSpace: 'nowrap',
                                maxWidth: '64px',
                              }}
                            >
                              {item.name}
                            </Box>
                            <Box
                              fontSize="8px"
                              color="rgba(200, 200, 200, 0.5)"
                              style={{
                                overflow: 'hidden',
                                textOverflow: 'ellipsis',
                                whiteSpace: 'nowrap',
                                maxWidth: '64px',
                              }}
                            >
                              {shortPath}
                            </Box>
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    );
                  })}
                </Stack>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
