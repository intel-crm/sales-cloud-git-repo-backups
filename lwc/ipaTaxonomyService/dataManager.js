import LANG from '@salesforce/i18n/lang';
import { handleError } from 'c/ipaErrorServiceMarketplace';
import fetchTaxonomyData from './fetchTaxonomyData';

/**
 * Cache Life for taxonomy
 *
 * @type {number}
 * @private
 */
const CACHE_LIFE = 2 * 60 * 60 * 1000; // 2 hours (SessionStorage)

/**
 * Session storage key
 *
 * @type {string}
 * @private
 */
const SESSION_STORAGE_KEY = 'ipaTaxonomyService-TaxonomyData';


/**
 * Taxonomy Data Object
 * - first checks sessionStorage
 *
 * @type {object}
 * @private
 */
let TaxonomyData = {};

try {
  const TaxonomyDataJSON = sessionStorage.getItem(SESSION_STORAGE_KEY);
  TaxonomyData = TaxonomyDataJSON ? JSON.parse(TaxonomyDataJSON) : TaxonomyData;
} catch (err) {
  handleError('Could not use session storage. It might be disabled.', 'ipaTaxonomyService', 'console');
}

/**
 * Default Taxonomy Data Object
 *
 * @type {object}
 * @private
 */
const DefaultTaxonomyData = {
  data: {},
  expires: Date.now() - 1000, // default expired
  language: LANG,
  includesBaseList: false,
  includesPreRelease: false,
  includesSecondaryList: false,
};

/* If Taxonomy is not cached, is expired, or language has changed... refresh everything */
if (!TaxonomyData || TaxonomyData.expires < Date.now() || LANG !== TaxonomyData.language) {
  TaxonomyData = { ...DefaultTaxonomyData };
  refresh();
/* edge case: If secondary list has not been successfully fetched (but cached base list exists) */
} else if (!TaxonomyData.includesSecondaryList) {
  refreshSecondaryList();
}

/**
 * subscribers object
 *
 * @type {object}
 * @private
 */
const subscribers = {};

/**
 * subscriber index to keep track of subscribers
 *
 * @type {number}
 * @private
 */
let subscriberIdx = 0;

/**
 * Subscribe Function
 * - to be used in components looking to use Taxonomy Data
 *
 * @param {Function} callback callback function
 * @returns {Function} unsubscribe function
 */
export default (callback) => {
  subscriberIdx += 1; // ensure UID
  const currentIdx = subscriberIdx;
  subscribers[currentIdx] = callback;
  callback(TaxonomyData); // immediately return current Taxonomy
  return () => {
    delete subscribers[currentIdx];
  };
};


/**
 * Refresh function
 * - fetches base taxonomy data, then secondary taxonomy data
 * - handles errors with error service
 *
 * @private
 */
async function refresh() {
  await refreshBaseList();
  await refreshSecondaryList();
}

/**
 * fetch base list data
 *
 * @private
 */
async function refreshBaseList() {
  try {
    const baseTaxonomyData = await fetchTaxonomyData({ baseTaxonomy: true });
    TaxonomyData.data = baseTaxonomyData;
    TaxonomyData.expires = Date.now() + CACHE_LIFE; // set expiration based on base taxonomy
    TaxonomyData.includesBaseList = true;
    update();
  } catch (err) {
    handleError(err, 'ipaTaxonomyService - fetchTaxonomyData (base list)');
  }
}

/**
 * fetch secondary list data
 *
 * @private
 */
async function refreshSecondaryList() {
  try {
    const secondaryTaxonomyData = await fetchTaxonomyData({ baseTaxonomy: false });
    TaxonomyData.data = { ...TaxonomyData.data, ...secondaryTaxonomyData };
    TaxonomyData.includesSecondaryList = true;
    update();
  } catch (err) {
    handleError(err, 'ipaTaxonomyService - fetchTaxonomyData (secondary list)');
  }
}

/**
 * Update Function
 * - notifies subscribers of data change
 * - stores data in session storage
 *
 * @private
 */
function update() {
  // notify subscribers
  Object.values(subscribers).forEach((callback) => {
    callback(TaxonomyData);
  });

  try {
    // save data in local storage
    sessionStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(TaxonomyData));
  } catch (err) {
    handleError('Could not use session storage. It might be disabled.', 'ipaTaxonomyService', 'console');
  }
}


// HELPER FUNCTIONS

/**
 * #requiredTaxonomyList
 *
 * This function returns the needed taxonomy list for a category to show the L2 Search page filters
 *
 * @param {string} taxonomyName the name of the taxonomy for lookup
 * @returns {object[]} list of taxonomies
 */
export function requiredTaxonomyList(taxonomyName) {
  return (TaxonomyData.data[taxonomyName].searchFiltersGroupings || [])
    .reduce((all, next) => all.concat(next.filters), [])
    .filter((filterName) => !TaxonomyData.data[filterName]);
}

/**
 * #taxonomyByCategoryId
 *
 * This function returns the taxonomy for a given category id
 *
 * @param {string} categoryId category id
 * @returns {object} taxonomy
 */
export function taxonomyByCategoryId(categoryId) {
  const taxonomy = Object.values(TaxonomyData.data).find((tax) => tax.records[categoryId]);
  if (taxonomy) {
    return taxonomy;
  }
  throw new Error(`Taxonomy for category Id: ${categoryId} not found in taxonomy data!`);
}

/**
 * #topLevelTaxonomyIds
 *
 * @param {string} taxonomyName name of taxonomy
 * @returns {string[]} record ids
 */
export function topLevelTaxonomyIds(taxonomyName) {
  const taxonomy = TaxonomyData.data[taxonomyName];
  if (taxonomy.topLevelIds && taxonomy.topLevelIds.length) {
    return taxonomy.topLevelIds;
  }
  return Object.keys(taxonomy.records || {});
}