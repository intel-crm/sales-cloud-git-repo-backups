import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import AGENTIC_DRAFTING_STATUS_FIELD from '@salesforce/schema/Executive_Meeting_Brief__c.CRM_Agentic_Drafting_Status__c';

export default class Crm_EMB_Agentic_Status extends LightningElement {
    @api recordId;
    
    @wire(getRecord, { 
        recordId: '$recordId', 
        fields: [AGENTIC_DRAFTING_STATUS_FIELD] 
    })
    embRecord;

    get agenticDraftingStatus() {
        return getFieldValue(this.embRecord.data, AGENTIC_DRAFTING_STATUS_FIELD);
    }
}