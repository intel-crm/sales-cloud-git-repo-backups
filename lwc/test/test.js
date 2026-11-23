import { LightningElement, track, wire } from 'lwc';
//import getCustomObjectRecords from '@salesforce/apex/CustomObjectController.getCustomObjectRecords';
import getCustomObjectRecords from '@salesforce/apex/PCC_LineItemController.getLineItems1';
const COLUMNS = [
    { label: 'Record Name', fieldName: 'Name' },
    { label: 'Field 1', fieldName: 'PCC_Registration_Type__c' },
    { label: 'Field 2', fieldName: 'Core_Product_Group_Nm__c' }
];

export default class CustomObjectDatatable extends LightningElement {
    @track customObjectData;
    @track columns = COLUMNS;

    @wire(getCustomObjectRecords)
    wiredCustomObjectData({ error, data }) {
        if (data) {
            this.customObjectData = data;
        } else if (error) {
            console.error('Error retrieving custom object records', error);
        }
    }
}