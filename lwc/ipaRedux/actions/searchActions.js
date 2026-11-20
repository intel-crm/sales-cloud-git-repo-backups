/* eslint-disable no-unused-vars */

/** {@link Redux.Action Redux Actions} for the {@link ipaRedux Marketplace Redux Store}
 * <h4>{@link module:Actions Marketplace Actions}</h4>
 * <h2>Search Actions</h2>
 * @redux
 * @reduxActionScope @SEARCH
 * @module Actions/Search
 */

// const USE_MOCK = window.location.href.match('mockdata') ? true : false;

import SearchService from 'c/ipaSearchService';
import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';

// import { MockSearchService } from 'c/ipaMockData';

// static list of sort filter options (this can be overwritten in searchResponse)
import relevance from '@salesforce/label/c.PMP_SortByRelevance';
import featured from '@salesforce/label/c.PMP_SortByFeatured';
import partnerTier from '@salesforce/label/c.PMP_SortByPartnerTier';
import newlyAdded from '@salesforce/label/c.PMP_SortByNew';
import alpha from '@salesforce/label/c.PMP_SortByAlpha';

const defaultSortByOptions = [
    { label: alpha,          value: 'alphabetical' },
    { label: relevance,      value: 'relevance' },
    { label: featured,       value: 'featured' },
    { label: partnerTier,    value: 'partner' },
    { label: newlyAdded,     value: 'new' }
];

const DEBUG_PERFORMANCE = false;

export default {

    /**
     * Searches Intel for products.
     * @async
     * @function @SEARCH/search
     * @param {object} params
     * @param {string} [params.category] search category
     * @param {string} [params.keyword] search keyword
     * @param {number} [params.page] current page
     * @param {string} [params.sortType] search sorting param
     * @param {object} [params.filters] search filters
     * @memberof module:Actions/Search
    */

    '@SEARCH/search': params => async (dispatch, getState) => {
        let searchParams = {
            ...getState().search.searchParams,
            ...params
        };

        // keeps track of current search to handle multiple requests fired before response
        const currentSearch = Date.now();
        
        dispatch({ type: '@SEARCH/request', searchParams, currentSearch });
        
        let searchResponse = {}, searchError = '';
        let searchAnalytics = getState().search.searchAnalytics;
        
        try {
            // Mock Data was used for development and performance testing
            // This code is disabled, but can be re-enabled if more enhancements/debug are necessary

            // if (USE_MOCK) {
            //     console.time('PERFORMANCE: L2 Search *Mock* Response')
            //     searchResponse = await MockSearchService.search(searchParams);
            //     console.timeEnd('PERFORMANCE: L2 Search *Mock* Response')
            // } else {
                if (DEBUG_PERFORMANCE) console.time('PERFORMANCE: L2 Search Response')

                // Dispatch Search / Get Filter Counts as Second Call in Background
                // Calls Should Not Be Bundled Together
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    SearchService.searchResultCounts(searchParams).then(res => {
                        if (getState().search.currentSearch !== currentSearch) {
                            return;
                        }
                        dispatch({ type: '@SEARCH/responseResultCounts', resultCounts: res.resultCounts })
                    })
                }, 5)
                searchResponse = await SearchService.search(searchParams);
                if (DEBUG_PERFORMANCE) console.timeEnd('PERFORMANCE: L2 Search Response')
            // }
        } catch(e) {
            // Errors are handled in the SearchService.
            return;
        }

        // if multiple successive search requests are made, wait until latest response is returned...
        if (getState().search.currentSearch !== currentSearch) {
            return;
        }

        // sets "Sort By" options for dropdown based on 1. default list, 2. override from search
        if (!searchResponse.sortByOptions) searchResponse.sortByOptions = defaultSortByOptions;
        if (!searchResponse.sortByOptions.find(opt => opt.selected)) {
            // if there is no selected option returned, try to use the searchParams value
            let paramSortValue = searchParams.sortType;
            searchResponse.sortByOptions.forEach(opt => {
                if (paramSortValue === opt.value) opt.selected = true;
            });
            // if there is still no selected option, select the first option
            if (!searchResponse.sortByOptions.find(opt => opt.selected)) {
                searchResponse.sortByOptions[0].selected = true;
            }
        }

        // Search Analytics
        if (searchAnalytics) {
            makeIpaAnalyticsCall({
                ...searchAnalytics,
                    details: searchResponse.totalResults + '|' + searchAnalytics.details
            });
        }

        dispatch({ type: "@SEARCH/response", searchResponse, searchError });
    },

};