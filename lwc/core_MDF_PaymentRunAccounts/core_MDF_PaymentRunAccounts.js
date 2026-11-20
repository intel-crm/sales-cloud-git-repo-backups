import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import applicationErrorMsg from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import applicationErrorTitle from '@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle';

import getAccounts from '@salesforce/apex/Core_MDF_PaymentRunAccounts.fetchAccounts';
export default class core_MDF_PaymentRunAccounts extends LightningElement {
    @api recordId;
    @track accountList;
    @track columns = [
        { label: 'Account Name', fieldName: 'Name', type: 'text',hideDefaultActions: true}];
        label = {applicationErrorMsg,applicationErrorTitle};
    @wire(getAccounts, {paymentRunId: '$recordId'}) 
    WireAccountRecords({error, data}){
        if(data){
            this.accountList = data;
            this.error = undefined;
        }else if(error){
            this.error = error;
            this.displayErrorMessageOnServerException();
        }
    }
/* Displaying Errors As a toast Message On Server Side Exception */
displayErrorMessageOnServerException() {
    const evt = new ShowToastEvent({
        title: this.label.applicationErrorTitle,
        message: this.label.applicationErrorMsg,
        variant: 'error',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}
}