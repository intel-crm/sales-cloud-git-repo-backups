import { LightningElement, api } from 'lwc';


/** A reusable component for displaying a Call to Action bar.
 *
 * This component is exposed in the Community Builder.
 *
 * The CTA button can link to an internal community page via api name ("CTA Community Page" <code>ctaCommPage</code>) or an external
 * url page ("CTA External URL" <code>ctaExternalUrl</code>).
 *
 * <div id="core-examples" sf-attr="c-coreintcctabar_coreintcctabar c-coreintclink_coreintclink">
 *  <c-core-intc-cta-bar cta-external-url="http://www.intel.com" cta-label="Learn More" cta-label-aria="Learn more about Intel"
 *   subtitle="See how Intel can help you" title="Visit Intel"></c-core-intc-cta-bar>
 *  <c-core-intc-cta-bar cta-external-url="http://www.intel.com" cta-label="Learn More 2" cta-label-aria="Learn more about Intel 2"
 *   subtitle="See how Intel can help you 2" title="Visit Intel 2" variation="dark"></c-core-intc-cta-bar>
 *  <c-core-intc-cta-bar cta-comm-page="Home" cta-label="Learn More 3" cta-label-aria="Learn more about Intel 3"
 *   subtitle="See how Intel can help you 3" title="Visit Intel 3" variation="light"></c-core-intc-cta-bar>
 * </div>
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- Using ctaExternalUrl and variation defaults to primary-->
 * <c-core-intc-cta-bar cta-external-url="http://www.intel.com" cta-label="Learn More" cta-label-aria="Learn more about Intel"
 *  subtitle="See how Intel can help you" title="Visit Intel"></c-core-intc-cta-bar>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- Using ctaExternalUrl and variation set to dark-->
 * <c-core-intc-cta-bar cta-external-url="http://www.intel.com" cta-label="Learn More 2" cta-label-aria="Learn more about Intel 2"
 *   subtitle="See how Intel can help you 2" title="Visit Intel 2" variation="dark"></c-core-intc-cta-bar>
 *
 * @example
 * <!-- HTML component example 3 -->
 * <!-- Using ctaCommPage and variation set to light-->
 * <c-core-intc-cta-bar cta-comm-page="Home" cta-label="Learn More 3" cta-label-aria="Learn more about Intel 3"
 *   subtitle="See how Intel can help you 3" title="Visit Intel 3" variation="light"></c-core-intc-cta-bar>
 *
 * @augments LightningElement
 * @property {string} [ctaCommPage] Api name for a community page.
 * @property {string} [ctaExternalUrl] Url for an external link (this takes priority over ctaCommPage if both are set).
 * @property {string} ctaLabel Text label for the CTA button.
 * @property {string} ctaLabelAria Aria label for the CTA button.
 * @property {string} subtitle Subheading for the CTA (accepts Rich Text).
 * @property {string} title Heading for the CTA.
 * @property {string} [variation='primary'] Display variation (can be 'primary', 'dark', or 'light').
 */
class CoreIntcCtaBar extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api ctaCommPage = '';

  @api ctaExternalUrl = '';

  @api ctaLabel;

  @api ctaLabelAria;

  @api subtitle;

  @api title;

  @api variation = 'primary';




  // ******* Functions ********
  /**
   * Gets the CSS classes for the button.
   *
   * @returns {string[]} The CSS classes for the button.
   * @private
   */
  get buttonClasses() {
    return ['button', 'button-secondary', 'button-arrow',
      this.variation === 'light' ? '' : 'button-inverse',
    ].join(' ');
  }



  /**
   * Creates an  object with all the text labels used by the component.
   *
   * @returns {object} An object with all the text labels used by the component.
   * @private
   */
  get labels() {
    return {
      title: this.title,
      subtitle: this.subtitle,
      ctaLabel: this.ctaLabel,
      ctaLabelAria: this.ctaLabelAria,
    };
  }
}
export default CoreIntcCtaBar;