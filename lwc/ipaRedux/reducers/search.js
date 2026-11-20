/* Reducer Guidelines: https://redux.js.org/style-guide/style-guide/ */
/* eslint-disable no-unused-vars */

/** <h2>Search Store</h2>
 * <h4>App State Key</h4>search
 * <h4>Description</h4>
 * This store keeps track of the Level 2 Search
 * <br><br>💾 - Cached in LocalStorage
 * @typedef search
 * @type {object}
 * @property {number} cacheLife=30000 💾 Lifespan of the Taxonomy cache (in ms)
 * @property {number} expires 💾 expiration date <code>Date.now() + cacheLife</code>
 * @property {boolean} currentlySearching=false current state of search
 * @property {string} searchError an error message to display in the search experience
 * @property {object} searchInitialValues a way to pass in initial search values (ie. thru ipaQuickSearch)
 * @property {object} searchParams contains all the information necessary to repeat a search / URL params / etc. (cached in searchHistory property)
 * @property {object} searchParams.category category ID - matches current page's record Id
 * @property {string} searchParams.keyword query string from search box in left sidebar
 * @property {number} searchParams.page=1 current page changed with pagination at bottom of results list
 * @property {string} searchParams.sortType=relevance sort dropdown in search header - possible values are 'relevance', 'featured', 'partner-tier', 'newly-added'
 * @property {Map<filterId, selectedId[]>} searchParams.filters search filters
 * @property {Map<filterId, selectedId[]>} draftFilters search filters in draft mode (used in mobile/modal views)<br>user can then Apply / Cancel
 * @property {boolean} currentlyRendering increases performance / UI for large data sets in search filters modal view
 * @property {object} searchResponse contains all the response information for displaying search results
 * @property {object[]} sortByOptions overwrites default static list of "Sort By" options for custom result sets<br>Format: { label: 'A-Z', value: 'alpha', selected: true }
 * @property {Product[]|Partner[]} searchResponse.results list of results from the search service
 * @property {Map<string, Product[]|Partner[]>} searchResponse.resultGroupings list of results in separate groupings, organized by heading
 * @property {number} searchResponse.resultsPerPage page size for the results returned
 * @property {number} searchResponse.totalResults total number of results from the search
 * @property {number} searchResponse.totalPages total number pages from the search
 * @property {Map<filterId, number>} searchResultCounts map of filters and the results count (ie. Application (10))
 * @property {Map<categoryId, searchParams>} searchHistory 💾 search history caches/saves searchParams (possible AR--include results as well?)
 * @memberof module:ApplicationState
 */

const defaultState = {
    cacheLife: 30000,
    expires: Date.now(), // default state is expired
    currentSearch: 0, // unique identifier of search (Tricky b/c 1 request action, 2 response actions)
    currentlySearching: false,
    currentlyFetchingCounts: false,
    searchError: '',
    searchInitialValues: {},
    searchAnalytics: null,
    searchParams: {
        category: '',
        keyword: '',
        page: 1,
        sortType: 'relevance',
        filters: {},
    },
    draftFilters: {},
    currentlyRendering: false,
    searchResponse: {
        sortByOptions: [],
        results: [],
        resultsPerPage: 0,
        totalResults: 0,
        totalPages: 0,
    },
    searchResultCounts: {},
    searchHistory: {},
};

export const cacheReducer = (previousState = defaultState, action) => {
    // cache everything
    return {
        ...defaultState,
        searchHistory: { ...previousState.searchHistory }
    };
}

/**
 * <h4>[View Search Store and Default State]{@link module:ApplicationState.search}</h4>
 * @redux
 * @reduxReducer
 * @function search
 * @param {module:ApplicationState.search} defaultState The initial state
 * @memberof ipaRedux
 */
export default (previousState = defaultState, action) => {
    switch (action.type) {

        case '@SEARCH/clearHistory': {
            return {
                ...previousState,
                searchHistory: {}
            }
        }

        case '@SEARCH/draft': {
            return {
                ...previousState,
                draftFilters: { ...action.filters },
                currentlyRendering: false
            };
        }

        case '@SEARCH/request': {
            return {
                ...previousState,
                searchInitialValues: {},
                searchParams: { ...previousState.searchParams, ...action.searchParams },
                draftFilters: {},
                currentSearch: action.currentSearch,
                currentlySearching: true,
                currentlyFetchingCounts: true,
            };
        }

        case '@SEARCH/rendering': {
            return {
                ...previousState, currentlyRendering: true
            };
        }

        case '@SEARCH/response': {
            return {
                ...previousState,
                searchError: action.searchError || '',
                searchResponse: action.searchResponse || previousState.searchResponse,
                // resets expiration
                expires: Date.now() + previousState.cacheLife,
                currentSearch: previousState.currentlyFetchingCounts ? previousState.currentSearch : 0,
                currentlySearching: false,
                // adds search to search history after successful search
                // deep clone to avoid cross-pollination
                searchHistory: {
                    ...previousState.searchHistory,
                    [previousState.searchParams.category]: { ...previousState.searchParams }
                },
                searchAnalytics: null
            };
        }

        case '@SEARCH/responseResultCounts': {
            return {
                ...previousState,
                currentSearch: previousState.currentlySearching ? previousState.currentSearch : 0,
                currentlyFetchingCounts: false,
                searchResultCounts: action.resultCounts
            };
        }

        case '@SEARCH/setAnalytics': {
            return {
                ...previousState,
                searchAnalytics: {
                    ...action.searchAnalytics
                }
            }
        }

        case '@SEARCH/setHistory': {
            return {
                ...previousState,
                searchHistory: {
                    ...previousState.searchHistory,
                    [action.searchParams.category]: { ...action.searchParams }
                }
            }
        }

        case '@SEARCH/setInitialSearchValues': {
            return {
                ...previousState,
                searchInitialValues: {
                    ...action.searchInitialValues
                }
            };
        }

        default:
            return previousState;

    }
}