/**
 * This function returns a map of selected filters (incl. all parents up the tree)
 *
 * @param {object} searchParams search params
 * @param {object} taxonomyData taxonomy data
 * @param {string} filterName filtern name
 * @returns {object} expanded object
 */
export default function expandedFilters(searchParams, taxonomyData, filterName) {
  const expanded = {};
  const selectedFilters = searchParams.filters[filterName] || [];
  selectedFilters.forEach((filter) => {
    let id = filter;
    while (id) {
      expanded[id] = true;
      const record = taxonomyData[filterName].records[id];
      id = record ? record.parentId : null;
    }
  });
  return expanded;
}