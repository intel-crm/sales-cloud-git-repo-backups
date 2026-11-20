/* eslint-disable no-unused-vars */

/** {@link Redux.Action Redux Actions} for the {@link ipaRedux Marketplace Redux Store}
 * <h4>{@link module:Actions Marketplace Actions}</h4>
 * <h2>Taxonomy Actions</h2>
 * @redux
 * @reduxActionScope @TAXONOMY
 * @module Actions/Taxonomy
 */

import TaxonomyService from 'c/ipaTaxonomyService';
import LANG from '@salesforce/i18n/lang';

const DEBUG_PERFORMANCE = false;

export default {
    /**
     * Refreshes the base static taxonomy
     * @function @TAXONOMY/refresh
     * @param {object} action
     * @memberof module:Actions/Taxonomy
     */
    "@TAXONOMY/refresh": (params) => async (dispatch, getState) => {
        let taxonomy = getState().taxonomy;
        if (!params.force) {
            // if request is already enroute don't send additional requests
            if (taxonomy.currentlyFetching) return;

            // if taxonomy cache has not expired, and language has not changed, no need to refresh
            if (taxonomy.expires > Date.now() && LANG === taxonomy.language) return;
        }

        dispatch("@TAXONOMY/fetch");
        try {
            let response;

            if (DEBUG_PERFORMANCE) console.time('PERFORMANCE: Fetching Taxonomy Data')
            response = await TaxonomyService.fetchTaxonomyData({ baseTaxonomy: true });
            dispatch("@TAXONOMY/set", { isBaseList: true, taxonomies: response });
            if (DEBUG_PERFORMANCE) console.timeEnd('PERFORMANCE: Fetching Taxonomy Data')

            TaxonomyService.fetchTaxonomyData({ baseTaxonomy: false }).then(res => {
                dispatch("@TAXONOMY/set", { taxonomies: res });
            });
        } catch(e) {
            console.error('TaxonomyService Error!', e);
            dispatch("@TAXONOMY/error")
        }
    },

};