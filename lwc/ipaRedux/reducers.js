/**
 * The Application State structure for the {@link ipaRedux Marketplace Redux Store}<br>
 * <ul>
 *      <li>{@link module:ApplicationState.compareTray Compare Tray Store} ([reducer function]{@link ipaRedux.compareTray})</li>
 *      <li>{@link module:ApplicationState.search Search Store} ([reducer function]{@link ipaRedux.search})</li>
 *      <li>{@link module:ApplicationState.taxonomy Taxonomy Store} ([reducer function]{@link ipaRedux.taxonomy})</li>
 *      <li>{@link module:ApplicationState.ui UI Store} ([reducer function]{@link ipaRedux.ui})</li>
 * </ul>
 * @module ApplicationState
*/

import compareTray from './reducers/compareTray';
import search from './reducers/search';
import taxonomy from './reducers/taxonomy';
import ui from './reducers/ui';

export default {
    compareTray,
    search,
    taxonomy,
    ui
};