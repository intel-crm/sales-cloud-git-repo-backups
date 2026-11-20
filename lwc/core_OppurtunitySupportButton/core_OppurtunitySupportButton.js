import { LightningElement ,api,wire } from 'lwc';
import getdataForOpportunity from "@salesforce/apex/Core_OpportunitySupport.getOpportunityDetails";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import { createRecord,updateRecord } from 'lightning/uiRecordApi';
import { refreshApex ,refreshRecord} from '@salesforce/apex';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getObjectInfo,getPicklistValuesByRecordType, getPicklistValues} from 'lightning/uiObjectInfoApi';

import OPPORTUNITYDESCRIPTION from '@salesforce/schema/Opportunity.Description';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';

import OPPORTUNITY_DESCRIPTION from '@salesforce/schema/Core_Opportunity_Support__c.Core_Opportunity_Description__c';
import CoEReqDETAIL from '@salesforce/schema/Core_Opportunity_Support__c.Core_CoE_Request_Detail__c';
import PRIMARYBLOCKERS from '@salesforce/schema/Core_Opportunity_Support__c.Core_PrimaryBlockers__c';
import ADDITIONAL_SUPPORT from '@salesforce/schema/Core_Opportunity_Support__c.Core_Additional_Support_Needed__c';
import BACKGROUND_ARCHITCT_INFO from '@salesforce/schema/Core_Opportunity_Support__c.Core_background_info_on_architecture__c';
import SUPPORT_OPPORTUNITY_ID from '@salesforce/schema/Core_Opportunity_Support__c.Opportunity__c';
import RECORD_TYPE_OPPSUP from '@salesforce/schema/Core_Opportunity_Support__c.RecordTypeId';
import TSS_SUPPORT from '@salesforce/schema/Core_Opportunity_Support__c.Core_TSS_Support_Type__c';
import COE_SUPPORT from '@salesforce/schema/Core_Opportunity_Support__c.Center_of_Excellence__c';
import STARTDATE from '@salesforce/schema/Core_Opportunity_Support__c.Core_Start_Date__c';
import CORE_STATUS from '@salesforce/schema/Core_Opportunity_Support__c.Core_Status__c';



export default class Core_OppurtunitySupportButton extends LightningElement {
    
    @api recordId;
    WarningMessage ='';
    WarningPromotMessage = 'Please review support request details as changes cannot be made after submission.';
    showForm = false;
    opportunityData = {};   
    opp_diesc = '';
    coe_reqDetail='';
    pri_blocker = '';
    add_sup = '';
    back_acr = '';
    tss_Supp = '';
    coe_Supp = '';
    resetpage = false;
    accountName = '';
    oppName = '';
    techOwner = '';
    recordTypeOptions;
    recordTypeId='';
    recortypName = '';
    showFormRecordType = false;
    //tss_Supp=[];
    checkRecordType= false;
    COERecordType = false;
    CSARecordType =false
    onSave = false;
    conditionToQr = '';
    checkForCoE = false;

    //Areefa Start
    picklistValues = []    
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: TSS_SUPPORT,
      })
      getTSSPicklistValues({ data, error }) {
        if (error) {
          console.error(error)
        } else if (data) {
          this.picklistValues = [...data.values]
          console.log('Picklist Options--' +JSON.stringify(this.picklistValues));
        }
      }

      //COE Picklist value
      coePicklistValues = []    
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: COE_SUPPORT,
      })
      getCOEPicklistValues({ data, error }) {
        if (error) {
          console.error(error)
        } else if (data) {
          this.coePicklistValues = [...data.values]
          console.log('Picklist Options--' +JSON.stringify(this.coePicklistValues));
        }
      }

    //Areefa End

    @wire(getObjectInfo, { objectApiName:  'Core_Opportunity_Support__c' })
    objectInfo({ error, data }) {
        if (data) {
            this.recordTypeOptions = Object.values(data.recordTypeInfos).filter(option => (option.name != 'Master')).map(option => ({ label: option.name, value: option.recordTypeId }));
            console.log('recordTypeOptions--'+JSON.stringify(this.recordTypeOptions));
           // let fieldInfo = data.fields[TSS_SUPPORT.fieldApiName];
           this.recordTypeOptions.sort((a, b) => (a.label < b.label ? -1 : a.label > b.label ? 1 : 0));
           this.showFormRecordType = true;
            
        } else if (error) {
            console.error(error);
        }
    }  

  
  

    handleRecordTypeChange(event) {
        this.recordTypeId = event.detail.value;
        const selectedOption = this.recordTypeOptions.find(option => option.value === this.recordTypeId);

        this.recortypName = selectedOption.label;
        //this.showFormRecordType = false;
        //this.showForm=true;
        // Handle record type selection here
    }  
    handleNextClick(){
        this.showFormRecordType = false;
        //this.showForm=true;
        if(this.recortypName == 'Center of Excellence Request')
            this.CSARecordType=true;
        if(this.recortypName == 'Technical Sales Specialist Request') // TSS Request
            this.checkRecordType = true;
        if(this.recortypName == 'Center of Excellence Request')
            this.COERecordType = true;
        if(this.recortypName == 'Cloud Solutions Architect Request')
            this.conditionToQr =  ' and Core_Status__c=\'Submitted\'';
        
        this.checkRequestExsit();
    }

  

     checkRequestExsit(){
        getdataForOpportunity({OpportunityId: this.recordId,oppSuprecorType: this.recordTypeId , whereCondition : this.conditionToQr})
			.then(data => {
				if(!data.isThereAnOpenOpptSupportReq){
                    this.showForm=true; 
                    //this.showFormRecordType = true;              
                    this.opportunityData = data.oppDetails[0];
                    console.log('data in @@'+JSON.stringify(this.opportunityData));
                    this.opp_diesc =  this.opportunityData.Description;
                    this.techOwner =  this.opportunityData.Core_Technical_Owner__r != undefined ? this.opportunityData.Core_Technical_Owner__r.Name : '';
                    
                    if(data.isThereContactwithTechnicalOW && !this.checkForCoE)
                        this.displaymessage('warning','There should be at least 1 Opportunity Contact with the role "Technical Decision Maker"','warning'); 
                }
                else {
                    
                     
                    if(this.checkForCoE){
                        this.checkForCoE = false;
                        let combobox;
                        if(this.recortypName == 'Technical Sales Specialist Request'){
                            combobox = this.template.querySelector('[data-id="TSS_Support_Type"]');
                            combobox.setCustomValidity('There is a Support Request created for this BU, Please select another BU.'); 
                        }
                        else{
                            combobox = this.template.querySelector('[data-id="Center_of_Excellence"]');
                            combobox.setCustomValidity('There is a Support Request created for this Center of Excellence. Please select another Category.');  
                        }                      
                    }
                    else{
                        this.displaymessage('Error','There is already another Submitted Support Request which needs to be Closed','error');
                        this.showForm=false;
                        this.dispatchEvent(new CloseActionScreenEvent());
                    }
                } 
			})
			.catch(error => {
				console.log('error'+JSON.stringify(error));
			});

    }
    // Update values changed by user 
    handleInputChange(event) {
        
        const fieldName = event.target.name;
        const value = event.target.value;
        if (fieldName === 'Opportunity Description') {
            this.opp_diesc = value;
        }else if (fieldName === 'CoE Request Detail') {
            this.coe_reqDetail = value;
        }else if (fieldName === 'Primary Blockers') {
            this.pri_blocker = value;
        } else if (fieldName === 'Additional Support Needed') {
            this.add_sup = value;
        } else if (fieldName === 'Background Information') {
            this.back_acr = value;
        } else if (fieldName === 'TSS Support Type'){
            this.tss_Supp = value;
            this.conditionToQr = ' and Core_TSS_Support_Type__c = '+ '\''+this.tss_Supp+'\'';
            const combobox = this.template.querySelector('[data-id="TSS_Support_Type"]');
            combobox.setCustomValidity('');
            this.checkForCoE = true;
            this.checkRequestExsit();
        }else if (fieldName === 'Center of Excellence'){
            this.coe_Supp = value;            
            this.conditionToQr = ' and Center_of_Excellence__c = '+ '\''+this.coe_Supp+'\'';
            const combobox = this.template.querySelector('[data-id="Center_of_Excellence"]');
            combobox.setCustomValidity('');
            this.checkForCoE = true;
            this.checkRequestExsit();
            
        }

    }

    // create Opportunity Support record 
    async  handleSubmit(event) {   
        event.preventDefault();
            const fields = {};
            var today = new Date();
            fields[OPPORTUNITY_DESCRIPTION.fieldApiName] = this.opp_diesc;
            fields[CoEReqDETAIL.fieldApiName] = this.coe_reqDetail;
            fields[PRIMARYBLOCKERS.fieldApiName] = this.pri_blocker;
            fields[ADDITIONAL_SUPPORT.fieldApiName] = this.add_sup;
            fields[BACKGROUND_ARCHITCT_INFO.fieldApiName] = this.back_acr;
            fields[SUPPORT_OPPORTUNITY_ID.fieldApiName] = this.recordId;
            fields[RECORD_TYPE_OPPSUP.fieldApiName] = this.recordTypeId;
            fields[CORE_STATUS.fieldApiName] = 'Submitted';
            fields[STARTDATE.fieldApiName] = today.toISOString().slice(0, 10);
            
            if(this.checkRecordType)
                fields[TSS_SUPPORT.fieldApiName] = this.tss_Supp;
            if(this.COERecordType)
                fields[COE_SUPPORT.fieldApiName] = this.coe_Supp;
            debugger;
            var allTextAreaValid = [...this.template.querySelectorAll('lightning-textarea')]
                .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
               var allComboValid = [...this.template.querySelectorAll('lightning-combobox')]
                .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);

                if(allTextAreaValid && allComboValid)  { 
                var resultConfirm = await LightningConfirm.open({
                        message: this.WarningPromotMessage,
                        variant: 'headerless',
                        label: 'this is the aria-label value',
                        // setting theme would have no effect
                    });
                }
            if(allTextAreaValid && resultConfirm){
                this.onSave = true;
                const recordInput = { apiName: 'Core_Opportunity_Support__c', fields };
                createRecord(recordInput)
                .then((record) => {
                    this.displaymessage('Success','Opportunity support created','success');                     
                    const Oppfield = {};
                    Oppfield[ID_FIELD.fieldApiName] = this.recordId;
                    Oppfield[OPPORTUNITYDESCRIPTION.fieldApiName] =  this.opp_diesc;
                    const oppDesUpdate = {fields : Oppfield};
                    updateRecord(oppDesUpdate)
                    .then(() => {
                        return refreshApex(this.recordId);
                       
                    })
                    .catch(error => {
                        console.log('error'+JSON.stringify(error));
                        this.displaymessage('Error while updating Opportunity description',error,'error');                        
                    });
                   var url = window.location.href; 
                    var value = url.substr(0,url.lastIndexOf('/') + 1);                                      
                    window.history.back();
                    setTimeout(function() {
                        window.location.reload();
                    }, 1000);
                         
                })
                .catch((error) => {
                    console.log('error'+JSON.stringify(JSON.stringify(error)));                    
                    this.displaymessage('Error creating record','There could be a possible error with Approval Process.please reach out to IT for more details','error');        
                
                });
            }
    }
    
    //Displays message
    displaymessage(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }


    handleCancelNew(){
        this.dispatchEvent(new CloseActionScreenEvent());
     
    } 

}