import { LightningElement,api,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import excessAmountField from '@salesforce/schema/PartnerFundClaim.Core_MDF_Excess_Requested_Amount__c';
import excessRequestedAmountMessage from '@salesforce/label/c.Core_MDF_Claim_amount_exceeding_activity_limit';
const fields = [excessAmountField];
export default class Core_MDF_ClaimAmountExceedingLimitMessage extends LightningElement {

    @api recordId;
    label = {excessRequestedAmountMessage};
    @wire(getRecord, { recordId: '$recordId', fields })
    claim;
    get hasExcessRequestedAmount() {
        
          // hasExcessRequestedAmount
        if(getFieldValue(this.claim.data, excessAmountField) >0){
            console.log('isAmountExceeding', this.claim.data);
            console.log('isAmountExceeding', getFieldValue(this.claim.data, excessAmountField));
            return true;
        }
        else{
            return false;
        }
    }
}