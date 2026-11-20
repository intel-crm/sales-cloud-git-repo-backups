/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api } from 'lwc';

import LearnMore from '@salesforce/label/c.PMP_Learn_More';
import searchMarketplace from '@salesforce/label/c.PMP_Search_Marketplace';
import termsAndCondURL from '@salesforce/label/c.PMP_IPA_Home_LoggedIn';
import { getMarketplaceBreadcrumbs } from 'c/ipaBreadcrumbsServiceMarketplace';
import { callAnalytics, getAnalyticsData } from 'c/ipaAnalyticsService';

// Added by MP Team for navigation to Terms and Conditions
import getLegalAggrement from '@salesforce/apex/PMP_SearchMarqueeDetailController.checkLegalAgreementForAllLocations';
import IpaMarqueeMarketplaceData from './data';

/**
 * Share Data with other components, allows other components to set marquee dynamically
 */
export const ipaMarqueeMarketplaceData = IpaMarqueeMarketplaceData;

/** Documentation for Marquee Marketplace Component
 * <br>
 * <h2>Marketplace Pages using ipaMarqueeMarketplace:</h2>
 * <h3>L0 - Home</h3><br>
 * <h3>L1 - Level One Pages (ie. Offering Categories, Partner Directory, ...)</h3><br>
 * <h3>L2 - Level Two Category Search Pages
 *
 * @augments LightningElement
 * @property {boolean} [dynamicMarquee=false] Set to true to set Marquee data dynamically
 * @property {string} backgroundVariant set the background variant
 * @property {string} pageType designattribute to pass value from ipaMarqueeMarketplace to SearchBox
 * @property {string} title Set the Title for the Marquee
 * @property {string} subtitle Set the Subtitle for the Marquee
 * @property {string} ctaLabel Set Label for Link
 * @property {string} ctaExternalUrl Set External URL - uses linkout icon
 * @property {string} ctaCommPage Set Community Page
 * @property {boolean} [showCaret=false] Show right arrow icon on link
 * @property {boolean} [showSearch=false] Show search box
 * @property {string} [alignment=Left] Set Left alignment or Center alignment
 * @property {string} analyticsPageType Analytics data in JSON string format
 */
class IpaMarqueeMarketplace extends LightningElement {
  @api backgroundVariant;

  @api title;

  @api subtitle;

  @api ctaLabel;

  @api ctaExternalUrl;

  @api ctaCommPage;

  @api showCaret;

  @api showSearch;

  @api alignment;

  @api dynamicMarquee;

  @api analyticsPageType;

  @api doAnalytics;

  @api pageType;

  // these properties are no longer used and should not be added to JSDocs
  @api isHomePage;

  @api isPartnerPage;

  @api isOfferingPage;

  /** link data
   *
   * @type {object}
   * @private
   */
  linkData = {};

  /* Added by MP Team for Navigation to Intel Home page */
  /**
   * @type {object}
   * @private
   */
  baseUrlRecord;

  /** Custom labels
   *
   * @type {object}
   * @private
   */
  label = {
    LearnMore,
    searchMarketplace,
  };

  /**
   * Indicates if the page analytics have already been called.
   *
   * @type {boolean}
   * @private
   */
  analyticsCalled = false;

  /**
   * Indicates if the breadcrumb data has already been retrieved and rendered.
   *
   * @type {boolean}
   * @private
   */
  breadcrumbsRendered = false;


  /** connected callback
   * - gets legal agreement, redirects if necessary
   * - sets link data
   * - subscribes to dynamic marquee values
   *
   */
  connectedCallback() {
    getLegalAggrement().then((result) => {
      if (result === false) {
        window.location.href = termsAndCondURL;
      }
    });
    this.linkData = {
      label: this.ctaLabel,
      communityPage: this.ctaCommPage,
      externalUrl: this.ctaExternalUrl,
    };
    if (this.dynamicMarquee) {
      this.subscription = IpaMarqueeMarketplaceData.subscribe((newData) => {
        this.title = newData.title;
        this.subtitle = newData.subtitle || '';
        this.showCaret = newData.showCaret || false;
        this.linkData = newData.linkData || {};
      });
    }
  }

  /** disconnected callback
   * - unsubscribes from message channel
   */
  disconnectedCallback() {
    if (this.subscription) {
      this.subscription();
    }
  }

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
      this.renderBreadcrumbs();
    }

    // doAnalytics will be undefined even though it is defaulted to true unless the value
    // has been updated in the builder.
    if ((this.doAnalytics || this.doAnalytics === undefined) && !this.analyticsCalled) {
      this.analyticsCalled = true;
      callAnalytics(this.analyticsPageType, 'Marketplace', true);
    }
  }



  /**
   * Gets the breadcrumbs and calls the component method to render them.
   *
   * @private
   */
  renderBreadcrumbs() {
    // Call the service to get the breadcrumbs. Not sure if this is actually going
    // to be a promise, so keeping it simple for now.
    getMarketplaceBreadcrumbs()
      .then((breadcrumbs) => {
        const breadcrumbsComponent = this.template.querySelector('c-core-intc-breadcrumbs');
        if (breadcrumbsComponent) {
          breadcrumbsComponent.renderBreadcrumbs({
            ...breadcrumbs,
            analyticsData: getAnalyticsData(this.analyticsPageType, 'Marketplace'),
          });
        } else {
          console.error('coreIntcBreadcrumbs not found in ipaMarqueeMarketplace');
        }
      });
  }
}
export default IpaMarqueeMarketplace;