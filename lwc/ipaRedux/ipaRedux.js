/**
 * The {@link Redux Redux} Store for the Salesforce Intel Marketplace<br><br>
 * Lightning Web Component: <b>ipaRedux</b><br><br>
 * <h2>Application State</h2>
 * <h4>{@link module:ApplicationState Marketplace Application State}</h4>
 * <ul>
 *      <li>{@link module:ApplicationState.compareTray Compare Tray}</li>
 *      <li>{@link module:ApplicationState.search Search}</li>
 *      <li>{@link module:ApplicationState.ui UI}</li>
 * </ul>
 * <h2>Actions and Reducers
 * <h4>{@link module:Actions Marketplace Actions}</h4>
 * <h4>Marketplace Reducers (listed below)</h4>
 * <ul>
 *      <li>{@link ipaRedux.compareTray compareTray}</li>
 *      <li>{@link ipaRedux.search search}</li>
 *      <li>{@link ipaRedux.ui ui}</li>
 * </ul>
 * <hr>
 * <h4>Notes on Redux and Flux Architecture</h4><br>
 * Redux is a helpful way to organize the "state" of an application, especially when shared data is used in multiple components.
 * Redux/Flux architecture relies on a <i>one-way flow of data</i>.
 * In other words, the UI state of a component can be thought of as a function of the current application state, or data store.
 * <br><br>
 * <b>APP STATE => UI Component View</b><br>
 * <ul>
 *      <li>Component dispatches an Action</li>
 *      <li>App State changes</li>
 *      <li>Component(s) update</li>
 * </ul>
 * <br><h4>Actions</h4><br>
 * Redux {@link Redux.Action Actions} are similar to global events. They can be dispatched anywhere. Standard actions are simple objects, with an action type and a payload. {@link Redux.ActionCreator Action Creators} can be more complex, including asynchronous server calls, but still have limited and simple logic.
 * <br><br><h4>Reducers</h4><br>
 * Redux {@link Redux.Reducer Reducers} are functions that change the data in the store. They are simple functions that respond to actions and contain non-asynchronous data changes.
 * <hr>
 * <h4>Resources, Guidelines & Best Practices - https://redux.js.org/style-guide/style-guide/</h4>
 * @namespace ipaRedux
 * @author Nick Demarest
*/

import actions from './actions';
import reducers from './reducers';
import cacheReducers from './cacheReducers';
import ReduxStore from './reduxStore';
import addGlobalListeners from './listeners';
import selectors from './selectors';

/* Logic for DEBUG Setting (ADJUST HERE for Production etc.) */
const DEBUG = false;

/* Config Settings */
const CONFIG = {
    debug: DEBUG,
    actions,
    reducers,
    selectors,
    cache: true, // approved list for caching
    cacheKey: 'ipaRedux:Store',
    cacheStorage: 'sessionStorage',
    cacheReducers
};
/* End Settings */

// creates ReduxStore object with config settings
const store = new ReduxStore(CONFIG);

// adds global listeners that affect redux state
addGlobalListeners(store);

// exports ReduxStore object with { dispatch, subscribe } functions
export default store;