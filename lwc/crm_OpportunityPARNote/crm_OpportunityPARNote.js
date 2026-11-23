import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import CORE_IPS_PREMIER_SUPPORT_PROJECT from '@salesforce/schema/Core_IPS_Opportunity_PAR__c.Core_IPS_Premier_Support_Project__c';
import CORE_IPS_PREMIER_SUPPORT_PROJECT_STATUS from '@salesforce/schema/Core_IPS_Opportunity_PAR__c.Core_IPS_Premier_Support_Project__r.Core_Status__c';

const FIELDS = [
    CORE_IPS_PREMIER_SUPPORT_PROJECT,
    CORE_IPS_PREMIER_SUPPORT_PROJECT_STATUS
];

export default class Crm_OpportunityPARNote extends LightningElement {
    @api recordId;
    showNote = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    WiredOpportunityPAR({ data, error }) {
        if (data) {
            console.log('data:', data);
            const premier_Support_Project = data.fields.Core_IPS_Premier_Support_Project__c.value;
            const premier_Support_Project_Status = data.fields.Core_IPS_Premier_Support_Project__r.value.fields.Core_Status__c.value;
            console.log('support: '+JSON.stringify(premier_Support_Project));
            if (premier_Support_Project == null || (premier_Support_Project !== null && premier_Support_Project_Status === 'Draft')) {
                this.showNote = true;
            }
        } else if (error) {
            console.error('Error fetching record:', error);
        }
    }
}