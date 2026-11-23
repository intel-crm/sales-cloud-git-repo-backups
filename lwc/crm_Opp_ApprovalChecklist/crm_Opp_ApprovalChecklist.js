import { LightningElement, wire, api, track } from "lwc";
import { CurrentPageReference,NavigationMixin } from "lightning/navigation";
import Core_SearchIcon from '@salesforce/resourceUrl/Core_SearchIcon';
import Checklist_Red from '@salesforce/resourceUrl/Checklist_Red';
import Checklist_Green from '@salesforce/resourceUrl/Checklist_Green';
import Checklist_Yellow from '@salesforce/resourceUrl/Checklist_Yellow';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Opportunity.Name";
import STAGE_FIELD from "@salesforce/schema/Opportunity.StageName";
import OPP_TYPE_FIELD from "@salesforce/schema/Opportunity.Core_Opportunity_Type__c";
import PROD_ATRISK_FIELD from "@salesforce/schema/Opportunity.Core_Product_At_Risk__c";
import COMMISSIONABLE_FIELD from "@salesforce/schema/Opportunity.Core_Commissionable__c";
import COMP_ARCH_FIELD from "@salesforce/schema/Opportunity.Core_Competitive_Architecture__c";
import DESCRIPTION_FIELD from "@salesforce/schema/Opportunity.Description";
import STATUS_FIELD from "@salesforce/schema/Opportunity.Core_Status_Update__c";
import MANU_GEO_FIELD from "@salesforce/schema/Opportunity.Core_Manufacturing_Geo__c";
import VOLUME_FIELD from "@salesforce/schema/Opportunity.Core_Volume__c";
import OPP_CVG_FIELD from "@salesforce/schema/Opportunity.Core_Opportunity_Coverage_Nm__c";
import Core_InactiveAccountLabel from '@salesforce/label/c.Core_InactiveAccountLabel';
import Core_InactiveVendorLabel from '@salesforce/label/c.Core_InactiveVendorLabel';
import fetchData from "@salesforce/apex/CRM_Opp_ApprovalChecklistController.fetchData";
import getCustomLabels from "@salesforce/apex/CRM_Opp_ApprovalChecklistController.getCustomLabels";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const fields = [NAME_FIELD,STAGE_FIELD,OPP_TYPE_FIELD,PROD_ATRISK_FIELD,COMMISSIONABLE_FIELD,STATUS_FIELD,DESCRIPTION_FIELD,COMP_ARCH_FIELD,MANU_GEO_FIELD,VOLUME_FIELD,OPP_CVG_FIELD];
const designType = ['Design: Original','Design: Secondary','Design: Software-enable'];

export default class Crm_Opp_ApprovalChecklist extends NavigationMixin(LightningElement) {

    label = {Core_InactiveAccountLabel,Core_InactiveVendorLabel};

    @api oppId;
    @track wrappedData = [];
    @track oliWrappedData = [];
    attachmentDW = false;
    attachmentPW = false;
    riskURL;
    @track textWrapper =[];
    loaded = false;

    @wire(CurrentPageReference)
    currentPageRef;

    get oppId() {
        return this.currentPageRef.state.c__oppId;
    }

    @wire(getRecord, {recordId: "$oppId", fields})
    opportunity;

    get name() {
        return getFieldValue(this.opportunity.data, NAME_FIELD);
    }

    get atRisk() {
        return getFieldValue(this.opportunity.data, PROD_ATRISK_FIELD);
    }

    get iconUrl() {
        return Core_SearchIcon;
    }

    get greenIcon() {
        return Checklist_Green;
    }

    get redIcon() {
        return Checklist_Red;
    }

    get yellowIcon() {
        return Checklist_Yellow;
    }

    get attachmentRender() {
        if(this.wrappedData.Note_Attachmentsize == false) {
            this.attachmentDW = true;
            if(getFieldValue(this.opportunity.data, COMMISSIONABLE_FIELD) === 'Yes') {
                return true;
            }
            else if(getFieldValue(this.opportunity.data, COMMISSIONABLE_FIELD) === 'No'){
                return false;
            }
        }
        else{
            this.attachmentDW = false;
            return false;
        }
    }

    get pWattachmentRender(){
        this.getWrapperData();
        
        if(getFieldValue(this.opportunity.data, COMMISSIONABLE_FIELD) === 'Yes' && this.wrappedData.PW_Note_Attachmentsize == false) {
            this.attachmentPW = true;
            return true;
        }
        else if(getFieldValue(this.opportunity.data, COMMISSIONABLE_FIELD) === 'No' && this.wrappedData.PW_Note_Attachmentsize == false){
            this.attachmentPW = true;
            return false;
        }
        else{
            this.attachmentPW = false;
            return false;
        }
    }

    get pageblocksectionredender() {
        if(designType.includes(getFieldValue(this.opportunity.data, OPP_TYPE_FIELD))){
            return true;
        }
        else{
            return false;
        }
    }

    get compArchRender() {
        if(getFieldValue(this.opportunity.data, COMP_ARCH_FIELD) == null || getFieldValue(this.opportunity.data, COMP_ARCH_FIELD) == undefined) {
            return true;
        }
        else{
            return false;
        }
    }

    get volumeRender() {
        if(getFieldValue(this.opportunity.data, VOLUME_FIELD) == null || getFieldValue(this.opportunity.data, VOLUME_FIELD) == undefined) {
            return true;
        }
        else{
            return false;
        }
    }

    get excludeVolume() {
        if(getFieldValue(this.opportunity.data, OPP_CVG_FIELD) == 'Intel-Led Opportunity') {
            return true;
        }
        else{
            return false;
        }
    }

    get statusUpdateRender() {
        if(getFieldValue(this.opportunity.data, STATUS_FIELD) == null || getFieldValue(this.opportunity.data, STATUS_FIELD) == undefined) {
            return true;
        }
        else{
            return false;
        }
    }

    get manufacturingRegionRender() {
        if(getFieldValue(this.opportunity.data, MANU_GEO_FIELD) == null || getFieldValue(this.opportunity.data, MANU_GEO_FIELD) == undefined || getFieldValue(this.opportunity.data, MANU_GEO_FIELD) == '') {
            return true;
        }
        else{
            return false;
        }
    }

    get descriptionCheckRender() {
        if(getFieldValue(this.opportunity.data, DESCRIPTION_FIELD) == null || getFieldValue(this.opportunity.data, DESCRIPTION_FIELD) == undefined) {
            return true;
        }
        else{
            return false;
        }
    }

    connectedCallback() {
        this.getWrapperData();
        setTimeout(() => {
            this.loaded = true;
        }, 3000);
        console.log('AA connected')
    }

    /*@wire(fetchData,{oppId : "$oppId"})
    getWrapperData({data,error}) {
        if(data){
            console.log('AA data frm Apex::'+JSON.stringify(data));
            this.wrappedData = data === undefined ? [] : data;
            console.log('AA wrappedData frm Apex::'+JSON.stringify(this.wrappedData));
            this.oliWrappedData = this.wrappedData.OliWrapper === undefined ? [] : this.wrappedData.OliWrapper;
            console.log('AA wrappedData oliwr frm Apex::'+JSON.stringify(this.wrappedData.OliWrapper)+JSON.stringify(data.OliWrapper));
            console.log('AA oliWrappedData frm Apex::'+JSON.stringify(this.wrappedData.DescriptiveFeature)+JSON.stringify(this.oliWrappedData));
        }
        if(error){
            console.log('AA error frm Apex::'+error);
        }
    }*/

    getWrapperData() {
       fetchData({oppId : this.oppId})
       .then(data=>{
            this.wrappedData = data === undefined ? [] : data;
            this.oliWrappedData = this.wrappedData.OliWrapper === undefined ? [] : this.wrappedData.OliWrapper;
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

    @wire(getCustomLabels,{})
    getCustomLabels({error,data}){
        if(data){
            this.textWrapper = data;
            this.riskURL=this.textWrapper.riskURL+this.oppId;
        }else{
            console.log('Error:',JSON.stringify(error));

        }
    }

    navigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.oppId,
                actionName: 'view'
            }
        });
    }
    
}