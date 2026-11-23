import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import OPTY_ID from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__c';
import OWNER_ID from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.OwnerId';

export default class PSG_OpportunityDetailOnQuote extends LightningElement {
    @api recordId;
    @wire(getRecord, {
		recordId: "$recordId",
    
    fields: [OPTY_ID,OWNER_ID]
	})
    optyData;

    get optyId() {
		return getFieldValue(this.optyData.data, OPTY_ID);	}
    get ownerId() {
		return getFieldValue(this.optyData.data, OWNER_ID);
  }    

    fields = ["Name","Core_Opportunity_ID__c","Core_Design_Registration_Id__c","CloseDate","Core_First_Customer_Ship_Date__c","Core_Production_End_Date__c",
                "Core_Volume__c","Core_Product_Segment__c","Core_Product_Application__c","Core_Opportunity_Owner__c"];
    fieldsOwner =["Email"];
}