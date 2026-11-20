import { LightningElement, api } from 'lwc';
import defaultTitle from '@salesforce/label/c.PMP_L0_CTA';
import defaultSubtitle from '@salesforce/label/c.PMP_L0_CTA_Subheading';
import defaultCTALabel from '@salesforce/label/c.PMP_Learn_More';
import defaultUrl from '@salesforce/label/c.PMP_L0_CTA_URL';
import defaultCTALabelAria from '@salesforce/label/c.PMP_Learn_More_Accessibility';
import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';

/* US751555 - To restrict the visiblity of the component only to guest users.
  This can be done on the community page via assignment to audience, but it cannot be deployed from one org to another.
  hence going with the custom approach
  */
import isGuest from '@salesforce/user/isGuest';

/** Documentation for the IPA CTA Bar
 * <br>
 * This component is exposed in the Community Builder.
 * <br>
 * CTA button can link to an internal community page via api name ('CTA Community Page' <code>ctaCommPage</code>) or an external
 * url page ('CTA External URL' <code>ctaExternalURL</code>).
 * <br><i>TODO - change 'theme' property to 'variation' (requires removing all ctas)</i>
 *
 * @augments LightningElement
 * @property {string} [theme='primary'] can be 'primary', 'dark', 'light'
 * @property {string} title Heading CTA heading
 * @property {string} subtitle 'Sub Heading' CTA sub heading
 * @property {string} ctaLabel label for cta action
 * @property {string} [ctaCommPage=''] api name for community page links
 * @property {string} [ctaExternalURL=''] url for external url links
 */
class IpaCtaBar extends LightningElement {
  @api theme = 'primary';

  @api title;

  @api subtitle;

  @api ctaLabel;

  @api ctaCommPage = '';

  @api ctaExternalURL = '';

  // ******* Variables *******
  isGuestUser = isGuest;

  testPage = 'Home';

  /**
   * TODO - description
   *
   * @returns {object} TODO - description
   * @private
   */
  get labels() {
    return {
      title: defaultTitle,
      subtitle: defaultSubtitle,
      ctaLabel: defaultCTALabel,
      ctaLabelAria: defaultCTALabelAria,
    };
  }

  /**
   * TODO - description
   *
   * @returns {string} TODO - description
   * @private
   */
  get ctaUrlValue() {
    return defaultUrl;
  }

  /**
   * TODO - description
   *
   * @returns {string[]} TODO - description
   * @private
   */
  get buttonCustomVariant() {
    return [
      'button',
      'button-secondary',
      'button-arrow',
      this.theme === 'light' ? '' : 'button-inverse',
    ].join(' ');
  }



  /**
   * Creates a data object based on the CTA link's properties and sends that
   * to the analytics library to be logged.
   *
   * @param {object} linkClickEvent  The corelinkclick event thrown by the coreIntcLink in coreIntcCtaBar.
   * @private
   */
  handleLinkClick(linkClickEvent) {
    // Create the parameters for the analytics post
    const messageData = {
      analyticsType: 'click',
      element: '',
      pageTitle: linkClickEvent.detail.label || '',
      targetURL: linkClickEvent.detail.href || '',
    };

    // The event should not be needed above this in the hierarchy
    linkClickEvent.stopPropagation();

    // Call the helper library to log the analytics data
    makeIpaAnalyticsCall(messageData);
  }
}
export default IpaCtaBar;