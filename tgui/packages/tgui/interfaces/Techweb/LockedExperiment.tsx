import { Box, Button, Flex, Icon } from 'tgui-core/components';

export function LockedExperiment(props) {
  return (
    <Box m={1} className="ExperimentConfigure__ExperimentPanel">
      <Button
        fluid
        backgroundColor="#40628a"
        className="ExperimentConfigure__ExperimentName"
        disabled
      >
        <Flex align="center" justify="space-between">
          <Flex.Item class="Techweb__Locked">
            <Icon name="lock" />
            Undiscovered Experiment
          </Flex.Item>
          <Flex.Item class="Techweb__Locked">???</Flex.Item>
        </Flex>
      </Button>
      <Box className="ExperimentConfigure__ExperimentContent">
        This experiment has not been discovered yet, continue researching nodes
        in the tree to discover the contents of this experiment.
      </Box>
    </Box>
  );
}
