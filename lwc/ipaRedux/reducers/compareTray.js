/* Reducer Guidelines: https://redux.js.org/style-guide/style-guide/ */
/* eslint-disable no-unused-vars */

/** <h2>Compare Tray Store</h2>
 * <h4>App State Key</h4>compareTray
 * <h4>Description</h4>
 * This store keeps track of the items in the Compare Tray component.
 * <br><br>💾 - Cached in LocalStorage
 * @typedef compareTray
 * @type {object}
 * @property {integer} capacity=4 💾 allowed number of items in compare tray
 * @property {Product[]} currentItems 💾 current tray items
 * @property {string} notificationMessage message alerting user ie. if tray is full
 * @memberof module:ApplicationState
 */

const defaultState = {
    capacity: 4,
    currentItems: [],
    notificationMessage: ''
};

export const cacheReducer = (previousState = defaultState, action) => {
    // cache everything except notification message
    return {
        ...previousState,
        notificationMessage: ''
    };
}

/**
 * <h4>[View Compare Tray Store and Default State]{@link module:ApplicationState.compareTray}</h4>
 * @redux
 * @reduxReducer
 * @function compareTray
 * @param {module:ApplicationState.compareTray} defaultState The initial state
 * @memberof ipaRedux
 */
export default (previousState = defaultState, action) => {
    switch (action.type) {

        case '@COMPARE_TRAY/clear': {
            return {
                ...previousState,
                currentItems: [],
                notificationMessage: ''
            };
        }

        case '@COMPARE_TRAY/clearNotification':
            return { ...previousState, notificationMessage: '' };

        case '@COMPARE_TRAY/notification':
            return { ...previousState, notificationMessage: action.msg };

        case '@COMPARE_TRAY/toggleItem': {
            let currentItems = [...previousState.currentItems];
            // modify items in tray
            let idx = currentItems.findIndex(i => i.id === action.item.id);
            if (idx > -1) {
                currentItems.splice(idx, 1);
            } else {
                currentItems.push(action.item);
            }
            return { ...previousState, currentItems, notificationMessage: '' };
        }

        default:
            return previousState;

    }
}