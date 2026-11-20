import { LightningElement, api } from 'lwc';
import learnMore from '@salesforce/label/c.PMP_MarketplaceCTABanner_LearnMore';

/** Promo Card Component
 *
 * @example
 * <!-- HTML component example -->
 * <c-ipa-promo-card promo={promo} display-type={displayType}></c-ipa-promo-card>
 *
 * @augments LightningElement
 * @property {string} displayType vertical or horizontal
 * @property {object} promo <h4>Promotional Card Data Object</h4>
 * @property {string} promo.image image src
 * @property {string} promo.title Title for promotion
 * @property {string} promo.description promotion description
 * @property {string} promo.linkLabel label for the link
 * @property {string} [promo.linkExternalUrl] external link url
 * @property {string} [promo.linkObjectPage] object page for link (ie. 'PMP_Category__c')
 * @property {string} [promo.linkRecordId] salesforce Id for link (<i>must include linkObjectPage to work properly</i>)
 * @property {string} [promo.linkCommunityPage] community page API name
 * @property {boolean} [hideLearnMoreLink] hide learn more link
 * @property {string} [learnMoreLinkLabel] Learn More button / link
 * @fires imageloaded to reset carousel height based on image height
 */
class IpaPromoCard extends LightningElement {
  @api displayType;

  @api promo;

  @api hideLearnMoreLink;

  @api learnMoreLinkLabel = learnMore;

  /** class list for "Learn More" link
   * this is a button (primary)
   * if it is external an arrow -> is added
   *
   * @returns {string} classes for link
   * @private
   */
  get learnMoreLinkClasses() {
    return [
      'slds-m-top_large',
      'button button-primary',
      this.promo.linkExternalUrl ? '' : 'button-arrow',
    ].join(' ');
  }

  /**
   * handle the image loaded
   *
   * dispatches an event
   * (helps to reset the carousel height)
   *
   * @private
   */
  handleImageLoaded() {
    this.dispatchEvent(new CustomEvent('imageloaded'));
  }
}
export default IpaPromoCard;