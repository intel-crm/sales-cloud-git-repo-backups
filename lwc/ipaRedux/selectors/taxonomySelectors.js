export default state => ({

    /**
     * This function returns the needed taxonomy list for a category to show the L2 Search page filters
     * @example
     * import { selectState } from 'c/ipaRedux'
     *
     * let tagStructure = selectState().requiredTaxonomyList()
     * @function requiredTaxonomyList
     * @returns {object}
     * @memberof module:Selectors
     */
    requiredTaxonomyList: taxonomyName => {
        return (state.taxonomy.taxonomies[taxonomyName].searchFiltersGroupings || [])
            .reduce((all, next) => all.concat(next.filters), [])
            .filter(filterName => !state.taxonomy.taxonomies[filterName]);
    },

    /**
     * This function returns the taxonomy for a given category id
     * @example
     * import { selectState } from 'c/ipaRedux'
     *
     * let tagStructure = selectState().taxonomyByCategoryId()
     * @function taxonomyByCategoryId
     * @returns {object} taxonomy
     * @memberof module:Selectors
     */
    taxonomyByCategoryId: categoryId => {
        for (let taxonomy of Object.values(state.taxonomy.taxonomies)) {
            if (taxonomy.records[categoryId]) return taxonomy;
        }
        throw new Error(`Taxonomy for category Id: ${categoryId} not found in taxonomies!`);
    },

    /**
     * This function returns the top level record ids for a given taxonomy
     * <br>
     * For flat list filters (ie. Country select dropdown), there is no longer a need to list all
     * record ids... if the topLevelIds is empty or an empty array, it will instead return ALL records
     * @example
     * import { selectState } from 'c/ipaRedux'
     *
     * let tagStructure = selectState().topLevelTaxonomyIds()
     * @function topLevelTaxonomyIds
     * @returns {string[]} record ids
     * @memberof module:Selectors
     */
    topLevelTaxonomyIds: taxonomyName => {
        let taxonomy = state.taxonomy.taxonomies[taxonomyName];
        if (taxonomy.topLevelIds && taxonomy.topLevelIds.length) return taxonomy.topLevelIds;
        return Object.keys(taxonomy.records || {});
    }

})