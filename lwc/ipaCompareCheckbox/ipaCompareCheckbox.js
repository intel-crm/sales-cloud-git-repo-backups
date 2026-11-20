import { LightningElement, api } from 'lwc';

import addToCompare from '@salesforce/label/c.PMP_Add_To_Compare';
import addToCompareAccessible from '@salesforce/label/c.PMP_Add_To_Compare_Accessible';
import ipaCompareTrayService from 'c/ipaCompareTrayService';

/**
 * @typedef Product compare product object
 * @property {string} id salesforce id
 * @property {string} title product name
 * @property {string} imageUrl product image appears on cards
 * @property {string} compareCategoryId category id used to compare similar offerings (Sub-category Id)
 */

/** Documentation for the "Add to Compare" Checkbox
 * <br><br>This checkbox is used on product cards to add/remove products from the {@link ipaCompareTray Compare Tray}
 *
 * @augments LightningElement
 * @property {Product} product the product object associated with the card
 * @property {string} [variant] options: 'dark' - apply inverse variant for dark backgrounds
 * @property {string} [textVariant] options: 'inverse'
 */
class IpaCompareCheckbox extends LightningElement {
  @api product = { id: null };

  @api variant = '';

  @api textVariant = '';

  /** "Compare now" label
   *
   * @type {string}
   * @private
   */
  labelCompareNow = addToCompareAccessible;

  /** tracks show "Compare now" link
   * (if 2 or more products are in the Compare Tray)
   *
   * @type {boolean}
   * @private
   */
  showCompareNow;

  /** get label value (blank if showing "Compare now")
   *
   * @returns {string} label string for lightning:input
   * @private
   */
  get label() {
    return this.showCompareNow ? '' : addToCompare;
  }

  /** get classes for "Compare now" text
   *
   * @returns {string} classes
   * @private
   */
  get compareNowClasses() {
    return this.textVariant === 'inverse' ? 'inverse color-white' : '';
  }

  /**
   * connected callback
   * - subscribes to ipaCompareTrayService for data
   *
   * @private
   */
  connectedCallback() {
    this.subscription = ipaCompareTrayService.subscribe(({ items }) => {
      const checkbox = this.template.querySelector('lightning-input');
      const checked = !!items[this.product.id];
      if (checkbox) {
        checkbox.checked = checked;
      } else {
        this.initChecked = checked;
      }
    });
  }

  /**
   * disconnected callback
   * removes subscription
   *
   * @private
   */
  disconnectedCallback() {
    if (this.subscription) {
      this.subscription();
    }
  }

  /** handles the checkbox
   *
   */
  handleCheckCompare() {
    ipaCompareTrayService.toggleItem(this.product);
  }
}
export default IpaCompareCheckbox;