/**
 * This grouping is used to associate a specific category record (L2 Search Page) with its filters on the left side of the page.
 * @typedef SearchFiltersGrouping
 * @property {string} label text label for the filter grouping
 * @property {string[]} filters a list of filters by unique {@link Taxonomy Taxonomy} name associated with the grouping
 */


/**
 * This grouping is used to associate search results with a group instead of one list.<br>
 * <br>
 * NOTE: For future development, it might be better to remove this object, and simply use a list of Taxonomy Record ids, which could lookup the records and use <i>id</i> instead of name, <i>label</i> instead of heading, and <i>description</i> instead of subheading.<br>
 * @typedef SearchResultsGrouping
 * @property {string} name unique name to id grouping
 * @property {string} heading text label for the results group heading
 * @property {string} subheading text label for the results group subheading
 */


/**
 * A Taxonomy Record is a Hierarchical Tree-Like Node where records have N levels deep.
 * <br><br>It is currently used for <b>search filters</b> and <b>categories</b>.
 * <br><h4>Search Filters</h4>
 * <br>Search filters are the contextual filters on the left side of the L2 Search category pages.
 * <br><h4>Categories</h4>
 * <br>A category is a unique type used in the {@link ipaTaxonomyList Taxonomy List} components on the L0 and L1 page, and as the record object in the L2 Search category record detail pages.<br>
 * <br>🗂 - for Category records only
 * <br>🗃 - for filter records only
 * @typedef TaxonomyRecord
 * @property {string} id Salesforce id of record
 * @property {string} parentId id of parent
 * @property {string} taxonomy unique id/name of taxonomy (ie. 'offeringCategories') to which the record belongs
 * @property {string} label display label
 * @property {string[]} children list of ids of child records
 * @property {boolean} [expandByDefault] 🗃 expand the filter by default on the L2 page
 * @property {boolean} [featured] 🗂 featured category (highlights Category in the Taxonomy List)
 * @property {string} [description] 🗂 category description
 * @property {string} [svgIconUrl] 🗂 category icon
 * @property {string} [learnMoreUrl] 🗂 "Learn More" url in Marquee on L2 Page
 * @property {string} [viewAllLabel] 🗂 category display label for "View all ... >" links
 * @property {SearchResultsGrouping[]} [searchResultsGroupings] 🗂 ordered list of search results groupings (<b>ie. Distributor</b>)
 * @property {SearchFiltersGrouping[]} [searchFiltersGroupings] 🗃 OPTIONAL - Overwrites Grouping Level Value<br>ordered list of search groupings & filters for L2 Search Category page
 * @property {Map<string, string[]>} [defaultFilters] 🗂 default value for filters (ie. { 'country': ['US'] })
 */


/** Taxonomy
 * <br>📊 - for taxonomies used as Level 2 Search Filters (ie. 'processors')
 * <br>🗄 - for taxonomies used as Level 2 Search Category Groupings (ie. 'offeringCategories', 'partnerDirectory')
 * @typedef Taxonomy
 * @property {string} name name of taxonomy <b>used as a unique id for search filtering</b>
 * @property {string} apiName api name of Salesforce object for linking
 * @property {string} label display name of the taxonomy ie. "Category", localized to current language
 * @property {string} viewAllLabel label for "View all ... >" links
 * @property {string} svgIconUrl icon
 * @property {string[]} topLevelIds a list of the first level of records by Salesforce Id
 * @property {string} [filterDisplayType] 📊 for custom filter display type, options:<ul><li><b>select</b> (ie. 'country')</li><li><b>large-data</b> (expandable & searchable, ie. 'processors')</li><li><b>partner-list</b> (only for 'partnerAZ')</li></ul>
 * @property {SearchFiltersGrouping[]} [searchFiltersGroupings] 🗄 ordered list of search groupings & filters for L2 Search Category page
 * @property {Map<Id, TaxonomyRecord>} records a list of all records in the taxonomy
 */


import helpers from './helpers/index';

const mockSvg = 'https://marketplace.intel.com/servlet/servlet.ImageServer?id=0153b000004Pg4r&oid=00Do0000000aRcf&lastMod=1570256505000'

const mockTaxonomyRecordFilter = ({
    id = helpers.id(),
    label = helpers.textTech() + '-' + helpers.color(),
    children = [],
    taxonomy
} = {}) => ({ id, label, children, taxonomy });

const mockSearchFilterGroupings = [
    { label: 'Technical Specifications', filters: ['filter1', 'filter2', 'filter3', 'partnerAZ', 'processors', 'filter4', 'filter5', 'filter6', 'filter7'] },
    { label: 'Other Grouping', filters: ['Offering Industries', 'filter8', 'filter9', 'filter10', 'filter11', 'filter12'] },
    { label: 'Another Grouping With A Really Long Title Name', filters: ['filter13', 'filter14', 'filter15', 'filter16', 'filter17', 'filter18', 'filter19', 'filter20', 'filter21', 'filter22'] },
];

const mockTaxonomyRecordCategory = ({
    id = helpers.id(),
    label = helpers.textShort(),
    svgIconUrl = mockSvg,
    description = helpers.text(),
    children = [],
    taxonomy,
    searchResultsGroupings,
    defaultFilters
} = {}) => ({ id, label, viewAllLabel: `View all ${label}s`, svgIconUrl, description, children, taxonomy, searchResultsGroupings, defaultFilters });

export const mockTaxonomy = () => {
    let taxonomies = {
        'Offering Categories': {
            name: 'Offering Categories',
            apiName: 'PMP_Category__c',
            label: 'Offerings by Category',
            viewAllLabel: 'View all offerings by Category',
            svgIconUrl: mockSvg,
            topLevelIds: [],
            records: {},
            searchFiltersGroupings: mockSearchFilterGroupings
        },
        'Offering Applications': {
            name: 'Offering Applications',
            apiName: 'PMP_Category__c',
            label: 'Offerings by Application',
            viewAllLabel: 'View all offerings by Application',
            svgIconUrl: mockSvg,
            topLevelIds: [],
            records: {},
            searchFiltersGroupings: mockSearchFilterGroupings
        },
        'Offering Industries': {
            name: 'Offering Industries',
            apiName: 'PMP_Category__c',
            label: 'Offerings by Industry',
            viewAllLabel: 'View all offerings by Industry',
            svgIconUrl: mockSvg,
            topLevelIds: [],
            records: {},
            searchFiltersGroupings: mockSearchFilterGroupings
        },
        'Partner Categories': {
            name: 'Partner Categorie',
            apiName: 'PMP_Category__c',
            label: 'Partner Directory',
            viewAllLabel: 'View all partners by Category',
            svgIconUrl: mockSvg,
            topLevelIds: [],
            records: {},
            searchFiltersGroupings: mockSearchFilterGroupings.slice(1,3)
        },
        'Partner Industries': {
            name: 'Partner Industries',
            apiName: 'PMP_Category__c',
            label: 'Partners by Industry',
            viewAllLabel: 'View all partners by Industry',
            svgIconUrl: mockSvg,
            topLevelIds: [],
            records: {},
            searchFiltersGroupings: mockSearchFilterGroupings
        },
        'Partner Specialties': {
            name: 'Partner Specialties',
            apiName: 'PMP_Category__c',
            label: 'Partners by Specialty',
            viewAllLabel: 'View all partners by Specialty',
            svgIconUrl: mockSvg,
            topLevelIds: [],
            records: {},
            searchFiltersGroupings: [{
                label: 'Partner Information', filters: ['filter3', 'filter4', 'country', 'filter5']
            }]
        },
        'Offering Segments': {
            name: 'Offering Segments',
            apiName: 'PMP_Category__c',
            label: 'Offerings by Segment',
            viewAllLabel: 'View all offerings by Segment',
            svgIconUrl: mockSvg,
            topLevelIds: [],
            records: {}
        },
    };

    taxonomies['Offering Categories'].records.a5N8A000000Co2IUAS = mockTaxonomyRecordCategory(
        { id: 'a5N8A000000Co2IUAS', label: 'Product Example - Laptop', taxonomy: 'Offering Categories' }
    );
    taxonomies['Offering Categories'].topLevelIds.push('a5N8A000000Co2IUAS');
    taxonomies['Offering Industries'].records.TESTINGQUICKSEARCH = mockTaxonomyRecordCategory(
        { id: 'TESTINGQUICKSEARCH', label: 'Quick Search Test', taxonomy: 'Offering Industries' }
    );
    taxonomies['Offering Industries'].topLevelIds.push('TESTINGQUICKSEARCH');

    taxonomies['Partner Categories'].records.a6y8A000000L8T3QAK = mockTaxonomyRecordCategory(
        { id: 'a6y8A000000L8T3QAK', label: 'Partner Example - Manufacturer', taxonomy: 'Partner Categories' }
    );

    taxonomies['Partner Specialties'].records.a5N8A000000Co3gUAC = mockTaxonomyRecordCategory(
        { id: 'a5N8A000000Co3gUAC', label: 'Distributor Example', taxonomy: 'Partner Specialties',
            searchResultsGroupings: [
                { name: 'dist1', heading: 'Dist Group 1', subheading: 'Minus magnam minima magnam.' },
                { name: 'dist2', heading: 'Dist Group 2', subheading: 'Voluptas minus modi est.' },
                { name: 'dist3', heading: 'Dist Group 3', subheading: 'Non a culpa est beatae et ipsam et occaecati.' },
            ], defaultFilters: { country: ['country_US'] } }
    );

    Object.keys(taxonomies).forEach(key => {
        let currentParent, i = 0, j = 0;
        while (i < 6) {
            j = 0;
            while (j < 20) {
                let nextTaxonomyRecord = mockTaxonomyRecordCategory();
                if (currentParent) nextTaxonomyRecord.parentId = currentParent;
                taxonomies[key].records[nextTaxonomyRecord.id] = nextTaxonomyRecord;
                if (j === 0) {
                    currentParent = nextTaxonomyRecord.id;
                    taxonomies[key].topLevelIds.push(nextTaxonomyRecord.id);
                } else if (j > 5) {
                    taxonomies[key].records[currentParent].children.push(nextTaxonomyRecord.id);
                    currentParent = helpers.sample(Object.keys(taxonomies[key].records));
                }
                j++;
            }
            i++;
        }
    });

    let id = 0;
    for (let idx = 1; idx < 23; idx++) {
        id++;
        let filter = 'filter' + idx;
        taxonomies[filter] = {
            label: 'Filter Label #' + idx,
            topLevelIds: [],
            records: {}
        };
        while (taxonomies[filter].topLevelIds.length < Math.ceil(Math.random() * 5) + 5) {
            id++;
            let nextTaxonomyRecord = mockTaxonomyRecordFilter({ id: 'filterid' + id, taxonomy: filter });
            while (nextTaxonomyRecord.children.length < Math.ceil(Math.random() * 10)) {
                id++;
                let nextChild = mockTaxonomyRecordFilter({ id: 'filterid' + id, taxonomy: filter });
                nextChild.parentId = nextTaxonomyRecord.id;
                while (nextChild.children.length < Math.floor(Math.random() * 2)) {
                    id++;
                    let nextNextChild = mockTaxonomyRecordFilter({ id: 'filterid' + id, taxonomy: filter });
                    nextNextChild.parentId = nextChild.id;
                    taxonomies[filter].records[nextNextChild.id] = nextNextChild;
                    nextChild.children.push(nextNextChild.id);
                }
                taxonomies[filter].records[nextChild.id] = nextChild;
                nextTaxonomyRecord.children.push(nextChild.id);
            }
            taxonomies[filter].records[nextTaxonomyRecord.id] = nextTaxonomyRecord;
            taxonomies[filter].topLevelIds.push(nextTaxonomyRecord.id);
        }
    }

    taxonomies.country = {
        label: 'Country',
        filterDisplayType: 'select',
        topLevelIds: [],
        records: {
            country_AL: { id: 'country_AL', label: 'Albania', taxonomy: 'country' },
            country_ALG: { id: 'country_ALG', label: 'Algeria', taxonomy: 'country' },
            country_AUS: { id: 'country_AUS', label: 'Australia', taxonomy: 'country' },
            country_US: { id: 'country_US', label: 'USA', taxonomy: 'country' },
            country_ZN: { id: 'country_ZN', label: 'Zanzibar', taxonomy: 'country' }
        }
    };

    taxonomies.partnerAZ = {
        label: 'Partner A-Z',
        filterDisplayType: 'partner-list',
        topLevelIds: ['PartnerID001', 'PartnerID002', 'PartnerID003', 'PartnerID004', 'PartnerID005', 'PartnerID006', 'PartnerID007', 'PartnerID008', 'PartnerID009', 'PartnerID0010','PartnerID0011','PartnerID0012','PartnerID0013','PartnerID0014'],
        records: {
            "PartnerID001": mockTaxonomyRecordFilter({ id: 'PartnerID001', label: 'ACME Partner 1', children: [], taxonomy: 'partnerAZ' }),
            "PartnerID002": mockTaxonomyRecordFilter({ id: 'PartnerID002', label: 'ACME Partner 2', children: [], taxonomy: 'partnerAZ' }),
            "PartnerID003": mockTaxonomyRecordFilter({ id: 'PartnerID003', label: 'MegaCorps Partner', children: [], taxonomy: 'partnerAZ' }),
            "PartnerID004": mockTaxonomyRecordFilter({ id: 'PartnerID004', label: 'Zyllo', children: [], taxonomy: 'partnerAZ' }),
            "PartnerID005": mockTaxonomyRecordFilter({ id: 'PartnerID005', label: '🥎🍥🚖', taxonomy: 'partnerAZ' }),
            "PartnerID006": mockTaxonomyRecordFilter({ id: 'PartnerID006', label: 'ACME Partner 3', taxonomy: 'partnerAZ' }),
            "PartnerID007": mockTaxonomyRecordFilter({ id: 'PartnerID007', label: 'ACME Partner 4', taxonomy: 'partnerAZ' }),
            "PartnerID008": mockTaxonomyRecordFilter({ id: 'PartnerID008', label: 'ACME Partner 5', taxonomy: 'partnerAZ' }),
            "PartnerID009": mockTaxonomyRecordFilter({ id: 'PartnerID009', label: 'ACME Partner 6', taxonomy: 'partnerAZ' }),
            "PartnerID0010": mockTaxonomyRecordFilter({ id: 'PartnerID0010', label: 'ACME Partner 7', taxonomy: 'partnerAZ' }),
            "PartnerID0011": mockTaxonomyRecordFilter({ id: 'PartnerID0011', label: 'ACME Partner 8', taxonomy: 'partnerAZ' }),
            "PartnerID0012": mockTaxonomyRecordFilter({ id: 'PartnerID0012', label: 'ACME Partner 9', taxonomy: 'partnerAZ' }),
            "PartnerID0013": mockTaxonomyRecordFilter({ id: 'PartnerID0013', label: 'ACME Partner 10', taxonomy: 'partnerAZ' }),
            "PartnerID0014": mockTaxonomyRecordFilter({ id: 'PartnerID0014', label: 'ACME Partner 11', taxonomy: 'partnerAZ' }),

        }
    };

    taxonomies.processors = {
        label: 'Processors',
        filterDisplayType: 'large-data',
        topLevelIds: ['processor1', 'processor2', 'processor3', 'processor4', 'processor5', 'processor6'],
        records: {}
    };
    let pid = 7;
    for (let p of taxonomies.processors.topLevelIds) {
        let filter = mockTaxonomyRecordFilter({ id: p, label: 'Intel® Core™ Processors - ' + p, taxonomy: 'processors' });
        while (filter.children.length < 15) {
            pid++;
            let nextChild = mockTaxonomyRecordFilter({ id: 'processor' + pid, taxonomy: 'processors' });
            nextChild.parentId = filter.id;
            while (nextChild.children.length < 10) {
                pid++;
                let nextNextChild = mockTaxonomyRecordFilter({ id: 'processor' + pid, taxonomy: 'processors' });
                nextNextChild.parentId = nextChild.id;
                // while (nextNextChild.children.length < (Math.floor(Math.random() * 2) + 2)) {
                //     pid++;
                //     let nextNextNextChild = mockTaxonomyRecordFilter({ id: 'processor' + pid, taxonomy: 'processors' });
                //     nextNextNextChild.parentId = nextNextChild.id;
                //     taxonomies.processors.records[nextNextNextChild.id] = nextNextNextChild;
                //     nextNextChild.children.push(nextNextNextChild.id);
                // }
                taxonomies.processors.records[nextNextChild.id] = nextNextChild;
                nextChild.children.push(nextNextChild.id);
            }
            taxonomies.processors.records[nextChild.id] = nextChild;
            filter.children.push(nextChild.id);
        }
        taxonomies.processors.records[filter.id] = filter;
    }

    taxonomies['Partner Specialties'].records.a5N8A000000Co3gUAC.children = [];

    return taxonomies;
}