import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createCPRecords from '@salesforce/apex/QuoteLogic.createCPRecords';


const columns = [
{ label: 'Quote', fieldName: 'SBQQ__Quote__c', type: 'lookup',  editable: 'true', typeAttributes: {
    placeholder: 'Select Quote',
    uniqueId: { fieldName: 'Id' }, //pass Id of current record to lookup for context
    object: "SBQQ__Quote__c",
    icon: "standard:product",
    label: "Quote",
    displayFields: "Name",
    displayFormat: "Name",
    filters: "",
    defaultRecord: {fieldName: 'SBQQ__Quote__c'},
}},
{ label: 'Price', fieldName: 'SBQQ__Price__c', type: 'currency', },
{ label: 'Discount', fieldName: 'SBQQ__Discount__c', type: 'number', editable: 'true' },
{ label: 'Effective Date', fieldName: 'SBQQ__EffectiveDate__c', type: 'date', editable: 'true' },
{ label: 'Lower Quantity', fieldName: 'PSG_Lower_Qty_Nbr__c', type: 'number', editable: 'true' },
{ label: 'Upper Quantity', fieldName: 'PSG_Upper_Qty_Nbr__c', type: 'number', editable: 'true' },



];

export default class PSG_DynamicDataTableUI extends LightningElement {
    @track records;
    @api recordJson;
    @track columns=columns;
    submit(event) {
         var table = this.template.querySelector("c-p-s-g_-dynamic-table");
         if(table!=undefined)
         {
             this.records = table.retrieveRecords();
 
             console.log(JSON.stringify(this.records));
             createCPRecords({ lstCPRecords : this.records })
             .then(result => {
                 this.message = result;
                 this.error = undefined;                
                 
                 //this.accountRecList = [];
                 if(this.message !== undefined) {
                     this.dispatchEvent(
                         new ShowToastEvent({
                             title: 'Success',
                             message: 'Accounts Created!',
                             variant: 'success',
                         }),
                     );
                 }
 
                 console.log(JSON.stringify(result));
                 console.log("result", this.message);
             })
             .catch(error => {
                 this.message = undefined;
                 this.error = error;
                 
                 console.log("error", JSON.stringify(this.error));
                 this.dispatchEvent(
                     new ShowToastEvent({
                         title: 'Error creating records',
                         message: error.body.message,
                         variant: 'error',
                     }),
                 );
             });
         }
     }
}