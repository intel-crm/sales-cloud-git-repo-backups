import { LightningElement, api, track } from 'lwc';
import IpaCampaignService from 'c/ipaCampaignService';

/** Documentation for the Promo Carousel Component
 * <br>This component is exposed in the community builder.<br>
 * <br>To be used with the {@link ipaPromoCard ipaPromoCard} component.<br>
 *
 * @augments LightningElement
 * @property {string} heading heading text
 * @property {string} promoListType L0 Featured Events or L1 Event Pillars
 * @property {string} recordId {!v.recordId}
 * @property {number} [perPageDesktop=1] specifies default "per page" / "per slide" value on desktop (Tablet/Mobile=1)
 *
 * @author Fawn Stevens, last modified 18 March 2021
 */
class IpaPromoCarousel extends LightningElement {
  @api heading;

  @api promoListType;

  @api recordId;

  @api perPageDesktop = 1;

  /**
   * @typedef Promo
   * @property {string} image image src
   * @property {string} title Title for promotion
   * @property {string} description promotion description
   * @property {string} linkLabel label for the link
   * @property {string} [linkExternalUrl] external link url
   * @property {string} [linkObjectPage] object page for link (ie. 'PMP_Category__c')
   * @property {string} [linkRecordId] salesforce Id for link (<i>must include linkObjectPage to work properly</i>)
   * @property {string} [linkCommunityPage] community page API name
   */

  /** list of promos
   *
   * @type {Promo[]}
   * @private
   */
  @track promos = [];

  /** keeps track of loaded images to adjust height after image load
   *
   * @type {number}
   * @private
   */
  loadedImages = 0;

  /** promo count
   *
   * @returns {number} number of promos
   * @private
   */
  get count() {
    return this.promos.length;
  }

  /** if more than 1 per page then show vertical, otherwise horizontal
   *
   * @returns {string} view type (horizontal / vertical)
   * @private
   */
  get displayType() {
    return this.cardsPerPageDesktop > 1 ? 'vertical' : 'horizontal';
  }

  /** use the minimum of either the total cards, or the perpagedesktop value
   *
   * @returns {number} cards per page
   * @private
   */
  get cardsPerPageDesktop() {
    return Math.min(this.count, this.perPageDesktop);
  }

  /** hardcoded to 1
   *
   * @returns {number} tablet value
   * @private
   */
  get cardsPerPageTablet() {
    return 1;
  }

  /** hardcoded to 1
   *
   * @returns {number} mobile value
   * @private
   */
  get cardsPerPageMobile() {
    return 1;
  }

  /** hide "Learn More" buttons / links
   *
   * @returns {boolean} boolean value
   * @private
   */
  get hideLearnMoreLinks() {
    return this.promoListType === 'Event Pillars';
  }

  /** connected callback
   * gets "Featured" promos or "Event Pillars" depending on builder context
   *
   * @private
   */
  connectedCallback() {
    if (this.promoListType === 'Featured Events') {
      IpaCampaignService.getFeaturedPromos().then((promos = []) => {
        this.promos = [...promos];
      });
    }

    if (this.promoListType === 'Event Pillars') {
      IpaCampaignService.getCampaignPromos({ campaignId: this.recordId }).then((promos = []) => {
        this.promos = [...promos];
      });
    }
  }

  /** handle image load to reset height
   *
   * @private
   */
  handleImageLoad() {
    this.loadedImages += 1;
    if (this.loadedImages === this.promos.length) {
      this.template.querySelector('c-core-intc-carousel').resetHeight();
    }
  }
}
export default IpaPromoCarousel;