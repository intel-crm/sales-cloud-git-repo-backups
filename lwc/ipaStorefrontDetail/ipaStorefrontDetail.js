import { LightningElement, api } from 'lwc';
import { fetchPartnerInfo, StorefrontFeed } from 'c/ipaStorefrontDetailService';
import { handleError } from 'c/ipaErrorServiceMarketplace';

// Custom Labels
import companyResourcesLabel from '@salesforce/label/c.PMP_Company_Resources';
import companyInfoLabel from '@salesforce/label/c.PMP_CompanyInformation';
import companyWebsiteLabel from '@salesforce/label/c.PMP_Company_Website';
import resourceTypeLabel from '@salesforce/label/c.PMP_Edit_Storefront_Resources_Type_Label';
import clearAllFiltersLabel from '@salesforce/label/c.PMP_Clear_All_Filters';
import filtersAppliedLabel from '@salesforce/label/c.PMP_FiltersApplied';
import loadMoreLabel from '@salesforce/label/c.PMP_Load_More';
import loadingLabel from '@salesforce/label/c.PMP_Loading';
import articleFeedLabel from '@salesforce/label/c.PMP_Storefront_Feed_Assistive';
import skipToFeedLabel from '@salesforce/label/c.PMP_Storefront_Feed_Skip';
import returnToFiltersLabel from '@salesforce/label/c.PMP_Storefront_Feed_Return';

import loadingTemplate from './loading.html';
import mainTemplate from './ipaStorefrontDetail.html';
import buildTags from './tags';


/**
 * Storefront component
 *
 * @property {string} recordId id of storefront partner
 * @augments LightningElement
 */
class IpaStorefrontDetail extends LightningElement {
  @api recordId;

  /**
   * Initial feed items shown
   *
   * @type {number}
   * @private
   */
  FEED_COUNT_FIRST_PAGE = 5;

  /**
   * Added on each "Load More" click
   *
   * @type {number}
   * @private
   */
  FEED_COUNT_LOAD_MORE = 5;

  /**
   * Custom Labels
   *
   * @type {object}
   * @private
   */
  labels = {
    clearAllFilters: clearAllFiltersLabel,
    filtersApplied: filtersAppliedLabel,
    skipToFeed: skipToFeedLabel,
    returnToFilters: returnToFiltersLabel,
    loadMore: loadMoreLabel,
    loading: loadingLabel,
    articleFeed: articleFeedLabel,
    companyInformation: companyInfoLabel,
    companyResources: companyResourcesLabel,
    resourceType: resourceTypeLabel,
    pageName: 'PartnerDetailPage'
  };

  /**
   * Data - companyResources are defined by default and other properties are dynamically added
   *
   * @type {object}
   * @private
   */
  data = {
    companyResources: [],
  };

  /**
   * keep track of loading
   *
   * @type {boolean}
   * @private
   */
  loading;

  /**
   * keep track of current screen size from coreIntcUtilities
   *
   * @type {object}
   * @private
   */
  currentScreen = {};

  /**
   * keep track of loading / filtering feed items
   *
   * @type {boolean}
   * @private
   */
  loadingFeed;

  /**
   * feed params
   *
   * @type {object}
   * @private
   */
  feedParams = {};

  /**
   * feed items
   *
   * @type {object[]}
   * @private
   */
  feedItems = [];

  /**
   * feed total items
   *
   * @type {number}
   * @private
   */
  totalFeedItems = 0;

  /**
   * filters (id => filter object)
   *
   * @type {object}
   * @private
   */
  filters = {};

  /**
   * filter tags
   *
   * @type {object[]}
   * @private
   */
  filterTags = [];

  /**
   * filter tree structure for UI
   *
   * @type {object[]}
   * @private
   */
  filterStructure = [];

  /**
   * Last opened company info modal
   *
   * @type {object}
   * @private
   */
   lastOpenedSection = {};

   /**
    * Returns company website label
    *
    * @returns {string} company website label
    * @private
    */
   get companyWebsiteLabel() {
     return (this.data && this.data.companyInfo) ? companyWebsiteLabel.replace('{0}', this.data.companyInfo.websiteLabel) : '';
   }


   /**
    * Returns partner analytics details for contact menu
    *
    * @returns {string[]} analytics details
    * @private
    */
   get contactPartnerAnalyticsDetails() {
     const details = ['modal_contact-partner'];
     const categories = (this.data && this.data.categories) || [];
     details.push(categories.length ? categories.join('-') : 'NA');
     details.push(this.recordId);
     return details;
   }

   /**
    * Indicates if the feed is visible
    * (it is visible for all storefronts until offerings are loaded, then hidden if no offerings)
    *
    * @returns {boolean} is feed visible
    * @private
    */
   get feedVisible() {
     return !this._completedFirstSearch || (!this.loadingFeed && this.feedItems.length) || (this.loadingFeed && this.totalFeedItems);
   }

   /**
    * Indicates if filters should be visible
    *
    * @returns {boolean} is filters visible
    * @private
    */
   get filtersVisible() {
     return !this.loadingFeed && this.feedItems.length;
   }

   /**
    * Returns css classes for left pane
    * shows feed layout unless feed is loaded and no offerings exist
    *
    * @returns {object} css classes
    * @private
    */
   get classes() {
     return {
       companyInfo: [
         'company-info-section slds-col slds-size_12-of-12 slds-p-top_large slds-p-around_medium left-pane',
         (this.feedVisible ? 'slds-medium-size_4-of-12 slds-large-size_3-of-12' : 'slds-large-size_9-of-12'),
       ].join(' '),
       companyResources: [
         'slds-col slds-size_12-of-12 slds-large-size_3-of-12 company-resources',
         (this.feedVisible ? 'slds-medium-size_8-of-12' : ''),
       ].join(' '),
     };
   }

   /**
    * formatted feed items for template
    *
    * @returns {object[]} formatted feed items for template
    * @private
    */
   get formattedFeedItems() {
     return this.feedItems.map((feedItem, idx) => ({
       ...feedItem,
       key: `feedItem-${idx}`,
     }));
   }

   /**
    * show Load more button
    *
    * @returns {boolean} button visibility
    * @private
    */
   get showLoadMore() {
     return this.feedItems.length < this.totalFeedItems;
   }

   /**
    * get total count for mobile button
    *
    * @returns {number} total
    * @private
    */
   get totalCountMobile() {
     return Object.keys(this.draftFilters)
       .reduce((total, filter) => total + this.draftFilters[filter].filter((id) => this.filters[id].count).length, 0);
   }

   /**
    * assistive text for "Applied filters"
    *
    * @returns {string} accessible filters applied text
    * @private
    */
   get filtersAppliedAssistive() {
     return this.filterTags.length ? ''
       : `${this.labels.filtersApplied} ${this.filterTags.map((tag) => tag.label + (tag.count ? ` + ${tag.count}` : '')).join(', ')}`;
   }

   /**
    * size for "Company Information" c-core-intc-text-block
    *
    * @returns {string} size value
    * @private
    */
   get companyInfoTextBlockSize() {
     return this.feedVisible ? 'small' : 'full'; // removes text block w/o feed
   }

  /**
   * draft filters (for mobile)
   *
   * @type {object}
   * @private
   */
  draftFilters = {};

  /**
   * connected callback
   * - gets data for storefront
   *
   * @private
   */
  connectedCallback() {
    this.loading = true;
    fetchPartnerInfo(this.recordId).then(async (data) => {
      this.data = { ...data };
      this.loading = false;
    }).catch((err) => {
      handleError(`Error getting partner data ${err}`, 'ipaStorefrontDetail', 'console');
    });
    this.feedParams = {
      partnerId: this.recordId,
      count: this.FEED_COUNT_FIRST_PAGE,
      filters: {},
    };
    this.loadingFeed = true;
    // ensure server calls are not joined by LWC framework for better UI
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.feed = new StorefrontFeed(); // initialize feed
      this.refreshFeed();
    }, 50);
  }

  /**
   * render function
   *
   * @returns {object} template
   * @private
   */
  render() {
    return this.loading ? loadingTemplate : mainTemplate;
  }

  /**
   * focus on last previously loaded card after "Loading more..."
   *
   * @private
   */
  renderedCallback() {
    if (this._focusOnNextFeedItem !== undefined) {
      const cards = this.template.querySelectorAll('c-ipa-storefront-detail-card');
      if (cards[this._focusOnNextFeedItem]) {
        cards[this._focusOnNextFeedItem].focus();
        this._focusOnNextFeedItem = undefined;
      }
    } else if (this._focusOnTag !== undefined) {
      const tagSelector = `button.pill-cancel[data-id='${this._focusOnTag}']`;
      const tag = this.template.querySelector(tagSelector);

      if (tag) {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => { tag.focus(); }, 50);
      }
      this._focusOnTag = undefined;
    }
  }

  /**
   * refresh feed
   *
   * @param {boolean} isNewSearch scroll to top on new search
   * @private
   */
  refreshFeed(isNewSearch) {
    this.loadingFeed = true;
    this.draftFilters = { ...this.feedParams.filters };

    // if new "search" (filters applied) reset count and scroll to top
    if (isNewSearch && this._completedFirstSearch) {
      this.feedParams.count = this.FEED_COUNT_FIRST_PAGE;
      const el = this.template.querySelector(this.currentScreen.isMobile ? '.filter-scroll-mobile' : '.filter-scroll-desktop');
      if (el && el.scrollIntoView) {
        el.scrollIntoView();
      }
    }

    this._feedId = Date.now();
    const feedId = this._feedId;
    this.feed.refresh(this.feedParams).then(async ({
      items, filters, filterStructure, totalItems,
    }) => {
      if (feedId !== this._feedId) {
        return; // wait for most recent call
      }

      // if "Load More" is clicked set focus on the next loaded item
      if (!isNewSearch && this._completedFirstSearch) {
        this._focusOnNextFeedItem = this.feedItems.length;
      }
      this._completedFirstSearch = true;

      // reset vars
      this.filterTags = buildTags(this.feedParams.filters, filters); // rebuild if necessary
      this.feedItems = [...items];
      this.totalFeedItems = totalItems;
      this.filters = { ...filters };
      const recurseTree = (filterName, filter) => ({
        ...filter,
        selected: (this.feedParams.filters[filterName] || []).includes(filter.id),
        children: (filter.children || []).map((id) => recurseTree(filterName, filters[id])),
      });
      this.filterStructure = filterStructure.map((filter) => recurseTree(filter.filterName, filter));

      // save these for mobile (when resetting draft on X / Cancel)
      this._savedFilters = JSON.parse(JSON.stringify(this.filters)); // deep clone
      this._savedFilterStructure = JSON.parse(JSON.stringify(this.filterStructure)); // deep clone

      this.loadingFeed = false;
    }).catch((err) => {
      this.loadingFeed = false;
      handleError(`Error with storefront detail feed ${err}`, 'ipaStorefrontDetail', 'console');
    });
  }

  /**
   * handle filters
   *
   * @param {event} evt filter change event
   * @private
   */
  handleFilterChange(evt) {
    const {
      filterName, filterId, isDraft,
    } = evt.detail;
    const feedParams = { ...this.feedParams };
    // use draft filters for draft (mobile)
    if (isDraft) {
      feedParams.filters = JSON.parse(JSON.stringify(this.draftFilters)); // deep clone
    }
    // see if filter is already selected
    const idx = (feedParams.filters[filterName] || []).indexOf(filterId);
    if (idx > -1) {
      feedParams.filters[filterName].splice(idx, 1);
    } else {
      feedParams.filters[filterName] = (feedParams.filters[filterName] || []).concat(filterId);
      const filterSet = new Set(feedParams.filters[filterName]);
      const recurseChildren = (id) => {
        filterSet.add(id);
        (this.filters[id].children || []).forEach((child) => { recurseChildren(child); });
      };
      recurseChildren(filterId);
      feedParams.filters[filterName] = [...filterSet];
    }
    if (isDraft) {
      this.draftFilters = feedParams.filters;
      this._draftFeedId = Date.now();
      const feedId = this._draftFeedId;
      this.feed.refresh(feedParams).then(({ filters, filterStructure }) => {
        if (feedId !== this._draftFeedId) {
          return; // wait for most recent call
        }
        this.filters = { ...filters };
        const recurseTree = (fName, filter) => ({
          ...filter,
          selected: (feedParams.filters[fName] || []).includes(filter.id),
          children: (filter.children || []).map((id) => recurseTree(fName, filters[id])),
        });
        this.filterStructure = filterStructure.map((filter) => recurseTree(filter.filterName, filter));
      });
    } else {
      this.feedParams = feedParams;
      this.filterTags = buildTags(this.feedParams.filters, this.filters);
      if (idx < 0) { // filter was added, now find relevant tag id
        const findTag = (id) => {
          if (this.filterTags.find((tag) => tag.id === id)) {
            return id;
          }
          return findTag(this.filters[id].parent);
        };
        this._focusOnTag = findTag(filterId);
      }
      this.filters = [];
      this.feedItems = [];
      this.refreshFeed(true);
    }
  }

  /**
   * handle load more
   *
   * @private
   */
  handleLoadMore() {
    this.feedParams.count += this.FEED_COUNT_LOAD_MORE;
    this.refreshFeed(false);
  }

  /**
   * handle apply mobile
   *
   * @private
   */
  handleApplyMobile() {
    this.feedParams.filters = { ...this.draftFilters };
    this.filterTags = buildTags(this.feedParams.filters, this.filters);
    this.filters = [];
    this.feedItems = [];
    this.refreshFeed(true);
  }

  /**
   * handle clear filter event
   *
   * @param {event} evt click event
   * @private
   */
  handleClearFilter(evt) {
    const { id, filterName } = evt.currentTarget.dataset;
    const idx = this.feedParams.filters[filterName].indexOf(id);
    this.feedParams.filters[filterName].splice(idx, 1);
    // build tags, then refresh filters (they change with response)
    this.filterTags = buildTags(this.feedParams.filters, this.filters);
    this.filters = [];
    this.feedItems = [];
    this.refreshFeed(true);
  }

  /**
   * clear all filters
   *
   * @param {event} evt clear all event
   * @private
   */
  handleClearAllFilters(evt) {
    const { isDraft } = evt.detail || {};
    if (isDraft) {
      this.draftFilters = {};
    } else {
      this.feedParams.filters = {};
      this.filterTags = [];
      this.filters = [];
      this.feedItems = [];
      this.refreshFeed(true);
    }
  }

  /**
   * handle reset draft
   *
   * @private
   */
  handleResetDraft() {
    this.draftFilters = JSON.parse(JSON.stringify(this.feedParams.filters)); // deep clone
    this.filters = this._savedFilters;
    this.filterStructure = this._savedFilterStructure;
  }

  /**
   * screen change (using coreIntcUtilities)
   *
   * @param {event} evt screen change event
   * @private
   */
  handleScreenChange(evt) {
    this.currentScreen = evt.detail.screen;
    if (this.lastOpenedSection.isOpen) {
      this.helperStyleColumns(this.lastOpenedSection.section, this.lastOpenedSection.displaySection);
    }
  }

  /**
   * return focus to filters
   *
   * @private
   */
  handleSkipToFeed() {
    this.template.querySelector('button.return-to-filters-button').focus();
  }

  /**
   * return focus to filters
   *
   * @private
   */
  handleReturnToFilters() {
    this.template.querySelector('button.skip-to-feed').focus();
  }

  /**
   * Scrolls to top of text block when clicking 'Show Less'
   */
  handleScrollTextBlock() {
    const textblock = this.template.querySelector('.company-info-section');
    textblock.scrollIntoView({ behavior: 'smooth' });
  }

  /**
   * Handles opening quick view modal and applies modal styling
   *
   * @param {event} evt open quick view
   */
  handleOpenQuickView(evt) {
    const { dataset } = evt.target;
    this.helperStyleColumns(dataset.section, dataset.displaySection);
    this.lastOpenedSection = { displaySection: dataset.displaySection, section: dataset.section, isOpen: true };
  }

  /**
   * Handles closing quick view modal
   */
  handleCloseQuickView() {
    this.lastOpenedSection.isOpen = false;
  }

  /**
   * Helper for adding column styling to company info modals
   *
   * @param {string} selectedSection selected section
   * @param {string} displaySection indicates if regional coverage data is being parsed
   */
  helperStyleColumns(selectedSection, displaySection) {
    let lines;
    let section;
    if (this.currentScreen.isDesktop) {
      if (displaySection === 'false') {
        this.data.partnerAttributes.forEach((item) => {
          if (item.title === selectedSection) section = item.sections;
        });
        lines = section.map((item) => item.values.length + 2).reduce((a, b) => a + b, 0);
      } else {
        this.data.partnerAttributes.forEach((item) => {
          if (item.displaySectionsInModal) {
            item.sections.forEach((value) => {
              if (value.label === selectedSection) section = value.values;
            });
          }
        });
        lines = (section.map((item) => item.subsection.length).reduce((a, b) => a + b, 0) + section.length * 2) / 15;
      }
    }

    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      const modalContainer = this.template.querySelector(`.modal-attributes-container[data-section="${selectedSection}"]`);
      modalContainer.style.columnCount = this.currentScreen.isDesktop ? Math.min(4, Math.ceil(lines / 9)) : 1;
    }, 0);
  }
}
export default IpaStorefrontDetail;