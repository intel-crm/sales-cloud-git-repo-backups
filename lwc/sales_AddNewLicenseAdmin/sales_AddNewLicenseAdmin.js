import { LightningElement } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
/*import { ShowToastEvent } from "lightning/platformShowToastEvent";
//import createNewLicenseAdmDelegate from '@salesforce/apex/Sales_AddNewLicenseAdminController.createNewLicenseAdmDelegate';
//import isCommunity from '@salesforce/apex/Sales_AddNewLicenseAdminController.isCommunity';
import LICENDE_ADMIN_DELEGATE_OBJECT from '@salesforce/schema/Sales_License_Admin_Delegate__c';
import PRIMARY_ADMIN_CONTACT_FIELD from '@salesforce/schema/Sales_License_Admin_Delegate__c.Sales_License_PrimaryAdmin_Contact__c';
import FIRSTNAME_FIELD from '@salesforce/schema/Sales_License_Admin_Delegate__c.Sales_License_DlgAdmin_FirstName_Txt__c';
import LASTNAME_FIELD from '@salesforce/schema/Sales_License_Admin_Delegate__c.Sales_License_DlgAdmin_LastName_Txt__c';
import EMAIL_FIELD from '@salesforce/schema/Sales_License_Admin_Delegate__c.Sales_License_DlgAdmin_Email_Txt__c';
import Saleslicenseadminsucess from '@salesforce/label/c.Sales_license_admin_sucess';
import Salesreviewerror from '@salesforce/label/c.Sales_review_error';
import Salesupdatelicensewithinactivehost from '@salesforce/label/c.Sales_update_license_with_inactive_host';
import Sales_view_manage_admin_Link from '@salesforce/label/c.Sales_view_manage_admin_Link';
import Sales_adminUser1 from '@salesforce/label/c.Sales_adminUser1';
import Sales_SaveOrder_HTML from '@salesforce/label/c.Sales_SaveOrder_HTML';
import Sales_Cancel from '@salesforce/label/c.Sales_Cancel';
import Sales_FirstName from '@salesforce/label/c.Sales_FirstName';
import Sales_LastName from '@salesforce/label/c.Sales_LastName';
import Sales_mail from '@salesforce/label/c.Sales_mail';
*/


export default class CreateContactForm extends NavigationMixin(LightningElement) {

  /*@track isLoaded = false;
  @api isInternal = false;
  @api isRender = false;
  @api licAdmDelegateId;
  @track errormessage;
  primaryAdminContact;
  firstName;
  lastName;
  email; 
  label={ Saleslicenseadminsucess,
    Salesreviewerror,Sales_FirstName,Sales_LastName,Sales_mail,
    Salesupdatelicensewithinactivehost,
    Sales_view_manage_admin_Link,Sales_Cancel,Sales_adminUser1,Sales_SaveOrder_HTML

  }

  /*connectedCallback() {
    console.log('in init');
    isCommunity()
      .then(result => {
        console.log('result:'+result);
        this.isInternal = result;             
  })
  .catch(error => {
    const evt = new ShowToastEvent({
      title: 'Error',
      message: error.body.message,
      variant: 'error',
      mode: 'dismissable'
  });
  this.dispatchEvent(evt);
  });   
  }*/

  /*handleInputFieldChange(event){    
    var fieldName = event.target.fieldName;
    switch(fieldName) {
      case PRIMARY_ADMIN_CONTACT_FIELD.fieldApiName:
        this.primaryAdminContact = event.target.value;
        break;
      case FIRSTNAME_FIELD.fieldApiName:
        this.firstName = event.target.value;
        break;
        case LASTNAME_FIELD.fieldApiName:
          this.lastName = event.target.value;
        break;
        case EMAIL_FIELD.fieldApiName:
          this.email = event.target.value;
        break;
     
    }    
  }

  handleOnLoad() {
    this.isLoaded = true;
  }

  handleOnSuccess(event) {
    const evt = new ShowToastEvent({
      title: 'Success',
      message: this.label.Saleslicenseadminsucess,
      variant: 'success',
      mode: 'dismissable'
  });
  this.dispatchEvent(evt);
  }

  navigateToObjectHome() {
    // Navigate to the License admin delegate record.
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
          recordId: this.licAdmDelegateId,
          objectApiName: 'Sales_License_Admin_Delegate__c', // objectApiName is optional
          actionName: 'view'
      }
  });
}

  /*handleOnSubmitBtnClick(event) {
    console.log('in btn click method');
    if (!this.validateFields()) {
      const toast = new ShowToastEvent({
          message: this.label.Salesreviewerror,
          variant: "error",
      });
      this.dispatchEvent(toast);
  }
  else {
    this.isLoaded = false;

   // event.preventDefault(); // stop the form from submitting
   /* const fields = {};
        fields[PRIMARY_ADMIN_CONTACT_FIELD.fieldApiName] = this.primaryAdminContact;
        fields[FIRSTNAME_FIELD.fieldApiName] = this.firstName;
        fields[LASTNAME_FIELD.fieldApiName] = this.lastName;
        fields[EMAIL_FIELD.fieldApiName] = this.email;
        const recordInput = { apiName: LICENDE_ADMIN_DELEGATE_OBJECT.objectApiName, fields };
        console.log('recordInput:'+ JSON.stringify(recordInput));
        var licAdmDelRecord = this.getSObject(recordInput); */
        /*let licAdmDelRecord = {
          sobjectType : LICENDE_ADMIN_DELEGATE_OBJECT.objectApiName,
          Sales_License_PrimaryAdmin_Contact__c : this.primaryAdminContact,
          Sales_License_DlgAdmin_FirstName_Txt__c : this.firstName,
          Sales_License_DlgAdmin_LastName_Txt__c : this.lastName,
          Sales_License_DlgAdmin_Email_Txt__c : this.email          
          
        }
        console.log('licAdmDelRecord:'+ JSON.stringify(licAdmDelRecord));
      createNewLicenseAdmDelegate({
      licAdmDelegate: licAdmDelRecord
    })
      .then(result => {
        console.log('result line 120'+result);
        if(result){
          console.log('result'+result);
          this.licAdmDelegateId = result;  
          const evt = new ShowToastEvent({
            title: 'Success',
            message: this.label.Saleslicenseadminsucess,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.navigateToListView();
        }
      })    
      .catch(error => {
        console.log('error'+ JSON.stringify(error));
        if(error.body.message.includes('trying to update a license record that is currently associated to an inactive computer')){
        const evt = new ShowToastEvent({
          title: 'Error',
          message:this.label.Salesupdatelicensewithinactivehost,
          variant: 'error',
          mode: 'dismissable'
      });
      this.isLoaded = true;
      this.dispatchEvent(evt);
      }
	  else{
      console.log('error 165'+ JSON.stringify(error));
      this.errormessage=error.body.message.split(',');
      this.errormessage=this.errormessage[1].split(':');
      console.log('errormessage :'+this.errormessage[0]);
		  const evt = new ShowToastEvent({
          title: 'Error',
          message:this.errormessage[0],
          variant: 'error',
          mode: 'sticky'
      });
      this.isLoaded = true;
      this.dispatchEvent(evt);
	  }
      });   
    }            
  }*/         
    
  /*navigateToListView() {
    console.log('in navigate');
    if(this.isInternal == true){
        this[NavigationMixin.Navigate]({
          type: 'standard__objectPage',
          attributes: {
              objectApiName: 'Sales_License_Admin_Delegate__c',
              actionName: 'list'
          },
          state: 'recent'
      });  
    }else{
      console.log('in else navigate');
    /*  this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
            pageName: 'my-active-delegate-admins'
        },        
    });*/ 
    /*this[NavigationMixin.Navigate]({
      "type": "standard__webPage",
      "attributes": {
          "url": this.label.Sales_view_manage_admin_Link
      }
      });
    }
  }

  validateFields() {
    return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
        // Return whether all fields up to this point are valid and whether current field is valid
        // reportValidity returns validity and also displays/clear message on element based on validity
        return (validSoFar && field.reportValidity());
    }, true);
}*/
  
  
}