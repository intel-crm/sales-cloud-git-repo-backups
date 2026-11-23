import { LightningElement, api } from 'lwc';

/** Documentation for the IPA Heading
 * <br>This component is exposed in the Community Builder.
 *
 * @augments LightningElement
 * @property {string} heading heading
 * @property {string} subheading subheading
 * @property {string} theme theme
 * @author Nick Demarest, last modified 20 July 2020
 */
class IpaHeading extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api heading;

  @api subheading;

  @api theme;



  // ******* Variables *******
  /**
   * Get style classes for header
   *
   * @returns {string} header classes
   * @private
   */
  get headerClasses() {
    return `h3 ${this.classes}`;
  }

  /**
   * TODO - description
   *
   * @returns {string[]} TODO - description
   * @private
   */
  get classes() {
    return [
      'slds-p-bottom_xx-small ',
      (this.theme === 'inverse' ? ' color-white inverse' : ' '),
    ].join(' ');
  }
}
export default IpaHeading;