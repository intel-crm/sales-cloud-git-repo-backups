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
    reasonForChange='';newAccountOwner='';teamMembers='';newSalesGroup=''; newAccountTier='';//TWC3123-6732 newAccountTier
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
    showChangeToIndirectCoveredFields=false;//TWC3123-5894 updated from 'showChangeToPartnerFields' to 'showChangeToIndirectCoveredFields'
    showChangeToNotCoveredFields=false;//TWC3123-5894 updated from 'showChangeToUncoveredFields' to 'showChangeToNotCoveredFields'
    showChangeOwnershipFields=false;
    showAddToIntelCoveredFields=false;//TWC3123-5894 updated from 'showAddToIntelLedFields' to 'showAddToIntelCoveredFields'
    showPartialFields=false;
    showCstFeedback = false;
   // showChangeToOtherLedFields=false;//TWC3123-6125,TWC3123-5894- Commented as 'Change to Other Led' feedback is deactivated
    successMessage;
    acctAccTierOptions;//TWC3123-6732 
    showChangeAccountLevelFields = false; //TWC3123-6732 

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
                    let feedbackOptions = []; let SGOptions =[]; let accountTierOptions=[];//TWC3123-6732
                    for (var op in data.feedbackOptions) { 
                        let option = data.feedbackOptions[op].split('|');
                     
                        feedbackOptions.push({ label: option[0], value: option[1]  });
                    }        
                this.cstFeedbackOptions = feedbackOptions;
                console.log('Feedback op are:'+JSON.stringify(this.cstFeedbackOptions));
                for (var op in data.salesGroupOptions) { 
                    let option = data.salesGroupOptions[op].split('|');
                 
                    SGOptions.push({ label: option[0], value: option[1]  });
                } 
                if(SGOptions.length !== 0)         {
                this.cstSalesGrpOptions = SGOptions;
                this.custSG = SGOptions;
                }
                //TWC3123-6732 start
                console.log('Customer acc tier:'+data.accountTierOptions)
                 for (var op in data.accountTierOptions) { 
                    let option = data.accountTierOptions[op].split('|');
                 
                    accountTierOptions.push({ label: option[0], value: option[1]  });
                } 
                if(accountTierOptions.length !==0){
                    this.accountTierOptions = accountTierOptions;
                }
                //TWC3123-6732 end   
                }
                else if(data.objectName=='SPM_Account_Detail__c' && data.showComp == true){
                    this.showComp = true;
                    this.feedbackObjectName = 'SPM_Account_Feedback__c';
                    this.accountFeedback = true;
                    this.coverage = data.coverage;
                     console.log('Coverage in js acc detail is:'+this.coverage);
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
                 this.acctAccTierOptions = data.picklistFieldValues.CST_New_Account_Level__c.values.filter(
                    (opt) => ({
                        label: opt.label,
                        value: opt.value
                    })
                  );
                  console.log('Acc Tier options:'+this.acctAccTierOptions);
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
        this.newAccountTier='';//TWC3123-6732
        let SGOptions = this.custSG;
        this.disabled=false;
        this.selectedCstFeedback = event.target.value; 
        if(this.selectedCstFeedback == 'Change to Indirect Covered')  { //TWC3123-5894
            let newOp = [];
            for(let op in SGOptions){
                if(SGOptions[op].label.includes('Partner Led')){
                    newOp.push({ label: SGOptions[op].label, value: SGOptions[op].value  });
                }
                if(newOp.length !== 0)         {
                this.cstSalesGrpOptions = newOp;
                }
            }
            this.showChangeToIndirectCoveredFields =true;//TWC3123-5894
            this.showChangeToNotCoveredFields=false;//TWC3123-5894
            this.showChangeOwnershipFields=false;
            this.showAddToIntelCoveredFields=false;//TWC3123-5894
            this.showPartialFields=false;
            //this.showChangeToOtherLedFields=false;
            this.showChangeAccountLevelFields=false;//TWC3123-6732 
            this.newAccountTier='Level 3';//TWC3123-6732
            
        }
        else if(this.selectedCstFeedback == 'Change to Not Covered')  { //TWC3123-5894
            let newOp = [];
            for(let op in SGOptions){
                if(SGOptions[op].label.includes('Undefined')){
                    newOp.push({ label: SGOptions[op].label, value: SGOptions[op].value  });
                }
                if(newOp.length !== 0)         {
                this.cstSalesGrpOptions = newOp;
                }
            }
            this.showChangeToIndirectCoveredFields =false;//TWC3123-5894 
            this.showChangeToNotCoveredFields=true;//TWC3123-5894
            this.showChangeOwnershipFields=false;
            this.showAddToIntelCoveredFields=false;//TWC3123-5894
            this.showPartialFields=false;
            //this.showChangeToOtherLedFields=false;
            this.showChangeAccountLevelFields=false;//TWC3123-6732 
            this.newAccountTier='No Level';//TWC3123-6732
            
        }
        else if(this.selectedCstFeedback == 'Change Ownership')  {
            this.cstSalesGrpOptions = SGOptions;
            this.showChangeToIndirectCoveredFields =false;//TWC3123-5894 
            this.showChangeToNotCoveredFields=false;//TWC3123-5894 
            this.showChangeOwnershipFields=true;
            this.showAddToIntelCoveredFields=false;//TWC3123-5894
            this.showPartialFields=false;
            //this.showChangeToOtherLedFields=false;
            this.showChangeAccountLevelFields=false;//TWC3123-6732 
            
        }
        else if(this.selectedCstFeedback == 'Partial')  {
            this.cstSalesGrpOptions = SGOptions;
            this.showChangeToIndirectCoveredFields =false;//TWC3123-5894 
            this.showChangeToNotCoveredFields=false;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelCoveredFields=false;//TWC3123-5894
            this.showPartialFields=true;
            //this.showChangeToOtherLedFields=false;
            this.showChangeAccountLevelFields=false;//TWC3123-6732 
            
        }
        else if(this.selectedCstFeedback == 'Add to Intel Covered')  {//TWC3123-5894
            this.cstSalesGrpOptions = SGOptions;
            this.showChangeToIndirectCoveredFields =false;//TWC3123-5894 
            this.showChangeToNotCoveredFields=false;//TWC3123-5894 
            this.showChangeOwnershipFields=false;
            this.showAddToIntelCoveredFields=true;//TWC3123-5894
            this.showPartialFields=false;
            //this.showChangeToOtherLedFields=false;
            this.showChangeAccountLevelFields=false;//TWC3123-6732 
            this.newAccountTier='Level 2';//TWC3123-6732
           
        }
        /*if(this.selectedCstFeedback == 'Change to Other Led')  {
            this.cstSalesGrpOptions = SGOptions;
            this.showChangeToIndirectCoveredFields =false;//TWC3123-5894
            this.showChangeToNotCoveredFields=false;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelCoveredFields=false;//TWC3123-5894
            this.showPartialFields=false;
            //this.showChangeToOtherLedFields=true;
            this.showChangeAccountLevelFields=false;//TWC3123-6732 
            this.newAccountTier='Level 2';//TWC3123-6732
            
        }*/
        //TWC3123-6732 
         if(this.selectedCstFeedback == 'Change Account Level')  {
              this.showChangeAccountLevelFields=true;
         }
         //TWC3123-6732 
    }

    handleAcctFeedbackChange(event){
        this.newSalesGroup ='';
        this.newAccountTier='';//TWC3123-6732
        let SGOptions = this.acctSG;
        this.disabled=false;
        this.selectedAcctFeedback = event.target.value; 
        if(this.selectedAcctFeedback == 'Change to Indirect Covered')  {//TWC3123-5894
            let newOp = [];
            for(let op in SGOptions){
                if(SGOptions[op].label.includes('Partner Led')){
                    newOp.push({ label: SGOptions[op].label, value: SGOptions[op].value  });
                }
                if(newOp.length !== 0)         {
                this.acctSalesGrpOptions = newOp;
                }
            }
            this.showChangeToIndirectCoveredFields =true;//TWC3123-5894
            this.showChangeToNotCoveredFields=false;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelCoveredFields=false;//TWC3123-5894
            this.showPartialFields=false;
            //this.showChangeToOtherLedFields=false;
            this.showChangeAccountLevelFields=false;//TWC3123-6732 
            
        }
        else if(this.selectedAcctFeedback == 'Change to Not Covered')  {//TWC3123-5894
            let newOp = [];
            for(let op in SGOptions){
                if(SGOptions[op].label.includes('Undefined')){
                    newOp.push({ label: SGOptions[op].label, value: SGOptions[op].value  });
                }
                if(newOp.length !== 0)         {
                this.acctSalesGrpOptions = newOp;
                }
            }
            this.showChangeToIndirectCoveredFields =false;//TWC3123-5894
            this.showChangeToNotCoveredFields=true;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelCoveredFields=false;//TWC3123-5894
            this.showPartialFields=false;
            //this.showChangeToOtherLedFields=false;
            this.showChangeAccountLevelFields=false;//TWC3123-6732 
            this.newAccountTier='No Level';//TWC3123-6732
            this.newAccountTier='Level 3';//TWC3123-6732
            
        }    
        else if(this.selectedAcctFeedback == 'Change Ownership')  {
            this.acctSalesGrpOptions = SGOptions;
            this.showChangeToIndirectCoveredFields =false;//TWC3123-5894
            this.showChangeToNotCoveredFields=false;
            this.showChangeOwnershipFields=true;
            this.showAddToIntelCoveredFields=false;//TWC3123-5894
            this.showPartialFields=false;
            //this.showChangeToOtherLedFields=false;
            this.showChangeAccountLevelFields=false;//TWC3123-6732 
            
        }
        else if(this.selectedAcctFeedback == 'Add to Intel Covered')  {//TWC3123-5894
            this.acctSalesGrpOptions = SGOptions;
            this.showChangeToIndirectCoveredFields =false;//TWC3123-5894
            this.showChangeToNotCoveredFields=false;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelCoveredFields=true;//TWC3123-5894
            this.showPartialFields=false;
            //this.showChangeToOtherLedFields=false;
            this.showChangeAccountLevelFields=false;//TWC3123-6732 
            this.newAccountTier='Level 2';//TWC3123-6732
            
        }

         /*if(this.selectedAcctFeedback == 'Change to Other Led')  {
            let newOp = [];
            this.acctSalesGrpOptions = SGOptions;
            this.showChangeToIndirectCoveredFields =false;//TWC3123-5894
            this.showChangeToNotCoveredFields=false;
            this.showChangeOwnershipFields=false;
            this.showAddToIntelCoveredFields=false;//TWC3123-5894
            this.showPartialFields=false;
            //this.showChangeToOtherLedFields=true;
            this.showChangeAccountLevelFields=false;//TWC3123-6732 
            this.newAccountTier='Level 2';//TWC3123-6732
            
        }*/
        //TWC3123-6732 
         if(this.selectedAcctFeedback == 'Change Account Level')  {
            this.showChangeAccountLevelFields=true;
         }
         //TWC3123-6732
       
    }

    handleCstAcctOwner(event){this.newAccountOwner = event.target.value;}
    handleCstReason(event){this.reasonForChange = event.target.value;}
    handleCstTeamMembers(event){this.teamMembers = event.target.value;}
    handleCstSG(event){this.newSalesGroup = event.target.value;}
    handleCstFeedbackBy(event){this.feedbackBy = event.target.value;}
    handleCstAccountTier(event){this.newAccountTier = event.target.value;}

    handleAFAcctOwner(event){this.newAccountOwner = event.target.value;}
    handleAFReason(event){this.reasonForChange = event.target.value;}
    handleAFTeamMembers(event){this.teamMembers = event.target.value;}
    handleAFSG(event){this.newSalesGroup = event.target.value;}
    handleAFAccountTier(event){this.newAccountTier = event.target.value;}

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
        console.log('NEW ACC TIER IS:'+this.newAccountTier);
        this.cstFeedback.NewAccTier = this.newAccountTier;//TWC3123-6732
        
        if(this.stage == 'Director'){
            this.cstFeedback.FeedbackType = 'DR';
        }
        else{
            this.cstFeedback.FeedbackType = this.stage;
        }
        
        this.cstFeedback.RecordTypeId = this.recordTypeId;
        this.cstFeedback.FeedbackBy = this.feedbackBy;
        //TWC3123-6463 - START
        if(this.cstFeedback.Feedback ==  'Change to Indirect Covered' || this.cstFeedback.Feedback == '	Change to Not Covered'  /*|| this.cstFeedback.Feedback == 'Change to Other Led'*/ ){//TWC3123-5894
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
        this.acctFeedback.NewAccTier = this.newAccountTier;//TWC3123-6732
        
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