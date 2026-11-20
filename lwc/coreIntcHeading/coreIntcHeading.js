import { LightningElement, api } from 'lwc';

/**
 * A reusable component for displaying header text. It can display a header and a subheader.
 *
 * This component can be added to a page directly in the Community Builder, or you can include
 * it in another component.
 *
 * <div id="core-examples" sf-attr="c-coreintcheading_coreintcheading">
 *  <c-core-intc-heading heading="This is a heading"></c-core-intc-heading>
 *  <c-core-intc-heading heading="This is a heading" subheading="This is a subheading"></c-core-intc-heading>
 * </div>
 *
 * @example
 * <!-- HTML component example 1 -->
 * <c-core-intc-heading heading="This is a heading"></c-core-intc-heading>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <c-core-intc-heading heading="This is a heading" subheading="This is a subheading"></c-core-intc-heading>
 *
 * @augments LightningElement
 * @property {string} heading The text to display as a header.
 * @property {string} [subheading] Optional test to display as a subheader underneath the header.
 * @property {string} [theme] Set this to "inverse" to use the white text color scheme.
 */
class CoreIntcHeading extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api heading;

  @api subheading;

  @api theme;


  // ******* Variables *******
  /**
   * Generates a string of CSS classes to add to the header.
   * Needed for including the CSS classes for h3.
   *
   * @returns {string} A string of CSS classes to add to the header.
   * @private
   */
  get headingClasses() {
    return `h3 ${this.classes}`;
  }

  /**
   * Generates a string of CSS classes to add to the header and subheader elements.
   * Needed for including the CSS classes for an inverse theme.
   *
   * @returns {string} A string of CSS classes to add to the header and subheader.
   * @private
   */
  get classes() {
    return [
      'slds-p-bottom_xx-small ',
      (this.theme === 'inverse' ? ' color-white inverse' : ' '),
    ].join(' ');
  }
}
export default CoreIntcHeading;