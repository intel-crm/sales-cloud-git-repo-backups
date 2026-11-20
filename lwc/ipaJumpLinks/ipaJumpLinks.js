import { LightningElement, api } from 'lwc';

/**
 * Documentation for IpaJumpLinks
 *
 * @property {boolean} [isMobile=false] indicates if current viewport is mobile
 * @property {string[]} [links] labels for the jump links
 * @property {string} navAriaLabel aria label for nav tag
 * @property {boolean} [previewMode=false] indicator for preview mode
 * @augments {LightningElement}
 */
class IpaJumpLinks extends LightningElement {
  @api links = [];

  @api navAriaLabel;

  @api isMobile = false;

  @api previewMode = false;

  /**
   * Id of active jump link
   *
   * @type {string}
   * @private
   */
  active = 0;

  /**
   * Handles clicking on a jump link
   *
   * @param {event} evt click event
   * @private
   */
  handleClick(evt) {
    if (this.previewMode !== true && this.previewMode !== 'true') {
      this.dispatchEvent(new CustomEvent('selectsection', { detail: evt.currentTarget.dataset.id }));
      this.handleActive(evt.currentTarget.dataset.id);
    }
  }

  /**
   * Handles scrolling to a jump link
   *
   * @param {string} datasetId id of jump link
   * @public
   */
  @api handleScroll(datasetId) {
    if (this.active !== datasetId) {
      this.handleActive(datasetId);
    }
  }

  /**
   * Helps scroll to an inactive jump link
   *
   * @param {string} datasetId id of jump link
   * @private
   */
  handleActive(datasetId) {
    const alllinks = this.template.querySelectorAll('.section');
    alllinks.forEach((link) => {
      link.classList.remove('active-section');
      link.classList.add('border-non-active');
      link.blur();
    });
    this.template.querySelector(`button[data-id="${datasetId}"]`).classList.add('active-section');
    this.template.querySelector(`button[data-id="${datasetId}"]`).classList.remove('border-non-active');
    this.active = datasetId;
  }

  /**
   * Returns if viewport is mobile
   *
   * @returns {boolean} is mobile
   * @private
   */
  get isMobileScreen() {
    return this.isMobile;
  }

  /**
   * Returns list of jump links with default css class list
   *
   * @returns {Array} list of jump links
   * @private
   */
  get jumplinks() {
    return this.links.map((obj, index) => {
      const link = {};
      link.label = obj;
      link.classList = (index === 0) ? this.activeClassList : this.nonActiveClassList;
      return link;
    });
  }

  /**
   * Returns class list for active link
   *
   * @returns {string} classes
   * @private
   */
  get activeClassList() {
    return 'section link-text link-no-underline text-bold active-section padding-link link-text-alignment';
  }

  /**
   * Returns class list for non active link
   *
   * @returns {string} classes
   * @private
   */
  get nonActiveClassList() {
    return 'section link-text link-no-underline text-bold border-non-active padding-link link-text-alignment';
  }
}
export default IpaJumpLinks;