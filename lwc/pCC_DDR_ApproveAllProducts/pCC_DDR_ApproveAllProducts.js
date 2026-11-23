import { LightningElement,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import approveProductd from '@salesforce/apex/PCC_DRR_ApproveAllPendingProducts.approvalAllpendingProd';

export default class PCC_DDR_ApproveAllProducts extends LightningElement {
    @api recordId;
   
    loadFields({ error, data }) {
        if (data) { }
    }

}