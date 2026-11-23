import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { ipaMarqueeMarketplaceData } from 'c/ipaMarqueeMarketplace';

import { SearchHelper } from 'c/ipaSearchService';
import { subscribeToTaxonomyData, taxonomyDataHelpers } from 'c/ipaTaxonomyService';
import { getAnalyticsData, makeIpaAnalyticsCall, addCanonicalLink } from 'c/ipaAnalyticsService';

// Custom Labels
import searchError from '@salesforce/label/c.PMP_Search_Error';
import searchErrorProcessingSearch from '@salesforce/label/c.PMP_Search_ErrorProcessingSearch';
import searchErrorPleaseTryAgain from '@salesforce/label/c.PMP_Search_Error_PleaseTryAgain';
import filterResultsBy from '@salesforce/label/c.PMP_FilterResultsBy';
import searchCategory from '@salesforce/label/c.PMP_Search_Category';
import searchFilters from '@salesforce/label/c.PMP_Search_Filters';
import searchFilter from '@salesforce/label/c.PMP_Search_Filter';
import searchResults from '@salesforce/label/c.PMP_Search_Results_Label';
import searchResultsLabel from '@salesforce/label/c.PMP_Search_SearchResults';
import searchResultsFor from '@salesforce/label/c.PMP_Search_ResultsFor';
import learnMoreLabel from '@salesforce/label/c.PMP_Learn_More';
import errorPage from '@salesforce/label/c.PMP_Error_Page_URL';
import countryWarningHeadingLabel from '@salesforce/label/c.PMP_Search_Distributor_Country_Warning_Heading';
import countryWarningLabel from '@salesforce/label/c.PMP_Search_Distributor_Country_Warning';
import countryWarningSelectLabel from '@salesforce/label/c.PMP_Search_Distributor_Country_Warning_Select';
import applyLabel from '@salesforce/label/c.PMP_Search_Apply';

import allowL2FilterAnalyticsCall from '@salesforce/apex/PMP_Utility.getValue';
import isIntelEmployee from '@salesforce/apex/PMP_Utility.isIntelEmployee';

// local helpers
import { getSearchHistory, setSearchHistory } from './cache';
import { search1, search2 } from './search';

/** Documentation for the Level 2 Search Parent Component
 * <br>This is the parent component of the following components:<br>
 * <ul><li>{@link ipaSeachHeader ipaSearchHeader}</li>
 * <li>{@link ipaSearchFilters ipaSearchFilters}</li>
 * <li>{@link ipaSearchFilterNode ipaSearchFilterNode}</li>
 * <li>{@link ipaSearchResults ipaSearchResults}</li></ul>
 *
 * @property {string} [category={!recordId}] this is the Category record Id (obtained from the record page via design attribute)
 * @property {boolean} showRecommendedResults displays recommended results above regular search results (excluded from "Distributor" / specific groupings)
 * @property {string} analyticsPageType Analytics data in JSON string format
 * @augments LightningElement
 * @augments NavigationMixin
 */
class IpaSearch extends NavigationMixin(LightningElement) {
    @api category;

    @api showRecommendedResults;

    @api analyticsPageType;

    /**
     * Custom labels
     * - uses getter b/c complexity of dynamic labels for template
     *
     * @type {object}
     * @private
     */
    get labels() {
      return {
        filterKeywordHeading: filterResultsBy,
        filterKeywordPlaceholder: searchResultsLabel,
        filterCategoryHeading: this.categoryRecord.label ? `${this.categoryRecord.label} ${searchCategory}` : searchCategory,
        filterModalHeading: searchFilters,
        mobileButtonCategory: `${searchCategory}: `,
        mobileButtonFilter: searchFilter + (this._totalFilterCount > 0 ? `+${this._totalFilterCount}` : ''),
        searchResultsHeading: this.categoryRecord.label ? searchResultsFor.replace('{0}', this.categoryRecord.label || '') : searchResults,
        searchResultsSubheading: 'Unde laborum mollitia id velit earum repellat.',
        searchError,
        searchErrorProcessingSearch,
        searchErrorPleaseTryAgain,
        countryWarningHeading: countryWarningHeadingLabel,
        countryWarning: countryWarningLabel,
        countryWarningSelect: countryWarningSelectLabel,
        apply: applyLabel,
      };
    }

    /**
     * on search scrolls to top of search
     *
     * @type {number}
     * @private
     */
    ON_SEARCH_WINDOW_SCROLL_VALUE = 244;

    /**
     * keeps track of each search with a unique id (in case multiple searches happen successively)
     *
     * @type {number}
     * @private
     */
    searchUID = 0;

    /**
     * Search Params
     * - keeps track of search params, when this value changes a new search REQUEST is sent
     *
     * @type {object}
     * @private
     */
    searchParams = {
      category: '',
      keyword: '',
      page: 1,
      sortType: 'relevance',
      filters: {},
    };

    /**
     * Search Response
     * - keeps track of search response... when this value changes search RESULTS have returned
     *
     * @type {object}
     * @private
     */
    searchResponse = {
      searched: false,
      sortByOptions: [],
      results: [],
      resultsPerPage: 0,
      totalResults: 0,
      totalPages: 0,
    };

    /**
     * Search Response (Filters)
     * - keeps track of search response #2 (Filter results counts in the filters bar)
     *
     * @type {object}
     * @private
     */
    searchResponseFilters = {};

    /**
     * draft filters
     *
     * @type {object}
     * @private
     */
    draftFilters = {};

    /**
     * Keeps track of taxonomy data from ipaTaxonomyService
     *
     * @type {object}
     * @private
     */
    taxonomyData = {};

    /**
     * shows Pre-Release checkbox (for Admin view only)
     *
     * @type {boolean}
     * @private
     */
    includesPreRelease;

    /**
     * calls backend to get intel employee boolean
     *
     * @param {object} response object with data
     * @param {boolean} response.data boolean object
     * @private
     */
    @wire(isIntelEmployee) wiredIntelEmployee({ data }) {
      this.includesPreRelease = !!data;
      // only for OFFERING pages
      const isOfferingPage = !!window.location.href.match('pmp-category');
      this.includesPreRelease = isOfferingPage && this.includesPreRelease;
      if (this.includesPreRelease && (this.preReleaseValue !== false)) {
        this.preReleaseValue = true;
        this.draftPreReleaseValue = this.preReleaseValue;
      }
    }


    /**
     * calls backend to get boolean which determines whether to call Analytics
     *
     * @param {object} response object with data
     * @param {boolean} response.data object with data
     * @param {object} response.error object with error
     * @private
     */
      @wire(allowL2FilterAnalyticsCall, { key: 'PMP_L2_Filter_Analytics_Is_Active' }) wiredallowL2FilterAnalyticsCall({ data, error }) {
      if (data) {
        this.allowL2FilterAnalytics = data;
      } else if (error) {
        this.allowL2FilterAnalytics = 'false';
      }
    }


    /**
     * Tracks draft value for PreRelease checkbox
     *
     * @type {boolean}
     * @private
     */
    draftPreReleaseValue;

    /**
     * tracks value for PreRelease checkbox
     *
     * @type {boolean}
     * @private
     */
    preReleaseValue;

    /**
     * Breakpoint object
     *
     * @type {object}
     * @private
     */
    breakpoint = {};

    /**
     * Indicates if search is loading
     *
     * @type {boolean}
     * @private
     */
    loading;

    /**
     * Indicates if taxonomy is loaded
     *
     * @type {boolean}
     * @private
     */
    taxonomyLoaded;

    /**
     * Indicates if country needs to be selected (first visit to "Distributor" page)
     *
     * @type {boolean}
     * @private
     */
    showCountryWarningModal;

    /**
     * Indicates if category filter modal is open
     *
     * @type {boolean}
     * @private
     */
    showCategoryModal;

    /**
     * Indicates if filters modal is open
     *
     * @type {boolean}
     * @private
     */
    showFiltersMobile;

    /**
     * Indicates if category filter is expanded
     *
     * @type {boolean}
     * @private
     */
    categoryExpanded;



    /**
     * selected Filter List Details
     *
     * @type {object}
     * @private
     */
     selectedFilterList;


     /**
      * selected Filter List Details
      *
      * @type {object}
      * @private
      */
     selectedFilters;




     /**
      * selected Filter List Details
      *
      * @type {string}
      * @private
      */
     allowL2FilterAnalytics;


    /**
     * Search keyword value
     *
     * @type {string}
     * @private
     */
    keywordValue = '';

    /**
     * Returns taxonomy records
     *
     * @returns {object} records
     * @private
     */
    get records() {
      if (!this.taxonomy || !this.taxonomyData[this.taxonomy]) {
        return {};
      }
      return this.taxonomyData[this.taxonomy].records;
    }

    /**
     * Returns category record
     *
     * @returns {object} category record
     * @private
     */
    get categoryRecord() {
      return this.records[this.category] || {};
    }

    /**
     * Returns category record label
     *
     * @returns {string} category record label
     * @private
     */
    get categoryRecordLabel() {
      return this.categoryRecord.label || '';
    }

    /**
     * Returns category api name
     *
     * @returns {string} api name
     * @private
     */
    get categoryApiName() {
      return this.taxonomyData[this.taxonomy].apiName;
    }

    /**
     * Returns list of search results groupings for category record
     *
     * @returns {object[]} search results groupings
     * @private
     */
    get groupSearchResults() {
      return this.categoryRecord.searchResultsGroupings || [];
    }

    /**
     * Returns list of child categories of category record
     *
     * @returns {object[]} child categories
     * @private
     */
    get categoryChildren() {
      return (this.categoryRecord.children || []).map((id) => this.records[id]);
    }

    /**
     * Indicates if child category filter is shown in mobile view
     *
     * @returns {number} child categories
     * @private
     */
    get showCategoryFilterMobile() {
      return this.categoryChildren.length;
    }

    /**
     * Indicates if child category filter is shown in desktop view
     *
     * @returns {boolean} show desktop category filter
     * @private
     */
    get showCategoryFilterDesktop() {
      return this.categoryChildren.length && this.breakpoint.isDesktop;
    }

    /**
     * Indicates if view more filters link should be hidden
     *
     * @returns {number} search results groupings
     * @private
     */
    get hideViewMoreFilters() {
      return this.groupSearchResults.length;
    }

    /**
     * Indicates if there is a search error
     *
     * @returns {boolean} error
     * @private
     */
    get searchError() {
      return false;
    }

    /**
     * Returns total number of search results
     *
     * @returns {number} search results
     * @private
     */
    get totalResults() {
      return this.searchResponse.totalResults;
    }

    /**
     * Connected callback - subscribes to current search and breakpoint data
     *
     * @private
     */
    connectedCallback() {
      this.categoryExpanded = true;
      this.loading = true;
      this.initialize();
    }

    /**
     * Unsubscribes from search, breakpoint, and taxonomy data
     *
     * @private
     */
    disconnectedCallback() {
      if (this._taxonomySubscription) {
        this._taxonomySubscription();
      }
    }

    /**
     * Initializes search component - performs initial search, retrieves cached
     * search history, and subscribes to taxonomy data
     *
     * @private
     */
    initialize() {
      this.setMarqueeValues();
      this._taxonomySubscription = subscribeToTaxonomyData((taxonomyData) => {
        if (taxonomyData.includesSecondaryList) {
          this.taxonomyData = taxonomyData.data;
          // Pranjal TWC4497-34 start
          if (this.taxonomyData != null) {
            const catSearch = Object.values(this.taxonomyData).find((tax) => tax.records[this.category]);
            if (catSearch == null) {
              window.location.href = errorPage;
            }
            // TWC4497-34 ends
            this.taxonomyLoaded = true;
            try {
              this.taxonomy = taxonomyDataHelpers.taxonomyByCategoryId(this.category).name;
              this.setMarqueeValues();
              this.initialSearch();
              // Once we have taxonomy data, do specific logic for first time Country filter
              this.countryFilterWarning();
            } catch (error) {
              console.error('Error with taxonomy for this category.', error, taxonomyData);
              if (!window.location.match('.salesforce-communities.')) {
                window.location.href = errorPage; // skip redirect in Experience Builder
              }
            }
          }
        }
      });
    }

    /**
     * Performs initial search request after recieving loaded taxonomy structure
     *
     * @private
     */
    initialSearch() {
      // inital search params with default sort type and filters for Category
      const searchParams = {
        category: this.category,
        keyword: '',
        page: 1,
        sortType: this.searchResponse.sortByOptions[0] ? this.searchResponse.sortByOptions[0].value : '',
        filters: (this.categoryRecord.defaultFilters || {}),

        // overwrite with any cached params from search history
        ...getSearchHistory(this.category),

        // overwrite with any url params (from a bookmark / copy / share url)
        ...SearchHelper.getSearchParamsFromUrl(),

        // overwrite with any "initial params set" (ie. from ipaQuickSearch)
        ...SearchHelper.initialParams,
      };

      // reset initial params
      SearchHelper.initialParams = {};

      // set UID counter for searches
      this.searchUID = 1;

      if (this.includesPreRelease === false) {
        // scrub any pre-release or non-existent filters (likely from copied/shared URL)
        searchParams.filters = Object.keys(searchParams.filters).reduce((filters, filter) => ({
          ...filters,
          [filter]: (searchParams.filters[filter] || []).filter((id) => this.taxonomyData[filter].records[id]
          && (!this.taxonomyData[filter].records[id].prerelease || this.taxonomyData[filter].records[id].isIntelEmployee)),
        }), {});
      }
      this.performSearch({ ...searchParams }, true);
    }

    /**
     * select options for country
     *
     * @type {object[]}
     * @private
     */
    get countrySelectOptions() {
      const ids = taxonomyDataHelpers.topLevelTaxonomyIds('Country');
      // add default unselected
      // build select filter options from records
      return ids.map((id) => {
        const record = this.taxonomyData.Country.records[id];
        return {
          label: record.label, value: record.id,
        };
      }).sort((optA, optB) => (optA.label < optB.label ? -1 : 1));
    }

    /**
     * first time country filter
     * - displays warning toast if Category page has "Country" filter and no selection has been made
     *
     * @private
     */
    countryFilterWarning() {
      const { showCountryWarning } = this.categoryRecord;
      const countrySelection = this.searchParams.filters.Country && this.searchParams.filters.Country.length;
      if (showCountryWarning && !countrySelection) {
        this.showCountryWarningModal = true;
      }
    }

    /**
     * handle country select
     */
    handleApplyCountry() {
      const selection = this.template.querySelector('select[name="country"]');
      if (selection.value) {
        this.performSearch({ filters: { ...this.searchParams.filters, Country: [selection.value] } });
        this.template.querySelector('c-core-intc-modal[data-id="country-warning"]').closeModal();
        this.template.querySelector('c-core-intc-search').focus();
      }
    }

    /**
     * handle screen change
     *
     * @param {event} evt screen change event
     * @private
     */
    handleScreenChange(evt) {
      this.breakpoint = evt.detail.screen;
    }

    /**
     * handle draft filters change
     *
     * @param {event} evt change event
     * @private
     */
    handleClearDraftFilters(evt) {
      this.draftPreReleaseValue = this.preReleaseValue;
      this.helperUpdateDraftPreRelease();
      this.draftFilters = {};
      evt.stopPropagation();
    }

    /**
     * handle select/deselect all (for large data in modal)
     * - more performant to do this here... because as the props get passed down, simple
     * - actions like converting the filter list into a Set (or JSON.stringify) take 10x-30x in grandchildren components
     *
     * @param {event} evt draft filters change event
     * @private
     */
    handleFilterChange(evt) {
      const {
        filterName, filterId, selected, all, isDraft, clearFilter,
      } = evt.detail;
      // resets draftFilters from filters if draftFilters[filterName] is undefined
      const ids = (isDraft && this.draftFilters[filterName]) || this.searchParams.filters[filterName] || [];
      const allIds = new Set([...ids]);
      const recurseChildren = (id) => {
        const record = this.taxonomyData[filterName].records[id];
        if (!this.draftPreReleaseValue && record.prerelease) {
          return; // ignore pre release if not checked
        }
        if (!selected) {
          allIds.delete(id);
          if (all) { // only recurse tree if de-select all
            record.children.forEach((child) => recurseChildren(child));
          }
        } else if (this.searchResponseFilters[id]) { // make sure there are results
          allIds.add(id); // always recurse for Selected filters
          record.children.forEach((child) => recurseChildren(child));
        }
      };

      if (filterId) {
        if (clearFilter) {
          allIds.clear(); // added for select filters
        }
        allIds.add(filterId);
        recurseChildren(filterId);
      } else if (!filterId) {
        // assume whole taxonomy
        taxonomyDataHelpers.topLevelTaxonomyIds(filterName).forEach((id) => recurseChildren(id));
      }
      const newAllIds = [...allIds]; // needed here for performance

      // below attribute used for L2 Adobe Analytics on Filter checkbox - TWC1824-3754
      if (isDraft) {
        this.selectedFilters = undefined;
        this.selectedFilterList = { ...this.selectedFilterList, [filterName]: newAllIds };
      } else if (!isDraft && !all && selected) {
        this.selectedFilters = newAllIds;
        this.selectedFilterList = { ...this.selectedFilterList, [filterName]: filterId };
      } else if (all) {
        this.selectedFilters = undefined;
        this.selectedFilterList = { ...this.selectedFilterList, [filterName]: newAllIds };
      }

      if (isDraft) {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
          this.draftFilters = {
            ...this.draftFilters,
            [filterName]: newAllIds,
          };
        }, 10);
      } else {
        this.performSearch({ filters: { ...this.searchParams.filters, [filterName]: [...allIds] }, page: 1 });
      }

      evt.stopPropagation();
    }

    /**
     * Handles search events from child components, performs search
     *
     * @param {event} evt search event
     * @private
     */
    handleSearch(evt) {
      const { useDefaultFilters, searchParams, prerelease } = evt.detail;

      if (prerelease !== undefined) {
        this.preReleaseValue = !!prerelease;
        this.draftPreReleaseValue = this.preReleaseValue;
        this.helperUpdateDraftPreRelease();
      }

      if (useDefaultFilters) {
        searchParams.filters = this.categoryRecord.defaultFilters || {};
        // special case for Country -- essentially make current selection the "default"
        if (this.searchParams.filters.Country) {
          searchParams.filters.Country = this.searchParams.filters.Country;
        }
      }
      if (this.breakpoint.isMobile) {
        this.showFiltersMobile = false;
        this.draftFilters = {};
      }
      this.performSearch(searchParams);
      evt.stopPropagation();
    }

    /**
     * Performs Search - this is the main search function
     * - it has two requests (search results and search filter counts)
     * - requests use setTimeouts for better UI and to separate calls from being bundled
     * - it saves responses in properties which flow down thru child components
     * - it also saves search history
     *
     * @param {object} searchParams search params
     * @param {boolean} noScroll skip scrolling
     * @private
     */
    performSearch(searchParams, noScroll) {
      if (!noScroll) {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
          window.scrollTo({ top: this.ON_SEARCH_WINDOW_SCROLL_VALUE, behavior: 'smooth' });
        }, 30);
      }
      this.searchParams = { ...this.searchParams, ...searchParams };

      // scrubs any params from URL on first search after initial search
      // (for consecutive searches we need to remove conflicting param data)
      if (this.searchUID === 2) {
        const url = new URL(window.location);
        if (url.searchParams.get('search')) {
          url.searchParams.delete('search');
          window.history.replaceState({}, document.title, url.href);
        }
      }
      this.searchUID += 1;

      // save search to history
      if (this.searchParams.category) {
        setSearchHistory(this.searchParams);
      }

      // set local properties
      this.loading = true;
      this.keywordValue = this.searchParams.keyword;
      this.showNoResults = false;

      const { searchUID } = this; // local copy
      let responses = 0;

      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        search1(this.searchParams).then((response) => {
          if (searchUID === this.searchUID) {
            this.searchResponse = { ...response, searched: true };
            this._totalFilterCount = Object.values(this.searchParams.filters).reduce((total, next) => total + next.length, 0);
            this.showNoResults = this.totalResults === 0;
            if (!this._invokedPageViewHit) {
              this.invokePageViewHit();
            }
            this.draftFilters = { ...this.searchParams.filters };
            responses += 1;
            if (responses === 2) {
              this.loading = false;
            }
          }
        }).catch((err) => { this.searchError = `${err}`; });
      }, 1);

      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        search2(this.searchParams).then((response) => {
          if (searchUID === this.searchUID) {
            this.searchResponseFilters = { ...response.resultCounts };
            responses += 1;
            if (responses === 2) {
              this.loading = false;
            }
            // Logic for L2 Adobe Analytics Call on Filter checkbox - TWC1824-3754
            const finishedChilds = [];
            Object.keys(this.selectedFilterList).forEach((filterkey) => {
              const filter = this.searchParams.filters[filterkey];
              let filterType = '';
              let eventDetails = '';
              this.taxonomyData[this.taxonomy].searchFiltersGroupings.forEach((myfilters) => {
                if (myfilters.filters.includes(filterkey)) {
                  filterType = myfilters.englishLabel;
                }
              });

              let totalResultsforEvent = 0;
              filter.forEach((childFilter) => {
                let parentName = '';
                eventDetails = `|${filterType}:${this.taxonomyData[filterkey].englishLabel}:`;
                let topParent = '';

                const allChilds = [];
                if (this.selectedFilters !== undefined && this.selectedFilterList[filterkey].includes(childFilter)) {
                  this.selectedFilterList[filterkey] = this.selectedFilters;
                  this.selectedFilters = undefined;
                }
                if (this.searchResponseFilters[childFilter] !== undefined
                  && this.taxonomyData[filterkey].records[childFilter].children.length === 0
                  && this.selectedFilterList[filterkey].includes(childFilter) && !finishedChilds.includes(childFilter)) {
                  const realParent = this.taxonomyData[filterkey].records[childFilter].parentId;
                  topParent = childFilter;
                  let level = -1;
                  let topParentName = '';
                  while (this.taxonomyData[filterkey].records[topParent].parentId !== undefined) {
                    level += 1;
                    topParent = this.taxonomyData[filterkey].records[topParent].parentId;
                  }
                  topParentName = this.taxonomyData[filterkey].records[topParent].englishLabel;
                  level = level > 1 ? 1 : level;
                  while (level !== -1) {
                    if (parentName.length !== 0) {
                      parentName = `Level ${level + 2}:${parentName}`;
                    } else {
                      parentName = `Level ${level + 2}`;
                    }
                    level -= 1;
                  }
                  if (parentName !== '') {
                    parentName = `${topParentName}:${parentName}`;
                  } else {
                    parentName = topParentName;
                  }

                  if (realParent !== undefined) {
                    filter.forEach((ch) => {
                      if (this.taxonomyData[filterkey].records[realParent].children.includes(ch)) {
                        allChilds.push(ch);
                        finishedChilds.push(ch);
                      }
                    });
                  }
                  if (parentName !== '' && !eventDetails.includes(parentName)) {
                    eventDetails += parentName;
                  }
                  allChilds.forEach((child) => {
                    if (this.searchResponseFilters[child] !== undefined) {
                      totalResultsforEvent += this.searchResponseFilters[child];
                    }
                  });
                  eventDetails = totalResultsforEvent + eventDetails;
                  eventDetails = eventDetails.toLowerCase();
                  this.invokeFilterAnalyticsHit(eventDetails);
                }
              });
            });
            this.selectedFilterList = {};
          }
        }).catch((err) => { this.error = `${err}`; });
      }, 2);
    }


    /**
     * Dispatches cagetory record info for Marquee
     *
     * @private
     */
    setMarqueeValues() {
      const cat = this.categoryRecord;
      const payload = {
        title: cat.id ? (cat.label || '') : '',
        subtitle: cat.id ? (cat.description || '') : '',
        showCaret: true,
        linkData: cat.learnMoreUrl ? {
          label: learnMoreLabel,
          externalUrl: cat.learnMoreUrl,
        } : {},
      };
      ipaMarqueeMarketplaceData.setData(payload);
    }

    /**
     * Calls analytics service
     *
     * @private
     */
    invokePageViewHit() {
      this._invokedPageViewHit = true;
      const analyticsData = getAnalyticsData(this.analyticsPageType, 'Marketplace');
      analyticsData.details = `${this.totalResults}|${this.keywordValue}`;
      makeIpaAnalyticsCall(analyticsData);
      addCanonicalLink();
    }


    /**
     * Calls analytics service for filter
     *
     * @param {string} eventdetails event details
     * @private
     */
    invokeFilterAnalyticsHit(eventdetails) {
      this._invokedPageViewHit = true;
      const analyticsData = getAnalyticsData(this.analyticsPageType, 'Marketplace');
      analyticsData.analyticsType = 'filter';
      analyticsData.details = eventdetails.toLowerCase();
      analyticsData.element = 'search-filter';
      analyticsData.pageName = 'marketplace';
      if (this.allowL2FilterAnalytics === 'true') {
        makeIpaAnalyticsCall(analyticsData);
      } else {
        // eslint-disable-next-line no-console
        console.log(analyticsData);
      }
    }

    /**
     * If keyword is entered, dispatch to redux to set new keywordValue.
     *
     * @param {event} event onkeywordinput event
     * @private
     */
    handleSearchByKeyword(event) {
      this.keywordValue = event.detail.keywordValue;
      if (!this._preventKeywordSearch) {
        if (this.keywordValue !== this.searchParams.keywordValue) {
          // Logic for L2 Adobe Analytics Call on search keyword - TWC1824-3754
          SearchHelper.analytics = {
            analyticsType: 'filter',
            element: 'search-offerings-filter',
            details: this.keywordValue,
          };
          this.performSearch({
            keyword: this.keywordValue,
            page: 1,
          });
        }
      } else {
        this._preventKeywordSearch = false;
      }
    }

    /**
     * Handle Search on Icon Click
     *
     * @param {event} evt onclick event
     * @private
     */
    handleSearchButtonClick(evt) {
      evt.preventDefault();
      this.handleSearchByKeyword();
    }

    /**
     * Clears search keyword and makes analytics call on results response with clear keyword
     *
     * @private
     */
    helperClearKeyword() {
      this.keywordValue = '';
      if (this.searchParams.keyword) {
        SearchHelper.analytics = {
          analyticsType: 'filter',
          element: 'search-offerings-filter',
          details: 'no keyword',
        };
        this.performSearch({ keyword: '', page: 1 });
      }
    }

    /**
     * Handles clearing search keyword value
     *
     * @private
     */
    handleClearKeyword() {
      this.helperClearKeyword();
    }


    /**
     * Toggles category filter expansion
     *
     * @private
     */
    helperToggleCateogryGrouping() {
      this.categoryExpanded = !this.categoryExpanded;
    }

    /**
     * Handles toggling category expansion
     *
     * @private
     */
    handleToggleCategoryGrouping() {
      this.helperToggleCateogryGrouping();
    }

    /**
     * Handles toggling category expansion using keys
     *
     * @param {event} evt onkeydown event
     * @private
     */
    handleToggleCategoryGroupingAccessibility(evt) {
      if (evt.code === 'Enter') {
        this.helperToggleCateogryGrouping();
      }
    }

    /**
     * Handles opening category filter modal
     *
     * @private
     */
    handleOpenMobileCategory() {
      this.showCategoryModal = true;
    }

    /**
     * Handles opening filters modal
     *
     * @private
     */
    handleOpenMobileFilters() {
      this.showFiltersMobile = true;
    }

    /**
     * Handles closing filters modal from filter node modal
     *
     * @private
     */
    handleCloseMobileModal() {
      this.template.querySelector('c-core-intc-modal').closeModal();
      this.showFiltersMobile = false;
      this.draftFilters = {};
    }

    /**
     * Handles closing filter and category modals
     *
     * @private
     */
    handleCloseMobileModalX() {
      this.showCategoryModal = false;
      this.showFiltersMobile = false;
      this.draftFilters = {};
    }

    /**
     * Handles click on category link
     *
     * @param {object} root0 link click event
     * @param {object} root0.detail link click event detail
     * @private
     */
    handleCategoryLinkClick({ detail }) {
      if (detail.recordId) {
        const keyword = this.keywordValue ? this.keywordValue.split(' ').join(',') : 'no keyword';
        // analytics call on response with category change response
        SearchHelper.analytics = {
          analyticsType: 'filter',
          element: 'search-panel-filter',
          details: [keyword, detail.recordId].join('|'),
        };
        // pass current filters and search params down to child category
        setSearchHistory({
          ...this.searchParams,
          category: detail.recordId,
          page: 1,
        });
        this[NavigationMixin.Navigate](detail.pageRef);
      }
    }

    /**
     * handles checkbox change "Includes Pre-Release"
     * (if unchecking, removes all prerelease items)
     *
     * @param {event} evt event
     * @private
     */
    handleTogglePreRelease(evt) {
      const { checked } = evt.detail;
      this.draftPreReleaseValue = !!checked;
      this.helperUpdateDraftPreRelease();

      evt.stopPropagation();
    }

    /**
     * Updates the draft filters if pre release checkbox value changes
     *
     * @private
     */
    helperUpdateDraftPreRelease() {
      if (!this.draftPreReleaseValue) {
        this.draftFilters = Object.keys(this.draftFilters).reduce((filters, filter) => ({
          ...filters,
          [filter]: this.draftFilters[filter].filter((id) => !this.taxonomyData[filter].records[id].prerelease),
        }), {});
      } else {
        // doing this triggers a rebuild of the filters in ipaSearchFilters to include prerelease
        // (required if large data search keyword is present)
        this.draftFilters = { ...this.draftFilters };
      }
    }
}
export default IpaSearch;