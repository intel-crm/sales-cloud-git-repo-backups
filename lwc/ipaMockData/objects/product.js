/** Product
 * @typedef Product
 * @property {string} id salesforce id
 * @property {string} name product name
 * @property {string} description short description
 * @property {string} imageUrl product image appears on cards
 * @property {Partner} partner product owner / related partner
 * @property {string} [searchGrouping] organizes product search result into a grouping on L2 Search
 * @property {Category[]} categories a list of categories
 * @property {string} compareCategoryId category id used to compare similar offerings (Sub-category Id)
 */

import helpers from './helpers/index';
import { mockPartner } from './partner';

const mockProductTitle = () => helpers.sample([
    'AM E4x/msd Compute Intensive Advanced Model',
    'Wind River Professional Services',
    'Cisco Connected Stadium',
    'Eiusmod esse duis quis duis labore in ex non consequat esse in magna anim consectetur'
]);

const mockProductCategories = () => {
    let mockCategories = ['XXcategory1', 'XXcategory2', 'XXcategory3', 'XXcategory4'];
    return helpers.sampleRandom(mockCategories, 1, 2);
}

export const mockProduct = ({ searchGrouping } = {}) => ({
    id: helpers.id(),
    name: mockProductTitle(),
    description: helpers.text(),
    imageUrl: helpers.imageUrlSmall(),
    partner: mockPartner(),
    categories: mockProductCategories(),
    searchGrouping
});