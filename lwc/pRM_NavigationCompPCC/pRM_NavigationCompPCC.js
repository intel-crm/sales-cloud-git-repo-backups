import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import prmBreadcrumbPartnerBenefitTxt from '@salesforce/label/c.PRM_Breadcrumb_PartnerBenefit_Txt';
import { getIpaBreadcrumbs } from 'c/ipaBreadcrumbsServiceIpa';
import { callAnalytics, getAnalyticsData } from 'c/ipaAnalyticsService';
import fetchUserPermissions from '@salesforce/apex/Core_DDR_Design_Handler_Utility.fetchUserPermissions';
import PCC_DealPermissionSet from '@salesforce/label/c.PCC_DealPermissionSets';
import PCC_DDRPermissionSet from '@salesforce/label/c.PCC_DDRPermissionSet';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';



export default class PRM_NavigationCompPCC extends NavigationMixin(LightningElement) {
  breadcrumbsRendered = false;
  @track changeStyle = false;
  @api SettingsMenuOption;
  @track adminProfiles;
  dealPermissionSet = PCC_DealPermissionSet;
  ddrPermissionSet = PCC_DDRPermissionSet;
  @track partnerPermissions = [];
  @track hasPartnerAccepted = false;
  @track isDealPartner = false;
  @track userName = '';
  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD]
  }) wireuser({
    error,
    data
  }) {
    if (data) {
      this.userName = data.fields.Name.value;
    }
  }


  get className() {
    //if changeStle is true, getter will return class1 else class2
    return 'slds-p-top_xx-small';
  }

  @api menuItems = [];
  @track menus = [];

  // clickedTab = 'tab1';
  handleNavigation(event) {

    const target = event.target.dataset.target;
    const tabId = event.target.dataset.tabId;
    const activetabContent = event.target.label;
    this.clickedTab = tabId;

    if (target) {
      this.navigateToPage(target);
    }
  }

  navigateToPage(pageUrl) {

    window.location.href = pageUrl;
  }

  connectedCallback() {
    fetchUserPermissions()
      .then(data => {
        if (data[0].permissionSets.length > 0) {
          if (data[0].permissionSets.includes(this.dealPermissionSet)) {
            this.isDealPartner = true;
            this.hasPartnerAccepted = data[0].hasPartnerAccepted;
          }
        }
        if (!this.hasPartnerAccepted && this.isDealPartner) { this.verifyTermsAndConditions(); } else{
          this.loadMenuItems();
        }

      })
      .catch(error => {
        this.error = error;
      });
  }

  loadMenuItems() {
    if (this.isDealPartner) {
      this.menus.push({ id: 1, label: 'Home', target: '/s/deal', className: '' });
      this.menus.push({ id: 2, label: 'Deal Registration', target: '/s/deal-reg-list-view', className: '' });
    }
    if (!this.isDealPartner) {
      this.menus.push({ id: 1, label: 'Home', target: '/s/ddr', className: '' });
      this.menus.push({ id: 3, label: 'Design Registration',target: '/s/core-design-registration/Core_Design_Registration__c/Default', className: ''
      });
      this.menus.push({ id: 6, label: 'Bulk Upload', target: '/s/pcc-bulkupload', className: '' });
      this.menus.push({ id: 7, label: 'User Preferences', target: '/s/user-preferences', className: '' });
    }
    this.menus.push({ id: 4, label: 'Opportunity', target: '/s/opportunity/Opportunity/Default', className: '' });
    this.menus.push({ id: 5, label: 'Reports', target: '/s/report/Report/Recent', className: '' });
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

  verifyTermsAndConditions() {
    if (this.isDealPartner && !this.hasPartnerAccepted) {
      this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
          name: 'deal_legal_agreement__c'
        }
      });
    }
  }
}