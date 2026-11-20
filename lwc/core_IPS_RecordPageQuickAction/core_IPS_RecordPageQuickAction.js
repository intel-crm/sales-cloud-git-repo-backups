import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import CURRENT_USER_ID from '@salesforce/user/Id';
import CASEID_FIELD from '@salesforce/schema/Case.Id';
import CASESTATUS_FIELD from '@salesforce/schema/Case.Status';
import CASESUBSTATUS_FIELD from '@salesforce/schema/Case.Core_Sub_Status__c';
import CASERECTYPENAME_FIELD from '@salesforce/schema/Case.RecordType.Name';
import CASEOWNERID_FIELD from '@salesforce/schema/Case.OwnerId';

import Core_IPS_CloseCaseMsg from '@salesforce/label/c.Core_IPS_CloseCaseMsg';
import Core_IPS_Case_Status_Closed from '@salesforce/label/c.Core_IPS_Case_Status_Closed';
import Core_IPS_InvalidCaseMsg from '@salesforce/label/c.Core_IPS_InvalidCaseMsg';
import Core_IPS_Case_Detail_Page from '@salesforce/label/c.Core_IPS_Case_Detail_Page';

import Core_IPS_System_Admin_Profile_Name from '@salesforce/label/c.Core_IPS_System_Admin_Profile_Name';
import Core_IPS_IT_Admin_Profile from '@salesforce/label/c.Core_IPS_IT_Admin_Profile';
import Core_IPS_Production_Support_IPS_Profile from '@salesforce/label/c.Core_IPS_Production_Support_IPS_Profile';
import Core_IPS_Sales_Rep_BB_Profile from '@salesforce/label/c.Core_IPS_Sales_Rep_BB_Profile';
import Core_IPS_Sales_Rep_BB_Dual_IPS_Profile from '@salesforce/label/c.Core_IPS_Sales_Rep_BB_Dual_IPS_Profile';
import Core_IPS_Agent_Profile from '@salesforce/label/c.Core_IPS_Agent_Profile';
import Core_IPS_Agent_Enhanced_Profile from '@salesforce/label/c.Core_IPS_Agent_Enhanced_Profile';

import getCurrentUserProfileName from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getCurrentUserProfileName";
import Core_IPS_AgentCaseClosureControllerLEX from '@salesforce/apex/Core_IPS_AgentCaseClosureControllerLEX.initialValidations';
import getButtonsVisibility from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getButtonsVisibility";
import checkcloseCaseEditPermission from "@salesforce/apex/Core_IPS_CaseCreateLWCController.checkcloseCaseEditPermission";
import hasEditAccess from "@salesforce/apex/Core_IPS_CaseCreateLWCController.hasEditAccess";
import getCaseCloneAccess from '@salesforce/apex/Core_IPS_AgentCaseClosureControllerLEX.getCaseCloneAccess';
import Survey_profile_name from '@salesforce/label/c.Survey_profile_name';


const FIELDS = [CASESTATUS_FIELD,CASESUBSTATUS_FIELD];
export default class Core_IPS_RecordPageQuickAction extends NavigationMixin(LightningElement) {
surveyprofilename=Survey_profile_name;
    @track recordId;
    @track currentPageReference;
    @track spinnerOn = false;
    @track isCloseCaseClicked = false;
    @track isInvalidClicked = false;
    @track isRequestCaseCloseClicked = false;
    @track isExportButtonClicked = false;
    @track profileName;
    @track isEditCaseVisible = false;
    @track isCloseCaseVisible = false;
    @track isCopyVisible = false;
    @track isAcceptCaseVisible = false;
    @track isRequestClosureVisible = false;
    @track isExportPDFVisible = false;
    @track isInvalidVisible = false;
    @track isManageInterestedPartyVisible = false;
    @track isCaseCommentVisible = false;
    @track recordTypeName;
    @track isloading = true;
    @track recordId;
    @track record;
    @track editCloseCase;
    @track hasEditAccessvar;
    gotrecord = false;
    gotUserDetails = false;
    visibleButtons = '';
    caseCloneAccess = true;
    closeCaseWarningMsg = Core_IPS_CloseCaseMsg;
    invalidCaseWarningMsg = Core_IPS_InvalidCaseMsg;
   @api item;

    @wire(CurrentPageReference)
    currentPageReference;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    fetchCase(response) {
        this.record = response;
    }

    get status() {
        return getFieldValue(this.record.data, CASESTATUS_FIELD);
    }

    get subStatus() {
        return getFieldValue(this.record.data, CASESUBSTATUS_FIELD);
    }
    //////
     @wire(getCurrentUserProfileName)
    wiredGetProfileName({ data, error }) {
        if(data) {
            //this.gotUserDetails = true;
            this.profileName = data;
            //this.setButtonVisibility();
            console.log('this.profileName ', this.profileName);
        }
        if(error) {
            console.error('Error in loading profile name');
        }
    }
   /* systemAdminProfile = Core_IPS_System_Admin_Profile_Name;
    itAdminProfile = Core_IPS_IT_Admin_Profile;
    productionSupportProfile = Core_IPS_Production_Support_IPS_Profile;
    salesRepBbProfile = Core_IPS_Sales_Rep_BB_Profile;
    dualIpsProfile = Core_IPS_Sales_Rep_BB_Dual_IPS_Profile;
    ipsAgentProfile = Core_IPS_Agent_Profile;
    agentEnhancedProfile = Core_IPS_Agent_Enhanced_Profile;

    nacStr; //'IPS No Assigned Contact Case'
    ipsCaseCreateStr;// = 'IPS Case Create';
    ipsCloseCaseStr;// = 'IPS Closed Case';
    ipsGecReadOnlyStr;// = 'IPS GEC ReadOnly';

   

    @wire(getRecord, { recordId: '$currentPageReference.attributes.recordId' , fields: ['Case.RecordType.Name'] })
    wiredResult({data, error}) {
        if(data) {
            this.recordTypeName = getFieldValue(data, 'Case.RecordType.Name');
            this.setButtonVisibility();
            this.gotrecord = true;
            console.log('this.recordTypeName ', this.recordTypeName);
        }
        if(error) {
            console.error('Error in loading case record type name', error, JSON.stringify(error));
        }
    }

    @wire(getCurrentUserProfileName)
    wiredGetProfileName({ data, error }) {
        if(data) {
            this.gotUserDetails = true;
            this.profileName = data;
            this.setButtonVisibility();
            console.log('this.profileName ', this.profileName);
        }
        if(error) {
            console.error('Error in loading profile name');
        }
    }

    setButtonVisibility() {
        console.log('this.profileName ', this.profileName);
        console.log('this.ipsAgentProfile ', this.ipsAgentProfile);
        if(((this.profileName === this.systemAdminProfile || this.profileName ===  this.itAdminProfile || this.profileName === this.productionSupportProfile)
            || ((this.profileName === this.salesRepBbProfile || this.profileName === this.dualIpsProfile 
            || this.profileName === this.ipsAgentProfile || this.profileName === this.agentEnhancedProfile) 
            && ((this.recordTypeName === this.ipsCaseCreateStr || this.recordTypeName === this.ipsCloseCaseStr 
                || this.recordTypeName === this.nacStr) )) && this.recordTypeName !== this.ipsGecReadOnlyStr)
        ) {
            this.isEditCaseVisible = true;
        }

        if(((this.profileName === this.systemAdminProfile || this.profileName ===  this.itAdminProfile || this.profileName === this.productionSupportProfile)
            || ((this.profileName === this.salesRepBbProfile || this.profileName === this.dualIpsProfile 
            || this.profileName === this.ipsAgentProfile || this.profileName === this.agentEnhancedProfile) 
            && (this.recordTypeName === this.ipsCaseCreateStr || this.recordTypeName === this.ipsCloseCaseStr 
                || this.recordTypeName === this.nacStr)) && this.recordTypeName !== this.ipsGecReadOnlyStr) 
        ) {
            this.isCopyVisible = true;
        }

        if(((this.profileName === this.systemAdminProfile || this.profileName ===  this.itAdminProfile || this.profileName === this.productionSupportProfile)
            || ((this.profileName === this.dualIpsProfile || this.profileName === this.ipsAgentProfile || this.profileName === this.agentEnhancedProfile) 
            && (this.recordTypeName === this.ipsCaseCreateStr || this.recordTypeName === this.ipsCloseCaseStr 
                || this.recordTypeName === this.nacStr)) && this.recordTypeName !== this.ipsGecReadOnlyStr)
        ) {
            this.isAcceptCaseVisible = true;
        }

        if(((this.profileName === this.systemAdminProfile || this.profileName ===  this.itAdminProfile || this.profileName === this.productionSupportProfile)
            || ((this.profileName === this.dualIpsProfile || this.profileName === this.ipsAgentProfile || this.profileName === this.agentEnhancedProfile) 
            && ((this.recordTypeName === this.ipsCaseCreateStr || this.recordTypeName === this.ipsCloseCaseStr 
                || this.recordTypeName === this.nacStr))) && this.recordTypeName !== this.ipsGecReadOnlyStr)
        ) {
            this.isRequestClosureVisible = true;
        }

        if(((this.profileName === this.systemAdminProfile || this.profileName ===  this.itAdminProfile || this.profileName === this.productionSupportProfile)
            || ((this.profileName === this.salesRepBbProfile || this.profileName === this.dualIpsProfile 
            || this.profileName === this.ipsAgentProfile || this.profileName === this.agentEnhancedProfile) 
            && ((this.recordTypeName === this.ipsCaseCreateStr || this.recordTypeName === this.ipsCloseCaseStr 
                || this.recordTypeName === this.nacStr))) && this.recordTypeName !== this.ipsGecReadOnlyStr) 
        ) {
            this.isExportPDFVisible = true;
        }

        if((this.profileName === this.systemAdminProfile || this.profileName ===  this.itAdminProfile || this.profileName === this.productionSupportProfile ) 
            || ((this.profileName === this.salesRepBbProfile || this.profileName === this.dualIpsProfile 
            || this.profileName === this.ipsAgentProfile || this.profileName === this.agentEnhancedProfile) 
            && (this.recordTypeName === this.ipsCaseCreateStr || this.recordTypeName === this.ipsCloseCaseStr 
                || this.recordTypeName === this.nacStr || this.recordTypeName === this.ipsGecReadOnlyStr)) 
        ) {
            this.isInvalidVisible = true;
        }

        if(((this.profileName === this.systemAdminProfile || this.profileName ===  this.itAdminProfile || this.profileName === this.productionSupportProfile)
            || ((this.profileName === this.salesRepBbProfile) && ((this.recordTypeName === this.ipsCaseCreateStr 
            || this.recordTypeName === this.ipsCloseCaseStr || this.recordTypeName === this.nacStr))) && this.recordTypeName !== this.ipsGecReadOnlyStr) 
        ) {
            this.isCloseCaseVisible = true;
        }
       
        if(  this.gotrecord &&  this.gotUserDetails ){
            this.isloading =false;
        }
        console.log('this.isloading '+ this.isloading);
        console.log('this.gotrecord '+ this.gotrecord);
        console.log('this.gotUserDetails '+ this.gotUserDetails);
    }

    connectedCallback() {
        this.recordId = this.currentPageReference.attributes.recordId;
        getIPSLabel({name: 'Case_RT_Name_IPS_NoAssignedContact' })
            .then(result=>{
                this.nacStr = result;
            })
            .catch(error=>{
                console.error('Error in loading Case_RT_Name_IPS_NoAssignedContact value');
            });
        getIPSLabel({name: 'Case_RT_Name_IPS_Case_Create' })
            .then(result=>{
                this.ipsCaseCreateStr = result;
            })
            .catch(error=>{
                console.error('Error in loading Case_RT_Name_IPS_Case_Create value');
            });
        getIPSLabel({name: 'Case_RT_Name_IPS_GECReadOnly' })
            .then(result=>{
                this.ipsGecReadOnlyStr  = result;
            })
            .catch(error=>{
                console.error('Error in loading Case_RT_Name_IPS_GECReadOnly value');
            });
        getIPSLabel({name: 'Case_RT_Name_IPS_Close_Case' })
            .then(result=>{
                this.ipsCloseCaseStr = result;
            })
            .catch(error=>{
                console.error('Error in loading Case_RT_Name_IPS_Close_Case value');
            })
        
        
    }*/

    connectedCallback() {
        this.recordId = this.currentPageReference.attributes.recordId;
        console.log("calling  getButtonsVisibility " + this.recordId  );
        getButtonsVisibility({
            caseId: this.recordId 

        }).then(result => {
            //  console.log("this.records inside varaints");
            console.log("rsult" + result);
          

            if (result !== undefined || result !== null) {
                console.log('inside result'+result);
                this.visibleButtons = result;
            }     
            console.log('visibleButtons ' + this.visibleButtons);
            if(this.visibleButtons.indexOf('Edit,') > -1   ){
                this.isEditCaseVisible = true;
                console.log('ShobhitEditflag--'+this.isEditCaseVisible);
            }
            
            if(this.visibleButtons.indexOf('Case Close,') > -1   ){
                this.isCloseCaseVisible = true;
            }
            if(this.visibleButtons.indexOf('Copy,') > -1   ){
                this.isCopyVisible = true;
            }
            if(this.visibleButtons.indexOf('Accept,') > -1   ){
                this.isAcceptCaseVisible = true;
            }
            if(this.visibleButtons.indexOf('Request Closure,') > -1   ){    
                this.isRequestClosureVisible = true;
            }
            if(this.visibleButtons.indexOf('Export PDF,') > -1   ){    
                this.isExportPDFVisible = true;
            }
            if(this.visibleButtons.indexOf('Invalid,') > -1   ){     
                this.isInvalidVisible = true;
            }
            //console.log('this.visibleButtons Manage Interested Parties '+this.visibleButtons.indexof('Interested Parties,'));
            if(this.visibleButtons.includes('Interested Parties,')  ){    
                this.isManageInterestedPartyVisible = true;
            }  
            if(this.visibleButtons.includes('Case Comment,')  ){    
                this.isCaseCommentVisible = true;
            }
            console.log('visibleButtons '+this.visibleButtons);
            console.log('isInvalidVisible '+this.isInvalidVisible);
            this.isloading =false;
        }).catch(error => {
            console.log("error" + JSON.stringify(error))
            //this.showToast('ERROR', 'Error in loading case', 'error');
            this.error = error;
            console.log("this.error" + JSON.stringify(this.error));
        });
        checkcloseCaseEditPermission({
            caseId : this.recordId
        })
        .then(result =>{
           this.editCloseCase = result;
           console.log('checkcloseCaseEditPermission-->'+this.editCloseCase);
        })
        .catch(error =>{
            this.error = error; 
        })
        hasEditAccess({
            caseId: this.recordId 

        }).then(result =>{
            this.hasEditAccessvar = result;
            console.log('hasEditAccessvar-->'+this.hasEditAccessvar);
         })
         .catch(error =>{
             this.error = error; 
         })
    }

    handleButtonClick(event) {
        console.log('handleButtonClick called');
        if(event.target.label === 'Close Case') {
            console.log('Closing the case...');
            this.isCloseCaseClicked = true;
        }
        if(event.target.label === 'Invalid') {
            console.log('Invalid case...');
            this.isInvalidClicked = true;
        }
        if(event.target.label === 'Accept Case') {
            console.log('Accepting the case...');
            this.spinnerOn = true;
            const fields = {};
            fields[CASEID_FIELD.fieldApiName] = this.recordId;
            fields[CASEOWNERID_FIELD.fieldApiName] = CURRENT_USER_ID;
            const recordInput = { fields };
            this.updateRecordMethod(recordInput);
        }
        if(event.target.label === 'Copy') {
            console.log('Copying the case...');
            if(this.profileName == 'Sales Ops'){
                this.showToast('ERROR', 'You have insufficient privilege to copy the Case.', 'error');
            }
            else if(this.profileName == 'Data Ops'){
                console.log('PBSSSS Copy Case DO');
                getCaseCloneAccess({  })
                .then(result =>{
                    if(result==false){
                        this.caseCloneAccess = false;
                    }
                    else{
                        this.caseCloneAccess = true;
                        var compDefinition = {
                            componentDef: "c:core_IPS_CreateCase",
                            attributes: {
                                recordId: this.recordId,
                                mode: 'copy'
                            }
                          };
                          // Base64 encode the compDefinition JS object
                          var encodedCompDef = btoa(JSON.stringify(compDefinition));
                          var url = 'https://'+window.location.hostname+'/one/one.app#' + encodedCompDef;
                          window.open(url, 'Copy Case', "width=1000,height=600");
                    }
                })
                .catch(error =>{
                    console.log('Error--'+error);
                })
            } else{
                console.log('PBSSSS Copy Case other');
            var compDefinition = {
                componentDef: "c:core_IPS_CreateCase",
                attributes: {
                    recordId: this.recordId,
                    mode: 'copy'
                }
              };
              // Base64 encode the compDefinition JS object
              var encodedCompDef = btoa(JSON.stringify(compDefinition));
              var url = 'https://'+window.location.hostname+'/one/one.app#' + encodedCompDef;
              window.open(url, 'Copy Case', "width=1000,height=600");
            }
        }
        if(event.target.label === 'Edit Case Details') {
            console.log('Editing the case...'+this.status);
            console.log('Editing the case...'+this.subStatus);
            if(!this.hasEditAccessvar){
                this.showToast('ERROR', 'You have insufficient privilege to edit the Case.', 'error');
            } else{
                if(this.editCloseCase){
              this.showToast('ERROR', '"This case is already closed and cannot be edited. To reopen, click on the case number, else you may submit a new case by clicking on Create New Case.', 'error');  
            } else{
            var compDefinition = {
                componentDef: "c:core_IPS_CreateCase",
                attributes: {
                    recordId: this.recordId,
                    mode:'edit'
                }
              };
              // Base64 encode the compDefinition JS object
              var encodedCompDef = btoa(JSON.stringify(compDefinition));
              console.log('encodedCompDef ', encodedCompDef);
              var url = 'https://'+window.location.hostname+'/one/one.app#' + encodedCompDef;
              window.open(url,  "_self");
              
            }
            }
        }
        if(event.target.label === 'Manage Interested Parties') {
            console.log('Manage Interested Parties...');
            var compDefinition = {
                componentDef: "c:Core_IPS_Case_Interested_Parties",
                attributes: {
                    recordId: this.recordId
                }
              };
              // Base64 encode the compDefinition JS object
              var encodedCompDef = btoa(JSON.stringify(compDefinition));
              console.log('encodedCompDef ', encodedCompDef);
              var url = 'https://'+window.location.hostname+'/one/one.app#' + encodedCompDef;
              window.open(url,  "_self");
        }
    }

    handleCancel() {
        this.isCloseCaseClicked = false;
        this.isInvalidClicked = false;
    }
    surveyvisible=false;

    handleCloseCase() {
        const result = this.surveyprofilename.split(',').map(element => element.trim());
        for(let i=0;i<=result.length;i++){
       if(this.profileName==(result[i])){
            
            this.surveyvisible=true;
          

            
            this[NavigationMixin.Navigate]({
                type: 'standard__navItemPage',
                attributes: {
                    
                    apiName: 'Survey_Report'
                    
                },
                state:{
                    c__recordId:this.recordId,
                    c__caseId:this.item
                }
               
            });
        this.spinnerOn = true;
        const fields = {};
        fields[CASEID_FIELD.fieldApiName] = this.recordId;
        fields[CASESTATUS_FIELD.fieldApiName] = Core_IPS_Case_Status_Closed;
        fields[CASESUBSTATUS_FIELD.fieldApiName] = Core_IPS_Case_Status_Closed;
        const recordInput = { fields };
        this.updateRecordMethodsurvey(recordInput);
        this.isCloseCaseClicked = false;
       }
        }

     
        if(this.surveyvisible==false){      
            this.spinnerOn = true;
        const fields = {};
        fields[CASEID_FIELD.fieldApiName] = this.recordId;
        fields[CASESTATUS_FIELD.fieldApiName] = Core_IPS_Case_Status_Closed;
        fields[CASESUBSTATUS_FIELD.fieldApiName] = Core_IPS_Case_Status_Closed;
        const recordInput = { fields };
        this.updateRecordMethod(recordInput);
        this.isCloseCaseClicked = false;
        
        }
        
    }

    handleInvalidCase() {
        this.spinnerOn = true;
        const fields = {};
        fields[CASEID_FIELD.fieldApiName] = this.recordId;
        fields[CASESTATUS_FIELD.fieldApiName] = Core_IPS_Case_Status_Closed;
        fields[CASESUBSTATUS_FIELD.fieldApiName] = "Invalid";
        const recordInput = { fields };

        this.updateRecordMethod(recordInput);
        this.isInvalidClicked = false;
    }

    /*@wire(
        getRecord, {
            recordId: "$recordId",
            fields: [CASESTATUS_FIELD, CASESUBSTATUS_FIELD]
        })
    caseRec;*/
    showErrormessage;
    handleClickClosure(){
        
        Core_IPS_AgentCaseClosureControllerLEX({ 
            caseID: this.recordId 
        })
        .then(result =>{
            console.log('result'+result);
            //if(result ===null && this.profileName!='Data Ops'){
            if(result ===null){    
                this.isRequestCaseCloseClicked = true;

            }else{
                /*if(this.profileName=='Data Ops'){
                    this.showToast('ERROR', 'You have insufficient privilege to request case closure.', 'error');
                }
                else{*/
                    this.showErrormessage = result;
                    this.dispatchEvent(new ShowToastEvent({
                       message: this.showErrormessage[0],
                       variant: 'error',
                    }));
               
            }
        })    
               
            
        /*if(getFieldValue(this.caseRec.data, CASESTATUS_FIELD) === 'Open' && getFieldValue(this.caseRec.data, CASESUBSTATUS_FIELD) === 'Close-Pending'){
            console.log('inside if cs check ');
            this.agentCaseClosure();
            console.log('mssges here cs ', this.showErrormessage);
            this.dispatchEvent(new ShowToastEvent({
                message: this.showErrormessage[0],
                variant: 'error',
            }));
        } else {
            this.isRequestCaseCloseClicked = true;
        }*/
        
        //console.log('case sub cs ', this.caseRec.data.CASESUBSTATUS_FIELD);
        console.log('Record id in LWC'+this.recordId);
    }

    handleExportToPDF(event){
        this.isExportButtonClicked = true;
        var test ='https://'+window.location.hostname+'/apex/Core_IPS_Case_ExportPDF_LEX?id='+this.recordId;
        console.log(test);
        window.open(test);
    }

    updateRecordMethod(recordInput) {
        console.log('isnide update Record');
        updateRecord(recordInput)
            .then(() => {
                this.showToast('Success', 'Record Updated', 'success');
                this.spinnerOn = false;
                window.location.reload();
            })
            .catch(error => {
                let errorMessage = JSON.stringify(error.body.output.errors[0].message);
                //let errorMessage = error.body.output.fieldErrors.Core_Sub_Status__c[0].message;
                this.showToast('Error', errorMessage , 'error');
                console.log('InvalidError2--'+JSON.stringify(error));
                this.spinnerOn = false;
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    updateRecordMethodsurvey(recordInput) {
        console.log('isnide update Record');
        updateRecord(recordInput)
            .then(() => {
              //  window.location.reload();
            
                this.spinnerOn = false;
               
            })
            .catch(error => {
                let errorMessage = JSON.stringify(error.body.output.errors[0].message);
                //let errorMessage = error.body.output.fieldErrors.Core_Sub_Status__c[0].message;
                this.showToast('Error', errorMessage , 'error');
                console.log('InvalidError2--'+JSON.stringify(error));
                this.spinnerOn = false;
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    handleNavigate(){
        if(this.status != 'Closed') {
        if(this.isLightningMode == true){
            var compDefinition = {
                componentDef: "c:core_IPS_DynamicTab",
                attributes: {
                    recordId: this.recordId
                }
            };
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/one/one.app#' + encodedCompDef
                }
            });
        } else {
            var encodedCompDef = btoa('{"componentDef":"c:core_IPS_DynamicTab","attributes":{"recordId": "'+this.recordId+'"},"state":{}}');
            window.open('/one/one.app#'+encodedCompDef,'_Self');
        }
	} else {
        this.showToast('Error', 'Comment cannot be added on Closed Cases.' , 'error');
      }
    }
    handleCancel(){
        window.location.href = Core_IPS_Case_Detail_Page + this.recordId + '/view'
    }
}