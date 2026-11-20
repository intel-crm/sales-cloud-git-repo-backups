import { LightningElement, api } from 'lwc';

/**
 * Banner component used to display notifications
 *
 * @augments LightningElement
 * @property {string} [theme] options: 'background', 'none' determines whether banner icon
 * should have any background
 * @property {string} [iconType] options: 'submitted', 'review', 'update', 'published',
 * 'lock'
 * @property {string} [bannerMessage] message to display on banner
 * @property {string} [bannerLink] Link to redirect user on banner click (if needed)
 */
class IpaStorefrontNotificationsBanner extends LightningElement {
  @api theme;

  @api iconType;

  @api bannerMessage;

  @api bannerLink;

  /** Get banner icon name/alternative text based on iconType
   *
   * @returns {string} banner icon name/alternative text to display
   * @private
   */
  get bannerIcon() {
    switch (this.iconType) {
      case 'submitted':
        return 'utility:save';
      case 'review':
        return 'utility:lock';
      case 'update':
        return 'utility:refresh';
      case 'published':
        return 'utility:check';
      case 'lock':
        return 'utility:lock';
      default:
        return 'utility:magicwand';
    }
  }

  /** Get banner icon class name based on iconType
   *
   * @returns {string} banner icon class name to display
   * @private
   */
  get bannerIconClass() {
    switch (this.theme) {
      case 'background':
        return 'banner-icon banner-icon-background';
      case 'none':
        return 'banner-icon banner-icon-none';
      default:
        return 'banner-icon';
    }
  }

  /** Get banner theme
   *
   * @returns {string} banner theme
   * @private
   */
  get bannerTheme() {
    switch (this.theme) {
      case 'background':
        return 'background';
      case 'none':
        return 'none';
      default:
        return 'none';
    }
  }
}
export default IpaStorefrontNotificationsBanner;