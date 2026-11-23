import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Opportunity.Name";
import STAGE_FIELD from "@salesforce/schema/Opportunity.StageName";
import OPP_TYPE_FIELD from "@salesforce/schema/Opportunity.Core_Opportunity_Type__c";
import PROD_ATRISK_FIELD from "@salesforce/schema/Opportunity.Core_Product_At_Risk__c";
import COMMISSIONABLE_FIELD from "@salesforce/schema/Opportunity.Core_Commissionable__c";
import COMP_ARCH_FIELD from "@salesforce/schema/Opportunity.Core_Competitive_Architecture__c";
import DESCRIPTION_FIELD from "@salesforce/schema/Opportunity.Description";
import STATUS_FIELD from "@salesforce/schema/Opportunity.Core_Status_Update__c";
import fetchData from "@salesforce/apex/CRM_Opp_ApprovalChecklistController.fetchData";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const fields = [NAME_FIELD,STAGE_FIELD,OPP_TYPE_FIELD,PROD_ATRISK_FIELD,COMMISSIONABLE_FIELD,STATUS_FIELD,DESCRIPTION_FIELD,COMP_ARCH_FIELD];
const approvedStages = ['Design Win','Production Win','Production Lost','Production Cancelled '];
const lostCancelledStages = ['Lost','Cancelled'];
const openStages = ['Define','Develop','Design'];
const designType = ['Design: Original','Design: Secondary','Design: Software-enable'];

export default class Crm_Opp_PreSubmitChecklist extends NavigationMixin(LightningElement) {

    @api recordId;
    @track wrappedData = [];
    @track oliWrappedData = [];
    arReviewtheList = false;
    completeflag = false;


    @wire(getRecord, {recordId: "$recordId", fields})
    opportunity;

    get ListtoReview(){
        if(getFieldValue(this.opportunity.data, STAGE_FIELD) == 'Qualify'){
            return true;
        }
        else{
            return false;
        }
    }

    get Approvedflag(){
        if(approvedStages.includes(getFieldValue(this.opportunity.data, STAGE_FIELD))){
            return true;
        }
        else{
            return false;
        }
    }

    get noLinkflag(){
        if(lostCancelledStages.includes(getFieldValue(this.opportunity.data, STAGE_FIELD))){
            return true;
        }
        else{
            return false;
        }

    }
    get ARReviewtheListcheck(){
        this.getWrapperData();
        return this.arReviewtheList;
    }

    get Completeflagcheck(){
        this.getWrapperData();
        return this.completeflag;
    }
    
    connectedCallback() {
        this.getWrapperData();
    }
    /*@wire(fetchData,{oppId : '$recordId'})
    getWrapperData({data,error}) {
        if(data){
            console.log('AA data frm Apex::'+JSON.stringify(data));
            this.wrappedData = data === undefined ? [] : data;
            console.log('AA wrappedData frm Apex::'+JSON.stringify(this.wrappedData));
            this.oliWrappedData = this.wrappedData.OliWrapper === undefined ? [] : this.wrappedData.OliWrapper;
            this.arReviewtheList = this.wrappedData.ARReviewtheList;
            this.completeflag = this.wrappedData.Completeflag;
            console.log('AA wrappedData oliwr frm Apex::'+JSON.stringify(this.wrappedData.OliWrapper)+JSON.stringify(data.OliWrapper));
            console.log('AA oliWrappedData frm Apex::'+JSON.stringify(this.wrappedData.DescriptiveFeature)+JSON.stringify(this.oliWrappedData));
        }
        if(error){
            console.error('AA error frm Apex::'+JSON.stringify(error));
        }
    }*/

    getWrapperData() {
       fetchData({oppId : this.recordId})
       .then(data=>{
            this.wrappedData = data === undefined ? [] : data;
            this.oliWrappedData = this.wrappedData.OliWrapper === undefined ? [] : this.wrappedData.OliWrapper;
            this.arReviewtheList = this.wrappedData.ARReviewtheList;
            this.completeflag = this.wrappedData.Completeflag;
       })
       .catch(error=>{
            console.error('AA error frm Apex::'+JSON.stringify(error));
            if(error!==''){
                const evnt = new ShowToastEvent({
                    title : error.statusText +' !!',
                    message : error.body.exceptionType +'::'+ error.body.stackTrace,
                    variant : 'Error',
                    mode : 'dismissable'
                });
                this.dispatchEvent(evnt);
            }
       })
    }
    

    navigateToApprovalChecklist(){
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__crm_Opp_ApprovalChecklist",
            },
            state: {
                c__oppId: this.recordId,
            },
        });
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 300);
    }

}