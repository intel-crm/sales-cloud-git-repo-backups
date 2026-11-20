import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Account.Name',
    'Account.AccountNumber',
    'Account.Core_IPA_Badge_Tier__c',
    'Account.Core_User_Defined_Website__c',
    'Account.PRM_IPA_Badge_Tier_Date__c'
    
];

export default class PRM_AccountLayout extends LightningElement {
    @api recordId;
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    account;
    
    get isLoaded() {
        return this.account && this.account.data;
    }
    
    get accountData() {
        if (!this.isLoaded) return {};
        
        return {
            name: this.account.data.fields.Name.value,
            accountNumber: this.account.data.fields.AccountNumber.value,
            badgeTier: this.account.data.fields.Core_IPA_Badge_Tier__c.value,
            userDefinedWebsite: this.account.data.fields.Core_User_Defined_Website__c.value,
            badgeTierDate: this.account.data.fields.PRM_IPA_Badge_Tier_Date__c.value
            
        };
    }
    
    
}