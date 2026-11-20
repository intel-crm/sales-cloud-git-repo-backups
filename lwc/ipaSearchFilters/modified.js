/**
 * This function tells whether the draft filters are modified,
 * ie. the "Draft" filters are different from the Actual search params filters
 *
 * @param {object} [searchParamFilters={}] search param filters
 * @param {object} [draftFilters={}] draft filters
 * @returns {boolean} if modified
 */
export default function filtersModified(searchParamFilters = {}, draftFilters = {}) {
  const filterKeys = Object.keys(draftFilters);

  let i = 0;
  let response = false;
  while (i < filterKeys.length) {
    // if filter is gone draft has been modified
    if (!draftFilters[filterKeys[i]]) {
      response = true;
      break;
    }

    const s1 = new Set(searchParamFilters[filterKeys[i]] || []);
    const s2 = new Set(draftFilters[filterKeys[i]] || []);

    // if the length is different draft has been modified
    if (s1.size !== s2.size) {
      response = true;
      break;
    }

    // if a value from filters is missing in draftFilters then the draft has been modified
    const missingValue = !([...s1.values()].every((val) => s2.has(val)));
    if (missingValue && s1.size) {
      response = true;
      break;
    }
    i += 1;
  }
  return response;
}