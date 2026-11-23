import { LightningElement, track, wire, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import ACTIVITY_NUMBER from '@salesforce/schema/PartnerFundRequest.Core_MDF_Activity_Number__c';
import ACTIVITY_NAME from '@salesforce/schema/PartnerFundRequest.Title';
import ACTIVITY_SPENDING_LIMIT_LOCAL from '@salesforce/schema/PartnerFundRequest.Core_MDF_Budget_Amount_Local_amt__c';
import REIMBURSEMENT_RATE from '@salesforce/schema/PartnerFundRequest.Core_MDF_Reimbursement_Rate_txt__c';
import ACTIVITY_RESERVED_AMOUNT from '@salesforce/schema/PartnerFundRequest.Allocation.Core_MDF_Total_Activity_Allocated_Amount__c';

const fields = [ACTIVITY_NUMBER, ACTIVITY_NAME, ACTIVITY_SPENDING_LIMIT_LOCAL, REIMBURSEMENT_RATE, ACTIVITY_RESERVED_AMOUNT];

export default class Core_MDF_Open_Activity extends LightningElement {

  @api recordId;
  isDisabled = true;
  amountValue;
  activityRecord;
  isInValidAmount = false;

  @wire(getRecord, { recordId: '$recordId', fields })
  activity({ error, data }) {
    if (data) {
      console.log('data from wire-->', JSON.stringify(data));
      this.activityRecord = data;
    } else if (error) {
    }
  }

  get activityNumber() {
    return getFieldValue(this.activityRecord, ACTIVITY_NUMBER);
  }

  get activityName() {
    return getFieldValue(this.activityRecord, ACTIVITY_NAME);
  }

  get activitySpendingLimitLocal() {
    return getFieldValue(this.activityRecord, ACTIVITY_SPENDING_LIMIT_LOCAL);
  }

  get reimbursementRate() {
    return getFieldValue(this.activityRecord, REIMBURSEMENT_RATE);
  }

  get activityReservedAmount() {
    return getFieldValue(this.activityRecord, ACTIVITY_RESERVED_AMOUNT);
  }

  handleAmountChange(event) {
    this.amountValue = event.detail.value;
    if(this.amountValue > getFieldValue(this.activityRecord, ACTIVITY_RESERVED_AMOUNT)){
      this.isInValidAmount = true;
    }else{
      this.isInValidAmount = false;
    }
    console.log('onchange value-->', this.amountValue);
  }

  handleCloseModal() {
    const closeModal = new CustomEvent('closemodal', {});
    this.dispatchEvent(closeModal);
  }
}