import { LightningElement, api } from 'lwc';
import { dispatch, subscribe } from 'c/ipaRedux';

// fix for ipaSearch -> Redux removal
import { SearchHelper } from 'c/ipaSearchService';

subscribe((state) => {
  window.currentAppState = state;
});

window.dispatch = (actionName, params = {}, debounceTime) => {
  const lwcParams = JSON.parse(JSON.stringify(params)); // eliminates Proxy aura objects

  // fix for ipaSearch -> Redux removal
  if (actionName === '@SEARCH/setInitialSearchValues') {
    SearchHelper.initialParams = { ...params.searchInitialValues };
    return Promise.resolve();
  }

  return dispatch(actionName, lwcParams, debounceTime);
};

window.subscribe = (path, reader, silent) => subscribe(path, reader, silent);

/** Documentation for Redux Connector
 *
 */
class IpaReduxConnector extends LightningElement {
  /**
   * dispatches 'ready' event
   *
   * @private
   */
  connectedCallback() {
    this.dispatchEvent(new CustomEvent('ready'));
  }

  /** connects lwc redux #dispatch to aura components
   *
   * @param {string} actionName name of action
   * @param {object} [params] params
   * @param {number} [debounceTime] debounce time
   * @returns {Promise} redux promise
   */
  @api dispatch(actionName, params = {}, debounceTime) {
    const lwcParams = JSON.parse(JSON.stringify(params)); // eliminates Proxy aura objects
    return dispatch(actionName, lwcParams, debounceTime);
  }

  /**
   * subscribe
   *
   * @param {boolean} path path
   * @param {function} reader reader
   * @param {string} silent silent
   *
   * @returns {function} subscription
   */
  @api subscribe(path, reader, silent) {
    return subscribe(path, reader, silent);
  }
}
export default IpaReduxConnector;