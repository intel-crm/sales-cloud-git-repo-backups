import removeFilterLabel from '@salesforce/label/c.PMP_Offering_Filters_Remove';

/**
 * Filter Tags
 *
 * @param {object} paramFilters current feed param filters
 * @param {object[]} filters current set of filters
 * @returns {object} tags and params
 */
export default function buildTags(paramFilters, filters) {
  const tags = {};

  // hardcoded Category filter name
  const CATEGORIES = 'Categories';

  // update filters to remove filters that are no longer relevant based on AND criteria (count 0)
  const relevantParamFilters = Object.keys(paramFilters).reduce((newFilters, filter) => ({
    ...newFilters,
    [filter]: paramFilters[filter].filter((id) => filters[id].count),
  }), {});

  Object.keys(relevantParamFilters).forEach((filter) => {
    const filtersDup = [...relevantParamFilters[filter]];
    if (filter === CATEGORIES) {
      filtersDup.forEach((filterId) => {
        const { label } = filters[filterId];
        tags[filterId] = {
          id: filterId,
          label,
          clearAriaLabel: removeFilterLabel.replace('{0}', label),
          filterName: CATEGORIES,
        };
      });
    } else {
      const filterValues = new Set(filtersDup);

      const recursivelyBuildTags = (filterId, count) => {
        let id = filterId;

        while (id) {
          const { parent } = filters[id];

          if (filterValues.has(parent)) {
            filterValues.delete(id);
            recursivelyBuildTags(parent, count + 1);
            break;
          } else if (tags[parent]) {
            tags[parent].count += 1;
          } else if (filterValues.has(id)) {
            const { label } = filters[id];
            tags[id] = {
              id,
              label,
              count,
              clearAriaLabel: removeFilterLabel.replace('{0}', label),
              filterName: filter,
            };
          }
          filterValues.delete(id);
          id = parent;
        }
      };

      while (filterValues.size) {
        recursivelyBuildTags([...filterValues][0], 0);
      }
    }
  });
  return Object.values(tags); // TODO SORT
}