import { LightningElement, api } from 'lwc';

// custom labels
import clearAllFiltersLabel from '@salesforce/label/c.PMP_Clear_All_Filters';
import filterLabel from '@salesforce/label/c.PMP_Search_Filter';
import filtersLabel from '@salesforce/label/c.PMP_Search_Filters';
import cancelLabel from '@salesforce/label/c.PMP_Search_Cancel';
import doneLabel from '@salesforce/label/c.PMP_Done';
import offeringsByCategoryLabel from '@salesforce/label/c.PMP_Filter_Offerings_Category';
import offeringFiltersLabel from '@salesforce/label/c.PMP_Offering_Filters';
import resultsLabel from '@salesforce/label/c.PMP_results';
import offeringsLabel from '@salesforce/label/c.PMP_Marketplace_Offerings';

import mainTemplate from './ipaStorefrontDetailFilters.html';
import mobileTemplate from './mobile.html';


/**
 * side filters for the storefront detail page
 *
 * @augments LightningElement
 * @property {object[]} filters filter structure object
 * @property {object} draftFilters draft filters
 * @property {number} totalCount total count (not draft)
 * @property {boolean} isMobile mobile version of filters
 * @property {boolean} showClear show "Clear All Filters" button
 */
class IpaStorefrontDetailFilters extends LightningElement {
  static delegatesFocus = true;

  @api filters;

  @api draftFilters;

  @api totalCount;

  @api isMobile;

  @api showClear;

  /**
   * Custom labels
   *
   * @type {object}
   * @private
   */
  labels = {
    filter: filterLabel,
    mobileHeading: filtersLabel,
    mobileCancel: cancelLabel,
    mobileApply: doneLabel,
    clearAllFilters: clearAllFiltersLabel,
    offeringsByCategory: offeringsByCategoryLabel,
    offeringFilters: offeringFiltersLabel,
    results: resultsLabel,
    offeringBy: offeringsLabel,
  };

  /**
   * keeps track of original filters to see if modal is in MODIFIED state
   *
   * @type {object}
   * @private
   */
  originalFilters = {};

  /**
   * 'Categories' Constant
   *
   * @type {string}
   * @private
   */
  CATEGORIES = 'Categories'

  /**
   * formatted CATEGORY filters
   *
   * @returns {object[]} formatted filters for template
   * @private
   */
  get categoryFilters() {
    const recurse = (children = []) => children.map((child) => ({
      ...child,
      label: child.label,
      children: recurse(child.children || []),
      selected: (this.draftFilters[this.CATEGORIES] || []).indexOf(child.id) > -1,
    }));
    return recurse((this.filters.find((filter) => filter.filterName === this.CATEGORIES) || {}).children);
  }

  /**
   * formatted OTHER filters
   *
   * @returns {object[]} formatted filters for template
   * @private
   */
  get otherFilters() {
    // create labels with counts ie. Filter (5)
    const recurse = (filterName, children = []) => children.map((child) => {
      const formattedLabel = child.label.replaceAll('/', '/\u200b');
      return {
        ...child,
        ariaLabel: child.label + (child.count ? ` (${child.count} ${this.labels.results})` : ''),
        label: formattedLabel + (child.count ? ` (${child.count})` : ''),
        children: recurse(filterName, child.children || []),
        selected: (this.draftFilters[filterName] || []).indexOf(child.id) > -1,
      };
    });
    return this.filters.filter((filter) => filter.filterName !== this.CATEGORIES)
      .map((filter) => ({ ...filter, children: recurse(filter.filterName, filter.children) }));
  }

  /**
   * filters unmodified
   *
   * @returns {boolean} if filters are unmodified
   * @private
   */
  get filtersUnmodified() {
    const filters = this.originalFilters || {};
    const draftFilters = { ...this.draftFilters };
    const filterKeys = Object.keys(draftFilters);
    let i = 0;
    let response = false;
    while (i < filterKeys.length) {
      const s1 = new Set(filters[filterKeys[i]] || []);
      const s2 = new Set(draftFilters[filterKeys[i]] || []);

      // if a value from filters is missing in draftFilters then the draft has been modified
      const missingValue = !([...s1.values()].every((val) => s2.has(val)));
      if (missingValue || (s1.size !== s2.size)) {
        response = true;
        break;
      }
      i += 1;
    }
    return !response;
  }

  /**
   * renders mobile / desktop template
   *
   * @returns {object} template
   * @private
   */
  render() {
    return this.isMobile ? mobileTemplate : mainTemplate;
  }

  /**
   * handle filter clicks
   *
   * @param {event} evt click event
   * @private
   */
  handleClick(evt) {
    const { filterName, filterId, isDraft } = evt.currentTarget.dataset;
    this.dispatchEvent(new CustomEvent('filterchange', {
      detail: { filterName, filterId, isDraft },
    }));
    if (filterName !== this.CATEGORIES && evt.currentTarget.checked) {
      const children = evt.currentTarget.parentElement.querySelectorAll('lightning-input');
      children.forEach((child) => {
        // optimistic change before filters return
        // eslint-disable-next-line no-param-reassign
        child.checked = true;
      });
    }
  }

  /**
   * handle accessibility
   *
   * @param {event} evt keydown event
   * @private
   */
  handleAccessibility(evt) {
    if (evt.code === 'Enter') {
      const { filterName, filterId, isDraft } = evt.currentTarget.dataset;
      this.dispatchEvent(new CustomEvent('filterchange', {
        detail: {
          filterName, filterId, isDraft, refocus: true,
        },
      }));
    }
  }

  /**
   * handle open mobile
   *
   * @private
   */
  handleOpenMobile() {
    this.template.querySelector('c-core-intc-modal').openModal();
    this.originalFilters = Object.keys(this.draftFilters).reduce((deepClone, filter) => ({
      ...deepClone,
      [filter]: [...(this.draftFilters[filter] || [])],
    }), {});
  }

  /**
   * handle apply filters
   *
   * @private
   */
  handleApplyFiltersMobile() {
    this.dispatchEvent(new CustomEvent('applymobile'));
  }

  /**
   * handle clear all draft
   *
   * @private
   */
  handleClearAllDraft() {
    this.dispatchEvent(new CustomEvent('clearallfilters', { detail: { isDraft: true } }));
  }

  /**
   * handle close mobile
   *
   * @private
   */
  handleCloseMobile() {
    this.dispatchEvent(new CustomEvent('resetdraft'));
  }

  /**
   * handle cancel mobile
   *
   * @private
   */
  handleCancelMobile() {
    this.template.querySelector('c-core-intc-modal').closeModal();
  }

  /**
   * handle clear all filters
   *
   * @private
   */
  handleClearAllFilters() {
    this.dispatchEvent(new CustomEvent('clearallfilters'));
  }
}
export default IpaStorefrontDetailFilters;