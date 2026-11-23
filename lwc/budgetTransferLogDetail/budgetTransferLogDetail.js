import { LightningElement, api } from 'lwc';

import ACCOUNT_TRANSFER_LOGS_OBJECT from '@salesforce/schema/Core_MDF_Budget_Transfer_Log__c';

export default class BudgetTransferLogDetail extends LightningElement {

    @api recordId;
    accountTransferLogObject  = ACCOUNT_TRANSFER_LOGS_OBJECT;
    handleSucccessOnEdit(){
    
    }
}