import {
  LightningElement, api, track,
} from 'lwc';

// import next from '@salesforce/label/c.PMP_Next';
// import previous from '@salesforce/label/c.PMP_Previous';
// import showingResults from '@salesforce/label/c.PMP_Search_ShowingResults';
// import showingOneResult from '@salesforce/label/c.PMP_Search_ShowingOneResult';
// import IpaCampaignService from 'c/ipaCampaignService';

// /** Documentation for the product/partner Campaign Card List Component
//  * <br>This component is on the Marketplace Event Detail Page for both 'Offerings' and 'Partners' lists
//  * <br>It uses the {@link ipaCardList} component with <code>cards-per-row</code> attributes
//  * <br>It is exposed in the community builder as <b>IPA Campaign Card List</b>
//  * <h3>Lazy Loading</h3>
//  * To turn on lazy loading (server calls), there is a setting inside the component.
//  * <br>This will pass in a <code>page</code> param to ipaCampaignService.getCampaignCards.
//  * <br>It is unlikely this will be a performance benefit unless the event offering or partner results are potentially very large sets. ie. 100, 300, 500
//  *
//  * @property {string} heading List heading.
//  * <br><i>NOTE: this can be set in the community builder if it is static across all events.
//  * <br>If it is dynamic it must be set from the {@link ipaCampaignService} response.</i>
//  * @property {string} listType Can be 'product' or 'partner'.
//  * @property {boolean} showLoading Set this to 'true' to show Loading cards while the service is being called.
//  * <br><i>(NOTE: only one list should set this to true b/c we don't know which list will return results... heading is hidden while loading).</i>
//  * @property {string} campaign This value is required and is to be set through the design attributes as the Record Detail page recordId
//  * <br>(required value: <code>{!recordId}</code>).
//  * @property {string} theme Changes theme options... inverse or default.
//  * @augments LightningElement
//  */
 class IpaCampaignCardList extends LightningElement {
//     /**
//      * Setting for Lazy Loading paginated data.
//      * Decided against making this a design property.
//      *
//      * @type {boolean}
//      * @private
//      */
//     LAZY_LOAD_PAGINATION = true;

//     /**
//      * Custom labels
//      *
//      * @type {object}
//      * @private
//      */
//     labels = {
//       showingOneResult,
//       showingResultsText: showingResults,
//       next,
//       previous,
//     };

//     /**
//      * Number of cards per row for mobile
//      *
//      * @type {number}
//      * @private
//      */
//     CARDS_PER_ROW_MOBILE = 1;

//     /**
//      * Number of cards per row for tablet
//      *
//      * @type {number}
//      * @private
//      */
//     CARDS_PER_ROW_TABLET = 2;

//     /**
//      * Number of cards per row for desktop
//      *
//      * @type {number}
//      * @private
//      */
//     CARDS_PER_ROW_DESKTOP = 4;

//     /**
//      * Number of cards per page for mobile
//      *
//      * @type {number}
//      * @private
//      */
//     CARDS_PER_PAGE_MOBILE = 4;

//     /**
//      * Number of cards per page for tablet
//      *
//      * @type {number}
//      * @private
//      */
//     CARDS_PER_PAGE_TABLET = 8;

//     /**
//      * Number of cards per page for desktop
//      *
//      * @type {number}
//      * @private
//      */
//     CARDS_PER_PAGE_DESKTOP = 8;

    @api heading;

    @api listType;

    @api showLoading;

    @api campaign;

    @api theme;
 }

//     /**
//      * Array of cards
//      *
//      * @type {object[]}
//      * @private
//      */
//     @track cards = [];

//     /**
//      * Indicates if component should be hidden
//      *
//      * @type {boolean}
//      * @private
//      */
//     hideComponent;

//     /**
//      * Breakpoint object
//      *
//      * @type {object}
//      * @private
//      */
//     @track breakpoint = {};

//     /**
//      * Array of all cards recieved from IpaCampaignService
//      *
//      * @type {object[]}
//      * @private
//      */
//     @track allCards = [];

//     /**
//      * The current start index
//      *
//      * @type {number}
//      * @private
//      */
//     currentStartIndex = 0;

//     /**
//      * Current page number
//      *
//      * @type {number}
//      * @private
//      */
//     currentPage = 1;

//     /**
//      * Total number of pages
//      *
//      * @type {number}
//      * @private
//      */
//     totalPages = 1;

//     /**
//      * Total number of cards
//      *
//      * @type {number}
//      * @private
//      */
//     total = 0;

//     /**
//      * Returns classes for HTML Markup
//      *
//      * @returns {object} classes
//      * @private
//      */
//     get classes() {
//       return {
//         heading: this.theme === 'inverse' ? 'color-white' : '',
//         pagination: `campaign-card-list-pagination slds-grid slds-grid_align-spread ${this.theme === 'inverse' ? ' color-white' : ' '}`,
//       };
//     }

//     /**
//      * Returns the number of cards to be displayed
//      *
//      * @returns {number} number of cards
//      * @private
//      */
//     get cardsPerPage() {
//       if (this.breakpoint.isMobile) return this.CARDS_PER_PAGE_MOBILE;
//       if (this.breakpoint.isTablet) return this.CARDS_PER_PAGE_TABLET;
//       return this.CARDS_PER_PAGE_DESKTOP;
//     }

//     /**
//      * Returns showing results text for pagination
//      *
//      * @returns {string} showing results text
//      * @private
//      */
//     get showingResultsText() {
//       if (this.total === 1) return this.labels.showingOneResult;
//       return this.labels.showingResultsText
//         .replace('{pageStart}', this.pageStart)
//         .replace('{pageEnd}', this.pageEnd)
//         .replace('{totalResults}', this.total);
//     }

//     /**
//      * Returns start index
//      *
//      * @returns {number} start index
//      * @private
//      */
//     get pageStart() {
//       return this.currentStartIndex + 1;
//     }

//     /**
//      * Returns end index
//      *
//      * @returns {number} end index
//      * @private
//      */
//     get pageEnd() {
//       return Math.min(this.currentPage * this.cardsPerPage, this.total);
//     }

//     /**
//      * Returns array of page objects
//      *
//      * @returns {object[]} array of pages
//      * @private
//      */
//     get paginationNumbers() {
//       return this.paginationAlgorithm().map((result, idx) => {
//         const isLink = !(result === '...' || result === this.currentPage);
//         const className = isLink ? `link-text${this.theme === 'inverse' ? ' color-white' : ''}` : '';
//         const page = {
//           key: `page-element-${idx}`,
//           class: className,
//           page: result,
//         };
//         if (result === this.currentPage) page.class += ' text-bold';
//         return page;
//       });
//     }

//     /**
//      * Returns the previous page number
//      *
//      * @returns {number} previous page
//      * @private
//      */
//     get prevPage() {
//       return (this.currentPage - 1);
//     }

//     /**
//      * Returns the classes of the previous page for HTML Markup
//      *
//      * @returns {string} classes
//      * @private
//      */
//     get prevPageClass() {
//       const isInverse = this.theme === 'inverse';
//       const isLink = this.currentPage > 1;
//       let prevclass = '';
//       if (isLink) {
//         prevclass = `link-text${isInverse ? ' color-white inverse' : ''}`;
//       } else {
//         prevclass = (isInverse ? ' color-white' : ' color-dark-gray');
//       }
//       return prevclass;
//     }

//     /**
//      * Returns the number of the next page
//      *
//      * @returns {number} next page
//      * @private
//      */
//     get nextPage() {
//       return (this.currentPage + 1);
//     }

//     /**
//      * Returns the classes of the next page for HTML Markup
//      *
//      * @returns {string} classes
//      * @private
//      */
//     get nextPageClass() {
//       const isInverse = this.theme === 'inverse';
//       const isLink = this.currentPage < this.totalPages;
//       let nextclass = '';
//       if (isLink) {
//         nextclass = `link-text${isInverse ? ' color-white inverse' : ''}`;
//       } else {
//         nextclass = (isInverse ? ' color-white' : ' color-dark-gray');
//       }
//       return nextclass;
//     }

//     /**
//      * Connected callback - subscribes to breakpoint data
//      *
//      * @private
//      */
//     connectedCallback() {
//       this.hideComponent = !this.showLoading;
//       this.isFirstLoad = true;
//       this.dynamicHeading = this.heading;
//     }

//     /**
//      * handle screen change thru breakpoints
//      *
//      * @param {event} evt screen change event
//      */
//     handleScreenChange(evt) {
//       this.breakpoint = evt.detail.screen;
//       this.getCampaignCards();
//     }

//     /**
//      * Retrieves campaign cards
//      *
//      * @private
//      */
//     getCampaignCards() {
//       if (this.LAZY_LOAD_PAGINATION || this.allCards.length === 0) {
//         // only calls IpaCampaignService once if not lazy loading data
//         this.cards = [];
//         this.getCards().then(() => this.resetCards());
//       } else {
//         this.resetCards();
//       }
//     }

//     /**
//      * Retrieves cards from IpaCampaignService
//      *
//      * @async
//      * @private
//      */
//     async getCards() {
//       let cardLength = 0;
//       const params = {
//         campaignId: this.campaign,
//         cardType: this.listType,
//       };
//       if (this.LAZY_LOAD_PAGINATION) {
//         params.page = this.currentPage;
//         params.perPage = this.cardsPerPage;
//       }

//       const response = await IpaCampaignService.getCampaignCards(params);

//       this.dynamicHeading = this.heading || response.heading;
//       this.isFirstLoad = false;
//       if (response.cards !== undefined) {
//         cardLength = response.cards.length;
//       }
//       this.total = this.LAZY_LOAD_PAGINATION ? response.total : cardLength;
//       this.hideComponent = cardLength === 0;
//       if (response.cards !== undefined) {
//         this.allCards = [...response.cards];
//       }
//     }

//     /**
//      * Resets component properties
//      *
//      * @private
//      */
//     resetCards() {
//       this.totalPages = Math.ceil(this.total / this.cardsPerPage);
//       this.currentPage = Math.floor(this.currentStartIndex / this.cardsPerPage) + 1;
//       this.currentStartIndex = (this.currentPage - 1) * this.cardsPerPage;
//       const cards = this.LAZY_LOAD_PAGINATION ? this.allCards.slice(0, 8) : this.allCards.slice(this.currentStartIndex,
//         this.currentStartIndex + this.cardsPerPage);
//       this.cards = this.formatCards(cards);
//     }

//     /**
//      * Returns formatted array of cards
//      *
//      * @param {object[]} cardData array of cards
//      * @returns {object[]} formatted array of cards
//      * @private
//      */
//     formatCards(cardData) {
//       return cardData.map((result) => {
//         let cardType = result.partner ? 'product' : 'partner';
//         const partner = result.partner || result;
//         if (cardType === 'partner' && partner.benefitType === 'Solution Marketplace Basic Access') cardType = 'member';
//         return {
//           cardType,
//           id: result.id,
//           compareCategoryId: result.compareCategoryId, // product only
//           title: result.name,
//           description: result.description,
//           imageUrl: result.imageUrl,
//           eyebrow: partner.eyebrow,
//           eyebrowTagline: partner.eyebrowTagline,
//           distributorWebsite: result.distributorWebsite,
//           distributorTagline: result.distributorTagline,
//           website: result.website,
//           categoryL1: result.categoryL1,
//           categoryL2: result.categoryL2,
//           categoryL3: result.categoryL3,
//           partnerId: partner.id,
//           partnerName: partner.name,
//           partnerByLine: partner.byline,
//           partnerRole: partner.role,
//           partnerStatus: partner.status,
//           contactPartnerVisible: result.contactPartnerVisible,
//           // lazy load these...
//           partnerSpecialties: [], // partner.specialties
//           partnerAttributes: [], // partner.attributes
//           longDescription: '', // partner.longDescription,
//           // CTA related attributes
//           leadLangPreference: result.leadLangPreference,
//           autoPartnerId: result.autoPartnerId || result.partner.autoPartnerId,
//           autoOffId: result.autoOffId,
//           isGuest: result.isGuest,
//         };
//       });
//     }

//     /**
//      * Handles page change
//      *
//      * @param {event} evt onclick event
//      * @private
//      */
//     handlePageChange(evt) {
//       const page = parseInt(evt.currentTarget.dataset.page, 10);
//       this.helperPageChange(page);
//     }

//     /**
//      * Handles page change using keys
//      *
//      * @param {event} evt onkeydown event
//      * @private
//      */
//     handlePageChangeAccessibility(evt) {
//       if (evt.code === 'Enter') {
//         const page = parseInt(evt.currentTarget.dataset.page, 10);
//         this.helperPageChange(page);
//       }
//     }

//     /**
//      * Helper function for page change functionality
//      *
//      * @param {number} page page number
//      * @private
//      */
//     helperPageChange(page) {
//       if (isNaN(page) || page === this.currentPage || page < 1 || page > this.totalPages) return;
//       this.template.querySelector('.scroll-to-me').scrollIntoView({ behavior: 'smooth' });
//       this.currentStartIndex = (page - 1) * this.cardsPerPage;
//       this.currentPage = page;
//       this.getCampaignCards();
//     }

//     // https://gist.github.com/kottenator/9d936eb3e4e3c3e02598
//     /**
//      * Algorithm for computing pagination
//      *
//      * @param {number} currentPage current page number
//      * @param {number} pageCount total pages
//      * @returns {string[]} page numbers
//      * @private
//      */
//     paginationAlgorithm(currentPage = this.currentPage, pageCount = this.totalPages) {
//       const delta = 2; const
//         range = [];
//       for (let i = Math.max(2, currentPage - delta); i <= Math.min(pageCount - 1, currentPage + delta); i += 1) {
//         range.push(i);
//       }
//       if (currentPage - delta > 2) range.unshift('...');
//       if (currentPage + delta < pageCount - 1) range.push('...');
//       range.unshift(1);
//       range.push(pageCount);
//       return range;
//     }
// }
 export default IpaCampaignCardList;