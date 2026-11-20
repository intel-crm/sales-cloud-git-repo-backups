/* Reducer Guidelines: https://redux.js.org/style-guide/style-guide/ */
/* eslint-disable no-unused-vars */

/** <h2>Settings Store</h2>
 * <h4>App State Key</h4>settings
 * <h4>Description</h4>
 * This store keeps track of user and client-side settings.
 * <br><i>NOTE: These settings are more data settings, while <code>ui</code> contains UI-related settings.</i>
 * <br><br>💾 - Cached in LocalStorage
 * @typedef settings
 * @type {object}
 * @property {string} clientLanguage <b>TODO</b> this is an optional override of the Salesforce platform backend language, based on user's region and locale. The value comes from the URL param 'language'
 * @memberof module:ApplicationState
 */


const defaultState = {
    clientLanguage: '',

    // (psMpRegionMapping) - TODO - convert to ipaRegionMapping
    currentCountry: '',
    currentRegions: ['NA'],
    currentRegionsLabel: '',
    currentLanguage: '',
    languageNotAvailable: false
};

export const cacheReducer = (previousState = defaultState, action) => {
    // cache everything
    return {
        ...previousState
    };
}

/**
 * <h4>[View Settings Store and Default State]{@link module:ApplicationState.settings}</h4>
 * @redux
 * @reduxReducer
 * @function settings
 * @param {module:ApplicationState.settings} defaultState The initial state
 * @memberof ipaRedux
 */
export default (previousState = defaultState, action) => {
    let {type, ...settings} = action;
    switch (type) {

        case 'changeSettings':
            return {
                ...previousState,
                ...settings
            };

        default:
            return previousState;

    }
}