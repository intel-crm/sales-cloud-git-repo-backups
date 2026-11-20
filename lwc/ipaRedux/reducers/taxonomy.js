/* Reducer Guidelines: https://redux.js.org/style-guide/style-guide/ */
/* eslint-disable no-unused-vars */

import LANG from '@salesforce/i18n/lang';

/** <h2>Taxonomy Store</h2>
 * <h4>App State Key</h4>taxonomy
 * <h4>Description</h4>
 * This store keeps track of the static hierarchy of Groupings / Taxonomy.
 * <br><br>💾 - Cached in SessionStorage<br><br><i>Current Cache Life: 2 hours</i>
 * @typedef taxonomy
 * @type {object}
 * @property {number} cacheLife 💾 Lifespan of the Taxonomy cache (in ms)
 * @property {number} expires 💾 expiration date <code>Date.now() + cacheLife</code>
 * @property {string} language 💾 language of stored taxonomy
 * @property {Map<string, Taxonomy>} taxonomies 💾 Offering categories (ie. Components, System, Software, ...)
 * @memberof module:ApplicationState
 */

const defaultState = {
    cacheLife: 2 * 60 * 60 * 1000, // 2 hours (SessionStorage)
    expires: Date.now(), // default state is expired
    language: LANG,
    currentlyFetching: false,
    fetchedBaseList: false,
    fetchedSecondary: false,
    taxonomies: {}
};

export const cacheReducer = (previousState = defaultState, action) => {
    // cache everything
    return {
        ...previousState,
        currentlyFetching: false
    };
}

/**
 * <h4>[View Taxonomy Store and Default State]{@link module:ApplicationState.taxonomy}</h4>
 * @redux
 * @reduxReducer
 * @function taxonomy
 * @param {module:ApplicationState.taxonomy} defaultState The initial state
 * @memberof ipaRedux
 */
export default (previousState = defaultState, action) => {
    switch (action.type) {

        case '@TAXONOMY/error': {
            return {
                ...previousState,
                currentlyFetching: false,
                fetchedSecondary: false
            }
        }

        case '@TAXONOMY/fetch': {
            return {
                ...previousState,
                currentlyFetching: true,
                fetchedBaseList: false,
                fetchedSecondary: false
            };
        }

        case '@TAXONOMY/set': {
            let taxonomies = {
                ...previousState.taxonomies,
                ...action.taxonomies
            };
            return {
                ...previousState,
                expires: action.isBaseList ? Date.now() + previousState.cacheLife : previousState.expires,
                currentlyFetching: action.isBaseList ? true : false,
                fetchedBaseList: action.isBaseList || previousState.fetchedBaseList,
                fetchedSecondary: !action.isBaseList || previousState.fetchedSecondary,
                language: LANG,
                taxonomies
            };
        }

        default:
            return previousState;

    }
}