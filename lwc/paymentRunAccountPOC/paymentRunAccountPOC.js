import { LightningElement,api,wire,track } from 'lwc';
import getAccounts from '@salesforce/apex/Core_MDF_PaymentRunAccounts.fetchAccounts';
export default class PaymentRunAccountPOC extends LightningElement {
    @api recordId;
    @track accountList;
    @track columns = [
        { label: 'Account Name', fieldName: 'Name', type: 'text',hideDefaultActions: true}];
    @wire(getAccounts, {paymentRunId: '$recordId'}) 
    WireAccountRecords({error, data}){
        if(data){
            this.accountList = data;
            this.error = undefined;
        }else{
            this.error = error;
            this.accountList = undefined;
        }
    }

}