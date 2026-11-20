import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import PCC_DraftStatusMessage from '@salesforce/label/c.PCC_DraftStatusMessage';
import PCC_DealDraftStatusMessage from '@salesforce/label/c.PCC_DealDraftStatusMessage';
import DealRegLabel from '@salesforce/label/c.IPA_DealRegistrationText';
import DesignRegLabel from '@salesforce/label/c.PRM_DDRBreadCrumb_Text';
import fetchUserPermissions from '@salesforce/apex/Core_DDR_Design_Handler_Utility.getDealDesignRecDetails';
import { getRecord } from 'lightning/uiRecordApi';
import PRODUCT_SEGMENT_FIELD from '@salesforce/schema/Opportunity.Core_Product_Segment__c';
import PRODUCT_GROUP_FIELD from '@salesforce/schema/Core_Design_Registration__c.Core_Product_Group_Nm__c';
import LOOKUP_OPPORTUNITY_FIELD from '@salesforce/schema/Core_Design_Registration__c.Core_Opportunity_Id__c';
import PRODUCT_SEGMENTDESIGN_FIELD from '@salesforce/schema/Core_Design_Registration__c.Core_Product_Segment_Nm__c';
import PRODUCT_APPLICATION_FIELD from '@salesforce/schema/Core_Design_Registration__c.Core_Product_Application_Nm__c';
import INTEL_PLATFORM_FIELD from '@salesforce/schema/Core_Design_Registration__c.Core_Intel_Platform_Nm__c';
import VERTICAL_MARKET_FIELD from '@salesforce/schema/Core_Design_Registration__c.Core_Vertical_Market_Nm__c';
import REG_STATUS_FIELD from '@salesforce/schema/Core_Design_Registration__c.Core_Design_Registration_Status_Nm__c';
import validateInactivepicklist from '@salesforce/apex/Core_DDR_Accept_Approve_Reject_Design.validateInactiveLOVPartner';

const DESIGN_PICKLIST_FIELDS = [REG_STATUS_FIELD,PRODUCT_SEGMENTDESIGN_FIELD,PRODUCT_APPLICATION_FIELD,INTEL_PLATFORM_FIELD,VERTICAL_MARKET_FIELD];

const DESIGN_REGISTRATION_FIELDS = [PRODUCT_GROUP_FIELD, LOOKUP_OPPORTUNITY_FIELD];
const OPPORTUNITY_FIELDS = [PRODUCT_SEGMENT_FIELD];

export default class pCC_DisplayDraftStatus extends LightningElement {
    @api recordId;
    @track showWarning = false;
    @track displayText = false;
    @track displayDealStatus = false;
    @track inactivePicklists;
    @track inactivePicklist = false;
    @track opportunityId;
    @track productGroup;

    label = {
        PCC_DraftStatusMessage,
        PCC_DealDraftStatusMessage,
        DealRegLabel,
        DesignRegLabel,
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }

    connectedCallback() {
       this.checkPermissionSet();
    }

        checkPermissionSet(){
            fetchUserPermissions({recId: this.recordId})
            .then((data) =>{
                if(data.PCC_Registration_Type__c===DealRegLabel && data.Core_Design_Registration_Status_Nm__c==='Draft'){
                    this.displayDealStatus =true;
                } 
                if(data.PCC_Registration_Type__c===DesignRegLabel){                 
                    if(data.Core_Design_Registration_Status_Nm__c==='Draft'){
                    console.log('Inside Design reg label');
                    this.displayText = true;
                    }this.ValidateInactiveLOVV;
                } 
            })
            .catch((error) => {
                this.error = error;
            });
    }
    @wire(getRecord, { recordId: '$recordId', fields: DESIGN_PICKLIST_FIELDS })
    ValidateInactiveLOVV({error,data}){
        if(data){
            const dr = {};
            dr.Core_Product_Segment_Nm__c=data.fields.Core_Product_Segment_Nm__c.value;
            dr.Core_Product_Application_Nm__c=data.fields.Core_Product_Application_Nm__c.value;
            dr.Core_Intel_Platform_Nm__c=data.fields.Core_Intel_Platform_Nm__c.value;
            dr.Core_Vertical_Market_Nm__c=data.fields.Core_Vertical_Market_Nm__c.value;
            dr.Core_Design_Registration_Status_Nm__c=data.fields.Core_Design_Registration_Status_Nm__c.value;
            console.log('dr-->',dr);
            if(dr.Core_Design_Registration_Status_Nm__c!='Abandoned' && dr.Core_Design_Registration_Status_Nm__c!='Cancelled' &&
                dr.Core_Design_Registration_Status_Nm__c!='Rejected' && dr.Core_Design_Registration_Status_Nm__c!='Expired'){
                validateInactivepicklist({designReg: JSON.stringify(dr)})
            .then((result) =>{
                console.log('resss',result);
                if (result && result.trim() !== '') {
                    this.inactivePicklists=result;
                    this.inactivePicklist = true;  }
                    console.log('this.inactivePicklists',this.inactivePicklists);
            })
            }
            
        }
    }
   
    @wire(getRecord, { recordId: '$recordId', fields: DESIGN_REGISTRATION_FIELDS })
    wiredDesignRegistrationResult({ error, data }) {
        if (data) {
            console.log('Design Registration:',data);
            this.productGroup = data.fields.Core_Product_Group_Nm__c.value;
            this.opportunityId = data.fields.Core_Opportunity_Id__c.value;
            if (this.productGroup === 'Embedded/IOT') {
                // Fetch opportunity data when product group is 'Embedded/IOT'
                this.fetchOpportunityData();
            } else {
                this.showWarning = false;
            }
        } else if (error) {
            console.error('Error fetching design registration data: ', error);
        }
    }

    @wire(getRecord, { recordId: '$opportunityId', fields: OPPORTUNITY_FIELDS })
    wiredOpportunityResult({ error, data }) {
        if (data) {
            console.log('Opportunity:',data);
            const productSegment = data.fields.Core_Product_Segment__c.value;
            if (this.productGroup === 'Embedded/IOT' && productSegment !== 'Comms Infra. / Networking' && productSegment !== 'Embedded / IOT') {
                this.showWarning = true;
            } else {
                this.showWarning = false;
            }
        } else if (error) {
            console.error('Error fetching opportunity data: ', error);
        }
    }

    fetchOpportunityData() {
        // Trigger the wired function by updating the opportunityId
        this.opportunityId = this.opportunityId;
    }
}