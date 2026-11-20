/* Reducer Guidelines: https://redux.js.org/style-guide/style-guide/ */
/* eslint-disable no-unused-vars */

export const breakpoints = [
    { mediaQuery: '(max-width: 479px)', name: 'x-small', abbr: 'xs', isMobile: true },
    { mediaQuery: '(min-width: 480px) and (max-width: 767px)', name: 'small', abbr: 'sm', isMobile: true },
    { mediaQuery: '(min-width: 768px) and (max-width: 1023px)', name: 'medium', abbr: 'md', isTablet: true },
    { mediaQuery: '(min-width: 1024px) and (max-width: 1279px)', name: 'large', abbr: 'lg', isDesktop: true },
    { mediaQuery: '(min-width: 1280px)', name: 'x-large', abbr: 'xl', isDesktop: true },
];

/** <h2>UI Store</h2>
 * <h4>App State Key</h4>ui
 * <h4>Description</h4>
 * This store keeps track of global UI state that is commonly referenced in components as well as global components like the Marquee.<br><br>
 * <h4>Responsive Breakpoints</h4><br>
 * <table class="props">
 *      <thead><tr><th>Breakpoint</th><th>Name</th><th>Abbr.</th><th>Screen Size</th><th>CSS Media Query</th></tr></thead>
 *      <tbody><tr><td>Extra Small</td><td>x-small</td><td>xs</td><td>mobile</td><td><code>(max-width: 479px)</code></td></tr>
 *      <tr><td>Small</td><td>small</td><td>sm</td><td>mobile</td><td><code>(min-width: 480px) and (max-width: 767px)</code></td></tr>
 *      <tr><td>Medium</td><td>medium</td><td>md</td><td>tablet</td><td><code>(min-width: 768px) and (max-width: 1023px)</code></td></tr>
 *      <tr><td>Large</td><td>large</td><td>lg</td><td>desktop</td><td><code>(min-width: 1024px) and (max-width: 1279px)</code></td></tr>
 *      <tr><td>Extra Large</td><td>x-large</td><td>xl</td><td>desktop</td><td><code>(min-width: 1280px)</code></td></tr></tbody>
 * </table>
 * <br><i>NOTE: No properties in this store are cached in localStorage</i>
 * @typedef ui
 * @type {object}
 * @property {object} breakpoint current breakpoint value
 * @property {string} breakpoint.mediaQuery CSS Media Query value
 * @property {string} breakpoint.name Breakpoint Name ie. 'small', 'large'
 * @property {string} breakpoint.abbr Breakpoint Abbreviation ie. 'sm', 'lg'
 * @property {boolean} breakpoint.isMobile Breakpoint is 'Mobile' (see list above)
 * @property {boolean} breakpoint.isTablet Breakpoint is 'Tablet' (see list above)
 * @property {boolean} breakpoint.isDesktop Breakpoint is 'Desktop' (see list above)
 * @property {string} openModal currently opened modal name
 * @property {object} marquee dynamic properties related to the global Marquee component ({@link ipaMarquee})
 * @property {string} marquee.title Marquee Title
 * @property {string} marquee.subtitle
 * @property {object} marquee.linkData TODO...
 * @property {string} marquee.linkData.label
 * @memberof module:ApplicationState
 */

const defaultState = {

    // Initial breakpoint set here, mediaQuery listeners set in psMpReduxStore.js
    breakpoint:  breakpoints.find(breakpoint => {
        return window.matchMedia(breakpoint.mediaQuery).matches;
    }),

    onerem: parseFloat(getComputedStyle(document.documentElement).fontSize),

    openModal: null,

    marquee: {
        title: '',
        subtitle: '',
        showCaret: true,
        linkData: {
            communityPage: '',
            externalUrl: '',
            objectPage: '',
            recordId: '',
            label: ''
        }
    }

};

/**
 * <h4>[View UI Store and Default State]{@link module:ApplicationState.ui}</h4>
 * @redux
 * @reduxReducer
 * @function ui
 * @param {module:ApplicationState.ui} defaultState The initial state
 * @memberof ipaRedux
 */
export default (previousState = defaultState, action) => {
    let { type, ...settings } = action;
    switch (type) {

        // Always reset UI State on initialize/reload
        case 'store:initialized': {
            return defaultState;
        }

        case 'changeUI': {
            let newState = {
                ...previousState,
                ...settings
            };
            return newState;
        }

        default:
            return previousState;

    }
}