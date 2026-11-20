import type { FeatureChoiced } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const directional_attack: FeatureChoiced = {
  name: 'Directional attack',
  category: 'GAMEPLAY',
  description:
    'Directional attacks let you hit a target by clicking past it, as long as it is within melee range. Only works within 1 tile.',
  component: FeatureDropdownInput,
};
