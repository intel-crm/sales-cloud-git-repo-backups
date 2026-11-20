import fetchTaxonomyData from './fetchTaxonomyData';
import subscribeToTaxonomyData, {
  requiredTaxonomyList,
  taxonomyByCategoryId,
  topLevelTaxonomyIds,
} from './dataManager';

export default {
  fetchTaxonomyData,
  subscribeToTaxonomyData,
  taxonomyDataHelpers: {
    requiredTaxonomyList,
    taxonomyByCategoryId,
    topLevelTaxonomyIds,
  },
};