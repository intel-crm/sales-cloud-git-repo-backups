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
import REGISTRATION_TYPE from "@salesforce/schema/Core_Design_Registration__c.PCC_Registration_Type__c";



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
  @track isDDRPartner = false;
  @track userName = '';
  @track reg_Type = '';
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
  @track menuLst= [
    { id: 1, label: 'Deal Home', target: '/partneradmin/s/deal' },
    { id: 2, label: 'Design Home', target: '/partneradmin/s/ddr' },
    { id: 3, label: 'Deal Registration', target: '/partneradmin/s/deal-reg-list-view' },
    { id: 4, label: 'Design Registration', target: '/partneradmin/s/core-design-registration/Core_Design_Registration__c/Default' },
    { id: 5, label: 'Opportunity', target: '/partneradmin/s/opportunity' },
    { id: 6, label: 'Reports', target: '/partneradmin/s/report/' },
    { id: 7, label: 'Bulk Upload', target: '/partneradmin/s/pcc-bulkupload' },
    { id: 8, label: 'User Preferences', target: '/partneradmin/s/user-preferences'},
    { id: 9, label: 'Rebate Claim', target: '/partneradmin/s/rebate-claim'}
    ];
  @track selectedTab;
  handleNavigation(event) {

    const target = event.target.dataset.target;
    const tabId = event.target.dataset.tabId;
    
    this.clickedTab = tabId;

    if (target) {
      this.navigateToPage(target);
    }
  }

  navigateToPage(pageUrl) {

    window.location.href = pageUrl;
  }

  connectedCallback() {
    const pageLink = window.location;
    console.log('@@PageLink=='+pageLink);
    this.menuLst.forEach(menuItem => {
      
      console.log('@@menuItem=='+menuItem.target);
      let url = pageLink.toString().toLowerCase();
      let menuStr = menuItem.target.toString().toLowerCase();
      if(url.includes(menuStr)){
        this.selectedTab = menuItem.label;
      }
    })
   console.log('@@Highlight=='+this.selectedTab);

    fetchUserPermissions()
      .then(data => {
        console.log('@@Data=='+JSON.stringify(data));
        if ((data[0].permissionSets.length > 0) && (data[0].permissionSets.includes(this.dealPermissionSet))) {
            this.isDealPartner = true;
            this.hasPartnerAccepted = data[0].hasPartnerAccepted;
          }
          if ((data[0].permissionSets.length > 0) && (data[0].permissionSets.includes(this.ddrPermissionSet))) {
            this.isDDRPartner = true;
          }
        if (!this.hasPartnerAccepted && this.isDealPartner) { 
          this.verifyTermsAndConditions(); 
        } 
        else{
          this.loadMenuItems();
        }

      })
      .catch(error => {
        this.error = error;
      });
  }

  loadMenuItems() {
    /*CodeScan Line Length is 160chars -- Don't Modify. */
    
          if (this.isDealPartner){
            this.menus.push({ id: 1, label: 'Home', target: '/partneradmin/s/deal', className: '' });
            this.menus.push({ id: 2, label: 'Deal Registration', target: '/partneradmin/s/deal-reg-list-view', 
                              className: '' });
            this.menus.push({ id: 4, label: 'Opportunity', target: '/partneradmin/s/opportunity/Opportunity/Default', 
                                className: '' });
            this.menus.push({ id: 5, label: 'Rebate Claim', target: '/partneradmin/s/rebate-claim/PCC_Rebate_Claim__c/Default', 
                              className: '' });
            this.menus.push({ id: 6, label: 'Reports', target: '/partneradmin/s/report/Report/Recent', className: '' });
          }
          if (this.isDDRPartner) {
            this.menus.push({ id: 1, label: 'Home', target: '/partneradmin/s/ddr', className: '' });
            this.menus.push({ id: 3, label: 'Design Registration',
                              target: '/partneradmin/s/core-design-registration/Core_Design_Registration__c/Default', className: ''});
            this.menus.push({ id: 4, label: 'Opportunity', target: '/partneradmin/s/opportunity/Opportunity/Default', 
                                className: '' });
            this.menus.push({ id: 6, label: 'Reports', target: '/partneradmin/s/report/Report/Recent', className: '' });
            this.menus.push({ id: 7, label: 'Bulk Upload', target: '/partneradmin/s/pcc-bulkupload', className: '' });
            this.menus.push({ id: 8, label: 'User Preferences', target: '/partneradmin/s/user-preferences', className: '' });
          }
    
    this.menus.sort((a, b) => a.id - b.id);

    if(this.selectedTab === undefined){
      if(this.isDDRPartner){
        this.selectedTab = 'Design Registration';
      }
      else {
        this.selectedTab = 'Deal Registration';
      }
    }

    this.menus.forEach(menuItem => {
      if(this.selectedTab.includes('Home')){
          if(this.isDealPartner && this.isDDRPartner &&(this.selectedTab === menuItem.label)){
            menuItem.className = 'liselection';
          }
          else if(menuItem.label === 'Home') {
            menuItem.className = 'liselection';
          }
        }
        else if((this.selectedTab === menuItem.label) && !this.selectedTab.includes('Home')){
          menuItem.className = 'liselection';
          console.log('@@Assigned');
        }
    })
    console.log('@@Menu Last=='+JSON.stringify(this.menus));
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