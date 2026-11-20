// Custom labels
import clearFilters from '@salesforce/label/c.PMP_Search_ClearFilters';

/**
 * This function returns the tag structure for the filter tags in th Level 2 Search Header
 *
 * @example
 * const tagStructure = filtersByTag();
 * // tagStructure example:
 * // { filterName1: { tagId1: ['selectedId1', 'selectedId2', ... ], ... }, ... }
 * //
 * // This would correspond to a filter tag of [ tagId1Label + 1 ] (2 checkbox ids represented)
 *
 * @param {object} searchParams search params
 * @param {object} taxonomyData taxonomydata
 * @returns {object} filters by tag object
 */
export default function filtersByTag(searchParams, taxonomyData) {
  let result = [];

  const recursivelyBuildPillbox = (filter, id, selectedIds, pillboxes, pillbox) => {
    if (!id) {
      return pillbox;
    }

    const record = filter.records[id];

    if (!record) {
      return pillbox;
    }

    const newPillbox = pillbox;
    const newPillboxes = pillboxes;

    if (selectedIds.has(record.id)) { // id is in selectedIds set
      newPillbox.id = record.id;
      newPillbox.label = record.label;
      newPillbox.count += 1;
      selectedIds.delete(record.id); // removes id from set now that it is in pillbox
    } else if (pillboxes[record.id]) { // parent was already in pillboxes (and previously selected)
      // merges into existing pillbox ids
      newPillboxes[record.id].count = pillboxes[record.id].count + pillbox.count + 1;
      return null;
      // for large data, traverse up the tree and use Format: "Top Level Label +N" (all children)
    } else if (filter.filterDisplayType === 'large-data') {
      newPillbox.id = record.id;
      newPillbox.label = record.label;
    }
    // traverses up tree looking for checked parents
    return recursivelyBuildPillbox(filter, record.parentId, selectedIds, newPillboxes, newPillbox);
  };

  const currentFilters = searchParams.filters || {};

  const filterKeys = Object.keys(currentFilters);

  filterKeys.forEach((filterName) => {
    const filter = taxonomyData[filterName];
    if (filter.filterDisplayType !== 'select') { // skips 'select' filters (ie. Country)
      const selectedIds = new Set(currentFilters[filterName]);
      const pillboxes = {}; // { id: pillbox }
      currentFilters[filterName].forEach((id) => {
        const defaultPillbox = { id: '', label: '', count: -1 };
        const pillbox = recursivelyBuildPillbox(filter, id, selectedIds, pillboxes, defaultPillbox);
        if (pillbox) {
          if (filter.filterDisplayType === 'large-data') {
            pillbox.count += 1;
          }
          pillbox.filterName = filterName;
          pillboxes[pillbox.id] = pillbox; // add pillbox to filter list
        }
      });
      result = result.concat(Object.values(pillboxes)); // add pillbox to final result list
    }
  });

  // adds keyword
  const { keyword } = searchParams;
  if (keyword) {
    result.push({
      id: '__keyword__', filterName: '__KEYWORD__', label: keyword, count: 0,
    });
  }

  // sorts alphabetically
  result = result.sort((b1, b2) => (b1.label.toLowerCase() > b2.label.toLowerCase() ? 1 : -1));

  // add accessibility label
  result = result.map((tag) => ({
    ...tag,
    clearAriaLabel: `${clearFilters} ${tag.label}${tag.count > 0 ? ` +${tag.count}` : ''}`,
  }));

  return result;
}