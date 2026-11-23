import { LightningElement, api } from 'lwc';
import { getMarketplaceBreadcrumbs } from 'c/ipaBreadcrumbsServiceMarketplace';
import { getIpaBreadcrumbs } from 'c/ipaBreadcrumbsServiceIpa';
import { getAnalyticsData } from 'c/ipaAnalyticsService';
import { handleError } from 'c/ipaErrorServiceMarketplace';


/**
 * A component for rendering IGHF breadcrumb navigation. The Marketplace and IPA marquees have this functionality
 * embedded inside them, so this component should be used on pages that need to render breadcrumbs but do not
 * include the Marketplace or IPA marquee.
 *
 * @example
 * // JavaScript component example 1
 * analyticsPageType = {
 *   pageType: 'PartnerDetailPage',
 *   title: 'PartnerDetail Page',
 * };
 *
 * @example
 * <!-- HTML component example 1 -->
 * <c-ipa-breadcrumbs analytics-page-type={analyticsPageType} community-name="Marketplace"></c-ipa-breadcrumbs>
 *
 * @augments LightningElement
 * @property {string} analyticsPageType Analytics data in JSON string format.
 * @property {string} communityName  The name of the community displaying the component (Marketplace,
 * Leads, IPA).
 */
class IpaBreadcrumbs extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api analyticsPageType;

  @api communityName;



  // ******* Class variables ********
  /**
   * Indicates if the breadcrumb data has already been retrieved and rendered.
   *
   * @type {boolean}
   * @private
   */
  breadcrumbsRendered = false;



  // ******* Methods ********
  /**
   * Called during render of the component lifecycle. Used to get the breadcrumbs
   * and call the method to render them.
   *
   * @private
   */
  renderedCallback() {
    // Only invoke the breadcrumb logic the first time the component is rendered
    if (!this.breadcrumbsRendered) {
      this.breadcrumbsRendered = true;
      if (this.communityName === 'Marketplace') {
        console.log('I am here inside marketplace');
        this.renderBreadcrumbs(getMarketplaceBreadcrumbs);
      } else if (this.communityName === 'IPA') {
        this.renderBreadcrumbs(getIpaBreadcrumbs);
      }
    }
  }



  /**
   * Gets the breadcrumbs and calls the component method to render them.
   *
   * @param {Function} getBreadcrumbData  The method to execute to get the breadcrumb data.
   * @private
   */
  renderBreadcrumbs(getBreadcrumbData) {
    // Call the service to get the breadcrumbs
    getBreadcrumbData()
      .then((breadcrumbs) => {
        console.log('breadcrumbs',...breadcrumbs);
        const breadcrumbsComponent = this.template.querySelector('c-core-intc-breadcrumbs');   
        if (breadcrumbsComponent) {
          breadcrumbsComponent.renderBreadcrumbs({
            ...breadcrumbs,
            analyticsData: getAnalyticsData(this.analyticsPageType, this.communityName),
          });
        } else {
          const errorMessage = 'coreIntcBreadcrumbs not found in ipaBreadcrumbs.';
          if (this.communityName === 'Marketplace') {
            handleError(errorMessage, 'ipaBreadcrumbs', 'console');
          } else {
            // IPA and Leads do not have an error service, so writing it directly to the console
            console.error(errorMessage);
          }
        }
      });
  }
}
export default IpaBreadcrumbs;