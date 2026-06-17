import React from 'react';
import {
  Box,
  Button,
  Flex,
  Input,
  Section,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const MAX_SEARCH_RESULTS = 25;

interface VerbItem {
  name: string;
  desc?: string;
  verb: string;
  selected?: boolean;
}

interface Category {
  name: string;
  items?: VerbItem[];
}

interface Context {
  compactMode: boolean;
  categories: Category[];
}

// Custom createSearch function since tgui-core/string doesn't exist
const createSearch = (searchText, getText) => {
  if (!searchText) return () => true;
  const searchLower = searchText.toLowerCase();
  return (item) => {
    const text = getText(item);
    return text && text.toLowerCase().includes(searchLower);
  };
};

export const AllVerbPanel = (props) => {
  const { act, data } = useBackend<Context>();
  const { compactMode, categories = [] } = data;

  // Use simple React state instead of useLocalState to avoid conflicts
  const [searchText, setSearchText] = React.useState('');
  const [selectedCategory, setSelectedCategory] = React.useState('Admin');

  // Clear search text when component mounts to prevent stale state
  React.useEffect(() => {
    setSearchText('');
  }, []);

  // Ensure categories data is always an array to prevent errors
  const safeCategories = Array.isArray(categories) ? categories : [];

  const testSearch = createSearch(searchText, (item) => {
    return item.name;
  });

  const items =
    (searchText.length > 0 &&
      safeCategories
        .filter(
          (category) =>
            category &&
            typeof category === 'object' &&
            category.name !== 'История'
        )
        .flatMap((category) =>
          Array.isArray(category.items) ? category.items : [],
        )
        .filter(testSearch)
        .filter((item, i) => i < MAX_SEARCH_RESULTS)) ||
    safeCategories.find(
      (category) =>
        category &&
        typeof category === 'object' &&
        category.name === selectedCategory,
    )?.items ||
    [];

  return (
    <Window theme="ntos_darkmode" width={500} height={720}>
      <Window.Content scrollable>
        <Section
          title={<Box inline>All Verb Panel</Box>}
          buttons={
            <>
              Поиск
              <Input
                autoFocus
                value={searchText}
                placeholder="Введите текст для поиска..."
                onChange={(value: string) => setSearchText(value)}
                onEnter={() => {
                  setSearchText('');
                  if(items.length > 0) {
                    act('run', {
                      name: items[0].name,
                      desc: items[0].desc,
                      verb: items[0].verb,
                    });
                  }
                }}
                mx={1}
              />
              <Button
                icon={compactMode ? 'list' : 'info'}
                children={compactMode ? 'Компактно' : 'Детально'}
                onClick={() => act('compact_toggle')}
              />
            </>
          }
        >
          <Flex>
            {searchText.length === 0 && (
              <Flex.Item>
                <Tabs vertical mr={1}>
                  {safeCategories.map((category) => (
                    <Tabs.Tab
                      key={category.name}
                      selected={category.name === selectedCategory}
                      onClick={() => setSelectedCategory(category.name)}
                    >
                      {category.name}
                    </Tabs.Tab>
                  ))}
                </Tabs>
              </Flex.Item>
            )}
            <Flex.Item grow={1} basis={0}>
              <VerbList
                compactMode={searchText.length > 0 || compactMode}
                items={items}
              />
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

const VerbList = (props) => {
  const { items = [], compactMode } = props;
  const { act } = useBackend();

  if (compactMode) {
    return (
      <Table>
        {items.map((obj) => (
          <Table.Row key={obj.name} className="candystripe">
            <Button
              fluid
              my={1}
              children={obj.name}
              selected={obj.selected}
              onClick={() =>
                act('run', {
                  name: obj.name,
                  desc: obj.desc,
                  verb: obj.verb,
                })
              }
            />
          </Table.Row>
        ))}
      </Table>
    );
  }
  return items.map((obj) => (
    <Section
      key={obj.name}
      mb={obj.desc ? 0 : -1}
      pb={obj.desc ? 0 : -1}
      title={
        <Button
          fluid
          children={obj.name}
          onClick={() =>
            act('run', {
              name: obj.name,
              desc: obj.desc,
              verb: obj.verb,
            })
          }
        />
      }
    >
      {!!obj.desc && <Box>{obj.desc}</Box>}
    </Section>
  ));
};
