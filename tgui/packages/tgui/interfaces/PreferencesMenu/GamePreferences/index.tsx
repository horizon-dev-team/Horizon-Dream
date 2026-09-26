import { useState } from 'react';
import { Stack } from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive';

import { PageButton } from '../components/PageButton';
import { GamePreferencesSelectedPage } from '../types';
import { GamePreferencesPage } from './GamePreferencesPage';
import { KeybindingsPage } from './KeybindingsPage';
import { VolumeMixerPage } from '../VolumeMixerPage';

type Props = {
  startingPage?: GamePreferencesSelectedPage;
};

export function GamePreferenceWindow(props: Props) {
  const [currentPage, setCurrentPage] = useState(
    props.startingPage ?? GamePreferencesSelectedPage.Settings,
  );

  let pageContents;

  switch (currentPage) {
    case GamePreferencesSelectedPage.Keybindings:
      pageContents = <KeybindingsPage />;
      break;
    case GamePreferencesSelectedPage.Settings:
      pageContents = <GamePreferencesPage />;
      break;
    case GamePreferencesSelectedPage.VolumeMixer:
      pageContents = <VolumeMixerPage />;
      break;
    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack fill>
          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={GamePreferencesSelectedPage.Settings}
              setPage={setCurrentPage}
            >
              Settings
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={GamePreferencesSelectedPage.Keybindings}
              setPage={setCurrentPage}
            >
              Keybindings
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={GamePreferencesSelectedPage.VolumeMixer}
              setPage={setCurrentPage}
            >
              Volume Mixer
            </PageButton>
          </Stack.Item>
        </Stack>
      </Stack.Item>

      <Stack.Divider />

      <Stack.Item grow shrink basis="1px">
        {pageContents}
      </Stack.Item>
    </Stack>
  );
}
