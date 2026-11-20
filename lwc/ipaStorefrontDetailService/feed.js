import getStorefrontFeedDetails from '@salesforce/apex/PMP_MarketplaceNewPartnerDetailFeed.getStorefrontFeedDetails';
import { handleError } from 'c/ipaErrorServiceMarketplace';

import langLocale from '@salesforce/i18n/lang';

const languageCode = langLocale.replaceAll('-', '_');

/**
 * @typedef CardDataOffering
 * @property {string} title title of offering
 * @property {string} tagline tagline for offering
 * @property {string} description description for offering
 * @property {string} id id of offering
 * @property {string} imageUrl image for offering
 * @property {string} [imageAlt] optional alternative text for offering images
 * @property {boolean} [featured] is offering featured?
 * @property {object[]} [categories] list of card category attributes
 */

/**
 * @typedef CardDataArticle
 * @property {string} title title of article
 * @property {string} description description of article
 * @property {string} createdDate created date for article
 * @property {string} externalUrl url to link the article to an external site
 */

/**
 * @typedef StorefrontFeedItem
 * @property {string} cardType can be 'article' or 'offering'
 * @property {CardDataOffering|CardDataArticle} cardData data for feed card
 */

/**
 * @typedef StorefrontFeedResponse
 * @property {StorefrontFeedItem[]} items feed items
 * @property {number} totalItems number of total available items in feed scroll
 * @property {object} filters a map of filters id -> filter object
 * @property {object[]} filterStructure how the filters are arranged on the page
 */

/**
 * Storefront Feed
 * - gets feed items (Offerings & Articles) from params
 * - stores items for "Load More"
 */
class StorefrontFeed {
  /**
   * Saved Filters
   * this is used to track the most recent list of filters
   * when the user changes filters and a new params object is passed
   * we check to see if any filters had 0 count (were hidden) in the previous set
   * we need to remove these from the list
   *
   * this preserves the original selection, but avoids returning 0 results for filters w/o intersection
   *
   * @type {object}
   * @private
   */
  savedFilters = {};

  /**
   * Get feed items/filters from Backend
   *
   * This function rebuilds the filters and filter structure based on the matching offerings
   *
   * @param {object} params params for feed
   * @param {number} params.count number of max results returned
   * @param {object} params.filters filters applied
   * @param {string} params.partnerId storefront partner ID
   * @returns {StorefrontFeedResponse} items, filters, filterStructure, totalItems
   */
  async refresh(params) {
    try {
      // calls the APEX method (cacheable=true prevents multiple calls if partnerId/langCode are the same)
      const result = await getStorefrontFeedDetails({ partnerId: params.partnerId, langCode: languageCode });

      // update filters to remove filters that are no longer relevant based on AND criteria (count 0)
      // see comments on savedFilters property above for more info
      const paramFilters = Object.keys(params.filters).reduce((newFilters, filter) => ({
        ...newFilters,
        [filter]: params.filters[filter].filter((id) => !this.savedFilters[id] || this.savedFilters[id].count),
      }), {});

      // set up variables
      const filterValues = Object.values(paramFilters);
      const hasFilters = filterValues.some((f) => f.length);

      let items = [...result.cardData];
      let updatedFilters = { ...result.filterData };
      let updatedFilterStructure = [...result.filterStructure];

      if (hasFilters) {
        const filteredOfferingIds = this.filterOfferings(paramFilters, updatedFilters);

        // filter items based on filtered offering ids
        items = items.filter((card) => filteredOfferingIds.has(card.id));

        // rebuild filters based on filtered offering ids
        updatedFilters = this.rebuildFilters(updatedFilters, filteredOfferingIds);

        // rebuild filter structure based on rebuilt filters object
        updatedFilterStructure = this.rebuildFilterStructure(updatedFilterStructure, updatedFilters, filteredOfferingIds);
      }

      // save filters for edge case on overlapping filters with 0 counts (see above)
      this.savedFilters = JSON.parse(JSON.stringify(updatedFilters));

      return {
        items: items.slice(0, params.count),
        totalItems: items.length,
        filters: updatedFilters,
        filterStructure: updatedFilterStructure,
      };
    } catch (error) {
      handleError(error, 'ipaStorefrontDetailService - feed', 'console');
      return {
        items: [],
        totalItems: 0,
        filters: [],
        filterStructure: [],
      };
    }
  }

  /**
   * Filters out offerings based on 'related offerings' property
   * on filters object returned from apex and user-selected filters
   *
   * OR - for all filters in same top level group
   * AND - for filters across different groups
   *
   * @param {object} paramFilters filters in parameters selected by user
   * @param {object} updatedFilters filters object returned from APEX
   * @returns {Set} list of filtered offering ids
   */
  filterOfferings(paramFilters, updatedFilters) {
    let filteredOfferingIds = new Set();
    Object.keys(paramFilters).forEach((filterName) => {
      const filterList = paramFilters[filterName] || [];

      // Within "Category/Top Level Group" additional filters use logical OR condition
      const ids = new Set();
      filterList.forEach((filterId) => {
        (updatedFilters[filterId].relatedOfferings || []).forEach((id) => ids.add(id));
      });

      // Across Categories / Top Level additional filters use logical AND condition
      if (filteredOfferingIds.size && ids.size) {
        filteredOfferingIds = new Set([...ids].filter((id) => filteredOfferingIds.has(id)));
      } else if (ids.size) {
        filteredOfferingIds = ids;
      }
    });
    return filteredOfferingIds;
  }

  /**
   * Rebuilds filter data based on filtered offering ids
   *
   * @param {object} filterData filter data from APEX result
   * @param {Set} filteredOfferingIds list of offering ids (filtered)
   * @returns {object} updated filter data
   */
  rebuildFilters(filterData, filteredOfferingIds) {
    const updatedFilters = { ...filterData };

    Object.values(updatedFilters).forEach((filter) => {
      const newRelatedOfferings = filter.relatedOfferings.filter((id) => filteredOfferingIds.has(id));
      updatedFilters[filter.id] = {
        ...filter,
        relatedOfferings: newRelatedOfferings,
        count: newRelatedOfferings.length,
      };
    });

    Object.values(updatedFilters).forEach((filter) => {
      updatedFilters[filter.id] = {
        ...filter,
        children: filter.children.filter((child) => updatedFilters[child].count),
      };
    });

    return updatedFilters;
  }

  /**
   * Rebuilds filter structure based on filtered offerings and rebuilt filter object
   *
   * @param {object[]} updatedFilterStructure existing filter structure
   * @param {object} updatedFilters rebuilt filters object with new filters
   * @param {Set} filteredOfferingIds list of filtered offering ids
   * @returns {object[]} rebuilt filter structure with new filters
   */
  rebuildFilterStructure(updatedFilterStructure, updatedFilters, filteredOfferingIds) {
    return updatedFilterStructure.reduce((structure, group) => {
      const relatedOfferings = group.relatedOfferings.filter((id) => filteredOfferingIds.has(id));
      if (relatedOfferings.length) {
        structure.push(({
          ...group,
          children: group.children.filter((child) => updatedFilters[child].count),
          relatedOfferings,
        }));
      }
      return structure;
    }, []);
  }
}
export default StorefrontFeed;