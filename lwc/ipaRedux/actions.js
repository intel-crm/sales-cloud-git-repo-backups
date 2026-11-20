/** {@link Redux.Action Redux Actions} for the {@link ipaRedux Marketplace Redux Store}
 * <h2>Marketplace Redux Actions</h2>
 * <br><i>Note: Since multiple Reducers can respond to the same Action, there is not a one-to-one mapping of reducers to actions.</i><br>
 * <h4>Global Actions</h4>
 * <ul>
 *     <li>Global actions are listed in the "METHODS" section below</li>
 * </ul>
 * <h4>Scoped Actions</h4>
 * <ul>
 *     <li>{@link module:Actions/CompareTray Compare Tray}</li>
 *     <li>{@link module:Actions/Search Search}</li>
 *     <li>{@link module:Actions/Taxonomy Taxonomy}</li>
 * </ul>
 * <br>
 * <hr>
 * <h2>Types of Actions</h2><br>
 * Actions must be "registered" or the reduxStore component will throw an error.<br>
 * The formats for standard and async actions are listed in the example below.<br>
 * <h4>Standard Actions</h4><br>
 * Standard Actions are synchronous actions.<br>
 * They are represented by simple objects, with an action <i>type</i> and a payload.<br><br>
 * <h4>Async Actions</h4><br>
 * Async Actions are asynchronous actions.<br>
 * They are functions that dispatch multiple standard actions, and perform additional logic, ie. server requests.<br><br>
 * @example
 *
 * // STANDARD ACTION EXAMPLE
 * // a standard action can be any truthy value
 * // (if an action is not "registered" an error will throw as an undefined action type)
 *
 * someStandardAction: true,
 *
 *
 * // ASYNC ACTION EXAMPLE
 * // an async action is an action creator that takes params
 * // inside the action we have access to dispatch actions directly (these can be unregistered)
 * // we can also get the current state with getState
 *
 * someAsyncAction: params => async (dispatch, getState, api) => {
 *     dispatch({ type: 'serverRequest', ...params });
 *     let response = ipaSomeService.getServerInfo(params);
 *     return dispatch({ type: 'serverResponse', response });
 * }
 *
 * @module Actions
 */

import compareTray from './actions/compareTrayActions';
import search from './actions/searchActions';
import taxonomy from './actions/taxonomyActions';

export default {
    ...compareTray,
    ...search,
    ...taxonomy
};