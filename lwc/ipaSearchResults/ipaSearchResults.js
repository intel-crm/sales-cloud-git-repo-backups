import { LightningElement, api } from 'lwc';

// Custom labels
import next from '@salesforce/label/c.PMP_Next';
import previous from '@salesforce/label/c.PMP_Previous';
import recommendedResults from '@salesforce/label/c.PMP_Search_RecommendedResults';
import showingResults from '@salesforce/label/c.PMP_Search_ShowingResults'; // 'Showing {pageStart} to {pageEnd} of {totalResults} results'
import noresults from '@salesforce/label/c.PMP_Search_NoResults';
import noresultsForKeyword from '@salesforce/label/c.PMP_Search_NoResultsForKeyword';

/**
 * Search Results (for ipaSearch - L2 Category search pages)
 *
 * @property {string} defaultHeading This is the default heading for the search results <br>NOTE: the heading can be dynamic, ie. Distributor grouped results
 * @property {object[]} groupResults if applicable, this is the searchResultsGroupings that groups / orders the results
 * @property {boolean} showRecommendedResults this is a setting inherited from {@link ipaSearch} design attribute
 * @augments LightningElement
 */
class IpaSearchResults extends LightningElement {
    @api defaultHeading = '';

    @api showRecommendedResults;

    @api groupResults = [];

    /**
     * sets search params
     * - displays loading cards
     */
    @api set searchParams(params) {
      this.loading = true;
      this.showNoResults = false;
      this.cardGroups = [{
        heading: ' ',
        subheading: '',
        key: 'group-loading',
        cards: [
          { key: 'loading-1', isLoading: true },
          { key: 'loading-2', isLoading: true },
          { key: 'loading-3', isLoading: true },
        ],
      }];
      this._searchParams = params;
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
     * - builds cards from response data
     */
    @api set searchResponse(response) {
      this._searchResponse = response;
      if (response.searched) {
        this.loading = false;
        this.showNoResults = response.searched && response.totalResults === 0;
        this.buildCards();
      }
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
     * Custom labels
     *
     * @type {object}
     * @private
     */
    labels = {
      showingResultsText: showingResults,
      next,
      previous,
      recommendedResultsHeading: recommendedResults,
    };

    /**
     * Returns text to be displayed if no results are returned
     *
     * @returns {string} no results text
     * @private
     */
    get noResultsLabel() {
      const { keyword } = this.searchParams;
      return keyword ? noresultsForKeyword.replace('{keyword}', keyword) : noresults;
    }

    /**
     * Returns formatted pagination 'Showing Results' label
     *
     * @returns {string} showing results text
     * @private
     */
    get showingResultsText() {
      return this.labels.showingResultsText
        .replace('{pageStart}', this.pageStart)
        .replace('{pageEnd}', this.pageEnd)
        .replace('{totalResults}', this.totalResults);
    }

    /**
     * List of card group objects
     *
     * @type {object[]}
     * @private
     */
    cardGroups = [];

    /**
     * build cards
     *
     * @private
     */
    buildCards() {
      const allCards = this.formatCards(this.searchResponse.results);
      if (this.groupResults && this.groupResults.length) {
        this.cardGroups = (this.groupResults || []).map((group, idx) => ({
          heading: group.heading,
          subheading: group.subheading,
          key: `card-group-${idx}`,
          cards: allCards.filter((card) => card.searchGrouping === group.name)
            // bolds grouping in card
            .map((card) => ({
              ...card,
              distributorTagline: (card.distributorTagline || '')
                .replace((group.heading || ''), (match) => `<b>${match}</b>`),
            })),
        })).map((g) => ({ ...g, cardCount: g.cards.length }));
      } else {
        const cardGroups = [];
        if (this.showRecommendedResults) {
          cardGroups.push({
            heading: this.labels.recommendedResultsHeading,
            key: 'recommended',
            cards: this.recommendedCards,
          });
        }
        cardGroups.push({
          heading: this.defaultHeading,
          subheading: '',
          key: 'group-default',
          cards: allCards,
        });
        this.cardGroups = cardGroups.map((g) => ({ ...g, cardCount: g.cards.length }));
      }
    }

    /**
     * Indicates if pagination should be hidden. Don't show pagination if searching, for Grouped results, or if there are NO results
     *
     * @returns {boolean} hide pagination
     * @private
     */
    get hidePagination() {
      const hasNotSearchedYet = !this.searchParams.category;
      const hasGroupResults = this.groupResults && this.groupResults.length;
      const hasNoResults = this.searchResponse.totalResults === 0;
      return hasNotSearchedYet || this.loading || hasGroupResults || hasNoResults;
    }

    /**
     * Returns current page number
     *
     * @returns {number} current page
     * @private
     */
    get currentPage() {
      if(this.searchParams.page>this.searchResponse.totalPages){
        return 1;
      }
      return this.searchParams.page;
    }

    /**
     * Returns number of first card displayed on current page (i.e. 'pageStart' to 'pageEnd' of 'totalResults')
     *
     * @returns {number} first card number
     * @private
     */
    get pageStart() {
      return ((this.currentPage - 1) * this.searchResponse.resultsPerPage) + 1;
    }

    /**
     * Returns number of last card displayed on current page (i.e. 'pageStart' to 'pageEnd' of 'totalResults')
     *
     * @returns {number} last card number
     * @private
     */
    get pageEnd() {
      return Math.min(this.currentPage * this.searchResponse.resultsPerPage, this.totalResults);
    }

    /**
     * Returns list of page objects for pagination
     *
     * @returns {object[]} pages
     * @private
     */
    get paginationNumbers() {
      return this.paginationAlgorithm().map((result, idx) => {
        const page = {
          key: `page-element-${idx}`,
          class: result === '...' || result === this.currentPage ? '' : 'link-text',
          page: result,
          tabIdx: result === this.currentPage ? '-1' : '0',
        };
        if (result === this.currentPage) page.class = 'text-bold';
        return page;
      });
    }

    /**
     * Returns tabindex for pagination 'Previous' label
     *
     * @returns {string} tabindex
     * @private
     */
    get prevTabIdx() {
      return this.currentPage > 1 ? '0' : '-1';
    }

    /**
     * Returns tabindex for pagination 'Next' label
     *
     * @returns {string} tabindex
     * @private
     */
    get nextTabIdx() {
      return this.currentPage < this.totalPages ? '0' : '-1';
    }

    /**
     * Returns total number of cards to be displayed
     *
     * @returns {number} total card results
     * @private
     */
    get totalResults() {
      return this.searchResponse.totalResults;
    }

    /**
     * Total number of pages to be displayed
     *
     * @returns {number} pages
     * @private
     */
    get totalPages() {
      return this.searchResponse.totalPages;
    }

    /**
     * Returns previous page number
     *
     * @returns {number} previous page
     * @private
     */
    get prevPage() {
      return (this.currentPage - 1);
    }

    /**
     * Returns css class for pagination 'Previous' label
     *
     * @returns {string} css class
     * @private
     */
    get prevPageClass() {
      return this.currentPage > 1 ? 'link-text' : 'color-gray';
    }

    /**
     * Returns next page number
     *
     * @returns {number} next page
     * @private
     */
    get nextPage() {
      return (this.currentPage + 1);
    }

    /**
     * Returns css class for pagination 'Next' label
     *
     * @returns {string} css class
     * @private
     */
    get nextPageClass() {
      return this.currentPage < this.totalPages ? 'link-text' : 'color-gray';
    }

    /**
     * Returns formatted list of reccomended cards or returns
     * placeholder cards if still searching
     *
     * @returns {object[]} reccomended cards
     * @private
     */
    get recommendedCards() {
      const searchingForRecommended = true;
      const recommendedCards = [];
      return searchingForRecommended ? [
        { key: 'rec-1', isLoading: true },
        { key: 'rec-2', isLoading: true },
        { key: 'rec-3', isLoading: true },
      ] : this.formatCards(recommendedCards);
    }

    /**
     * Returns formatted list of card objects
     *
     * @param {object[]} cardData card list
     * @returns {object[]} formatted card list
     * @private
     */
    formatCards(cardData) {
      return cardData.map((result) => {
        let cardType = result.partner ? 'product' : 'partner';
        const partner = result.partner || result;
        if (cardType === 'partner' && partner.benefitType === 'Solution Marketplace Basic Access') {
          cardType = 'member';
        }
        return {
          cardType,
          searchGrouping: result.searchGrouping,
          id: result.id,
          compareCategoryId: result.compareCategoryId, // product only
          title: result.name,
          description: result.description,
          imageUrl: result.imageUrl,
          eyebrow: partner.eyebrow,
          eyebrowTagline: partner.eyebrowTagline,
          distributorWebsite: result.distributorWebsite,
          distributorTagline: result.distributorTagline,
          website: result.website,
          categoryL1: { ...result.categoryL1, highlight: this.matchesCategory(result.categoryL1 || {}) },
          categoryL2: ([].concat(result.categoryL2 || [])).map((cat) => ({ ...cat, highlight: this.matchesCategory(cat) })),
          categoryL3: ([].concat(result.categoryL3 || [])).map((cat) => ({ ...cat, highlight: this.matchesCategory(cat) })),
          partnerId: partner.id,
          partnerName: partner.name,
          partnerByLine: partner.byline,
          partnerRole: partner.role,
          partnerStatus: partner.status,
          contactPartnerVisible: result.contactPartnerVisible,
          // lazy load these...
          partnerSpecialties: [], // partner.specialties
          partnerAttributes: [], // partner.attributes
          // CTA related attributes
          leadLangPreference: result.leadLangPreference,
          autoPartnerId: result.autoPartnerId || result.partner.autoPartnerId,
          autoOffId: result.autoOffId,
          isGuest: result.isGuest,
        };
      });
    }

    /**
     * Matches category with current page (searchParams) category
     * (Highlights card category if same as current page)
     *
     * @param {object} cat category to match
     * @returns {boolean} true if match
     */
    matchesCategory(cat) {
      const category = cat || { Id: null };
      return category.Id === this.searchParams.category;
    }

    /**
     * handle page change
     *
     * @param {event} evt page change event
     */
    handlePageChange(evt) {
      const page = parseInt(evt.currentTarget.dataset.page, 10);
      this.helperPageChange(page);
    }

    /**
     * Handles changing pages using keys
     *
     * @param {event} evt onkeydown event
     * @private
     */
    handlePageChangeAccessibility(evt) {
      if (evt.code === 'Enter') {
        const page = parseInt(evt.currentTarget.dataset.page, 10);
        this.helperPageChange(page);
      }
    }

    /**
     * Helps change pages and performs search
     *
     * @param {number} page page to navigate to
     * @private
     */
    helperPageChange(page) {
      if (isNaN(page) || page === this.currentPage || page < 1 || page > this.totalPages) return;
      this.dispatchEvent(new CustomEvent('search', { detail: { searchParams: { page } } }));
    }

    // https://gist.github.com/kottenator/9d936eb3e4e3c3e02598
    /**
     * Computes and returns pagination
     *
     * @param {number} currentPage current page number
     * @param {number} pageCount total number of pages
     * @returns {object[]} pagination
     * @private
     */
    paginationAlgorithm(currentPage = this.currentPage, pageCount = this.totalPages) {
      const delta = 2; const
        range = [];
      for (let i = Math.max(2, currentPage - delta); i <= Math.min(pageCount - 1, currentPage + delta); i += 1) {
        range.push(i);
      }
      if (currentPage - delta > 2) range.unshift('...');
      if (currentPage + delta < pageCount - 1) range.push('...');
      range.unshift(1);
      range.push(pageCount);
      return range;
    }
}
export default IpaSearchResults;