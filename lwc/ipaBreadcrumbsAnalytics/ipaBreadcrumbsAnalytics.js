import { LightningElement, api } from 'lwc';


/**
 * A component for rendering IGHF breadcrumb navigation and page load analytics. The Marketplace and IPA marquees have this functionality
 * embedded inside them, so this component should be used on pages that need to render breadcrumbs and log analytics but do not
 * include the Marketplace or IPA marquee.
 *
 * This component references the ipaAnalyticsPageLoad and ipaBreadcrumbs components.
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
 * <c-ipa-breadcrumbs-analytics analytics-page-type={analyticsPageType} community-name={communityName} include-canonical={includeCanonical}>
 * </c-ipa-breadcrumbs-analytics>
 *
 * @augments LightningElement
 * @property {string} analyticsPageType Analytics data in JSON string format.
 * @property {string} communityName  The name of the community displaying the component (Marketplace,
 * @property {string} includeCanonical  Indicates if a canonical link should be added to the page.
 * Leads, IPA).
 */
class IpaBreadcrumbsAnalytics extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api analyticsPageType;

  @api communityName;

  @api includeCanonical;
}
export default IpaBreadcrumbsAnalytics;