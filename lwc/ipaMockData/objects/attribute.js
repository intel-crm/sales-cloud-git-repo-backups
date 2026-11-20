/** a Partner attribute and its list of values shown on the Partner card (ie. "Application Expertise")
 * @typedef Attribute
 * @property {string} title
 * @property {string[]} values
 */

import helpers from './helpers/index';

export const mockAttribute = () => ({
    title: helpers.textShort(),
    values: [helpers.textShort(), helpers.textShort()]
})