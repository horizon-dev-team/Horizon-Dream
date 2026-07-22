import { useBackend } from 'tgui/backend';

import type { PreferencesMenuData } from '../../../types';
import {
  CheckboxInput,
  type FeatureChoiced,
  type FeatureChoicedServerData,
  type FeatureToggle,
  type FeatureValueProps,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const ghost_accs: FeatureChoiced = {
  name: 'Ghost accessories',
  category: 'GHOST',
  description: 'Determines what adjustments your ghost will have.',
  component: FeatureDropdownInput,
};

export const ghost_hud: FeatureToggle = {
  name: 'Ghost HUD',
  category: 'GHOST',
  description: 'Enable HUD buttons for ghosts.',
  component: CheckboxInput,
};

export const ghost_orbit: FeatureChoiced = {
  name: 'Ghost orbit',
  category: 'GHOST',
  description: `
    The shape in which your ghost will orbit.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    const { data } = useBackend<PreferencesMenuData>();

    return (
      <FeatureDropdownInput {...props} />
    );
  },
};

export const inquisitive_ghost: FeatureToggle = {
  name: 'Ghost inquisitiveness',
  category: 'GHOST',
  description: 'Clicking on something as a ghost will examine it.',
  component: CheckboxInput,
};

export const ghost_roles: FeatureToggle = {
  name: 'Get ghost roles',
  category: 'GHOST',
  description: `
    If you de-select this, you will not get any ghost role pop-ups what-so-ever!
    Every single type of these pop-ups WILL be muted for you when you are
    ghosted. Very useful for those who find ghost roles or the
    pop-ups annoying, use at your own peril.
`,
  component: CheckboxInput,
};
