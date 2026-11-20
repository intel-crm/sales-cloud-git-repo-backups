import { LightningElement, track } from 'lwc';
import IpaCampaignService from 'c/ipaCampaignService';

/**
 * @typedef Banner
 * @property {string} title banner title
 * @property {string} linkLabel label for link in banner
 * @property {string} linkUrl external url value for link in banner
 * @property {string} image image url
 * @property {string} imageAlt alternate text for image
 */

/** Banner Carousel Component
 * Uses the <c-core-intc-carousel> component for UI
 * Uses the IpaCampaignService component for data
 *
 * @example
 * <!-- HTML component example -->
 *  <c-ipa-banner-carousel></c-ipa-banner-carousel>
 *
 * @augments LightningElement
 */
class IpaBannerCarousel extends LightningElement {
  /** Data for banners
   *
   * @type {Banner[]} banner data (list)
   * @private
   */
  @track banners = [];

  /**
   * Keeps track of loaded images to adjust height after image load
   *
   * @type {number}
   * @private
   */
  loadedImages = 0;

  /** banner count
   *
   * @returns {number} count of banners
   * @private
   */
  get count() {
    return this.banners.length;
  }

  /** connected callback
   * - fetch banner data from Service Layer
   *
   * @private
   */
  connectedCallback() {
    this._connected = true;
    IpaCampaignService.getCampaignBanners().then((banners = []) => {
      if (this._connected) {
        this.banners = [...banners];
      }
    });
  }

  /** disconnected callback
   * ensures component is connected once data is returned
   *
   * @private
   */
  disconnectedCallback() {
    this._connected = false;
  }

  /** handle image load to reset height
   *
   * @private
   */
  handleImageLoad() {
    this.loadedImages += 1;
    if (this.loadedImages === this.banners.length) {
      this.template.querySelector('c-core-intc-carousel').resetHeight();
    }
  }
}
export default IpaBannerCarousel;