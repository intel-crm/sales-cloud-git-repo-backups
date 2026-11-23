import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import prmBreadcrumbPartnerBenefitTxt from '@salesforce/label/c.PRM_Breadcrumb_PartnerBenefit_Txt';
import { getIpaBreadcrumbs } from 'c/ipaBreadcrumbsServiceIpa';
import { callAnalytics, getAnalyticsData } from 'c/ipaAnalyticsService';
export default class PRM_NavigationCompPCC extends NavigationMixin(LightningElement) {
  breadcrumbsRendered = false;
    menuItems = [
        { id: 1, label: 'Home', target: '/partneradmin/s/ddr' },
        { id: 2, label: 'Design Registration', target: '/about' },
        { id: 3, label: 'Opportunity', target: '/partneradmin/s/opportunity/Opportunity/Default' },
        { id: 4, label: 'Reports', target: '/partneradmin/s/report/Report/Recent' },
        { id: 5, label: 'Dashboard', target: '/partneradmin/s/dashboard/Dashboard/Recent' }
      ];
   
      handleNavigation(event) {
        const target = event.target.dataset.target;
        if (target) {
          this.navigateToPage(target);
        }
      }
    
      navigateToPage(pageUrl) {
        window.location.href = pageUrl;
      }
  
  
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