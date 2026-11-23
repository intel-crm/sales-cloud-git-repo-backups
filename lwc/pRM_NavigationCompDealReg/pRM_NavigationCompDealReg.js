import { LightningElement ,track, api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import prmBreadcrumbPartnerBenefitTxt from '@salesforce/label/c.PRM_Breadcrumb_PartnerBenefit_Txt';
import { getIpaBreadcrumbs } from 'c/ipaBreadcrumbsServiceIpa';
import { callAnalytics, getAnalyticsData } from 'c/ipaAnalyticsService';
import fetchUserPermissions from '@salesforce/apex/Core_DDR_Design_Handler_Utility.fetchUserPermissions';
import USERPROFILE_NAME from '@salesforce/schema/User.Profile.Name';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';


export default class PRM_NavigationCompDealReg extends NavigationMixin(LightningElement) {
  breadcrumbsRendered = false;
  @track changeStyle = false;
  @api SettingsMenuOption;
  @track adminProfiles;
  
  //@track menus =[];
    get className(){
      //if changeStle is true, getter will return class1 else class2
        return this.changeStyle ? 'slds-p-top_xx-small': 'slds-p-top_xx-small';
    }
    /*
    @track menu= [
      { id: 1, label: 'Home', target: '/partneradmin/s/ddr' },
      { id: 2, label: 'Deal Registration', target: '/partneradmin/s/core-design-registration/Core_Design_Registration__c/Default?Core_Design_Registration__c-filterId=00BDf00000AJJUWMA5' },
      { id: 3, label: 'Design Registration', target: '/partneradmin/s/core-design-registration/Core_Design_Registration__c/Default' },
      { id: 4, label: 'Opportunity', target: '/partneradmin/s/opportunity/Opportunity/Default' },
    { id: 5, label: 'Reports', target: '/partneradmin/s/report/Report/Recent' },
    { id: 6, label: 'Bulk Upload', target: '/partneradmin/s/pcc-bulkupload' },
      ];
      */
    @api menuItems = [];
    @track menus =[];
      
     // clickedTab = 'tab1';
      handleNavigation(event) {
        console.log('Inside Nav Handler--',event.target.innerText);
        const target = event.target.dataset.target;
         const tabId = event.target.dataset.tabId;
         const activetabContent  = event.target.label;
         this.clickedTab = tabId;
         console.log('this.activetabContent---->',activetabContent);
         console.log('Target--->',target);
        this.template.querySelector('li').activeTabValue = target;
        if (target) {
          this.navigateToPage(target);
        }
      }
    
      navigateToPage(pageUrl) {
        console.log('pageUrl---'+pageUrl);
        window.location.href = pageUrl;
      } 

      connectedCallback(){
        //console.log('hasDealRegPermissionSet--',hasDealRegPermissionSet);
        console.log('Menus -->',this.menuItems);
        this.loadMenuItems();
      
      }
      
      loadMenuItems(){
        fetchUserPermissions()       
        .then(data =>{

          this.menus.push({ id: 1, label: 'Home', target: '/partneradmin/s/ddr' });
            console.log('#data from permission set in Apex ---',data);
            console.log('Profile is---',data[0].profile);
            console.log('Permission Set in user is---',data[0].permissionSets);
            if(data[0].profile=='System Administrator' || data[0].profile=='IT Admin'){
              console.log('Logged in user is---',data[0].profile);
              this.menus.push({ id: 2, label: 'Deal Registration', target: '/partneradmin/s/deal-reg-list-view' });
              this.menus.push({ id: 3, label: 'Design Registration', target: '/partneradmin/s/core-design-registration/Core_Design_Registration__c/Default' });
            }else if(data[0].permissionSets.length>0){
              console.log('Inside else if--');
              if(data[0].permissionSets.includes('PCC_Deal_Reg_Partner_Access')){
                console.log('Inside Deal Reg');
                this.menus.push({ id: 2, label: 'Deal Registration', target: '/partneradmin/s/deal-reg-list-view' }); 
              }else if(data[0].permissionSets.includes('Core_DDR_Permission_Set')){
                console.log('Inside DDR');
                this.menus.push({ id: 3, label: 'Design Registration', target: '/partneradmin/s/core-design-registration/Core_Design_Registration__c/Default' });
              }
            }
             
            this.menus.push({ id: 4, label: 'Opportunity', target: '/partneradmin/s/opportunity/Opportunity/Default' });
            this.menus.push({ id: 5, label: 'Reports', target: '/partneradmin/s/report/Report/Recent' });
            this.menus.push({ id: 6, label: 'Bulk Upload', target: '/partneradmin/s/pcc-bulkupload' });

        })
        .catch(error => {

          this.error = error;

      });
    }
      
      renderedCallback() {
        // Only invoke the breadcrumb logic the first time the component is rendered and has
        // not been invoked via the wire data.
        
        if (!this.breadcrumbsRendered && !this.recordId) {
          console.log('Inside 78');
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
      console.log('breadcrumbs --- '+this.breadcrumbs);
      console.log('children --- '+this.breadcrumbs.breadcrumb.children);
      console.log('length --- '+this.breadcrumbs.breadcrumb.children.length);

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
    console.log('Inside renderBreadcrumbs');
    // Call the service to get the breadcrumbs.
    getIpaBreadcrumbs().then((breadcrumbs) => {
      const breadcrumbsComponent = this.template.querySelector('c-core-intc-breadcrumbs');
      console.log('breadcrumbsComponent--',breadcrumbsComponent);
      if (breadcrumbsComponent) {
        // Check if need to add the data for the Lead being edited on the Edit Lead page
        if (recordData) {
          console.log('recordData--',recordData);
          this.addEditBreadcrumb(breadcrumbs, recordData);
        }
        breadcrumbsComponent.renderBreadcrumbs({
          ...breadcrumbs,
          analyticsData: getAnalyticsData(this.analyticsPageType, 'Leads'),
        });
        console.log('breadcrumbs --- '+this.breadcrumbs);
      }
    });
  }

  
  /*
  @wire(getRecord, { recordId: USER_ID, fields: [USERPROFILE_NAME]}) 
    userDetails({error, data}) {
        if (data) {
          console.log('Data--',data);
            this.profileName = data.fields.Profile.value.fields.Name.value; 
            if(this.profileName =='Partner'){
              console.log('Profile Name -->',this.profileName);
              console.log('Menus -->', this.menuItems);
              this.menus = this.menu;
              //this.menus.push({ id: 6, label: 'My Settings', target: '/partneradmin/s/my-settings' })
              
            } else{
              this.menus = this.menu;

            }
           
        } else if (error) {
            this.error = error ;
        }
    }
    */

    
    

}