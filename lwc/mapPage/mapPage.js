import { LightningElement } from 'lwc';

export default class MapPage extends LightningElement {

    salutationsList = [
        { label: 'None', value: 'None' },
        { label: 'Mr.', value: 'Mr.' },
        { label: 'Ms.', value: 'Ms.' },
        { label: 'Mrs.', value: 'Mrs.' },
        { label: 'Dr.', value: 'Dr.' },
        { label: 'Prof.', value: 'Prof.' },
    ];

    fieldsList = ['id', 'Name', 'Related_Account__c','Accountid__c', 'Core_Support_Org_Name__c	', 
    'Related_Product_id__c', 'Core_Status__c','AccessFlag','Related_Account__c'];

    get salutationOptions() {
        return this.salutationsList;
    }

    get fields() {
        return this.fieldsList;
    }
}