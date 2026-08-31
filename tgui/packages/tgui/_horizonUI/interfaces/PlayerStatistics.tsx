/**
 * @copyright 2024 Veth-s (https://github.com/Monkestation/Monkestation2.0/issues/4030)
 * @author Original Veth-s
 * @author Changes KOCMOHABT
 */
import { Section, LabeledList } from 'tgui-core/components';
import { Window } from '../../layouts';
import { useBackend } from '../../backend';
type Data = {
  total_clients: number;
  living_players: number;
  dead_players: number;
  observers: number;
  living_antags: number;
};

export const PlayerStatistics = () => {
  const {
    data: {
      total_clients,
      living_players,
      dead_players,
      observers,
      living_antags,
    },
  } = useBackend<Data>();

  return (
    <Window title="Player Statistics" width={400} height={180} theme="ntos_darkmode">
      <Section title="Player Overview">
        <LabeledList>
          <LabeledList.Item
            label="Total Clients"
            labelColor="#4287f5"
            color="#4287f5"
          >
            {total_clients}
          </LabeledList.Item>
          <LabeledList.Item
            label="Living Players"
            labelColor="#1d9123"
            color="#1d9123"
          >
            {living_players}
          </LabeledList.Item>
          <LabeledList.Item
            label="Dead Players"
            labelColor="#666e66"
            color="#666e66"
          >
            {dead_players}
          </LabeledList.Item>
          <LabeledList.Item
            label="Observers"
            labelColor="#34949e"
            color="#34949e"
          >
            {observers}
          </LabeledList.Item>
          <LabeledList.Item
            label="Living Antags"
            labelColor="#bd2924"
            color="#bd2924"
          >
            {living_antags}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Window>
  );
};
