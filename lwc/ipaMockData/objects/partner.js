/** Partner
 * @typedef Partner
 * @property {string} id salesforce id of partner
 * @property {string} name partner name
 * @property {string} description brief description of the partner
 * @property {string} website website of the member partner
 * @property {string} byline partner byline (ie. "2k Solutions Deployed")
 * @property {string} imageUrl image url of partner logo
 * @property {string} longDescription a longer description of the partner (appears in QuickView)
 * @property {string} status tier status of a partner -- can be 'gold', 'titanium' or 'member'
 * @property {string} [searchGrouping] organizes partner search result into a grouping on L2 Search
 * @property {Specialty[]} specialties a list of partner specialties
 * @property {Attribute[]} attributes a list of partner attributes
 */

import helpers from './helpers/index';
import { mockSpecialties } from './specialty';

const mockAttributes = () => {

    let regions = helpers.sampleRandom(['North America Region', 'Latin America Region', 'Europe Region', 'Asia Region', 'Arctic Region']);
    let industries = helpers.sampleRandom(['Automotive', 'Transportation and Warehouse', 'Education', 'Technology', 'Railroads', 'Ocean Exploration', 'Aviation', 'Markets', 'Envrionment', 'Utilities', 'Water and Air', 'Financial Services', 'Transportation']);
    let applications = helpers.sampleRandom(['Video Management', 'Natus Maiores Minima', 'Computers', 'Sports', 'Movies', 'Tools', 'Clothing', 'Grocery', 'Toys', 'Industrial', 'Awesome Granite Soap', 'Unbranded Frozen Bike', 'Gorgeous Frozen Pizza', 'Licensed Metal']);

    return helpers.sampleRandom([
        { title: 'Regional Coverage', values: regions },
        { title: 'Industry Expertise', values: industries },
        { title: 'Application Expertise', values: applications }
    ]);
}

const mockName = () => {
    let mockTitles = ['Concurrent Tech PLC', 'Intel', 'Technology Services Manufacturing Agency', 'Cupidatat eiusmod dolore in sunt quis occaecat tempor anim'];
    return helpers.sample(mockTitles);
}

const mockUpgradedPartner = ({ searchGrouping } = {}) => ({
    id: helpers.id(),
    name: mockName(),
    eyebrow: Math.random() < 0.5,
    eyebrowTagline: 'COVID-19 Healthcare',
    description: helpers.text(),
    distributorTagline: 'Intel® Authorized Distributor',
    distributorWebsite: helpers.website(),
    website: helpers.website(),
    byline: helpers.sample(['', '4.2k Solutions Deployed', '185 Solutions Deployed', '3.2m Solutions Deployed']),
    imageUrl: helpers.imageUrlSmall(),
    longDescription: helpers.textLong(),
    role: 'Partner Role',
    status: helpers.sample(['gold', 'titanium']),
    specialties: helpers.sampleRandom(mockSpecialties, 0, 4),
    attributes: mockAttributes(),
    searchGrouping
});

const mockMemberPartner = ({ searchGrouping } = {}) => ({
    id: helpers.id(),
    name: mockName(),
    description: '',
    website: helpers.website(),
    byline: '',
    imageUrl: 'https://www.intel.com/content/dam/www/public/us/en/ai/images/university-icon.png.rendition.intel.web.416.234.png',
    longDescription: '',
    status: 'member',
    specialties: [],
    attributes: [],
    searchGrouping
});

export const mockPartner = ({ member, searchGrouping } = {}) =>
    (member ? mockMemberPartner({ searchGrouping }) : mockUpgradedPartner({ searchGrouping }));