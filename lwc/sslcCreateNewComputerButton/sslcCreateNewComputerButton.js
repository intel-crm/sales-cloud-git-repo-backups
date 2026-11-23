import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';


//APEX
import licensefileGeneration from '@salesforce/apex/Sales_LicenseGenIntegration_Utility.returnHostIdDetail';
//import createHostonLicenseRecord from '@salesforce/apex/Sales_LicenseRecordPageComponentsUtility.createHostonLicenseRecord';
import isCommunity from '@salesforce/apex/Sales_AddNewLicenseAdminController.isCommunity';
import getUserDetails from '@salesforce/apex/Sales_SetupHostComputerController.getUserDetails';
//import getDelegateContactIds from '@salesforce/apex/Sales_SetupHostComputerController.getDelegateContactIds';
import getFeedRecord from '@salesforce/apex/Sales_FeedbackController.getFeedRecord';//added for feedback
import checkCapablity from '@salesforce/apex/Sales_FeedbackController.checkCapablity';//added for feedback

//import createNewHost from '@salesforce/apex/sslcCreateNewComputerButton.createHost';
//import getDelegateContactIds from '@salesforce/apex/sslcCreateNewComputerButton.getDelegateContactIds';

//SCHEMA
import HOST_OBJECT from "@salesforce/schema/Sales_Host__c";

//Import the current userâ€™s ID 
import userId from '@salesforce/user/Id';

//LABELS
import errorMsg from '@salesforce/label/c.Sales_Error_Message';
import validUsersErrorMsg from '@salesforce/label/c.Sales_CreateHost_ContactErrMsg';
import SalesLicenseFileGenErrMsg from '@salesforce/label/c.Sales_LicenseFileGenErrMsg';
import Saleslicenseadminsucess from '@salesforce/label/c.Sales_license_admin_sucess';
import SalesLicGenSuccessMsg from '@salesforce/label/c.Sales_LicGenSuccessMsg';
import Sales_SuccessHostReassignment from '@salesforce/label/c.Sales_SuccessHostReassignment';
import Sales_DetermineCompType from '@salesforce/label/c.Sales_DetermineCompType';
import Sales_ComputerTypeHelpText from '@salesforce/label/c.Sales_ComputerTypeHelpText';
import Sales_ComputerNameHelpText from '@salesforce/label/c.Sales_ComputerNameHelpText';
import Sales_ComputertypeTooltipText from '@salesforce/label/c.Sales_ComputertypeTooltipText';
import Sales_CompanionComputerIdHelpText from '@salesforce/label/c.Sales_CompanionComputerIdHelpText';
import Sales_RedundantServerHelpText from '@salesforce/label/c.Sales_RedundantServerHelpText';
import Sales_CreateComputerConfirmationPage from '@salesforce/label/c.Sales_CreateComputerConfirmationPage';
import Sales_RedundantServerId2ConfirmationPage from '@salesforce/label/c.Sales_RedundantServerId2ConfirmationPage';
import Sales_CompanionComputerId2ConfirmationPage from '@salesforce/label/c.Sales_CompanionComputerId2ConfirmationPage';
import Sales_ComputerTypeConfirmationPage from '@salesforce/label/c.Sales_ComputerTypeConfirmationPage';
import Sales_PrimaryAdminConfirmationPage from '@salesforce/label/c.Sales_PrimaryAdminConfirmationPage';
import Sales_CompanionComputerId1ConfirmationPage from '@salesforce/label/c.Sales_CompanionComputerId1ConfirmationPage';
import Sales_ComputerNameConfirmationPage from '@salesforce/label/c.Sales_ComputerNameConfirmationPage';
import Sales_LicenseTypeConfirmationPage from '@salesforce/label/c.Sales_LicenseTypeConfirmationPage';
import Sales_RedundantServer1ConfirmationPage from '@salesforce/label/c.Sales_RedundantServer1ConfirmationPage';
import Sales_Cancel from '@salesforce/label/c.Sales_Cancel';
import Sales_SaveConfirmationPage from '@salesforce/label/c.Sales_SaveConfirmationPage';
import Sales_LicenseTypeToolTipComputerPage from '@salesforce/label/c.Sales_LicenseTypeToolTipComputerPage';

//FIELDS
const FIELDS = ['Sales_Host__c.Sales_License_Type__c','Sales_Host__c.Name',
    'Sales_Host__c.Sales_Companion_Server2_Txt__c', 'Sales_Host__c.Sales_Companion_Server1_Txt__c',
    'Sales_Host__c.Sales_Computer_Type__c', 'Sales_Host__c.Sales_Computer_Name_Txt__c', 'Sales_Host__c.Sales_Contact__c', 'Sales_Host__c.Sales_Redundant_Server1_Txt__c', 'Sales_Host__c.Sales_Redundant_Server2_Txt__c'];

export default class sslcCreateNewComputerButton extends NavigationMixin(LightningElement) {

    
    @api fromlac;
    @track showmodal=true;
    @api recordid;
    @track callingfronOnchange=false;
    //@api licneserecordid;
    @api toollicensetype;
    @api isInternal;
    @api primaryadmincontact;       //ON License
    @api licensedusercontact;       //ON License
    @api delegatesList = [];
    @api loggedInUserId = userId;
    @api contactId = '';
    @api validContact;
    //@api newHostId;
    @api createComputer;
    @track isfloatRecord;
    @track isfixedRecord;
    @api fromcomponent = false;
   // @api fromlicensegenerate=false;
    @track success = false;
    @track buttonClicked=false;
    //@api hostId;
    @track isspinnerOn = false;
    recordEditFormSpinner = false;
    eventType='';
    //Labels
    label = {
        errorMsg,
        validUsersErrorMsg,
        SalesLicenseFileGenErrMsg,
        Saleslicenseadminsucess,
        SalesLicGenSuccessMsg,
        Sales_SuccessHostReassignment,
		Sales_DetermineCompType,
        Sales_ComputerTypeHelpText,
        Sales_ComputerNameHelpText,
        Sales_ComputertypeTooltipText,
        Sales_CompanionComputerIdHelpText,
        Sales_RedundantServerHelpText,
        Sales_CreateComputerConfirmationPage,
        Sales_Cancel,Sales_SaveConfirmationPage,
        Sales_ComputerNameConfirmationPage,
        Sales_LicenseTypeConfirmationPage,
        Sales_RedundantServer1ConfirmationPage,
        Sales_CompanionComputerId1ConfirmationPage,
        Sales_PrimaryAdminConfirmationPage,
        Sales_ComputerTypeConfirmationPage,
        Sales_RedundantServerId2ConfirmationPage,
        Sales_CompanionComputerId2ConfirmationPage,
        Sales_LicenseTypeToolTipComputerPage
    };
    //feedback start
   @track enableFeedback=false;
   @api disablefeedback=false;
   @track getNICId;
   @track feedrec;
   @track isFeedbackvisible=false;
   @track noofdays;
   @track feedbackchatbot;
   @track eventtype;
   @track iscapablity=false;
   capablity='Generate License';
   @wire(checkCapablity, {capablity : '$capablity'})
   checkCapablity({error,data}){
       if(data){
          console.log('capability available>'+data);
           this.iscapablity=data;
           this.getFeedbackRecords();
        }
       if(error){
       }
   }
   getFeedbackRecords(){
       getFeedRecord({capablity:this.capablity})
           .then((result) => {
               this.feedrec = result;
               console.log('feed back records length>>'+ JSON.stringify(this.feedrec));
               console.log("This is data"+this.feedrec.Last_Feedback_Captured__c);
               this.noofdays=this.feedrec.Last_Feedback_Captured__c;
               this.eventType=this.feedrec.Event_Type__c;
               this.feedbackchatbot=this.feedrec.Chatbot_Feedback__c;
               console.log("this.noofdays>>"+this.noofdays);
               if(this.noofdays>89 && this.iscapablity==true && (this.eventType='Event Feedback')&& (this.feedbackchatbot=false)){
                this.isFeedbackvisible=true;
                console.log('feedback visible');
               } 
                else{
                   console.log('inside else isFeedbackvisible>>>'+this.isFeedbackvisible);   
                   this.isFeedbackvisible=false;
               }
               
           })
           .catch((error) => {
               console.log('imperative existing feedback>>>'+JSON.stringify(error) +'this.iscapablity>>'+this.iscapablity);
               if(this.iscapablity==true){
                   this.isFeedbackvisible=true;
               }
           });
   }
   //feedback end
    handleOnLoad(event) {

        //console.log(this.fromlicensegenerate+'fromlicensegenerate');
      
        console.log('In OnLoad/Init Callback');
       // console.log('This==>' + this.licneserecordid);
        console.log('toollicensetype==>' + this.toollicensetype);
       // this.validateLicenseType();

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
                    this.fireToastEvent(this.label.errorMsg, error.body.message, 'info', 'dismissable');
                });
        }

        if(this.toollicensetype != undefined){
            if(this.toollicensetype == 'FIXED'){
                this.toollicensetype = 'FIXED';
            }
            else if (this.toollicensetype == 'N-A' || this.toollicensetype == 'FLOAT'){
                this.toollicensetype = 'FLOAT';
            }
            else if (this.toollicensetype == 'NEUTRAL'){
                this.toollicensetype = null;//'FIXED or FLOAT';    
            }
        }
        
        //Changes made by -Bishal Singh
        this.handleHelpText();
        console.log('this.recordEditFormSpinner1::');
    }

    //Changes made by Bishal Singh
    handleHelpText(){
        const style = document.createElement('style');
        style.innerText = ".newHostInputFieldFormat div.slds-form-element__icon { display: none; }";
        let qs = this.template.querySelectorAll('.newHostInputFieldFormat');
        for (let i = 0; i < qs.length; i++) {
            const element = qs[i];
            element.appendChild(style);
        }
        this.recordEditFormSpinner = true;
        console.log('this.recordEditFormSpinner2::');
        console.log(this.recordEditFormSpinner);
    }

    handleSubmit(event) { 
        console.log('submit');
        this.isspinnerOn = true;
        //added for new button
        //event.preventDefault();
        
        if(this.fromlicensegenerate==true){

            const topDiv = this.template.querySelector('[data-id="focusOnErrorBannerId"]');
            topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
            const fields = event.detail.fields;
            fields.Sales_Host_Is_Created_From_Custom_Page__c=true;
            
            //Add by Tejaswini
            if(fields.Sales_Computer_Type__c=='NIC ID'){
                fields.Name = this.getNICId; 
               
            }

    
            console.log('new Fields'+fields.Sales_Host_Is_Created_From_Custom_Page__c);
            fields.Sales_isActiveHost__c = true;
            if(this.primaryadmincontact!=undefined){
                fields.Sales_Contact__c = this.primaryadmincontact;
            }
            console.log('delegatesList => ' + this.delegatesList);
            
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
                    //event.preventDefault();
                    console.log('183');
                    this.fireToastEvent(this.label.errorMsg, this.label.validUsersErrorMsg, 'info', 'sticky');
                }
            } else {
                this.validContact = true;
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
        else{
            this.buttonClicked=true;
            console.log("190");
            let fields = event.detail.fields;
            if(this.primaryadmincontact!=undefined){
                fields.Sales_Contact__c = this.primaryadmincontact;
            }
            fields.Sales_Host_Is_Created_From_Custom_Page__c=true;
            console.log('new Fields -else'+fields.Sales_Host_Is_Created_From_Custom_Page__c);
            this.template.querySelector('lightning-record-edit-form').submit(fields);
                     
             }
        
      
    }
   handleError(){
			 
			   this.buttonClicked=false;
               this.isspinnerOn = false;
	 }

    

    handleSuccess(event) {
        let currhostId = event.detail.id;
        const selectedEvent = new CustomEvent("success", { detail : {"HostId" : currhostId}});
        this.dispatchEvent(selectedEvent);
        this.isspinnerOn = false;
        console.log('success');
        //hostId = event.detail.id;
        //console.log(hostId);
       // this.redirectPage();
       console.log('redirect');
       //window.location.reload()
       
            /* var compDetails = {
                 componentDef: "c:page2",
                 attributes: {
                    //Value you want to pass to the next lwc component
                    currhostId : event.detail.id         
    
                }
                               
             };
              // Base64 encode the compDefinition JS object
              var encodedCompDetails = btoa(JSON.stringify(compDetails));
              this[NavigationMixin.Navigate]({
                  type: 'standard__webPage',
                  attributes: {
                      url: '/one/one.app#' + encodedCompDetails
                  }                  
              });*/
             
              //eval("$A.get('e.force:refreshView').fire();")
        /*this.buttonClicked=true;
        console.log('button disabled'+this.buttonClicked);
        //if(this.fromlicensegenerate==true){
        this.newHostId = event.detail.id;
        var results;
        if (this.validContact == true) {
           // createNewHost({ hostId: this.newHostId})
           createNewHost()
                .then(result => {
                    console.log('license type'+this.toollicensetype);
                    console.log('contactid'+this.getContactValue);
                    console.log('license type');
                    console.log('Primary Computer ID');
                    results = result;
                    console.log('createhost op'+result);
                    if(results.includes(this.label.Sales_SuccessHostReassignment)){

                    console.log('Order record' + result);
                    //this.licensefileGenerationQueue();
                    }
                    else{  
                        this.buttonClicked=false;
                        console.log('create host else line 266');
                        const evt = new ShowToastEvent({
                                variant:'info',
                                title: result,
                                message: '',
                        });
                        this.dispatchEvent(evt);
                    }
                  //  alert('before if this.fromComponent>>>'+this.fromComponent);
                    /*if (!this.fromComponent) {
                        alert('this.fromComponent>>>'+this.fromComponent);
                        this.reloadPage();
                    }*/
                /*})
                .catch(error => {
                    this.buttonClicked=false;
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        title: 'Error',
                        message: ''
                    });
                    this.dispatchEvent(evt);
                })
        }
    //}
    else{
        console.log('button disabled'+this.buttonClicked);
        this.buttonClicked=true;
        const evt = new ShowToastEvent({
            title: 'Success',
            message: this.label.Saleslicenseadminsucess,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
       // this.navigateToListView();
         this.handleCancelNew();
    }*/

    }

    handleCancelNew() {
        let evt=new CustomEvent('cancel');
        this.dispatchEvent(evt);
        // navigate to order record page
        /*console.log("createComputer"+ this.createComputer);
        console.log('fromcmp:'+this.fromcomponent);
      
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    //recordId: this.licneserecordid,
                    objectApiName: 'Sales_License__c', // objectApiName is optional
                    actionName: 'view'
                }
            });*/
           // this.redirectPage();
        }

    onchangePrimaryAdmin(event){
        this.primaryadmincontact = event.target.value;
    }

    //Changes by Tejaswini
    onchangeNICId(event){
        this.getNICId = event.target.value;
        this.getNICId = this.getNICId.replace(/-/g, "");
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
        console.log('this.contactIddd ' +this.contactId);
        console.log('isInternalll ' +this.isInternal);
        if (this.isInternal == false) {  //On Community - Primary Admin Contact Field - Primary admin to be same as logged-in user contact
            return this.contactId;
        } else {  
            console.log('Inside primaryadmincontact');                        //On Salesforce Internal - Primary Admin Contact Field - Contact can be changed either to a Primary admin / delegate admin to the primary admin on the license record or licensed user 
            //By default Primary admin contact on license will populate
            if (this.primaryadmincontact != null) {
                console.log('Inside primaryadmincontacttt');    
                console.log('primaryadmincontact-->' + this.primaryadmincontact);
                return this.primaryadmincontact;
            } else if (this.licensedusercontact != null) { //If in case primary admin is blank but license has licensed user, populate that contact then by default
                console.log('Inside licenseadmincontacttt');    
                console.log('licensedusercontact-->' + this.licensedusercontact);
                return this.licensedusercontact;
            }
            else {
                console.log('nulll');
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
          console.log('toollicensetype==>' + this.toollicensetype);

           this.isfixedRecord = false;
            this.isfloatRecord = false;
          /*  if (this.toollicensetype == 'FIXED') {
                this.isfixedRecord = true;
            } else if (this.toollicensetype == 'FLOAT') {
                this.isfloatRecord = true;
            }*/
            return false;
        }
        else if(this.callingfronOnchange==true){
            console.log('In else if');
            return false;
        }else {
            console.log('In else');
            if (this.toollicensetype == 'FIXED') {
                this.isfixedRecord = true;
            } else if (this.toollicensetype == 'FLOAT') {
                this.isfloatRecord = true;
            }
            else if(this.toollicensetype != 'FIXED' || this.toollicensetype != 'FLOAT'){
                 return false;
            }
            return true;
        }
    }

    /*handleCancelNew(){
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
    }*/
    handleOnChange(event){
        this.callingfronOnchange=true;
        this.toollicensetype= event.target.value;
        if (this.toollicensetype == 'FIXED') {
            this.isfixedRecord = true;
            this.isfloatRecord = false;
        } else if (this.toollicensetype == 'FLOAT') {
            this.isfloatRecord = true;
            this.isfixedRecord = false;
        }
        else{
            this.isfixedRecord = false;
            this.isfloatRecord = false;
        }

    }
 /*   openPage(hostId){
        console.log('origin'+window.location.origin);
        if(JSON.stringify(window.location.origin ).includes('.lightning.'))
        { console.log(window.location.origin);
            setTimeout(function() {
                window.open(window.location.origin+'/lightning/r/Sales_Host__c/' + hostId+'/related/License_Generation_Req_Logs__r/view', '_top');        

       }, 4000);  
            }else{
                //console.log('final approach'+JSON.parse(JSON.stringify(JSON.parse(JSON.stringify(window.location.href))).split('s/')[0]+'"')+hostId, '_blank');
                setTimeout(function() {
                    window.open(window.location.origin+'/psg/s/relatedlist/' + hostId+'/License_Generation_Req_Logs__r', '_top'); 
    
           }, 4000);
              //  window.open(JSON.parse(JSON.stringify(JSON.parse(JSON.stringify(window.location.href))).split('s/')[0]+'"')+hostId, '_top');
            }    
        
        }*/
        redirectPage(){
            console.log('redirect');
             var compDetails = {
                 componentDef: "c:page2",
                
             };
              // Base64 encode the compDefinition JS object
              var encodedCompDetails = btoa(JSON.stringify(compDetails));
              this[NavigationMixin.Navigate]({
                  type: 'standard__webPage',
                  attributes: {
                      url: '/one/one.app#' + encodedCompDetails
                  }
              });
            
     }
}