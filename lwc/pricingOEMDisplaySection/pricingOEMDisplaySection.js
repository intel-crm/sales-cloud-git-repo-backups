import { LightningElement, api, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import getAccountIdCommentsMapping from '@salesforce/apex/Pricing_CommentsController.getAccountIdCommentsMapping';
const FIELDS = ["SBQQ__Quote__c.SBQQ__Account__c", "SBQQ__Quote__c.Pricing_On_Hold_Cb__c", "SBQQ__Quote__c.Name"];
export default class PricingOEMDisplaySection extends LightningElement {

    @api recordId;

    quoteData;
    error;
    accountId;
    isPricingOnHold = false;
    accountComments;
    showAccountComments = false;
    isOEM = false;
    mailToText;
    showHoldPannel = false;

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    async getQuoteData({ error, data }) {
        if (data) {
            this.quoteData = JSON.parse(JSON.stringify(data));
            this.accountId = this.quoteData.fields.SBQQ__Account__c.value;
            this.isPricingOnHold = this.quoteData.fields.Pricing_On_Hold_Cb__c.value;
            this.mailToText = 'mailto:DealValidation@intel.com?subject=' + this.quoteData.fields.Name.value;
            if (this.accountId.length > 0) {
                await getAccountIdCommentsMapping({ accountId: this.accountId })
                    .then(result => {
                        if (result != undefined && result != null && result != '') {
                            let comments1 = (result.Comments_Part_1__c != undefined && result.Comments_Part_1__c != null && result.Comments_Part_1__c != '') && result.Comments_Part_1__c.length > 0 ? result.Comments_Part_1__c :'';
                            let comments2 = (result.Comments_Part_2__c != undefined && result.Comments_Part_2__c != null && result.Comments_Part_2__c != '') && result.Comments_Part_2__c.length > 0 ? result.Comments_Part_2__c :'';
                            this.accountComments = comments1 + comments2;
                        }
                        this.showAccountComments = typeof(this.accountComments) !== 'undefined' && this.accountComments.length > 0 ? true: false;
                    })
                    .catch(error => {
                        console.error('Error @ getAccountIdCommentsMapping ', error);
                    });
            }
            this.showHoldPannel = (this.isPricingOnHold || this.showAccountComments) ? true : false;

        } else if (error) {
            console.error('Error @ getQuoteData '+ error);
        }
    }
}