import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribeToTaxonomyData } from 'c/ipaTaxonomyService';
import { SearchHelper } from 'c/ipaSearchService';
import { handleError } from 'c/ipaErrorServiceMarketplace';

// Custom Labels
import copyUrl from '@salesforce/label/c.PMP_CopyUrl';
import copied from '@salesforce/label/c.PMP_Copied';
import share from '@salesforce/label/c.PMP_Share';
import close from '@salesforce/label/c.PMP_Close';
import filtersApplied from '@salesforce/label/c.PMP_Search_FiltersApplied';
import searchResults from '@salesforce/label/c.PMP_Search_Results_Label';
import clearAllFilters from '@salesforce/label/c.PMP_Search_ClearAllFilters';

import filtersByTag from './tags';

/** Header for the ipaSearch (L2 Category page)
 * - Includes filter tags for current search, "Sort By" dropdown, and share pop-out
 *
 * @property {object} searchParams search params
 * @property {object} searchResponse search response
 * @property {string} categoryRecordLabel category record label
 * @fires search new search event (from X - clearing filters, or changing "Sort By" dropdown)
 * @augments LightningElement
 */
class IpaSearchHeader extends LightningElement {
  /**
   * sets search params
   * - if taxonomy data exists, builds out filter tags as well (ie. Processors +5)
   */
  @api set searchParams(params) {
    this.searching = true;
    this._searchParams = params;
    if (params && this.taxonomyData) {
      this.filterTags = filtersByTag(params, this.taxonomyData);
    }
  }

  @api categoryRecordLabel;

  /**
   * get search params
   *
   * @returns {object} search params
   */
  get searchParams() {
    return this._searchParams || {};
  }

  /**
   * sets search response
   */
  @api set searchResponse(response) {
    this.searching = false;
    this._searchResponse = response;
  }

  /**
   * gets search response
   *
   * @returns {object} search response
   */
  get searchResponse() {
    return this._searchResponse;
  }

  /**
   * Url to copy
   *
   * @returns {string} url
   * @private
   */
  get urlValueToCopy() {
    return SearchHelper.getUrlFromSearchParams(this.searchParams);
  }

  /**
   * Indicates if currently searching
   *
   * @type {boolean}
   * @private
   */
  searching;

  /**
   * Keeps track of taxonomy data
   *
   * @type {object}
   * @private
   */
  taxonomyData = null;

  /**
   * Keeps track of filter tags (ie. Processors +4)
   *
   * @type {object[]}
   * @private
   */
  filterTags = [];

  /**
   * Custom labels
   *
   * @type {object}
   * @private
   */
  labels = {
    share,
    close,
    copy: copyUrl,
    filtersApplied,
    results: searchResults,
    clearAllFilters,
  };

  /**
   * Connected callback - subscribes to taxonomy data
   *
   * @private
   */
  connectedCallback() {
    this.searching = true;
    this._subscription = subscribeToTaxonomyData((taxonomyData) => {
      if (taxonomyData.includesSecondaryList) {
        this.taxonomyData = taxonomyData.data;
        if (!this.filterTags.length) { // don't compute this twice if tags already exist
          this.filterTags = filtersByTag(this.searchParams, this.taxonomyData);
        }
      }
    });
  }

  /**
   * Unsubscribes from taxonomy data
   *
   * @private
   */
  disconnectedCallback() {
    if (this._subscription) {
      this._subscription();
    }
  }

  /**
   * search
   *
   * @param {object} searchDetail searchParams, etc.
   */
  search(searchDetail) {
    this.filterTags = [];
    this.dispatchEvent(new CustomEvent('search', {
      detail: searchDetail,
    }));
  }

  /**
   * Handles changing search sort by option
   *
   * @param {event} evt onchange event
   * @private
   */
  handleSelectFilter(evt) {
    const selectedSortOption = evt.currentTarget.value;
    this.search({ searchParams: { sortType: selectedSortOption, page: 1 } });
  }

  /**
   * Clears all search filters and performs analytics call on results response with clear keyword
   *
   * @private
   */
  helperClearAllFilters() {
    SearchHelper.analytics = {
      analyticsType: 'filter',
      element: 'search-offerings-filter',
      details: 'no keyword',
    };
    this.search({ searchParams: { keyword: '', page: 1 }, useDefaultFilters: true });
  }

  /**
   * Handles clearing all search filters
   *
   * @private
   */
  handleClearAllFilters() {
    this.helperClearAllFilters();
  }

  /**
   * Handles clearing all search filters using keys
   *
   * @param {event} evt onkeydown event
   * @private
   */
  handleClearAllFiltersAccessibility(evt) {
    if (evt.code === 'Enter') {
      this.helperClearAllFilters();
    }
  }

  /**
   * Clears a pill box contextual filter
   *
   * @param {event} evt click event
   * @private
   */
  helperClearFilter(evt) {
    const tagId = evt.currentTarget.dataset.id;
    const { filterName } = evt.currentTarget.dataset;

    if (filterName === '__KEYWORD__') {
      SearchHelper.analytics = {
        analyticsType: 'filter',
        element: 'search-offerings-filter',
        details: 'no keyword',
      };
      this.search({ searchParams: { keyword: '', page: 1 } });
      return;
    }

    const allFilters = { ...this.searchParams.filters };
    let selectedIds = [...allFilters[filterName]];
    if (filterName === 'processors') {
      const allSelected = new Set(selectedIds);
      const removeRecursive = (id) => {
        allSelected.delete(id);
        const children = this.taxonomyData[filterName].records[id].children || [];
        children.forEach((childId) => removeRecursive(childId));
      };
      removeRecursive(tagId);
      selectedIds = [...allSelected];
    } else {
      selectedIds.splice(selectedIds.indexOf(tagId), 1);
    }

    const newFilters = { ...allFilters, [filterName]: selectedIds };

    if (selectedIds.length === 0) {
      delete newFilters[filterName]; // important
    }

    this.search({ searchParams: { filters: newFilters, page: 1 } });
  }

  /**
   * Handles clearing a pill box contextual filter
   *
   * @param {event} evt click event
   * @private
   */
  handleClearFilter(evt) {
    this.helperClearFilter(evt);
  }

  /**
   * Handles clearing a pill box contextual filter using keys
   *
   * @param {event} evt onkeydown event
   * @private
   */
  handleClearFilterAccessibility(evt) {
    if (evt.code === 'Enter') {
      this.helperClearFilter(evt);
    }
  }

  /**
   * Handles opening share link
   *
   * @private
   */
  handleOpenShareLinks() {
    this.template.querySelector('.share-overlay').classList.add('slds-show');
    this.template.querySelector('.share-overlay').classList.toggle('slds-hide');
  }

  /**
   * Handles closing share link
   *
   * @private
   */
  handleCloseShareLinks() {
    this.template.querySelector('.share-overlay').classList.add('slds-hide');
    this.template.querySelector('.share-overlay').classList.remove('slds-show');
  }

  /**
   * Handles copying share link using keys
   *
   * @param {event} evt onkeydown event
   * @private
   */
  handleCopyKeydown(evt) {
    if (evt.code === 'Enter') {
      this.handleCopy();
    }
  }

  /**
   * Handles copying share link, then displays a toast message and closes share overlay
   *
   * @private
   */
  handleCopy() {
    const inputEle = document.createElement('input');
    const urlValueToCopy = SearchHelper.getUrlFromSearchParams(this.searchParams);
    inputEle.setAttribute('value', urlValueToCopy);
    document.body.appendChild(inputEle);
    inputEle.select();
    inputEle.setSelectionRange(0, 9999999);

    try {
      // note: navigator.clipboard.writeText not working...
      document.execCommand('copy');
      this.template.querySelector('button[data-id="shareButton"]').focus();
      this.dispatchEvent(new ShowToastEvent({
        title: copied,
        variant: 'info',
      }));
      this.template.querySelector('.share-overlay').classList.add('slds-hide');
      this.template.querySelector('.share-overlay').classList.remove('slds-show');
    } catch (err) {
      handleError('Error Unable to Copy To Clipboard', 'ipaSearchHeader', 'console');
    }
    inputEle.parentNode.removeChild(inputEle);
  }
}
export default IpaSearchHeader;