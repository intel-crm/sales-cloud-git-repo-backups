/*
PSG_Quote_Int_Record_Page Quote record page opportunity details section
*/
import { api,wire,track, LightningElement } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import OPPORTUNITY_ID_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__c';
import OPPORTUNITY_OWNER_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.OwnerId';

export default class psg_OpportunityDetails extends LightningElement {
    @api recordId;
    @track quote;
    @api parentfields = ["Name","Core_Opportunity_ID__c","Core_Design_Registration_Id__c","CloseDate","Core_First_Customer_Ship_Date__c","Core_Production_End_Date__c","Core_Volume__c","Core_Product_Segment__c","Core_Product_Application__c","Core_Opportunity_Owner__c"];
    @api parentfieldsulti = ['Email'];
    @wire(getRecord, { recordId: '$recordId', fields: [OPPORTUNITY_ID_FIELD,OPPORTUNITY_OWNER_FIELD]})
    quote;
    get oppid() {
        console.log('get opp id');
        return getFieldValue(this.quote.data, OPPORTUNITY_ID_FIELD);
    }

    get userid() {
        console.log('get user id');
        return getFieldValue(this.quote.data, OPPORTUNITY_OWNER_FIELD);
    }
    connectedCallback(){

    } 
}