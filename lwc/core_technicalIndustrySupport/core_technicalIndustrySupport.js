import { LightningElement ,api,wire } from 'lwc';
import getdataForOpportunity from "@salesforce/apex/Core_OpportunitySupport.getOpportunityDetails";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import { createRecord,updateRecord } from 'lightning/uiRecordApi';
import { refreshApex ,refreshRecord} from '@salesforce/apex';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
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
/*TWC4767-2678- Start*/
import CORE_BUSINESS_CHALLENGE from '@salesforce/schema/Core_Opportunity_Support__c.CRM_Business_Challenge_Txt__c';
import CORE_BUSINESS_RES_OUTCOME from '@salesforce/schema/Core_Opportunity_Support__c.CRM_Cust_Business_Results_Outcomes_Txt__c';
import CORE_WHY_INTEL from '@salesforce/schema/Core_Opportunity_Support__c.CRM_Why_Intel_Txt__c';
import CORE_SOLUTION_SUMMARY from '@salesforce/schema/Core_Opportunity_Support__c.CRM_Solution_Summary_Txt__c';
import CORE_CUSTOMER_WILLINGNESS from '@salesforce/schema/Core_Opportunity_Support__c.CRM_Customer_Willingness__c';
import CORE_SALES_INSIGHTS from '@salesforce/schema/Core_Opportunity_Support__c.CRM_Sales_Insights_Txt__c';
/*TWC4767-2678- End*/
import customerWinErrorMsg from '@salesforce/label/c.Customer_Win_error_msg';
import { CurrentPageReference } from 'lightning/navigation';

export default class Core_OppurtunitySupportButton extends NavigationMixin(LightningElement) {
    
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
    /*TWC4767-2678- Start*/
    cus_Will='';
    bus_chall ='';
    bus_resOut ='';
    why_intl ='';
    sol_sum ='';
    sales_inst ='';
    /*TWC4767-2678- End*/
    resetpage = false;
    accountName = '';
    oppName = '';
    techOwner = '';
    recordTypeOptions;
    @api recordTypeId='';
    @api recortypName = '';
    showFormRecordType = false;    
    checkRecordType= false;
    COERecordType = false;
    CSARecordType =false;
    MSRecordType = false; //TWC4767-2678
    onSave = false;
    conditionToQr = '';
    checkForCoE = false;
    isLoading =   false;
    tsshelptext = 'AI TSS – AI architect to dive into the related opportunity \nCCG ECG TSS – Technical Solution Specialist for CCG Edge related opportunity \nCCG TSS – Technical solutions specialist to dive into the CCG related opportunity \nDCAI TSS – Technical solutions support to a general DataCentre compute opportunity \nDAIS (DataCentre AI Solutions) TSS – Technical solutions specialist to support with data center workloads from generative AI and deep learning to analytics, HPC, and graphics.\nNTG TSS – Technical Solution Specialist for Networking & Telcom related opportunity';
    
    @wire(CurrentPageReference)
    pageRef;
    connectedCallback() {
        
        if ( this.pageRef.state.c__recId !=null) {
        this.recordId = this.pageRef.state.c__recId;
        this.recordTypeId= this.pageRef.state.c__type;
        this.recortypName=this.pageRef.state.c__typeName;
        
        }
        this.handleNextClick();
    }

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
      //Customer Willness Picklist value - TWC4767-2678- Start
      customWillPicklistValues = []    
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: CORE_CUSTOMER_WILLINGNESS,
      })
      getCusWillPicklistValues({ data, error }) {
        if (error) {
          console.error(error)
        } else if (data) {
          this.customWillPicklistValues = [...data.values]
          console.log('Picklist Options--' +JSON.stringify(this.customWillPicklistValues));
        }
      }
      //TWC4767-2678- End
    handleNextClick(){
        if(this.recortypName == 'Center of Excellence Request')
            this.CSARecordType=true;
        if(this.recortypName == 'Technical Sales Specialist Request') // TSS Request
            this.checkRecordType = true;
        if(this.recortypName == 'Center of Excellence Request')
            this.COERecordType = true;
        /*TWC4767-2678- Start*/
        if(this.recortypName == 'Marketing Support')
            this.MSRecordType = true; 
        /*TWC4767-2678- End*/ 
        if(this.recortypName == 'Cloud Solutions Architect Request')
            this.conditionToQr =  ' and Core_Status__c IN (\'Submitted\',\'Pending\')';
        
        this.checkRequestExsit();
    }

     checkRequestExsit(){
        this.isLoading = true;
        getdataForOpportunity({OpportunityId: this.recordId,oppSuprecorType: this.recordTypeId , whereCondition : this.conditionToQr})
			.then(data => {
                console.log('isThereAnOpenOpptSupportReq--'+ data.isThereAnOpenOpptSupportReq);
				if(!data.isThereAnOpenOpptSupportReq){
                    this.showForm=true; 
                    //this.showFormRecordType = true;              
                    this.opportunityData = data.oppDetails[0];
                    console.log('data in @@'+JSON.stringify(this.opportunityData));
                    this.opp_diesc =  this.opportunityData.Description;
                    this.techOwner =  this.opportunityData.Core_Technical_Owner__r != undefined ? this.opportunityData.Core_Technical_Owner__r.Name : '';
                    
                    if(data.isThereContactwithTechnicalOW && !this.checkForCoE && !this.MSRecordType)
                        this.displaymessage('warning','There should be at least 1 Opportunity Contact with the role "Technical Decision Maker"','warning'); 
                }
                else if(data.isThereAnOpenOpptSupportReq && this.MSRecordType){
                        this.displaymessage('Error',customerWinErrorMsg,'error');
                        this.showForm=false;
                        this.dispatchEvent(new CloseActionScreenEvent());
                        this.handleCancelNew();
                }
                else {
                    
                    if(this.checkForCoE){
                        this.checkForCoE = false;
                       // let combobox ;
                        if(this.recortypName == 'Technical Sales Specialist Request'){
                           let combobox = this.template.querySelector('[data-id="TSS_Support_Type"]');
                            combobox.setCustomValidity('There is already another Pending / Submitted Support Request created for this BU, Please select another BU.'); 
                            //combobox.setCustomValidity('There is a Support Request created for this BU, Please select another BU.'); 
                        }
                        else{
                            let combobox = this.template.querySelector('[data-id="Center_of_Excellence"]');
                            combobox.setCustomValidity('There is a Support Request created for this Center of Excellence. Please select another Category.');  
                        }                      
                    }
                    else{
                        this.displaymessage('Error','There is already another  Pending / Submitted Support Request which needs to be Closed.','error');
                        this.showForm=false;
                        this.dispatchEvent(new CloseActionScreenEvent());
                        this.handleCancelNew();
                    }
                } 
                this.isLoading = false;
			})
			.catch(error => {
                this.isLoading = false;
				console.log('error'+JSON.stringify(error));
			});

    }
    // Update values changed by user 
    async handleInputChange(event) {
        
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
            this.conditionToQr = '  and Core_Status__c IN (\'Submitted\',\'Pending\') and Core_TSS_Support_Type__c = '+ '\''+this.tss_Supp+'\'';
            const combobox = this.template.querySelector('[data-id="TSS_Support_Type"]');
            await combobox.setCustomValidity('');
            this.checkForCoE = true;
             new Promise((resolve, reject) => {
                setTimeout(() => {
                    this.checkRequestExsit();
                    resolve();
                }, 0);
            });
        }else if (fieldName === 'Center of Excellence'){
            this.coe_Supp = value;            
            this.conditionToQr = ' and Center_of_Excellence__c = '+ '\''+this.coe_Supp+'\'';
            const combobox = this.template.querySelector('[data-id="Center_of_Excellence"]');
            await combobox.setCustomValidity('');
            this.checkForCoE = true;
            new Promise((resolve, reject) => {
                setTimeout(() => {
                    this.checkRequestExsit();
                    resolve();
                }, 0);
            });            
        }

        //TWC4767-2678- Start
        else if (fieldName === 'Business Challenge') {
            this.bus_chall = value;
        }
        else if (fieldName === 'Customers Business Results/ Outcomes') {
            this.bus_resOut = value;
        }
        else if (fieldName === 'Why Intel') {
            this.why_intl = value;
        }
        else if (fieldName === 'Solution Summary') {
            this.sol_sum = value;
        }
        else if (fieldName === 'Sales Insights') {
            this.sales_inst = value;
        }
        else if (fieldName === 'Customer Willingness') {
            this.cus_Will = value;
        }
        //TWC4767-2678- End
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
            //TWC4767-2678- Start
            if(this.MSRecordType){
                fields[CORE_BUSINESS_CHALLENGE.fieldApiName] = this.bus_chall;
                fields[CORE_BUSINESS_RES_OUTCOME.fieldApiName] = this.bus_resOut;
                fields[CORE_WHY_INTEL.fieldApiName] = this.why_intl;
                fields[CORE_SOLUTION_SUMMARY.fieldApiName] = this.sol_sum;
                fields[CORE_CUSTOMER_WILLINGNESS.fieldApiName] = this.cus_Will;
                fields[CORE_SALES_INSIGHTS.fieldApiName] = this.sales_inst;
            }
            //TWC4767-2678- End
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
                        this.handleCancelNew();                       
                    });
                    setTimeout(function() {
                        window.location.reload();
                    }, 1000);
                         
                })
                .catch((error) => {
                    console.log('error'+JSON.stringify(JSON.stringify(error))); 
                    this.displaymessage('Error creating record','A resource has not been allocated in your region. Please reach out to your regional management team for support','error');   
                    this.handleCancelNew();     
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

        const selectEvent = new CustomEvent('mycustomevent', {
        });
       this.dispatchEvent(selectEvent);
    
     
    } 

}