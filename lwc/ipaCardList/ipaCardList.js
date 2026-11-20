import { LightningElement, api, track } from 'lwc';

/** Documentation for the product/partner Card List Component
 * <br>
 * <h3>Carousel</h3>
 * Add <b>carousel</b> attribute if card list is being used in a carousel.
 * <h3>Cards Per Row</h3>
 * The number of cards per row can be controller per breakpoint. See example.
 *
 * @example
 * <!-- HTML component example -->
 * <c-ipa-card-list cards={cards} carousel></c-ipa-card-list>;
 * <c-ipa-card-list cards={cards} cards-per-row="3" cards-per-row-mobile="1"></c-ipa-card-list>
 *
 * @property {boolean} hideAddToCompare If 'true' cards will not display the Add to Compare checkbox
 * @property {boolean} withoutImages Use the card variation that does not display images (products, logos, etc.)
 * @property {boolean} carousel Set this to 'true' if cards are in a carousel to eliminate wrapping.
 * @property {number} [cardsPerRow=3] Use this to set a default cards per row width (ie. 3 = 33.3333%).
 * @property {number} cardsPerRowMobile Use this to override the cardsPerRow setting on Mobile viewports (uses App State ui breakpoints)
 * @property {number} cardsPerRowTablet Use this to override the cardsPerRow setting on Tablet viewports (uses App State ui breakpoints)
 * @property {number} cardsPerRowDesktop Use this to override the cardsPerRow setting on Desktop viewports (uses App State ui breakpoints)
 * @augments LightningExperience
 */
class IpaCardList extends LightningElement {
    @api hideAddToCompare;

    @api withoutImages; // without image variation

    @api carousel;

    @api cardsPerRow = 3;

    @api cardsPerRowMobile;

    @api cardsPerRowTablet;

    @api cardsPerRowDesktop;

    /**
     * Array of cards
     *
     * @type {object[]}
     * @private
     */
    _cards = [];

    /**
     * Set cards array
     *
     * @param {object[]} cards array of cards
     * @public
     */
    @api set cards(cards) {
      this._cards = cards;
    }

    /**
     * Returns array of card objects
     *
     * @returns {object[]} array of cards
     * @private
     */
    get cards() {
      if (this._cards.length > 0) {
        return this._cards.map((card) => ({
          ...card,
          // NOTE: key needs to change to refresh cards for quick view slots
          key: `${card.id}-${this.isHubSpoke ? 'hubspoke' : 'modal'}`,
        }));
      }
      return this.generateLoadingCards();
    }

    /**
     * Returns the number of cards to be displayed according to viewport
     *
     * @returns {number} number of cards displayed
     * @private
     */
    get responsiveCardsPerRow() {
      let { cardsPerRow } = this;
      if (this.breakpoint.isMobile) cardsPerRow = this.cardsPerRowMobile || cardsPerRow;
      if (this.breakpoint.isTablet) cardsPerRow = this.cardsPerRowTablet || cardsPerRow;
      if (this.breakpoint.isDesktop) cardsPerRow = this.cardsPerRowDesktop || cardsPerRow;
      return cardsPerRow;
    }

    /**
     * Current breakpoint value
     *
     * @type {object}
     * @private
     */
    @track breakpoint = {};

    /**
     * Returns classes for HTML markup
     *
     * @returns {string} classes
     * @private
     */
    get containerClasses() {
      return [
        'card-list-container',
        `bp-${this.breakpoint.name}`,
        `cards-per-row-${this.responsiveCardsPerRow}`,
      ].join(' ');
    }

    /**
     * If current viewport requires hub-spoke
     *
     * @returns {boolean} if hub-spoke
     * @private
     */
    get isHubSpoke() {
      return ['xs', 'sm'].includes(this.breakpoint.abbr);
    }

    /**
     * handle screen change thru breakpoints
     *
     * @param {event} evt screen change event
     */
    handleScreenChange(evt) {
      this.breakpoint = evt.detail.screen;
    }

    /**
     * Creates array of card objects
     *
     * @returns {object[]} array of cards
     * @private
     */
    generateLoadingCards() {
      const cards = [];
      while (cards.length < this.responsiveCardsPerRow) {
        cards.push({ key: cards.length, isLoading: true });
      }
      return cards;
    }
}
export default IpaCardList;