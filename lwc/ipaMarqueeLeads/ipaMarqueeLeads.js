import { api, LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import prmBreadcrumbPartnerBenefitTxt from '@salesforce/label/c.PRM_Breadcrumb_PartnerBenefit_Txt';
import { getIpaBreadcrumbs } from 'c/ipaBreadcrumbsServiceIpa';
import { callAnalytics, getAnalyticsData } from 'c/ipaAnalyticsService';


/**
 * Renders the Marquee for Leads. This component uses the ipaMarqueeDefault
 * component for the majority of its rendering. This component is generally
 * added directly to a page in the community builder versus being added
 * to another component.
 *
 *
 * @property {string} [alignment=center] Set Left alignment or Center alignment.
 * @property {string} analyticsPageType Analytics data in JSON string format.
 * @property {string} backgroundVariant Set the background variant (Component uses IpaMarqueeDefault).
 * @property {string} recordId The ID of the object whose page is being viewed.
 * @property {string} subtitle Set the Subtitle for the Marquee.
 * @property {string} title Set the Title for the Marquee.
 * @augments LightningElement
 */
class IpaMarqueeLeads extends LightningElement {
  @api alignment='center';

  @api analyticsPageType;

  @api backgroundVariant;

  @api recordId;

  @api subtitle;

  @api title;

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


  /**
   * Used to retrieve the data record displayed on the Edit Lead page.
   * The Edit page will use this call to renderBreadcrumbs and the My Leads
   * page will use the version in renderedCallback.
   *
   * @param {object} root0 response from wire adaptor
   * @param {object} root0.error error response
   * @param {object} root0.data record response
   * @private
   */
  @wire(getRecord, { recordId: '$recordId', fields: ['Lead.Name'] })
  wiredRecord({ error, data }) {
    if (error) {
      console.error('Error in wireRecord of ipaMarqueeLeads:', error);
    } else if (data) {
      // Make sure breadcrumbs have not already been rendered
      if (!this.breadcrumbsRendered) {
        // No so render them
        this.renderBreadcrumbs(data);
        this.breadcrumbsRendered = true;
      }
    }
  }



  /**
   * Called during render of the component lifecycle. Used to get the breadcrumbs
   * and call the method to render them.
   *
   * @private
   */
  renderedCallback() {
    // Only invoke the breadcrumb logic the first time the component is rendered and has
    // not been invoked via the wire data.
    if (!this.breadcrumbsRendered && !this.recordId) {
      this.renderBreadcrumbs();
      this.breadcrumbsRendered = true;
    }

    if (!this.analyticsCalled) {
      this.analyticsCalled = true;
      callAnalytics(this.analyticsPageType, 'Leads', false);
    }
  }



  /**
   * Creates a breadcrumb for the Lead that is being edited.
   *
   * @param {object} breadcrumbs  The breadcrumbs
   * @param {object} recordData  The Lead data object returned by the wire service.
   * @private
   */
  addEditBreadcrumb(breadcrumbs, recordData) {
    // Make sure their are children
    if (breadcrumbs.breadcrumb && breadcrumbs.breadcrumb.children && breadcrumbs.breadcrumb.children.length) {
      // Yes so need to find Manage Benefits breadcrumb
      const partnerBenefit = breadcrumbs.breadcrumb.children.find((child) => child.text === prmBreadcrumbPartnerBenefitTxt);

      // Check if Manage Benefits found
      if (partnerBenefit) {
        // Yes so deselect My Leads which is selected by default
        partnerBenefit.children[0].selected = false;

        // Add a breadcrumb for the Lead that is being edited
        partnerBenefit.children.push({
          id: 'Edit Leads',
          selected: true,
          text: recordData.fields.Name.value,
          url: window.location.pathname,
        });
      }
    }
  }



  /**
   * Gets the breadcrumbs and calls the component method to render them.
   *
   * @param {object} recordData record object
   * @private
   */
  renderBreadcrumbs(recordData) {
    // Call the service to get the breadcrumbs.
    getIpaBreadcrumbs().then((breadcrumbs) => {
      const breadcrumbsComponent = this.template.querySelector('c-core-intc-breadcrumbs');
      if (breadcrumbsComponent) {
        // Check if need to add the data for the Lead being edited on the Edit Lead page
        if (recordData) {
          this.addEditBreadcrumb(breadcrumbs, recordData);
        }
        breadcrumbsComponent.renderBreadcrumbs({
          ...breadcrumbs,
          analyticsData: getAnalyticsData(this.analyticsPageType, 'Leads'),
        });
      }
    });
  }
}
export default IpaMarqueeLeads;