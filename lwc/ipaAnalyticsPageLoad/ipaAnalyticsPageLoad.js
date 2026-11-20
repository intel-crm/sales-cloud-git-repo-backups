import { api, LightningElement } from 'lwc';
import { callAnalytics } from 'c/ipaAnalyticsService';

/**
 * A component that will log a hit with the analytics service for a pageView. An optional
 * canonical link can also be created.
 *
 * @example
 * // JavaScript component example 1
 * analyticsPageType = {
 *   pageType: 'PartnerDetailPage',
 *   title: 'PartnerDetail Page',
 * };
 * communityName = 'Marketplace';
 * includeCanonical = false;
 *
 * @example
 * <!-- HTML component example 1 -->
 * <c-ipa-analytics-page-load analytics-page-type={analyticsPageType} community-name={communityName} include-canonical={includeCanonical}>
 * </c-ipa-analytics-page-load>
 *
 * @augments LightningElement
 * @property {string} analyticsPageType  Analytics data in JSON string format.
 * @property {string} communityName  The name of the community displaying the component (Marketplace,
 * Leads, IPA).
 * @property {string} includeCanonical  Indicates if a canonical link should be added to the page.
 */
export default class IpaAnalyticsPageLoad extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api analyticsPageType;

  @api communityName;

  @api includeCanonical;



  // ******* Class variables ********
  /**
   * Indicates if the page analytics have already been called.
   *
   * @type {boolean}
   * @private
   */
  analyticsCalled = false;



  // ******* Methods ********
  /**
   * Called when the element is inserted into the DOM. Used to call the method to log the
   * analytics pageView hit.
   *
   * @private
   */
  renderedCallback() {
    if (!this.analyticsCalled) {
      this.analyticsCalled = true;
      callAnalytics(this.analyticsPageType, this.communityName, this.includeCanonical);
    }
  }
}