import { Window } from '../layouts';
import { Button, Input, Section, Stack } from 'tgui-core/components';

export function Changelog() {
  return (
    <Window title="Horizon Changelog" width={700} height={720}
      buttons={
        <Stack align="center">
          <Button
            m={0}
            icon='paste'
            color='yellow'
            tooltip="Open changelog in browser"
            onClick={() => Byond.command('.url https://horizon-dev-team.github.io/Horizon-Changelog/')}
          />
        </Stack>
      }>
      <Window.Content>
        <iframe
          style={{ width: '100%', height: '100%', border: 'none' }}
          src="https://horizon-dev-team.github.io/Horizon-Changelog/"
        />
      </Window.Content>
    </Window>
  );
}
