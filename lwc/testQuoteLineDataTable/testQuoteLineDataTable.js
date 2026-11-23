import { LightningElement,track,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getQLData from '@salesforce/apex/PSG_UploadFile.getQLData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class TestQuoteLineDataTable extends LightningElement {
 @api recordId;
 @api tabledata;
 @track data ;
 @track error;
 @track qlColumns=[
    //{fieldName:'PSG_Product_Nm__c',label:'Product/Part#',type: 'text' },
    {fieldName:'PSG_Requested_Qty_qty__c',label:'EAU Quantity',type: 'Integer'},
    {fieldName:'PSG_Years_Nbr__c',label:'# Years',type: 'Integer'},
    {fieldName:'PSG_Requested_Resale_Amt__c',label:'Requested Resale',type: 'currency'},
    {fieldName:'PSG_Production_Dt__c',label:'Production Start Date',type: 'Date'}   
]; 
/*
@wire(getQLData, { quoteID: '$recordId'})
wiredOpps({
    error,
    data
}) {
    if (data) {
        this.data = data;
        console.log(data);
        console.log(JSON.stringify(data, null, '\t'));
    } else if (error) {
        this.error = error;
    }
}
*/

connectedCallback(){
getQLData({quoteId: this.recordId})
.then(result => {
    this.tabledata = result;
    console.log('test '+result);
    console.log('test1 '+result.data);
})
.catch(error => {
    this.showLoadingSpinner = false;
    console.log(error);
    window.console.log(error);
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error while uploading File',
            message: error.message,
            variant: 'error',
        }),
    );
});
}
}