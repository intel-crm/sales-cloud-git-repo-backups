import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from 'lightning/navigation';
import Saleslicenseadminsucess from '@salesforce/label/c.Sales_license_admin_sucess';

//APEX
//import licensefileGeneration from '@salesforce/apex/Sales_LicenseGenIntegration_Utility.returnHostIdDetail';
import createHostonLicenseRecord from '@salesforce/apex/Sales_LicenseRecordPageComponentsUtility.createHostonLicenseRecord';
import isCommunity from '@salesforce/apex/Sales_AddNewLicenseAdminController.isCommunity';
import getUserDetails from '@salesforce/apex/Sales_SetupHostComputerController.getUserDetails';
import getDelegateContactIds from '@salesforce/apex/Sales_SetupHostComputerController.getDelegateContactIds';

//import getFeedRecord from '@salesforce/apex/Sales_FeedbackController.getFeedRecord';//added for feedback
//import checkCapablity from '@salesforce/apex/Sales_FeedbackController.checkCapablity';//added for feedback

//SCHEMA
import HOST_OBJECT from "@salesforce/schema/Sales_Host__c";

//Import the current user’s ID 
import userId from '@salesforce/user/Id';

//LABELS
import errorMsg from '@salesforce/label/c.Sales_Error_Message';
import validUsersErrorMsg from '@salesforce/label/c.Sales_CreateHost_ContactErrMsg';

//FIELDS
const FIELDS = ['Sales_Host__c.Sales_License_Type__c',
    'Sales_Host__c.Sales_Companion_Server2_Txt__c', 'Sales_Host__c.Sales_Companion_Server1_Txt__c',
    'Sales_Host__c.Sales_Computer_Type__c', 'Sales_Host__c.Sales_Computer_Name_Txt__c', 'Sales_Host__c.Sales_Contact__c', 'Sales_Host__c.Sales_Redundant_Server1_Txt__c', 'Sales_Host__c.Sales_Redundant_Server2_Txt__c'];


export default class Sales_CreateNewHostForNewButton extends NavigationMixin(LightningElement) {
    @track isModalOpen = true;
    @api recordid;
    @api licneserecordid;
    @api toollicensetype;
    @api isInternal;
    @api primaryadmincontact;       //ON License
    @api licensedusercontact;       //ON License
    @api delegatesList = [];
    @api loggedInUserId = userId;
    @api contactId = '';
    @api validContact;
    @api newHostId;
    @track isfloatRecord;
    @track isfixedRecord;
   // @api fromComponent = false;
    @track success = false;
    eventType='';
    computername;
    computertype;
    licensetype;
    primarycompid;
    compserverid2;
    compserverid1;
    redserverid2;
    redserverid1;
    //Labels
    label = {
        errorMsg,
        validUsersErrorMsg,
        Saleslicenseadminsucess
    };
  /*  handleInputFieldChange(event){
        var fieldName = event.target.fieldName;
        switch(fieldName) {
          case Sales_Computer_Name_Txt__c.fieldApiName:
            this.computername = event.target.value;
            break;
           case Sales_Computer_Type__c.fieldApiName:
            this.computertype = event.target.value;
            break;
            case Sales_License_Type__c.fieldApiName:
              this.licensetype = event.target.value;
            break;
            case Name.fieldApiName:
              this.primarycompid = event.target.value;
            break;
            case Sales_Companion_Server2_Txt__c.fieldApiName:
              this.compserverid2 = event.target.value;
            break;
            case Sales_Redundant_Server2_Txt__c.fieldApiName:
              this.redserverid2 = event.target.value;
            break;
            case Sales_Redundant_Server1_Txt__c.fieldApiName:
              this.redserverid1 = event.target.value;
            break;
            case Sales_Companion_Server1_Txt__c.fieldApiName:
              this.compserverid = event.target.value;
            break;
       
        }    
    }*/
    handleOnLoad(event) {
        console.log('In OnLoad/Init Callback');
        console.log('This==>' + this.licneserecordid);
        console.log('toollicensetype==>' + this.toollicensetype);

        //If the below method returns true -> Internal Salesforce,  else if false then -> Salesforce Community
        isCommunity()
            .then(result => {
                console.log('Is Internal Salesforce result:' + result);
                this.isInternal = result;
            })
            .catch(error => {
                this.fireToastEvent(this.label.errorMsg, error.body.message, 'error', 'dismissable');
            });

        //Fetching Current User's Contact Id
        console.log('Logged In user Id : ' + this.loggedInUserId);
        getUserDetails({ uId: this.loggedInUserId })
            .then((result) => {
                console.log('Controller result payload: ' + JSON.stringify(result));
                if (result != null) {
                    if (result.Contact != null) {
                        this.contactId = result.Contact.Id;
                    }
                    console.log('Logged In User - Contact Id: ' + this.contactId);
                }
            })
            .catch((error) => {
                this.fireToastEvent(this.label.errorMsg, error.body.message, 'error', 'dismissable');
            });

        if (this.primaryadmincontact != undefined) {
            getDelegateContactIds({ primarycontactId: this.primaryadmincontact })
                .then((result) => {
                    console.log('delegates => ' + result);
                    this.delegatesList = result;
                })
                .catch((error) => {
                    this.validContact = false;
                    this.fireToastEvent(this.label.errorMsg, error.body.message, 'error', 'dismissable');
                });
        }
    }


    handleSubmit(event) {
        const topDiv = this.template.querySelector('[data-id="focusOnErrorBannerId"]');
        topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
        let fields = event.detail.fields;
        fields.Sales_isActiveHost__c = true;

        //Validate if the Contact selected is a Primary admin / delegate admin to the primary admin on the license record or licensed user on the license record
        console.log('Selected Contact Id for host =>' + fields.Sales_Contact__c);
        //var licContactIdsMap = new Map();
        //licContactIdsMap.set('Sales_License_Primary_Admin_Contact__c', this.primaryadmincontact);
        //licContactIdsMap.set('Sales_License_Lic_User_Contact_ID__c', this.licensedusercontact);

        if (this.isInternal == true) {
            if (fields.Sales_Contact__c == this.licensedusercontact || fields.Sales_Contact__c == this.primaryadmincontact ||
                (this.delegatesList != [] && (this.delegatesList).includes(fields.Sales_Contact__c))) {
                this.validContact = true;
            } else {
                this.fireToastEvent(this.label.errorMsg, this.label.validUsersErrorMsg, 'error', 'sticky');
            }
        } else {
            this.validContact = true;
        }
//added new 
/*let hostRecord = {
    sobjectType : SALES_HOST_OBJECT.objectApiName,
            Sales_Computer_Name_Txt__c:this.computername,
            Sales_Computer_Type__c:this.computertype,
            Sales_License_Type__c:this.licensetype,
            Name                   :this.primarycompid,
            Sales_Companion_Server2_Txt__c:this.compserverid2,
            Sales_Redundant_Server2_Txt__c:this.redserverid2,
            Sales_Redundant_Server1_Txt__c:this.redserverid1,
            Sales_Companion_Server1_Txt__c:this.compserverid1,     
    
  }
  console.log('hostRecord:'+ JSON.stringify(hostRecord));
createNewHost({
    hostRecordinput: hostRecord
})*/


this.template.querySelector('lightning-record-edit-form').submit(fields);

}            



  /*  licensefileGenerationQueue() {
        licensefileGeneration({ input: this.newHostId, inputType: 'HostId', eventType:this.eventType })
            .then(result => {
                console.log('result=-->' + result);
                if (!result) {
                    console.log('inside if=-->' + result);
                    const evt = new ShowToastEvent({
                        variant: 'success',
                        title: 'Thank you. Your license file will be generated and sent to your email shortly!',
                        message: '',
                    });
                    this.dispatchEvent(evt);

                  //  if (this.fromComponent) {
                  //      this.dispatchEvent(new CustomEvent('close'));
                   // } 
                 //  console.log('isFeedbackvisible>>>'+this.isFeedbackvisible+' >>>'+this.enableFeedback);
                 //   if(this.isFeedbackvisible==true){
                 //   this.enableFeedback=true;//added for feedback
                   // alert('enableFeedback>>'+this.enableFeedback+'this.licneserecordid>>'+this.licneserecordid);
                 //   this.showmodal=false;
                   // alert('this.showmodal>>'+this.showmodal);
                  //  }
                  /*  else {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.licneserecordid,
                                objectApiName: 'Sales_Host__c', // objectApiName is optional
                                actionName: 'view'
                            }
                        });
                    }
                } else {
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        title: '',
                        message: 'An error has occured in generating license file!',
                    });
                    this.dispatchEvent(evt);
                }
            })
    }*/

    handleSuccess(event) {

    const evt = new ShowToastEvent({
      title: 'Success',
      message: this.label.Saleslicenseadminsucess,
      variant: 'success',
      mode: 'dismissable'
  });
  this.dispatchEvent(evt);
 // this.navigateToListView();
   this.handleCancel();
  }



    //UTILITY METHODS

    reloadPage() {

        setTimeout(function () {
            location.reload(true);
        }, 2000);
    }

    fireToastEvent(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    // GET VALUE METHODS

    get getContactValue() {

        if (this.isInternal == false) {  //On Community - Primary Admin Contact Field - Primary admin to be same as logged-in user contact
            return this.contactId;
        } else {                          //On Salesforce Internal - Primary Admin Contact Field - Contact can be changed either to a Primary admin / delegate admin to the primary admin on the license record or licensed user 
            //By default Primary admin contact on license will populate
            if (this.primaryadmincontact != null) {
                console.log('primaryadmincontact-->' + this.primaryadmincontact);
                return this.primaryadmincontact;
            } else if (this.licensedusercontact != null) { //If in case primary admin is blank but license has licensed user, populate that contact then by default
                console.log('licensedusercontact-->' + this.licensedusercontact);
                return this.licensedusercontact;
            }
            else {
                return null;        //else keep blank
            }
        }

    }

    get disablePrimaryAdmin() {
        if (this.isInternal == false) {        // Earlier condition -->  this.primaryadmincontact != null
            return true;        //On Community - Primary Admin Contact Field - Non Editable
        } else {
            return false;       //On Salesforce Internal - Primary Admin Contact Field - Editable
        }
    }

    get validateLicenseType() {
        if (this.toollicensetype == null) {
            this.isfixedRecord = true;
            this.isfloatRecord = true;
            return false;
        } else {
            if (this.toollicensetype == 'FIXED') {
                this.isfixedRecord = true;
            } else if (this.toollicensetype == 'FLOAT') {
                this.isfloatRecord = true;
            }
            return true;
        }
    }
    handleCancel(){
        if(this.isInternal == true){
            console.log('internal user');
            this[NavigationMixin.Navigate]({
              type: 'standard__objectPage',
              attributes: {
                  objectApiName: 'Sales_Host__c',
                  actionName: 'list'
              },
              state: 'recent'
          });  
        }
        else{
        console.log('external user');
        this.reloadPage();
        }
    }

    handleError(event){
         const evt = new ShowToastEvent({
             title: 'Error!',
             message: event.detail.detail,
             variant: 'error',
            // mode:'dismissable'
         });
         this.dispatchEvent(evt);
    }

}