import { LightningElement,api,wire,track } from 'lwc';
import getEmbeddingObjectDetails from "@salesforce/apex/CST_CreateFeedback.getEmbeddingObjectDetails"; 
import createCustomerFeedback from "@salesforce/apex/CST_CreateFeedback.createCustomerFeedback"; 
import createAccountFeedback from "@salesforce/apex/CST_CreateFeedback.createAccountFeedback"; 
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import Team_Member_Label from '@salesforce/label/c.CST_Team_Member_Label';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountCategoryValues from '@salesforce/apex/CST_CreateFeedback.getAccountCategoryValues';
//to check custom permission
import hasRAPermission from '@salesforce/customPermission/CST_Regional_Admin';//TWC3123-6463

export default class Cst_feedback extends LightningElement {
    
    teamMemberLabel=Team_Member_Label;
    reasonForChange='';newAccountOwner='';teamMembers='';newSalesGroup='';
    showFeedbackBy=false;
    Error_Message='';
    showWarnings=false;
    cstFeedback = {};
    acctFeedback = {};
    showComp = false;
    @api objectInfo;
    @api recordId;
    @track customerFeedback=false;
    @track accountFeedback=false;
    @track acctFeedbackOptions;
    @track cstSalesGrpOptions;
    @track acctSalesGrpOptions;
    @track cstFeedbackOptions;
    @track selectedCstFeedback;
    @track selectedAcctFeedback;
    stage;coverage;
    @track recordTypeId;
    @track feedbackObjectName;
    @track feedbackBy;
    @track selectedAccountCategory =[];
    @track accountCategoryOptions=[];

    custSG=[];
    acctSG=[];

    disabled=true;
    showChangeToPartnerFields=false;
    showChangeToUncoveredFields=false;
    showChangeOwnershipFields=false;
    showAddToIntelLedFields=false;
    showPartialFields=false;
    showCstFeedback = false;
    showChangeToOtherLedFields=false;//TWC3123-6125
    successMessage;

    get hasRAPermission() { //TWC3123-6463
        return hasRAPermission;
    }

    
        @wire(getEmbeddingObjectDetails,{ recordId: '$recordId' })
        feedbackObjDetails({ error, data }) {
            if(data){
                if(data.objectName == 'SPM_Customer_Detail__c' && data.showComp == true){
                    this.showComp = true;
                    this.feedbackObjectName = 'SPM_Customer_Feedback__c';
                    this.customerFeedback = true;
                    this.coverage = data.coverage;
                    console.log('Coverage in js is:'+this.coverage);
                    if(data.stageName == 'DR'){
                        this.stage = 'Director';
                    }
                    else{
                        this.stage = data.stageName;
                    }
                    //this.recordTypeId = '';
                    this.feedbackBy = data.feedbackBy;
                    if(data.showFeedbackBy == true){
                        this.showFeedbackBy = true;
                    }
                    let feedbackOptions = []; let SGOptions =[];
                    for (var op in data.feedbackOptions) { 
                        let option = data.feedbackOptions[op].split('|');
                     
                        feedbackOptions.push({ label: option[0], value: option[1]  });
                    }        
                this.cstFeedbackOptions = feedbackOptions;

                for (var op in data.salesGroupOptions) { 
                    let option = data.salesGroupOptions[op].split('|');
                 
                    SGOptions.push({ label: option[0], value: option[1]  });
                } 
                if(SGOptions.length !== 0)         {
                this.cstSalesGrpOptions = SGOptions;
                this.custSG = SGOptions;
                }
                    
                }
                else if(data.objectName=='SPM_Account_Detail__c' && data.showComp == true){
                    this.showComp = true;
                    this.feedbackObjectName = 'SPM_Account_Feedback__c';
                    this.accountFeedback = true;
                    this.coverage = data.coverage;
                    if(data.stageName == 'DR'){
                        this.stage = 'Director';
                    }
                    else{
                        this.stage = data.stageName;
                    }
                    this.recordTypeId = data.recordTypeId;
                }
            }
        
    }
    
    @wire(getPicklistValuesByRecordType, { objectApiName: '$feedbackObjectName', recordTypeId: '$recordTypeId' })
    
    picklistValues({error, data}){
    	if(data){
        	//let options = [];
            //let key=data.picklistFieldValues.Feedback__c.controllerValues[this.coverage];
            if(this.accountFeedback){
                this.acctFeedbackOptions = data.picklistFieldValues.Feedback__c.values.filter(
                    (opt) => ({
                        label: opt.label,
                        value: opt.value
                    })
                  );
                this.acctSalesGrpOptions = data.picklistFieldValues.New_Sales_Group__c.values.filter(
                    (opt) => ({
                        label: opt.label,
                        value: opt.value
                    })
                  );
                 this.acctSG =  data.picklistFieldValues.New_Sales_Group__c.values.filter(
                    (opt) => ({
                        label: opt.label,
                        value: opt.value
                    })
                  );
            }
            /*else{
                this.cstFeedbackOptions = data.picklistFieldValues.Feedback__c.values.filter(
                    (opt) => opt.validFor.includes(key)
                  );
                
                /*this.cstSalesGrpOptions = data.picklistFieldValues.New_Sales_Group__c.values.filter(
                    (opt) => ({
                        label: opt.label,
                        value: opt.value
                    })
                  );
            }*/
            
                    /*for (var rec in data.picklistFieldValues.Feedback__c.values) { 
                        options.push({ label: data.picklistFieldValues.Feedback__c.values[rec].label, value: data.picklistFieldValues.Feedback__c.values[rec].value  });
                    }          
                    this.feedbackOptions = options;*/
        }else if(error){
        	console.log(error);
        }
    }

    handleCstFeedbackChange(event){
        this.newSalesGroup ='';
        let SGOptions = this.custSG;
        this.disabled=false;
        this.selectedCstFeedback = event.target.value; 
        if(this.selectedCstFeedback == 'Change to Partner')  {
            let newOp = [];
            for(let op in SGOptions){
                if(SGOptions[op].label.includes('Partner Led')){
                    newOp.push({ label: SGOptions[op].label, value: SGOptions[op].value  });
                }
                if(newOp.length !== 0)         {
                this.cstSalesGrpOptions = newOp;
                }
            }
            this.showChangeToPartnerFields =true;
            this.showChangeToUncoveredFields=false;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelLedFields=false;
            this.showPartialFields=false;
            this.showChangeToOtherLedFields=false;
            
        }
        else if(this.selectedCstFeedback == 'Change to Uncovered')  {
            let newOp = [];
            for(let op in SGOptions){
                if(SGOptions[op].label.includes('Undefined')){
                    newOp.push({ label: SGOptions[op].label, value: SGOptions[op].value  });
                }
                if(newOp.length !== 0)         {
                this.cstSalesGrpOptions = newOp;
                }
            }
            this.showChangeToPartnerFields =false;
            this.showChangeToUncoveredFields=true;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelLedFields=false;
            this.showPartialFields=false;
            this.showChangeToOtherLedFields=false;
            
        }
        else if(this.selectedCstFeedback == 'Change Ownership')  {
            this.cstSalesGrpOptions = SGOptions;
            this.showChangeToPartnerFields =false;
            this.showChangeToUncoveredFields=false;
            this.showChangeOwnershipFields=true;
            this.showAddToIntelLedFields=false;
            this.showPartialFields=false;
            this.showChangeToOtherLedFields=false;
            
        }
        else if(this.selectedCstFeedback == 'Partial')  {
            this.cstSalesGrpOptions = SGOptions;
            this.showChangeToPartnerFields =false;
            this.showChangeToUncoveredFields=false;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelLedFields=false;
            this.showPartialFields=true;
            this.showChangeToOtherLedFields=false;
            
        }
        else if(this.selectedCstFeedback == 'Add to Intel led')  {
            this.cstSalesGrpOptions = SGOptions;
            this.showChangeToPartnerFields =false;
            this.showChangeToUncoveredFields=false;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelLedFields=true;
            this.showPartialFields=false;
            this.showChangeToOtherLedFields=false;
           
        }
        //newly added
        if(this.selectedCstFeedback == 'Change to Other Led')  {
            this.cstSalesGrpOptions = SGOptions;
            this.showChangeToPartnerFields =false;
            this.showChangeToUncoveredFields=false;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelLedFields=false;
            this.showPartialFields=false;
            this.showChangeToOtherLedFields=true;
            
        }
    }

    handleAcctFeedbackChange(event){
        this.newSalesGroup ='';
        let SGOptions = this.acctSG;
        this.disabled=false;
        this.selectedAcctFeedback = event.target.value; 
        if(this.selectedAcctFeedback == 'Change to Partner')  {
            let newOp = [];
            for(let op in SGOptions){
                if(SGOptions[op].label.includes('Partner Led')){
                    newOp.push({ label: SGOptions[op].label, value: SGOptions[op].value  });
                }
                if(newOp.length !== 0)         {
                this.acctSalesGrpOptions = newOp;
                }
            }
            this.showChangeToPartnerFields =true;
            this.showChangeToUncoveredFields=false;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelLedFields=false;
            this.showPartialFields=false;
            this.showChangeToOtherLedFields=false;
            
        }
        else if(this.selectedAcctFeedback == 'Change to Uncovered')  {
            let newOp = [];
            for(let op in SGOptions){
                if(SGOptions[op].label.includes('Undefined')){
                    newOp.push({ label: SGOptions[op].label, value: SGOptions[op].value  });
                }
                if(newOp.length !== 0)         {
                this.acctSalesGrpOptions = newOp;
                }
            }
            this.showChangeToPartnerFields =false;
            this.showChangeToUncoveredFields=true;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelLedFields=false;
            this.showPartialFields=false;
            this.showChangeToOtherLedFields=false;
            
        }    
        else if(this.selectedAcctFeedback == 'Change Ownership')  {
            this.acctSalesGrpOptions = SGOptions;
            this.showChangeToPartnerFields =false;
            this.showChangeToUncoveredFields=false;
            this.showChangeOwnershipFields=true;
            this.showAddToIntelLedFields=false;
            this.showPartialFields=false;
            this.showChangeToOtherLedFields=false;
            
        }
        else if(this.selectedAcctFeedback == 'Add to Intel led')  {
            this.acctSalesGrpOptions = SGOptions;
            this.showChangeToPartnerFields =false;
            this.showChangeToUncoveredFields=false;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelLedFields=true;
            this.showPartialFields=false;
            this.showChangeToOtherLedFields=false;
            
        }
        //newly added
         if(this.selectedAcctFeedback == 'Change to Other Led')  {
            let newOp = [];
            this.acctSalesGrpOptions = SGOptions;
            this.showChangeToPartnerFields =false;
            this.showChangeToUncoveredFields=false;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelLedFields=false;
            this.showPartialFields=false;
            this.showChangeToOtherLedFields=true;
            
        }
       
    }

    handleCstAcctOwner(event){this.newAccountOwner = event.target.value;}
    handleCstReason(event){this.reasonForChange = event.target.value;}
    handleCstTeamMembers(event){this.teamMembers = event.target.value;}
    handleCstSG(event){this.newSalesGroup = event.target.value;}
    handleCstFeedbackBy(event){this.feedbackBy = event.target.value;}

    handleAFAcctOwner(event){this.newAccountOwner = event.target.value;}
    handleAFReason(event){this.reasonForChange = event.target.value;}
    handleAFTeamMembers(event){this.teamMembers = event.target.value;}
    handleAFSG(event){this.newSalesGroup = event.target.value;}

    requiredFieldsCheck(){
        let isValid = true;
        let fieldErrorMsg="Please Enter the";
        this.template.querySelectorAll('.validate').forEach(item => {
            let fieldValue=item.value;
            let fieldLabel=item.label;            
            if(!fieldValue){
                isValid = false;
                item.setCustomValidity(fieldErrorMsg+' '+fieldLabel);
            }
			else{
                item.setCustomValidity("");
            }
            item.reportValidity();
		});
        return isValid;
    }
    
    handleCstFeedbackSubmit(){
        let formValid = this.requiredFieldsCheck();
        
        this.cstFeedback.Feedback = this.selectedCstFeedback;
        this.cstFeedback.ReasonForChange = this.reasonForChange;
        this.cstFeedback.NewAcctOwner = this.newAccountOwner;
        this.cstFeedback.TeamMembers = this.teamMembers;
        this.cstFeedback.SalesGroup = this.newSalesGroup;
        this.cstFeedback.Coverage = this.coverage;
        this.cstFeedback.CustomerId = this.recordId;
        
        if(this.stage == 'Director'){
            this.cstFeedback.FeedbackType = 'DR';
        }
        else{
            this.cstFeedback.FeedbackType = this.stage;
        }
        
        this.cstFeedback.RecordTypeId = this.recordTypeId;
        this.cstFeedback.FeedbackBy = this.feedbackBy;
        //TWC3123-6463 - START
        if(this.cstFeedback.Feedback ==  'Change to Partner' || this.cstFeedback.Feedback == 'Change to Uncovered'  || this.cstFeedback.Feedback == 'Change to Other Led' ){
            if(hasRAPermission){
                this.successMessage ='Account feedbacks have been propagated to the respective accounts. Accounts which already have feedback will be overriden.'
            }
            else{
                this.successMessage = 'Account feedbacks have been propagated to the respective accounts. '
            }
        }
        else{
            this.successMessage = 'Data saved successfully.';
        }
        //TWC3123-6463 - END
        if(formValid){
            createCustomerFeedback({
                customerFeedback:this.cstFeedback
                })
                .then(result => {

                    console.log('result:'+JSON.stringify(result));
                    for (let key in result) {
                        if(key == 'true'){
                            if(result[key] == ''){
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message:   this.successMessage,
                                        variant: 'Success',
                                        mode: 'Sticky' 
                                    })
                                );
                                location.reload();
                            }
                            if(result[key] != ''){
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Warning',
                                        message:  result[key],
                                        variant: 'warning',
                                        mode: 'Sticky'
                                         
                                    })
                                );
                                setTimeout(() => {
                                    location.reload();
                                }, 5000);
                            }
                        }
                        
                        else{
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Application Error',
                                    message:  result[key],
                                    variant: 'Error',
                                    mode: 'Sticky' 
                                })
                            );
                        }
                       
                     }
                })
                .catch(error => {
                                console.log('Error: ', error);
                             this.showWarnings = true;
                             this.Error_Message =  JSON.stringify(error.body.message);
                                this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Application Error',
                                                message:  JSON.stringify(error.body.message) ,
                                                variant: 'Error',
                                                mode: 'Sticky' 
                                            })
                                        );
                                        });
        }
        
    }


    handleAcctFeedbackSubmit(){
        let formValid = this.requiredFieldsCheck();
        
        this.acctFeedback.Feedback = this.selectedAcctFeedback;
        this.acctFeedback.ReasonForChange = this.reasonForChange;
        this.acctFeedback.NewAcctOwner = this.newAccountOwner;
        this.acctFeedback.TeamMembers = this.teamMembers;
        this.acctFeedback.SalesGroup = this.newSalesGroup;
        this.acctFeedback.Coverage = this.coverage;
        this.acctFeedback.AccCategoryList = this.selectedAccountCategory;
        this.acctFeedback.AccountId = this.recordId;
        
        if(this.stage == 'Director'){
            this.acctFeedback.FeedbackType = 'DR';
        }
        else{
            this.acctFeedback.FeedbackType = this.stage;
        }
        
        this.acctFeedback.RecordTypeId = this.recordTypeId;
        if(formValid){
            createAccountFeedback({
                acctFeedback:this.acctFeedback
                })
                .then(result => {
                    for (let key in result) {
                        if(key == 'false'){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Application Error',
                                    message:  result[key],
                                    variant: 'Error',
                                    mode: 'Sticky' 
                                })
                            );
                        }
                        else if(key == 'true' && result[key] == ''){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message:  'Data saved successfully.',
                                    variant: 'Success',
                                    mode: 'Sticky' 
                                })
                            );
                            location.reload();
                        }
                        else{
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Warning',
                                    message:  result[key],
                                    variant: 'warning',
                                    mode: 'Sticky' 
                                })
                            );
                            location.reload();
                        }
                       
                       
                     }
                })
                .catch(error => {
                                console.log('Error: ', error);
                             this.showWarnings = true;
                              this.Error_Message =  JSON.stringify(error.body.message);
                                this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Application Error',
                                                message:  JSON.stringify(error.body.message) ,
                                                variant: 'Error',
                                                mode: 'Sticky' 
                                            })
                                        );
                                        });
        }
        
    }
   
@wire(getAccountCategoryValues, {})
    wiredAccountCategoryValues({ error, data }) {
        if (data) {
            this.accountCategoryOptions = data.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
            console.log(this.accountCategoryOptions);
        }
        else if (error) {
            console.error(error);
        }
    }
    handleAccountCategoryChange(event){
       
         this.selectedAccountCategory =  event.detail.value;
         console.log('Var is:'+this.selectedAccountCategory);
       
    }
}