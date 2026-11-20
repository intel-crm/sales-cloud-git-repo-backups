import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import fetchComputerDetails from '@salesforce/apex/Sales_LicenseRecordPageComponentsUtility.retriveComputerDetails';
/*import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import licensefileGeneration from '@salesforce/apex/Sales_LicenseGenIntegration_Utility.returnHostIdDetail';
import hostReassignment from '@salesforce/apex/Sales_LicenseRecordPageComponentsUtility.hostReassignment';
//import isCommunity from '@salesforce/apex/Sales_AddNewLicenseAdminController.isCommunity';
import checkisexistingLicense from '@salesforce/apex/Sales_LicenseRecordPageComponentsUtility.askForReassignment';
import validateLicenseType from '@salesforce/apex/Sales_LicenseRecordPageComponentsUtility.LicenseTypeCheck';

import { CloseActionScreenEvent } from 'lightning/actions';
import getFeedRecord from '@salesforce/apex/Sales_FeedbackController.getFeedRecord';//added for feedback
import checkCapablity from '@salesforce/apex/Sales_FeedbackController.checkCapablity';//added for feedback
import SalesSerialError from '@salesforce/label/c.Sales_SerialError';
import Sales_Statuserror  from '@salesforce/label/c.Sales_LicenseStatusError';
import SalesAddSeatRenewError from '@salesforce/label/c.Sales_AddSeatRenewError';
import Sales_SuccessHostReassignment from '@salesforce/label/c.Sales_SuccessHostReassignment';
//import Sales_Err from '@salesforce/apex/Sales_FeedbackController.Sales_Err';//added for feedback
import Sales_genliconlicrecord from '@salesforce/label/c.Sales_genliconlicrecord';
import Sales_Errwhilegenlicfile from '@salesforce/label/c.Sales_Errwhilegenlicfile';
import Sales_Assigncomp from '@salesforce/label/c.Sales_Assigncomp';
import Sales_Lictooltyp from '@salesforce/label/c.Sales_Lictooltyp';
import Sales_OrderClose from '@salesforce/label/c.Sales_OrderClose';
import Sales_genlic from '@salesforce/label/c.Sales_genlic';
import Sales_creatnewcomp from '@salesforce/label/c.Sales_creatnewcomp';
import Sales_AccessCheckMsg from '@salesforce/label/c.Sales_AccessCheckMsg';

//import Sales_addnewcomp from '@salesforce/label/c.Sales_addnewcomp';
//import Sales_Assignexisting from '@salesforce/label/c.Sales_Assignexisting';
//import Sales_compname from '@salesforce/label/c.Sales_compname';
//import Sales_Generate from '@salesforce/label/c.Sales_Generate';
//import Sales_ConfirmationTitle from '@salesforce/label/c.Sales_ConfirmationTitle';
//import Sales_Cancel from '@salesforce/label/c.Sales_Cancel';
//import Sales_Err from '@salesforce/label/c.Sales_Err';
//import userId from '@salesforce/user/Id';
//import validateUserAccess from '@salesforce/apex/Sales_ValidateUserEditAccess.validateUserAccess';
//import BypassRehostForCustomOps from '@salesforce/apex/Sales_ValidateUserEditAccess.BypassRehostForCustomOps';
*/
//const FIELDS = [ 'Sales_License__c.Id', 'Sales_License__c.Sales_License_Web_Display_Flag__c','Sales_License__c.Sales_Tool_License_Type__c','Sales_License__c.Sales_License_Activation_Code__c','Sales_License__c.Sales_License_Host_Node_Id__c','Sales_License__c.Sales_License_Primary_Admin_Contact__c','Sales_License__c.Sales_License_Lic_User_Contact_ID__c','Sales_License__c.Sales_License_Type__c','Sales_License__c.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c','Sales_License__c.Sales_License_Status__c'];
export default class Sales_GenerateLicense_OnLicenseRecord extends NavigationMixin(LightningElement){
    /*@api fromlac;
    @track userId=userId;
    @track hostlist;
    @api licenserecordid;
    @track isvisibleModal;
    @track isLoaded;
    @api licensetypevalue;
    @api iscreateNewHost=false;
    @api primarycontact;
    @api tooltype;//added for tool type
    @api licusercontact;
    @api recordId;
    @track showModal=true;
    @api activationcode;
    @api licneserecordid;
    @api isnotexistingHost;
    @api existingcomputername;
    @api item;
    @api activatecodeonload;
    @api successmsg;
    @track validateExistingLicenseHost=false;
    @api hostValue;
    @api hostid;
    @api licenseType;
    @track createComputer= false;
    @api sendactivationcodetochatmsg;
    @api successResponse;
    @api toollicensetype;
    @api primaryadmincontact;
    @api showMessage=false;
    @api licenseTypeMatch;
    @api isInternal;
    @api webdisplayFlag;
    @api fromcmp;
    @api licgenerate;
    @api licstatus;
    eventType='';
     //feedback start
     @track enableFeedback=false;
     @api disablefeedback=false;
     @track feedrec;
     @track isFeedbackvisible=false;
     @track noofdays;
     @track feedbackchatbot;
     @track eventtype;
     @track iscapablity=false;
     @track licensestatus;
     @track buttonClicked=false;//added for disabling user from clicking generate license button twice
	 @track bypassRehostStatus=false;
	 
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
    hostNameInput;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    license;

    label={
        SalesSerialError,SalesAddSeatRenewError,Sales_SuccessHostReassignment,
        Sales_Err,
Sales_genliconlicrecord,
Sales_Errwhilegenlicfile,
Sales_Assigncomp,
Sales_Lictooltyp,
Sales_OrderClose,
Sales_genlic,
Sales_creatnewcomp,
Sales_addnewcomp,
Sales_Assignexisting,
Sales_compname,
Sales_Generate,
Sales_Cancel,
Sales_ConfirmationTitle,
Sales_Statuserror,
Sales_AccessCheckMsg
    }

    connectedCallback() {
        /*BypassRehostForCustomOps()
            .then(result => {
                this.bypassRehostStatus = result;
                console.log('Output Of Bypass logic outer: '+result);

            })
            .catch(error => {
                //this.error = error;
            });
        this.validateUserAccessLogic();
     console.log('tooltype'+this.tooltype+'primarycontact'+this.primarycontact+'licneserecordid'+this.licneserecordid+'licensetypevalue'+this.licensetypevalue+'activatecodeonload'+this.activatecodeonload+'license status'+this.licensestatus);
      //  this.handleOnLoad();
  // this.recordId=this.licenserecordid;
     this.licgenerate=true;
        console.log('in init');
        isCommunity()
          .then(result => {
            console.log('result:'+result);
            this.isInternal = result;             
      })
      .catch(error => {
        const evt = new ShowToastEvent({
          title: this.label.Sales_Err,
          message: error.body.message,
          variant: 'error',
          mode: 'dismissable'
      });
      this.dispatchEvent(evt);
      });*/   
      /*}

    handleOnLoad(){
     this.isLoaded = true;
	 //this.validateUserAccessLogic();
        //INITIALIZATION
        console.log('this.license.data==>'+this.license.data+this.isLoaded);
        if(this.license.data!=undefined){
             this.isvisibleModal = true;
            this.primarycontact = this.license.data.fields.Sales_License_Primary_Admin_Contact__c.value;
                        this.licusercontact  = this.license.data.fields.Sales_License_Lic_User_Contact_ID__c.value;
            this.licenseType = this.license.data.fields.Sales_Tool_License_Type__c.value;
            if(this.licenseType == 'FIXED'){
                this.liceseType = 'FIXED';
            }
            else if (this.licenseType == 'N-A' || this.licenseType == 'FLOAT'){
                this.licenseType = 'FLOAT';
            }
            else if (this.licenseType == 'NEUTRAL'){
                this.licenseType = null;//'FIXED or FLOAT';    
            }
    
            this.licneserecordid= this.recordId;
            if(this.license.data.fields.Sales_License_Host_Node_Id__c.value!=null){
                this.existingcomputername = this.license.data.fields.Sales_License_Host_Node_Id__c.value;
            }else {
                this.isnotexistingHost=true;
            }
            this.webdisplayFlag = this.license.data.fields.Sales_License_Web_Display_Flag__c.value;
            this.activatecodeonload=this.license.data.fields.Sales_License_Activation_Code__c.value;   
            this.licensestatus=this.license.data.fields.Sales_License_Status__c.value;                                               
            this.recordId=this.license.data.fields.Id.value;                                  
        }
        else if(this.license.data==undefined && this.licensetypevalue!=undefined){
            console.log('On load license type>>'+this.licensetypevalue);
            this.licenseType = this.licensetypevalue;
            if(this.licenseType == 'FIXED'){
                this.liceseType = 'FIXED';
            }
            else if (this.licenseType == 'N-A' || this.licenseType == 'FLOAT'){
                this.licenseType = 'FLOAT';
            }
            else if (this.licenseType == 'NEUTRAL'){
                this.licenseType = null;//'FIXED or FLOAT';    
            }
        }
    }

licensefileGenerationQueue(){
    var hostId=''; 
    if(this.selectedhostId!=null && this.selectedhostId!=undefined && this.selectedhostId!=''){
        hostId = this.selectedhostId;
    }else if(this.existingcomputername!=null && this.existingcomputername!=undefined && this.existingcomputername!=''){
        hostId = this.existingcomputername;
    }
    
    if(hostId!=''){
       
        licensefileGeneration({input :hostId ,inputType : 'HostId',  eventType:this.eventType})
            .then(result => {
                if(!result){
                    const evt = new ShowToastEvent({
                        variant:'success',
                        title: this.label.Sales_genliconlicrecord,
                        message: '',
                    });
                    this.dispatchEvent(evt);
                    console.log('isFeedbackvisible>>>'+this.isFeedbackvisible+'this.enableFeedback >>>'+this.enableFeedback+'this.disablefeedback>>>'+this.disablefeedback);
                    //added for feedback
                    if(this.isFeedbackvisible==true && this.disablefeedback==false && (this.fromlac==false || this.fromlac==undefined)){
                        console.log('inside enable feedback>>>');
                        this.enableFeedback=true;
                        this.showModal=false;
                    }
                    else{
                        console.log('no Feedback>>>>>');
                        if(this.fromcmp==true){
                            console.log('fromcmp is true');
                            this.fromComponentValue = false;
                            this.closeModel=false;
                         //this.dispatchEvent(new CloseActionScreenEvent());
                          
                            this.dispatchEvent(new CustomEvent('close'));
                            
                        }        
                        else{
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: this.licneserecordid,
                                    objectApiName: 'Sales_License__c', // objectApiName is optional
                                    actionName: 'view'
                                }
                            });
                        //  alert('before reload');
                      this.reloadPage();
                        //this.openPage(hostId);
                        }
                    }
                    /*
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.licneserecordid,
                            objectApiName: 'Sales_License__c', // objectApiName is optional
                            actionName: 'view'
                        }
                    });*/
                    
                /*}else{
                    this.buttonClicked=false;
                    const evt = new ShowToastEvent({
                        variant:'error',
                        title: this.label.Sales_Errwhilegenlicfile,
                        message: '',
                    });
                    this.dispatchEvent(evt);
                }
            })
        }
}

/*validateLicenseType(){
// licenseID : this.licneserecordid
//host ID  : this.selectedhostId
}*/

/*handleHostChange(event){
    this.selectedhostId = event.target.value;
    this.buttonClicked=false;
}

handleSubmit(event){
    this.buttonClicked=true;
    console.log('buton disabled'+this.buttonClicked);
    console.log('licstatus ' + this.licstatus);
    console.log('fromlac ' + this.fromlac);
    if(this.fromlac == true){
        this.licensestatus = this.licstatus;
    }
    //console.log(JSON.stringify(this.license)+'license');
   // console.log('this.license.data'+this.license.data.fields);
  if(this.license.data !=null){
  console.log('licene'+JSON.stringify(this.license));
  if((this.license.data.fields.Sales_License_Type__c.value =='Add Seat') || (this.license.data.fields.Sales_License_Type__c.value =='Renewal')|| (this.license.data.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value=='ADD SEAT')||(this.license.data.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value =='RENEWAL'))                 
  {      this.buttonClicked=false;  
        const evt = new ShowToastEvent({
          variant: 'error',
          title: this.label.Sales_Err,
          mode: 'sticky',
          message: this.label.SalesAddSeatRenewError,
        });
        this.dispatchEvent(evt);
    }
    else{
      this.generateLicenselogic();
    }
  }

    else 
    {   
    console.log('this.tooltype'+this.tooltype);
    if(this.tooltype=='ADD SEAT' ||this.tooltype=='RENEWAL' ){
        this.buttonClicked=false;
        const evt = new ShowToastEvent({
            variant: 'error',
            title: this.label.Sales_Err,
            mode: 'sticky',
            message: this.label.SalesAddSeatRenewError,
          });
          this.dispatchEvent(evt);
    }
  else{
    this.generateLicenselogic();
  }

   /* console.log('inside handle SUbmit recordId'+this.licneserecordid);
    console.log('this.selectedhostId '+this.selectedhostId);
    console.log(' this.existingcomputername '+ this.existingcomputername);

    if(this.activatecodeonload==undefined || this.webdisplayFlag==false){
        const evt = new ShowToastEvent({
            title: 'Error',
            message: this.label.SalesSerialError,//SalesAddSeatRenewError,
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }
    else if(this.selectedhostId==undefined && this.existingcomputername!=undefined){
            this.licensefileGenerationQueue();
    }
    else if(this.existingcomputername==undefined && this.selectedhostId==undefined){
        const evt = new ShowToastEvent({
            variant:'error',
            title: 'Please assign a computer to generate the license',
            mode: 'sticky',
            message: '',
        });
        this.dispatchEvent(evt);
    }
    else if(this.selectedhostId!=null && this.selectedhostId!=undefined && this.selectedhostId!=''){
        this.hostValue = this.selectedhostId;
        this.validateExistingLicenseHost = false;//resetting var value
        //method call
        validateLicenseType({hostId :this.selectedhostId, licenseId: this.licneserecordid})
        .then(result => {
            if(result==true){
                if(this.licenseType=='FIXED'){//for fixed license, check if host is associated to some another license;
                    checkisexistingLicense({hostId :this.hostValue, licenseId: this.licneserecordid})
                    .then(result => {
                        if(result==true){//if host is assgined to some other license, open a confirmation prompt
                                this.validateExistingLicenseHost = true;
                            }else{
                                this.validateExistingLicenseHost = false;
                                this.hostReassignmentLogic();
                            }
                        })
                    }else{
                        this.validateExistingLicenseHost = false;
                        this.hostReassignmentLogic();
                    }
            }
            else{
                const evt = new ShowToastEvent({
                    variant:'error',
                    title: 'Error!',
                    mode: 'sticky',
                    message: 'For License Tool Type as FIXED, you can select Host with FIXED License Type / For License Tool Type as FLOAT or N-A, you can select Host with FLOAT License Type & For License Tool Type as NEUTRAL, you can select Host with FIXED/FLOAT License Type.',
                });
                this.dispatchEvent(evt);
            }
        })
        .catch((error) => {
            this.error = error;
            this.soldAccount = undefined;
            const evt = new ShowToastEvent({
                title: 'Error!',
                message: error.body.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        });
    }
}*//*
}
}

generateLicenselogic(){

    console.log('inside handle SUbmit recordId'+this.licneserecordid);
    console.log('this.selectedhostId '+this.selectedhostId);
    console.log(' this.existingcomputername '+ this.existingcomputername);
    console.log('error message ' + this.licensestatus);
    if(this.licensestatus=='Renewals Applied' || this.licensestatus=='Cancelled') 
    { this.buttonClicked=false;
        const evt = new ShowToastEvent({
        title: this.label.Sales_Err,
        message: this.label.Sales_Statuserror,
        variant: 'error',
        mode: 'sticky'
    });
    this.dispatchEvent(evt);
    }

    
	else if((this.activatecodeonload==undefined || this.webdisplayFlag==false) && this.bypassRehostStatus==false){
			this.buttonClicked=false;
			const evt = new ShowToastEvent({
				title: this.label.Sales_Err,
				message: this.label.SalesSerialError,//SalesAddSeatRenewError,
				variant: 'error',
				mode: 'sticky'
        });
        this.dispatchEvent(evt);
    
		}
       
    else if(this.selectedhostId==undefined && this.existingcomputername!=undefined){
            this.licensefileGenerationQueue();
    }
    else if(this.existingcomputername==undefined && this.selectedhostId==undefined){
        this.buttonClicked=false;
        const evt = new ShowToastEvent({
            variant:'error',
            title: this.label.Sales_Assigncomp,
            mode: 'sticky',
            message: '',
        });
        this.dispatchEvent(evt);
    }
    else if(this.selectedhostId!=null && this.selectedhostId!=undefined && this.selectedhostId!=''){
        this.hostValue = this.selectedhostId;
        this.validateExistingLicenseHost = false;//resetting var value
        //method call
        validateLicenseType({hostId :this.selectedhostId, licenseId: this.licneserecordid})
        .then(result => {
            if(result==true){
                if(this.licenseType=='FIXED'){//for fixed license, check if host is associated to some another license;
                    checkisexistingLicense({hostId :this.hostValue, licenseId: this.licneserecordid})
                    .then(result => {
                        console.log('result->'+result);
                        if(result==true){//if host is assgined to some other license, open a confirmation prompt
                                this.validateExistingLicenseHost = true;
                            }else{
                                console.log('line 403');
                                this.validateExistingLicenseHost = false;
                                this.hostReassignmentLogic();
                            }
                        })
                    }else{
                        console.log('line 408');
                        this.validateExistingLicenseHost = false;
                        this.hostReassignmentLogic();
                        
                    }
            }
            else{ this.buttonClicked=false; 
                const evt = new ShowToastEvent({
                    variant:'error',
                    title: this.label.Sales_Error_Message,
                    mode: 'sticky',
                    message: this.label.Sales_Lictooltyp
                });
                this.dispatchEvent(evt);
            }
        })
        .catch((error) => {
            this.error = error;
            this.soldAccount = undefined;
            this.buttonClicked=false;
            const evt = new ShowToastEvent({
                title: this.label.Sales_Error_Message,
                message: error.body.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        });
    
   }
}


hostReassignmentLogic(){
    hostReassignment({hostId: this.selectedhostId, licenseId : this.licneserecordid})
                .then(result => {
                var output = result;
                           console.log('output'+output);
                    if(output.includes(this.label.Sales_SuccessHostReassignment)){
                                                console.log('line445');
                        this.licensefileGenerationQueue();  
                    //    alert('calling licensefileGenerationQueue');
                        //this.reloadPage(); //commented to show the feedback
                    }else{
                        this.buttonClicked=false;                   
                        console.log('line450');
                    const evt = new ShowToastEvent({
                            variant:'info',
                            title: result,
                            message: '',
                    });
                    this.dispatchEvent(evt);
                   
                }
    })
}

    get getHostValue(){
        console.log('this.existingcomputername-->'+this.existingcomputername);
        if(this.existingcomputername!=undefined && this.existingcomputername!=null && this.existingcomputername!=''){
            if(this.license.data!=undefined){
                return this.license.data.fields.Sales_License_Host_Node_Id__c.value;
            }else{
                return this.existingcomputername;
            }
            
        }
    }

    handleCancel(){
        if(this.fromcmp==true){
            console.log('fromcmp is true');
            this.fromComponentValue = false;
            this.closeModel=false;
         //this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(new CustomEvent('close'));
        }      
        else if(this.licgenerate==true){
            if(this.isInternal == true){
            console.log('internal user');
             this.reloadPage();
            this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.licneserecordid,
                objectApiName: 'Sales_License__c', // objectApiName is optional
                actionName: 'view'
            }
             });
            }
            else{
                this.reloadPage();
            }
            console.log('licgenerate is true');
            this.fromlicensegenerate = false;
            this.closeModel=false;
         //this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(new CustomEvent('close'));
           
        }      
      /*  else if(this.isInternal==true){
           // alert('before reload');
           this.dispatchEvent(new CloseActionScreenEvent());
           //this.dispatchEvent(new CustomEvent('quickactionclose'));
           this.reloadPage();
           this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.licneserecordid,
                objectApiName: 'Sales_License__c', // objectApiName is optional
                actionName: 'view'
            }
        });
        }*/
       /*else{
        // navigate to order record page
        this[NavigationMixin.Navigate]({
           type: 'standard__recordPage',
           attributes: {
               recordId: this.licneserecordid,
               objectApiName: 'Sales_License__c', // objectApiName is optional
               actionName: 'view'
           }
       });
    }
   }

    reloadPage(){

        setTimeout(function() {
        location.reload(true);
        }, 2000);    
    }

    createNewComputer(event){
				if(this.fromlac == true){
        this.licensestatus = this.licstatus;
    }
        if(this.license.data !=null){
            console.log('licene'+JSON.stringify(this.license));
            if((this.license.data.fields.Sales_License_Type__c.value =='Add Seat') || (this.license.data.fields.Sales_License_Type__c.value =='Renewal')|| (this.license.data.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value=='ADD SEAT')||(this.license.data.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value =='RENEWAL'))
            {     this.buttonClicked=false;
                  const evt = new ShowToastEvent({
                    variant: 'error',
                    title: 'Error',
                    mode: 'sticky',
                    message: this.label.SalesAddSeatRenewError,
                  });
                  this.dispatchEvent(evt);
              }
              else{
                this.createcomputerlogic();
              }
            }
          
              else 
              {   
              console.log('this.tooltype'+this.tooltype);
              if(this.tooltype=='ADD SEAT' ||this.tooltype=='RENEWAL' ){
                this.buttonClicked=false;
                  const evt = new ShowToastEvent({
                      variant: 'error',
                      title: 'Error',
                      mode: 'sticky',
                      message: this.label.SalesAddSeatRenewError,
                    });
                    this.dispatchEvent(evt);
              }
            else{
              this.createcomputerlogic();
            }

        }

       /* console.log('this.licneserecordid=>'+this.licneserecordid);
        console.log('this.licensetypevalue=>'+this.licensetypevalue);
        if(this.licensetypevalue!=null){
            this.licenseType = this.licensetypevalue;
        }
        if(this.licenseType == 'FIXED'){
            this.liceseType = 'FIXED';
        }
        else if (this.licenseType == 'N-A' || this.licenseType == 'FLOAT'){
            this.licenseType = 'FLOAT';
        }
        else if (this.licenseType == 'NEUTRAL'){
            this.licenseType = null;//'FIXED or FLOAT';    
        }
    
        if(this.activatecodeonload==undefined || this.webdisplayFlag==false){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: this.label.SalesSerialError,//SalesAddSeatRenewError,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        }
        else{           
                           
            if(this.isInternal == true && this.fromcmp == false){
               console.log('I am here');
                var compDetails = {
                    componentDef: "c:salesCreateNewHost",
                    attributes: {
                        //Value you want to pass to the next lwc component
                        propertyValue: "500",
                        licneserecordid: this.licneserecordid,
                        toollicensetype : this.licenseType,
                        primaryadmincontact : this.primarycontact,
                        licensedusercontact : this.licusercontact,
                        showmodal:true                        
        
                    }
                };
                // Base64 encode the compDefinition JS object
                var encodedCompDetails = btoa(JSON.stringify(compDetails));
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/one/one.app#' + encodedCompDetails
                    }
                });
            }else{
                console.log('@@@@ in else');
            this.createComputer = true;
            //this.showModal=false
            }
        }*/

    /*}

createcomputerlogic(){
    
    console.log('this.licneserecordid=>'+this.licneserecordid);
    console.log('this.licensetypevalue=>'+this.licensetypevalue);
    if(this.licensetypevalue!=null){
        this.licenseType = this.licensetypevalue;
    }
    if(this.licenseType == 'FIXED'){
        this.liceseType = 'FIXED';
    }
    else if (this.licenseType == 'N-A' || this.licenseType == 'FLOAT'){
        this.licenseType = 'FLOAT';
    }
    else if (this.licenseType == 'NEUTRAL'){
        this.licenseType = null;//'FIXED or FLOAT';    
    }
    console.log('error message');
    if(this.licensestatus=='Renewals Applied' || this.licensestatus=='Cancelled') 
    {  this.buttonClicked=false; 
        const evt = new ShowToastEvent({
        title: this.label.Sales_Err,
        message: this.label.Sales_Statuserror,
        variant: 'error',
        mode: 'sticky'
    });
    this.dispatchEvent(evt);
    }


    
	else if((this.activatecodeonload==undefined || this.webdisplayFlag==false) && this.bypassRehostStatus==false){
        this.buttonClicked=false; 
			const evt = new ShowToastEvent({
				title: 'Error',
				message: this.label.SalesSerialError,//SalesAddSeatRenewError,
				variant: 'error',
				mode: 'sticky'
			});
			this.dispatchEvent(evt);
       
       
		}
 
    else{           
                       
        if(this.isInternal == true && this.fromcmp == false){
           console.log('I am here');
            var compDetails = {
                componentDef: "c:salesCreateNewHost",
                attributes: {
                    //Value you want to pass to the next lwc component
                    propertyValue: "500",
                    licneserecordid: this.licneserecordid,
                    toollicensetype : this.licenseType,
                    primaryadmincontact : this.primarycontact,
                    licensedusercontact : this.licusercontact,
                    showmodal:true                        
    
                }
            };
            // Base64 encode the compDefinition JS object
            var encodedCompDetails = btoa(JSON.stringify(compDetails));
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/one/one.app#' + encodedCompDetails
                }
            });
        }else{
            console.log('@@@@ in else');
        this.createComputer = true;
        //this.showModal=false
        }
    }

}
   cancelEvent(event){
    console.log('cancel event');
    //event.stopPropogation();
    this.createComputer = false;
     }

    closeEvent(event){
        console.log('Event Received');
        //event.stopPropogation();
        this.createComputer = false;
        //this.fromcmp = false;
        //this.closeModel=false;
        //this.licgenerate=false;
        //this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new CustomEvent('close'));
       }
    
    inputChange(event){
        this.hostNameInput = event.target.value;
    }
   /* openPage(hostId){
        console.log('origin'+window.location.origin);
        if(JSON.stringify(window.location.origin ).includes('.lightning.'))
        { console.log(window.location.origin);
            setTimeout(function() {
               // window.open(window.location.origin+'/' + hostId, '_blank');  

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


/*validateUserAccessLogic(){
    console.log('824');
    validateUserAccess({userID: this.userId, recordId : this.recordId})
                .then((result) =>{
                    console.log('result ='+result);
					if(result==false){
						    console.log('user doesnt have access to the record');
							//this.closeQuickAction();
                            const evt = new ShowToastEvent({
                                variant: 'error',
                                title: 'Failure',
                                mode: 'sticky',
                                message: this.label.Sales_AccessCheckMsg,
                              });
                              //
							//this.fireToastEvent('Failure!','You cannot modify this record !! ','error','Sticky');
                           this.dispatchEvent(evt);
                           this.dispatchEvent(new CustomEvent('close'));
					}
				})
}*/

}