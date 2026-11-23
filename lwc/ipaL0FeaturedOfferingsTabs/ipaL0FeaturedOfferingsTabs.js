import { LightningElement, api, track } from 'lwc';
//import { getFeaturedOfferings } from 'c/ipaOfferingService';
// import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';

// import headingLabel from '@salesforce/label/c.PMP_L0_Featured_Header';

// this needs to be outside the component b/c a #hash in the URL gets removed after load
// in the future look at using a different method to store the tab for a copy/paste URL
// maybe use a parameter instead
//const tabHash = window.location.hash || '';

/** L0 Featured Offerings Card Carousel Component
 *
 * @augments LightningElement
 * @property {string} mainHeading heading text
 * @property {string} loadingFirstTabHeading text for the first tab while the data is loading
 * @property {number} [autoScroll=0] if set greater than 0 the card carousel will autoscroll through offerings
 * @property {boolean} lazyRender lazy render cards for increased performance (lazy render tabs is by default)
 * @author Nick Demarest, last modified 22 July 2020
 */
class IpaL0FeaturedOfferingsTabs extends LightningElement {
 
  /** custom labels
   *
   * @type {object}
   * @private
   */
//   labels = {
//     heading: headingLabel,
//   };

  @api mainHeading;

  @api loadingFirstTabHeading;

  @api autoScroll = 0;

  @api lazyRender;}

//   // Performance Settings
//   // These settings are not meant to be at the design attribute level, but still hardcoded config

//   /** helps performance by lazy-loading tabs
//    *
//    * @type {boolean}
//    * @private
//    */
//   LAZY_LOAD_TABS = true;

//   /** helps performance by rendering tabs only once they have been navigated to
//    *
//    * @type {boolean}
//    * @private
//    */
//   LAZY_RENDER_TABS = true;

//   /** lazy render delay setting
//    * based on coreIntcCarousel transition delay speed (500ms)
//    *
//    * @type {number}
//    * @private
//    */
//   LAZY_RENDER_DELAY = 600;

//   /** Number of cards per page shown on Mobile
//    * (only used for 'loading' content)
//    *
//    * @type {number}
//    * @private
//    */
//   CARDS_PER_PAGE_MOBILE = 1;

//   /** Number of cards per page shown on Tablet
//    * (only used for 'loading' content)
//    *
//    * @type {number}
//    * @private
//    */
//   CARDS_PER_PAGE_TABLET = 2;

//   /** Number of cards per page shown on Desktop
//    * (only used for 'loading' content)
//    *
//    * @type {number}
//    * @private
//    */
//   CARDS_PER_PAGE_DESKTOP = 4;

//   /**
//    * Current breakpoint
//    *
//    * @type {object}
//    * @private
//    */
//    @track breakpoint = {};

//   /** tabs and their content
//    *
//    * @type {object[]}
//    * @private
//    */
//   tabs = [];

//   /** tracks currently active tab
//    *
//    * @type {number}
//    * @private
//    */
//   activeTab = 0;

//   /** tracks most recent active page per tab
//    *
//    * @type {number[]}
//    * @private
//    */
//   activeCarouselPages = [0]; // keeps track of current page on tab - basis

//   /** tracks loading spinner
//    *
//    * @type {boolean}
//    * @private
//    */
//   showLoadingSpinner = false;

//   /**
//    * An array of errors that were thrown. This is only populated with errors that are thrown
//    * before rendering.
//    *
//    * @type {object[]}
//    * @private
//    */
//   unhandledErrors = [];

//   /** loads data
//    * - uses the ipaOfferingService
//    * - different params based on lazy load options
//    *
//    * @private
//    */
//   loadTabData() {
//     const params = this.LAZY_LOAD_TABS ? { tab: this.activeTab } : {};

//     // skip loading data if tab already loaded
//     if (this.tabs.length && this.tabs[this.activeTab] && this.tabs[this.activeTab].loaded) {
//       return;
//     }

//     // getFeaturedOfferings(params).then((tabs) => {
//     //   this.tabs = tabs.map((tab, idx) => {
//     //     const t = { ...tab };

//     //     // keep already loaded tab data for other tabs
//     //     if (this.tabs[idx] && this.tabs[idx].loaded) {
//     //       return { ...this.tabs[idx] };
//     //     }

//     //     // mark tab as loaded if active
//     //     if (String(idx) === String(this.activeTab)) {
//     //       t.loaded = true;
//     //     }

//     //     const link = `tab-${idx}_${tab.heading.replace(/[^A-Z0-9]+/ig, '-')}`;
//     //     // checking if hash is pointing to a tab link
//     //     if (!this._loaded && tabHash && tabHash.indexOf(link) > -1) {
//     //       this._loaded = true;
//     //       this.activeTab = idx;
//     //       // Situation... load tab 2 from URL, have to fetch second tab
//     //       if (!tab.loaded) {
//     //         this.loadTabData();
//     //       }
//     //     }
//     //     return { ...t, link };
//     //   });
//     //   this._loaded = true; // ensure url only affects first load

//     //   // create baseline list for 'active carousel pages'
//     //   this.activeCarouselPages = Array(this.tabs.length).fill(0);

//     //   // if lazy render is set to true
//     //   if (this.lazyRender) {
//     //     this.tabs = this.tabs.map((tab) => ({
//     //       ...tab,
//     //       cards: tab.cards.map((card) => ({ ...card, isLoading: true })),
//     //     }));
//     //   }

//     //   // prepare tabs for template
//     //   this.formatTabs();
//     // }).catch((error) => {
//     //   // handle errors
//     //   this.handleComponentError(error, 'loadTabData');
//     // });
//   }

//   /**
//    * connected callback
//    * loads data and subscribes to breakpoint changes
//    */
//   connectedCallback() {
//     try {
//       // loading placeholder tab content
//       this.tabs = [{ heading: this.loadingFirstTabHeading || 'Loading...' }];
//       this.formatTabs();

//       // load tab data
//       this.loadTabData();
//     } catch (error) {
//       // error handling
//       this.handleComponentError(error, 'connectedCallback');
//     }
//   }


//   /**
//    * rendered callback
//    * handle unhandled errors
//    */
//   renderedCallback() {
//     // Check for any errors thrown before DOM attachment
//     if (this.unhandledErrors.length) {
//       // Yes so handle them
//       this.unhandledErrors.forEach((unhandled) => {
//         this.handleComponentError(unhandled.error, unhandled.location, unhandled.type);
//       });
//       this.unhandledErrors.length = 0;
//     }
//   }

//   /**
//    * calculates cards per page (based on screen size)
//    *
//    * @returns {number} per page value
//    * @private
//    */
//   get cardsPerPage() {
//     let perPage = this.CARDS_PER_PAGE_MOBILE;
//     if (this.breakpoint.isTablet) perPage = this.CARDS_PER_PAGE_TABLET;
//     if (this.breakpoint.isDesktop) perPage = this.CARDS_PER_PAGE_DESKTOP;
//     return perPage;
//   }

//   /**
//    * get loading cards (based on screen size)
//    *
//    * @returns {object[]} loading cards
//    * @private
//    */
//   get loadingCards() {
//     const cards = [];
//     while (cards.length < this.cardsPerPage) {
//       cards.push({ id: `loading-${cards.length}`, isLoading: true });
//     }
//     return cards;
//   }

//   /**
//    * formats tabs for template
//    *
//    * @private
//    */
//   formatTabs() {
//     this.tabs = this.tabs.map((tab, idx) => {
//       const isActive = String(idx) === String(this.activeTab); let
//         cards = tab.cards || [];
//       cards = cards.length ? [...tab.cards] : this.loadingCards;
//       const rendered = !!((!this.LAZY_RENDER_TABS || tab.rendered || (isActive && cards.length)));
//       const renderedCards = rendered ? cards : this.loadingCards;

//       if (this.lazyRender && isActive && cards[0].cardType) {
//         // sets isLoading to false to allow render of active page's visible cards
//         const currentPage = parseInt(this.activeCarouselPages[this.activeTab], 10);
//         let i = currentPage * this.cardsPerPage;
//         while (i < (currentPage + 2) * this.cardsPerPage && i < cards.length) {
//           cards[i] = { ...cards[i], isLoading: false };
//           i += 1;
//         }
//       }

//       const pages = Math.ceil(renderedCards.length / this.cardsPerPage); // total page count
//       const autoScroll = isActive && pages ? this.autoScroll : 0;
//       return {
//         ...tab,
//         cards,
//         autoScroll,
//         prescroll: cards.slice(cards.length - this.cardsPerPage, cards.length),
//         prescrollActive: autoScroll > 0,
//         rendered,
//         renderedCards,
//       };
//     });
//   }

//   /**
//    * handles tab change
//    * - calls analytics
//    * - logic for lazy load / lazy rendering
//    *
//    * @param {event} evt tab change event
//    * @private
//    */
//   handleTabChange(evt) {
//     this.activeTab = evt.detail.idx;
//     this.callTabSelectAnalytics(evt.detail);
//     if (this.LAZY_LOAD_TABS) {
//       this.loadTabData();
//     }
//     // eslint-disable-next-line @lwc/lwc/no-async-operation
//     setTimeout(() => { this.formatTabs(); }, this.LAZY_RENDER_TABS ? 250 : 0);
//   }

//   /**
//    * handles page change
//    * - lazy render logic
//    *
//    * @param {event} evt page change event
//    * @private
//    */
//   handlePageChange(evt) {
//     this.activeCarouselPages[this.activeTab] = evt.detail.page - 1;
//     if (this.lazyRender) {
//       // eslint-disable-next-line @lwc/lwc/no-async-operation
//       setTimeout(() => { this.formatTabs(); }, this.LAZY_RENDER_DELAY);
//     }
//   }

//   /**
//    * analytics code
//    *
//    * @param {object} detail analytics detail
//    * @private
//    */
//   callTabSelectAnalytics(detail) {
//     const analyticsObj = {
//       analyticsType: 'navigation',
//       element: 'tab-nav',
//       details: detail.label,
//       href: `#${detail.link}`,
//     };

//     makeIpaAnalyticsCall(analyticsObj);
//   }

//   /**
//    * handle screen change thru breakpoints
//    *
//    * @param {event} evt screen change event
//    */
//   handleScreenChange(evt) {
//     this.breakpoint = evt.detail.screen;
//   }

//   /**
//    * Handles errors thrown while processing.
//    *
//    * @param {object} error  The error that was thrown.
//    * @param {string} location  The location where the error was caught. This can be a
//    * method name, a try-catch block name, or anything you want to identify it.
//    * @param {string} [type] The type of error that was trapped. Set this to 'console'
//    * if you always want the error written to the console instead of displayed to the user.
//    * @private
//    */
//   handleComponentError(error, location, type) {
//     // Get the error component to publish the error
//     const errorComponent = this.template.querySelector('c-ipa-error-component-marketplace');

//     // It won't be found if the error is caught before DOM attachment
//     if (errorComponent) {
//       // Found so call the error component
//       errorComponent.handleError(error, `ipaL0FeaturedOfferingsTabs - ${location}`, type);
//     } else {
//       // Not found so add it to the unhandled array - this will be checked in the renderedCallback method
//       this.unhandledErrors.push({ error, location, type });
//     }
//   }
// }
// export default IpaL0FeaturedOfferingsTabs;