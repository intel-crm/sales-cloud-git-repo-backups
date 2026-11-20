export default state => ({

    /**
     * This function tells whether the draft filters are modified,
     * ie. the "Draft" filters are different from the Actual search params filters
     * @example
     * import { selectState } from 'c/ipaRedux'
     *
     * let tagStructure = selectState().draftFiltersModified()
     * @function draftFiltersModified
     * @returns {boolean}
     * @memberof module:Selectors
     */
    draftFiltersModified: () => {
        let filters = state.search.searchParams.filters,
            draftFilters = state.search.draftFilters;
        for (let f of Object.keys(draftFilters)) {
            if (!draftFilters[f]) return true;
            if ((filters[f] || []).length !== draftFilters[f].length) return true;
            let s1 = new Set(filters[f]), s2 = new Set(draftFilters[f])
            for (let m of s1) if (!s2.has(m)) return true;
        }
        return false;
    },

    /**
     * This function returns the tag structure for the filter tags in th Level 2 Search Header
     * @example
     * import { selectState } from 'c/ipaRedux'
     *
     * let tagStructure = selectState().filtersByTag()
     * // tagStructure example:
     * // { filterName1: { tagId1: ['selectedId1', 'selectedId2', ... ], ... }, ... }
     * //
     * // This would correspond to a filter tag of [ tagId1Label + 1 ] (2 checkbox ids represented)
     * @function filtersByTag
     * @returns {object}
     * @memberof module:Selectors
     */
    filtersByTag: () => {
        let result = [];
        let recursivelyBuildPillbox = (filter, id, selectedIds, pillboxes, pillbox) => {
            if (!id) return pillbox;
            let record = filter.records[id];
            if (!record) return pillbox;
            if (selectedIds.has(record.id)) { // id is in selectedIds set
                pillbox.id = record.id;
                pillbox.label = record.label;
                pillbox.count++;
                selectedIds.delete(record.id); // removes id from set now that it is in pillbox
            } else if (pillboxes[record.id]) { // parent was already in pillboxes (and previously selected)
                // merges into existing pillbox ids
                pillboxes[record.id].count = pillboxes[record.id].count + pillbox.count + 1;
                return null;
            // for large data, traverse up the tree and use Format: "Top Level Label +N" (all children)
            } else if (filter.filterDisplayType === 'large-data') {
                pillbox.id = record.id;
                pillbox.label = record.label;
            }
            // traverses up tree looking for checked parents
            return recursivelyBuildPillbox(filter, record.parentId, selectedIds, pillboxes, pillbox);
        }
        let currentFilters = state.search.searchParams.filters;

        for (let filterName of Object.keys(currentFilters)) {
            let filter = state.taxonomy.taxonomies[filterName];
            if (filter.filterDisplayType === 'select') continue; // skips 'select' filters
            let selectedIds = new Set(currentFilters[filterName]);
            let pillboxes = {}; // { id: pillbox }
            currentFilters[filterName].forEach(id => {
                let defaultPillbox = { id: '', label: '', count: -1 };
                let pillbox = recursivelyBuildPillbox(filter, id, selectedIds, pillboxes, defaultPillbox);
                if (pillbox) {
                    if (filter.filterDisplayType === 'large-data') pillbox.count++;
                    pillbox.filterName = filterName;
                    pillboxes[pillbox.id] = pillbox; // add pillbox to filter list
                }
            });
            result = result.concat(Object.values(pillboxes)); // add pillbox to final result list
        }

        // adds keyword
        let keyword = state.search.searchParams.keyword;
        if (keyword) result.push({ id: '__keyword__', filterName: '__KEYWORD__', label: keyword, count: 0 });

        // sorts alphabetically
        result = result.sort((b1, b2) => (b1.label.toLowerCase() > b2.label.toLowerCase() ? 1 : -1));

        return result;
    },

    /**
     * This function returns a url string w/ search parameters
     * <br><b>NOTE: This is Still Work in Progress</b>
     * @example
     * import { selectState } from 'c/ipaRedux'
     *
     * let tagStructure = selectState().shareUrl()
     * @function shareUrl
     * @returns {object}
     * @memberof module:Selectors
     */
    shareUrl: () => {
        let searchParams = state.search.searchParams;
        let url = new URL(window.location);
        let urlSearchParams = {
            // cat: searchParams.category,
            q: searchParams.keyword,
            p: searchParams.page,
            s: searchParams.sortType,
            f: searchParams.filters
        }
        urlSearchParams = encodeURIComponent(JSON.stringify(urlSearchParams));
        url.searchParams.set('search', urlSearchParams);
        return url.toString();
    },

    /**
     * This function returns the total filter count
     * <br>Used for the "Apply" button in ipaSearch and in ipaSearchResults
     * @example
     * import { selectState } from 'c/ipaRedux'
     *
     * let tagStructure = selectState().totalFilterCount()
     * @function totalFilterCount
     * @returns {object}
     * @memberof module:Selectors
     */
    totalFilterCount: () => {
        return Object.values(state.search.searchParams.filters)
            .reduce((total, next) => total + next.length, 0);
    },

    /**
     * This function returns a map of selected filters (incl. all parents up the tree)
     * @example
     * import { selectState } from 'c/ipaRedux'
     * selectState().expandedFilters()
     * @function expandedFilters
     * @returns {object}
     * @memberof module:Selectors
     */
    expandedFilters: (filterName) => {
        let expanded = {};
        let selectedFilters = state.search.searchParams.filters[filterName] || [];
        selectedFilters.forEach(filter => {
            let id = filter;
            while (id) {
                expanded[id] = true;
                let record = state.taxonomy.taxonomies[filterName].records[id];
                id = record ? record.parentId : null;
            }
        });
        return expanded;
    },

})