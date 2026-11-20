import { LightningElement, api } from 'lwc';

/**
 * @typedef Banner
 * @property {string} title banner title
 * @property {string} linkLabel label for link in banner
 * @property {string} linkUrl external url value for link in banner
 * @property {string} image image url
 * @property {string} imageAlt alternate text for image
 */

/** Banner Component
 * (used for event banners in ipaBannerCarousel on L3 pages)
 *
 * @augments LightningElement
 * @property {Banner} banner banner object
 */
class IpaBanner extends LightningElement {
    @api banner;

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
export default IpaBanner;