//import fetchTaxonomy from '@salesforce/apex/PMP_TaxonomyStore.fetchTaxonomy';
import LANG from '@salesforce/i18n/lang';
import { handleError } from 'c/ipaErrorServiceMarketplace';

/**
 * Fetch Taxonomy Data
 * calls backend APEX function:  PMP_TaxonomyStore.fetchTaxonomy
 *
 * @param {object} options fetch options object
 * @param {boolean} options.baseTaxonomy use base taxonomy list
 * @returns {Promise<object>} a promise that resolves with taxonomy data
 * @private
 */
export default async function fetchTaxonomyData({ baseTaxonomy }) {
  const params = {
    requestJSON: JSON.stringify({
      baseTaxonomy: !!baseTaxonomy,
      langCode: LANG,
    }),
  };

  // try {
  //   return await fetchTaxonomy(params);
  // } catch (err) {
  //   handleError(err, 'ipaTaxonomyService - fetchTaxonomyData');
  //   // Throwing the error so it is caught by the try-catch in taxonomyActions.js in the ipaRedux component. This will
  //   // dispatch the error condition.
  //   throw err;
  // }
}