/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api } from 'lwc';
import { handleError } from 'c/ipaErrorServiceMarketplace';
import { subscribeToTaxonomyData, taxonomyDataHelpers } from 'c/ipaTaxonomyService';

// Custom Labels
import searchFilters from '@salesforce/label/c.PMP_Search_SearchFilters';
import selectAll from '@salesforce/label/c.PMP_Search_SelectAll';
import deselectAll from '@salesforce/label/c.PMP_Search_DeselectAll';
import viewMoreFilters from '@salesforce/label/c.PMP_Search_ViewMoreFilters';
import cancel from '@salesforce/label/c.PMP_Search_Cancel';
import apply from '@salesforce/label/c.PMP_Search_Apply';
import searchFilter from '@salesforce/label/c.PMP_Search_Filter';
import searchResults from '@salesforce/label/c.PMP_Search_Results_Label';
import loadingLabel from '@salesforce/label/c.PMP_Loading';
import prereleaseLabel from '@salesforce/label/c.PMP_Search_PreRelease';

import filtersModified from './modified';
import getExpandedFilters from './expanded';

// Templates
import mobileVersion from './mobileVersion.html';
import modalVersion from './modalVersion.html';
import defaultVersion from './ipaSearchFilters.html';


/** Search Filters (for L2 Category search)
 * Child Component: {@link ipaSearchFilterNode ipaSearchFilterNode}
 * Related Components: {@link ipaSearch ipaSearch}, {@link ipaSearchHeader ipaSearchHeader}, and {@link ipaSearchResults ipaSearchResults}
 * <h4>Versions</h4>
 * There are 3 'versions' of this component.
 * <ul><li><b>desktop</b> - this is the left hand column desktop filter list</li>
 * <li><b>modal</b> - this is the modal grouped version, visible after clicking "View More", "Processors", or "Partners A-Z"
 * <li><b>mobile</b> - this is the mobile (and modal) version of the filters</li></ul>
 *
 * @property {string} [version=desktop] can be 'desktop', 'modal', 'mobile'
 * @property {object} selectedFilterForModal custom data to open the modal to a specific filter, ie. Processors
 * @property {object} categoryRecord category record needed to use to lookup label, taxonomy, etc.
 * @property {boolean} [includesPreRelease] includes pre-release products (admin view only)
 * @property {boolean} [preReleaseValue] value of pre-release checkbox/state
 * @augments LightningElement
 */
class IpaSearchFilters extends LightningElement {
  @api version = 'desktop';

  @api selectedFilterForModal = {};

  @api categoryRecord = {};

  @api includesPreRelease;

  /**
   * set prerelease value
   */
  @api set preReleaseValue(val) {
    this._preReleaseValue = !!val;
    if (this.searchKeywordValue) {
      this.helperPerformSearch();
    }
  }

  /**
   * get prerelease value
   *
   * @returns {boolean} prerelease value
   */
  get preReleaseValue() {
    return this._preReleaseValue;
  }

  /**
   * sets search params
   */
  @api set searchParams(params) {
    this.loading = true;
    this.fetchingCounts = true;
    this._searchParams = params;
    if (this.taxonomyDataLoaded) {
      this.buildGroupings();
      this.setAllSelectedFiltersCount();
    }
  }

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
    this.loading = false;
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
   * sets search response
   */
  @api set searchResponseFilters(response) {
    this.fetchingCounts = false;
    this._searchResponseFilters = response;
    if (this.taxonomyDataLoaded) {
      this.buildGroupings();
    }
  }

  /**
   * gets search response
   *
   * @returns {object} search response
   */
  get searchResponseFilters() {
    return this._searchResponseFilters;
  }

  /**
   * Draft Filters (for mobile / modal)
   *
   * @type {object}
   * @private
   */
  @api set draftFilters(filters) {
    this._draftFilters = filters;
    if (this.taxonomyDataLoaded) {
      if (['modal', 'mobile'].includes(this.version)) {
        this.loading = false;
        this.resetFilters();
        this.forceShowModalFilterNodesSpinner = false;
      } else {
        this.buildGroupings();
      }
      this.draftFiltersModified = filtersModified(this.searchParams.filters, filters);
      this.setAllSelectedFiltersCount();
    }
  }

  /**
   * draft filters
   *
   * @returns {object} draft filters
   * @private
   */
  get draftFilters() {
    return this._draftFilters || { ...this.searchParams.filters };
  }

  /**
   * Custom labels
   *
   * @type {boolean}
   * @private
   */
  get labels() {
    return {
      filterSearchInputPlaceholder: searchFilters,
      selectAll,
      deselectAll,
      viewMoreFilters,
      modalHeader: `${searchFilter} ${this.categoryRecord.label} ${searchResults}`,
      modalCancelButton: cancel,
      modalApplyButton: apply,
      results: searchResults,
      includesPreRelease: prereleaseLabel,
      loading: loadingLabel,
    };
  }

  /**
   * Configuration Setting: EXPAND_BY_DEFAULT
   * - expands filters by default (instead of auto-closing on search
   *
   * @type {boolean}
   * @private
   */
  EXPAND_BY_DEFAULT = true;

  /**
   * Configuration Setting: FILTER LIMIT BEFORE SHOWING "View More"
   * - truncates list of filters to this value before showing the view more
   *
   * @type {number}
   * @private
   */
  FILTER_LIMIT_BEFORE_VIEW_MORE = 5;

  /**
   * Indicates if search is loading
   *
   * @type {boolean}
   * @private
   */
  loading;

  /**
   * Indicates if filters are loading
   *
   * @type {boolean}
   * @private
   */
  fetchingCounts;

  /**
   * Total number of selected filters
   *
   * @type {number}
   * @private
   */
  allSelectedFiltersCount = 0;

  /**
   * List of top level filter grouping objects
   *
   * @type {object[]}
   * @private
   */
  filterGroupings = [];

  /**
   * Indicates if modal should be rendered
   *
   * @type {boolean}
   * @private
   */
  renderModal;

  /**
   * Indicates if modal filters should be rendered
   *
   * @type {boolean}
   * @private
   */
  renderModalFilters;

  /**
   * Indicates if modal filter nodes should be rendered
   *
   * @type {boolean}
   * @private
   */
  renderModalFilterNodes;

  /**
   * Indicates if modal filter nodes spinner should be shown
   *
   * @type {boolean}
   * @private
   */
  forceShowModalFilterNodesSpinner;

  /**
   * Indicates if filter search spinner should be shown
   *
   * @type {boolean}
   * @private
   */
  showFilterSearchInputSpinnerIcon;

  /**
   * Indicates draft state of prerelease checkbox
   *
   * @type {boolean}
   * @private
   */
  draftPreRelease = this.preReleaseValue;

  /**
   * Expanded filter groupings (internal override for initial state expansion)
   *
   * @type {object}
   * @private
   */
  expandedGroupings = {};

  /**
   * Expanded filters (internal override for initial state expansion)
   *
   * @type {object}
   * @private
   */
  expandedFilters = {};

  /**
   * Selected filter (used for modal version)
   *
   * @type {object}
   * @private
   */
  selectedFilter = {}

  /**
   * @type {object} taxonomy data
   */
  taxonomyData = {};

  /**
   * Connected callback - subscribes to redux search, draft filter, rendering, and fetching counts data
   *
   * @private
   */
  connectedCallback() {
    // init some internal state variables
    this.isDesktopVersion = this.version === 'desktop';
    this.renderModalFilterNodes = true;
    this.loading = true;
    this.searchKeywordValue = '';
    this.subscription = subscribeToTaxonomyData((taxonomyData) => {
      if (taxonomyData.includesSecondaryList) {
        this.taxonomyData = taxonomyData.data;
        this.taxonomyDataLoaded = true;
        if (!this.groupingsBuilt) {
          this.buildGroupings();
          this.draftFiltersModified = filtersModified(this.searchParams.filters, this.draftFilters);
          if (['modal', 'mobile'].includes(this.version)) {
            this.loading = false;
            this.resetFilters();
            this.forceShowModalFilterNodesSpinner = false;
          }
        }
      }
    });
  }

  /**
   * Returns HTML Template used to render filter
   *
   * @returns {object} template
   * @private
   */
  render() {
    if (this.version === 'modal') {
      return modalVersion;
    }
    if (this.version === 'mobile') {
      return mobileVersion;
    }
    return defaultVersion;
  }

  /**
   * Rendered callback function - adjusts focus to filter modal
   *
   * @private
   */
  renderedCallback() {
    if (this.focusOnChangedFilterNodes) {
      const tabpanel = this.template.querySelector('.search-filter-nodes[role="tabpanel"]');
      if (tabpanel) {
        tabpanel.focus();
      }
      this.focusOnChangedFilterNodes = false;
    }
  }

  /**
   * Unsubscribes from taxonomy data
   *
   * @private
   */
  disconnectedCallback() {
    if (this.subscription) {
      this.subscription();
    }
  }

  /**
   * Returns current search filters
   *
   * @returns {object} current filters
   * @private
   */
  get currentFilters() {
    let filters = { ...this.searchParams.filters };
    if (['modal', 'mobile'].includes(this.version)) { // merges in draft filters
      filters = { ...filters, ...this.draftFilters };
    }
    return filters;
  }

  /**
   * Returns tabindex for filter modal 'Apply' button
   *
   * @returns {string} tabindex
   * @private
   */
  get modalApplyTabIndex() {
    return this.draftFiltersModified ? '0' : '-1';
  }

  /**
   * Returns sort options for mobile
   *
   * @returns {object[]} sort options
   * @private
   */
  get sortByOptionsForMobile() {
    return this.searchResponse.sortByOptions || [];
  }

  /**
   * Sets total number of selected filters
   *
   * @private
   */
  setAllSelectedFiltersCount() {
    const allFilters = {
      ...this.searchParams.filters,
      ...this.draftFilters,
    };
    this.allSelectedFiltersCount = Object.values(allFilters)
      .reduce((total, filter) => total + filter.length, 0);
  }

  /**
   * search
   *
   * @param {object} searchParams searchParams
   * @private
   */
  performSearch(searchParams) {
    this.dispatchEvent(new CustomEvent('search', {
      detail: { searchParams, prerelease: this.preReleaseValue },
      bubbles: true,
      composed: true,
    }));
    console.log('performsearch:'+searchParams,searchParams);
  }

  /**
   * change draft filters - dispatch event to ipaSearch
   *
   * @private
   */
  clearDraftFilters() {
    this.dispatchEvent(new CustomEvent('cleardraftfilters', { bubbles: true, composed: true }));
  }

  /**
   * sets rendering
   *
   * @type {event} rendering event
   * @private
   */
  handleFilterChange(evt) {
    if (evt.detail.renderModalSpinner) {
      this.forceShowModalFilterNodesSpinner = true;
    }
  }

  /**
   * Builds out search filter groupings/tree
   *
   * @private
   */
  buildGroupings() {
    this.groupingsBuilt = true;
    // Overwrite structure with category-specific structure if it exists on the taxonomy record
    // Otherwise get the structure from the taxonomy
    let groupings;
    try {
      groupings = this.categoryRecord.searchFiltersGroupings || this.taxonomyData[this.categoryRecord.taxonomy].searchFiltersGroupings || [];
    } catch {
      return; // likely in Experience Builder
    }

    this.filterGroupings = groupings.map((grouping, gIdx) => {
      let filtersDisplayed = 0;
      let selectedFiltersTotal = 0;
      const groupingKey = `grouping-${gIdx}`;
      const filterGrouping = {
        key: groupingKey,
        label: grouping.label,
        expanded: true,
        filters: grouping.filters.map((filterName, fIdx) => {
          // error handling
          if (!this.taxonomyData[filterName]) {
            const error = new Error(`Missing taxonomy for filter: ${filterName}`);
            handleError(error, 'ipaSearchFilters - buildGroupings');
            throw error;
          }

          const selectedFilters = this.currentFilters[filterName] || [];
          // initial expanded state of filter
          let initialExpandedState = this.EXPAND_BY_DEFAULT && selectedFilters.length > 0;
          if (this.taxonomyData[filterName].expandByDefault) {
            initialExpandedState = true;
          }
          if (this.expandedFilters[filterName] !== undefined && !initialExpandedState) {
            initialExpandedState = this.expandedFilters[filterName];
          }
          if (filterName === 'Country') {
            initialExpandedState = true;
          }

          const filter = {
            key: `${groupingKey}-filter-${fIdx}`,
            label: this.taxonomyData[filterName].label,
            name: filterName,
            children: [...taxonomyDataHelpers.topLevelTaxonomyIds(filterName)],
            expanded: initialExpandedState,
            rendered: initialExpandedState,
            sfIcon: initialExpandedState ? 'utility:dash' : 'utility:add',
            selectedFiltersList: selectedFilters.reduce((obj, prop) => ({ ...obj, [prop]: true }), {}),
            selectedFiltersCount: selectedFilters.filter((id) => this.searchResponseFilters[id]).length,
            filterDisplayType: this.taxonomyData[filterName].filterDisplayType, // for custom filters
          };

          // unique filter display type logic
          if (['select', 'large-data', 'partner-list'].includes(filter.filterDisplayType)) {
            filter.hideSelectAllLinks = true;
          }
          if (filter.filterDisplayType === 'large-data') {
            filter.hasSearch = true;
            filter.ariaRole = 'tree';
          }

          // sum all selected filters
          selectedFiltersTotal += filter.selectedFiltersCount;
          // custom logic to open modal to specific grouping/filter selected
          if (this.version === 'modal' && filter.key === this.selectedFilterForModal.key) {
            filter.selected = true;
            filter.modalData = this.selectedFilterForModal.modalData; // expands selected processor
          }

          // check if results exist from the current Search response in Redux
          const preReleaseCheck = (id) => (this.preReleaseValue || !(
            this.taxonomyData[this.categoryRecord.taxonomy].records[id] && this.taxonomyData[this.categoryRecord.taxonomy].records[id].prerelease));
          filter.hasResults = filter.children.some((id) => this.searchResponseFilters[id] && (!this.includesPreRelease || preReleaseCheck(id)));

          // limits/truncates # of desktop filters
          if (filter.hasResults) {
            filtersDisplayed += 1;
            filter.visibleOnDesktop = filtersDisplayed <= this.FILTER_LIMIT_BEFORE_VIEW_MORE;
          }
          return filter;
        }),
      };

      filterGrouping.selectedFiltersCount = selectedFiltersTotal; // sum total counts

      // show desktop "View More" if list is truncated
      if (this.version === 'desktop') {
        const filtersWithResults = filterGrouping.filters.filter((f) => f.hasResults).length;
        filterGrouping.showViewMoreFiltersLink = filtersWithResults > this.FILTER_LIMIT_BEFORE_VIEW_MORE;
      }
      filterGrouping.hasFiltersWithResults = filterGrouping.filters.some((f) => f.hasResults);
      return filterGrouping;
    });
  }

  /**
   * Resets the filters without completely rebuilding groupings
   * Faster, (used for draft filters within modal/mobile)
   *
   * @private
   */
  resetFilters() {
    this.filterGroupings = this.filterGroupings.map((grouping) => {
      let selectedFiltersTotal = 0;
      const filterGrouping = {
        ...grouping,
        filters: grouping.filters.map((filter) => {
          const expandedFilters = getExpandedFilters(this.searchParams, this.taxonomyData, filter.name);
          const newFilter = {
            ...filter,
            children: [...filter.children],
            expandedFilters,
            selectedFiltersList: (this.currentFilters[filter.name] || []).reduce((obj, prop) => {
              const elem = obj;
              elem[prop] = true;
              return elem;
            }, {}),
            selectedFiltersCount: (this.currentFilters[filter.name] || []).filter((id) => this.searchResponseFilters[id]).length,
            hasResults: filter.children.some((id) => this.searchResponseFilters[id]),
          };
          if (filter.selected) {
            this.selectedFilter = newFilter;
          }
          selectedFiltersTotal += newFilter.selectedFiltersCount;
          return newFilter;
        }),
      };
      filterGrouping.selectedFiltersCount = selectedFiltersTotal;
      filterGrouping.hasFiltersWithResults = filterGrouping.filters.some((f) => f.hasResults);
      return filterGrouping;
    });
    // in filter with search: maintains search structure after modifying selection
    if (this.searchKeywordValue && this.selectedFilter.hasSearch) {
      this.helperPerformSearch();
    }
  }

  /**
   * Helps toggle filter groupings
   *
   * @param {event} evt onclick or onkeydown event
   * @private
   */
  helperToggleGrouping(evt) {
    const { key } = evt.currentTarget.dataset;
    this.filterGroupings = this.filterGroupings.map((grouping) => ({
      ...grouping,
      expanded: key === grouping.key ? !grouping.expanded : grouping.expanded,
    }));
  }

  /**
   * Handles toggling filter groupings
   *
   * @param {event} evt onclick event
   * @private
   */
  handleToggleGrouping(evt) {
    this.helperToggleGrouping(evt);
  }

  /**
   * Handles toggling filter groupings using keys
   *
   * @param {event} evt onkeydown event
   * @private
   */
  handleToggleGroupingAccessibility(evt) {
    if (evt.code === 'Enter') this.helperToggleGrouping(evt);
  }

  /**
   * Helps toggle top level filters in filter groups and
   * updates filter groupings list
   *
   * @param {event} evt onclick or onkeydown event
   * @private
   */
  helperToggleTopLevelFilter(evt) {
    const { key } = evt.currentTarget.dataset;
    this.filterGroupings = this.filterGroupings.map((grouping) => ({
      ...grouping,
      filters: grouping.filters.map((filter) => {
        const expandedIcon = filter.expanded ? 'utility:add' : 'utility:dash';
        const newFilter = {
          ...filter,
          expanded: key === filter.key ? !filter.expanded : filter.expanded,
          rendered: key === filter.key ? true : filter.rendered,
          sfIcon: key === filter.key ? (expandedIcon) : filter.sfIcon,
        };
        this.expandedFilters[newFilter.name] = newFilter.expanded;
        return newFilter;
      }),
    }));
  }

  /**
   * Handles toggling top level filters in filter groups
   *
   * @param {event} evt onclick event
   * @private
   */
  handleToggleTopLevelFilter(evt) {
    this.helperToggleTopLevelFilter(evt);
  }

  /**
   * Handles toggling top level filters in filter groups using keys
   *
   * @param {event} evt onkeydown event
   * @private
   */
  handleToggleTopLevelFilterAccessibility(evt) {
    if (evt.code === 'Enter') this.helperToggleTopLevelFilter(evt);
  }

  /**
   * Helps deselect all filters and performs search
   *
   * @param {event} evt onclick or onkeydown event
   * @private
   */
  helperDeSelectAll(evt) {
    const { filterName, isDraft } = evt.currentTarget.dataset;
    this.dispatchEvent(new CustomEvent('filterchange', {
      detail: {
        filterName, selected: false, all: true, isDraft,
      },
      bubbles: true,
      composed: true,
    }));
    if (!isDraft) {
      this.expandedFilters[filterName] = true;
    }
  }

  /**
   * Handles deselecting all filters
   *
   * @param {event} evt onclick event
   * @private
   */
  handleDeSelectAll(evt) {
    this.helperDeSelectAll(evt);
  }

  /**
   * Handles deselecting all filters using keys
   *
   * @param {event} evt onkeydown event
   * @private
   */
  handleDeSelectAllAccessibility(evt) {
    if (evt.code === 'Enter') {
      this.helperDeSelectAll(evt);
    }
  }

  /**
   * Helps select all filters and performs search
   *
   * @param {event} evt onclick or onkeydown event
   * @private
   */
  helperSelectAll(evt) {
    console.log('helper.selectAll');
    const { filterName, isDraft } = evt.currentTarget.dataset;
    this.dispatchEvent(new CustomEvent('filterchange', {
      detail: {
        filterName, selected: true, all: true, isDraft,
      },
      bubbles: true,
      composed: true,
    }));
    if (!isDraft) {
      this.expandedFilters[filterName] = true;
    }
  }

  /**
   * Handles selecting all filters
   *
   * @param {event} evt onclick event
   * @private
   */
  handleSelectAll(evt) {
    this.helperSelectAll(evt);
  }

  /**
   * Handles selecting all filters using keys
   *
   * @param {event} evt onkeydown event
   * @private
   */
  handleSelectAllAccessibility(evt) {
    if (evt.code === 'Enter') {
      this.helperSelectAll(evt);
    }
  }

  /**
   * Handles opening filter modal using keys
   *
   * @param {event} evt onkeydown event
   * @private
   */
  handleOpenModalKeydown(evt) {
    if (evt.code === 'Enter') {
      this.handleOpenModal(evt);
    }
  }

  /**
   * Handles opening filter modal
   *
   * @param {event} evt onclick event
   * @private
   */
  handleOpenModal(evt) {
    this.renderModalFilters = false;
    this.renderModal = true;
    // DELAY rendering slightly for better UI
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => { this.renderModalFilters = true; }, 200);
    this.filterGroupings = this.filterGroupings.map((grouping) => ({
      ...grouping,
      filters: grouping.filters.filter((f) => f.hasResults).map((filter, idx) => {
        const elem = filter;
        let selected;
        if (evt.type === 'openmodal') { // NOTE: Custom Event from child
          selected = elem.name === evt.detail.filterName;
          elem.modalData = evt.detail.modalData; // for custom filter node types
        } else {
          selected = grouping.key === evt.currentTarget.dataset.key && idx === 0;
        }
        if (selected) {
          this.selectedFilter = { ...elem };
        }
        return { ...elem };
      }),
    }));
  }

  /**
   * Helps select a filter in modal or mobile view
   *
   * @param {event} evt onclick or onkeydown event
   * @private
   */
  helperSelectFilterInModal(evt) {
    const { key } = evt.currentTarget.dataset;
    this.filterGroupings = this.filterGroupings.map((grouping) => ({
      ...grouping,
      expanded: grouping.filters.some((f) => f.key === key) || grouping.expanded,
      filters: grouping.filters.map((filter) => {
        const newFilter = { ...filter, selected: filter.key === key };
        if (newFilter.selected) {
          if (this.version === 'mobile') {
            newFilter.rendered = true;
          }
          this.selectedFilter = newFilter;
        }
        return newFilter;
      }),
    }));
    // scrolls to top of modal
    const scrollEl = this.template.querySelector('.scroll-top-filter-modal');
    if (scrollEl && scrollEl.scrollIntoView) {
      scrollEl.scrollIntoView();
    }
    this.renderModalFilterNodes = false;
    // Delays rendering for better UI
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.renderModalFilterNodes = true;
      this.focusOnChangedFilterNodes = true;
      if (this.searchKeywordValue) {
        this.helperPerformSearch();
      }
    }, 80);
  }

  /**
   * Handles selecting a filter in modal or mobile view
   *
   * @param {event} evt onclick event
   * @private
   */
  handleSelectFilterInModal(evt) {
    this.helperSelectFilterInModal(evt);
  }

  /**
   * Handles selecting a filter in modal or mobile view using keys
   *
   * @param {event} evt onkeydown event
   * @private
   */
  handleSelectFilterInModalAccessibility(evt) {
    if (evt.code === 'Enter') {
      this.helperSelectFilterInModal(evt);
    }
  }

  /**
   * Handles selecting sort by option in mobile view
   *
   * @param {event} evt onchange event
   * @private
   */
  handleSelectSortByMobile(evt) {
    this.mobileSortOption = evt.currentTarget.value;
  }

  /**
   * Handles closing filter modal
   *
   * @private
   */
  handleCloseModal() {
    this.renderModal = false;
    if (!this._skipClearingDraftFilters) {
      this.clearDraftFilters();
    }
    this._skipClearingDraftFilters = false;
  }

  /**
   * Handles closing filter modal from 'Cancel' button (calls handleCloseModal as a result)
   *
   * @private
   */
  handleCancelModal() {
    this.template.querySelector('c-core-intc-modal').closeModal();
  }

  /**
   * Handles applying selected filters
   *
   * @private
   */
  handleApplyFilters() {
    this.helperApplyFilters();
  }

  /**
   * Handles applying selected filters using keys
   *
   * @param {event} evt onkeydown event
   * @private
   */
  handleApplyFiltersAccessibility(evt) {
    if (evt.code === 'Enter') this.helperApplyFilters();
  }

  /**
   * Helps apply selected filters, closes filter modal, and performs search with selected filters
   *
   * @private
   */
  helperApplyFilters() {
    this._skipClearingDraftFilters = true; // closes modal before resetting draft for better UI
    this.template.querySelector('c-core-intc-modal').closeModal();
    // no analytics on filter change just change in keyword/clear all/category update
    console.log('draftfilters applied:'+this.draftFilters,this.draftFilters);
    this.performSearch({ filters: { ...this.draftFilters }, page: 1 });
    this.clearDraftFilters();
  }

  /**
   * Handles closing mobile filter modal. Dispatches custom closemobile event.
   *
   * @private
   */
  handleCancelModalMobile() {
    this.clearDraftFilters();
    this.dispatchEvent(new CustomEvent('closemobile'));
  }

  /**
   * Handles applying filters from mobile modal. Performs search using
   * selected filters and dispatches custom closemobile event.
   *
   * @private
   */
  handleApplyFiltersMobile() {
    let searchParams = { filters: { ...this.draftFilters }, page: 1 };
    if (this.mobileSortOption) {
      searchParams = { ...searchParams, sortType: this.mobileSortOption };
      if (!this.draftFiltersModified) {
        searchParams.filters = { ...this.searchParams.filters };
      }
    }
    // no analytics on filter change just change in keyword/clear all/category update
    this.performSearch(searchParams);
  }

  /**
   * Helps change filter search input
   *
   * @param {string} keyword search keyword
   * @private
   */
  helperFilterSearchInputChange(keyword = '') {
    this.searchKeywordValue = keyword;
    const minimumChars = 3;

    if (this.selectedFilter.searchKeyword === this.searchKeywordValue) return;
    if (!keyword) { // if search is cleared reset expanded/highlighted filters
      this.selectedFilter = {
        ...this.selectedFilter,
        expandedFilters: {},
        searchKeyword: '',
        highlightedFilters: {},
      };
      this.largeDataHighlightedResultCount = 0;
    }
    if (!keyword || keyword.length < minimumChars) {
      return;
    }
    this.showFilterSearchInputSpinnerIcon = true;
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => { this.helperPerformSearch(); });
  }

  /**
   * Helps perform large data search using new keyword value
   *
   * @private
   */
  helperPerformSearch() {
    const keyword = this.searchKeywordValue || '';
    let q = keyword.toLowerCase();
    q = q.replace(/[-[\]{}()*+?.,\\^$|#]/g, '\\$&');
    q = q.replace(/\s+/g, '(\\s*?)'); // make white space variable size if it exists
    const expandedFilters = {};
    const highlightedFilters = {};
    const traverseTree = (ids) => {
      let expandParent = false;
      (ids || []).forEach((id) => {
        const record = this.taxonomyData[this.selectedFilter.name].records[id];
        if (record.label.toLowerCase().match(q) && this.searchResponseFilters[id]
          && (this.preReleaseValue || !record.prerelease)) {
          highlightedFilters[id] = true;
          expandParent = true;
        }
        if (traverseTree(record.children)) {
          expandedFilters[id] = true;
          expandParent = true;
        }
      });
      return expandParent;
    };
    traverseTree(this.selectedFilter.children);
    if (keyword !== this.searchKeywordValue) {
      return; // user is still typing...
    }
    this.largeDataHighlightedResultCount = Object.keys(highlightedFilters).length;
    this.selectedFilter = {
      ...this.selectedFilter, expandedFilters, searchKeyword: q, highlightedFilters,
    };
    this.showFilterSearchInputSpinnerIcon = false;
  }

  /**
   * Handles filter search input change
   *
   * @param {event} evt onclick event
   * @private
   */
  handleFilterSearchInputChange(evt) {
    this.helperFilterSearchInputChange(evt.detail && evt.detail.keywordValue);
  }

  /**
   * Handles filter search button click event
   *
   * @param {event} evt onclick event
   * @private
   */
  handleFilterSearchButtonClick(evt) {
    evt.preventDefault();
    this.helperFilterSearchInputChange(this.template.querySelector('input[type="search"]').value);
  }

  /**
   * Handles clearing filter search using keys
   *
   * @param {event} evt onkeydown event
   * @private
   */
  handleFilterSearchClearIconKeyDown(evt) {
    if (evt.code === 'Enter') {
      this.helperFilterSearchInputChange(evt.currentTarget.value);
    }
  }

  /**
   * prerelease toggle
   *
   * @param {event} evt change event
   * @private
   */
  handleTogglePreRelease(evt) {
    this.dispatchEvent(new CustomEvent('toggleprerelease', {
      detail: { checked: !!evt.detail.checked },
      bubbles: true,
      composed: true,
    }));
  }
}
export default IpaSearchFilters;