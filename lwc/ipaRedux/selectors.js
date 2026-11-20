/**
 * <h2>Selectors</h2><br>
 * Redux Selectors for the {@link ipaRedux Marketplace Redux Store}<br><hr>
 * These functions return processed values as a function of the state.<br>
 * <i>Functions are pure and synchronous functions.</i>
 * @example
 * import { selectState } from 'c/ipaRedux';
 * selectState().someSelector()
 * @module Selectors
*/

import search from './selectors/searchSelectors'
import taxonomy from './selectors/taxonomySelectors'

export default state => ({
    ...search(state),
    ...taxonomy(state)
})