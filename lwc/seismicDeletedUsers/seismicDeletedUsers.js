import { LightningElement, wire, track } from 'lwc';
import getDeletedUsers from '@salesforce/apex/ManageUsers_Controller.getDeletedUsers';

const columns = [
    {
        label: 'User Id',
        fieldName: 'User_Id__c', 
        type: 'text',
    },
    {
        label: 'Name',
        fieldName: 'Name__c', 
        type: 'text',
    }, {
        label: 'Email',
        fieldName: 'Email__c',
        type: 'text'
    }, {
        label: 'Role',
        fieldName: 'Role__c',
        type: 'text'
    }
    , {
        label: 'Deleted On',
        fieldName: 'CreatedDate',
        type: 'text'
    }, {
        label: 'Deleted By',
        fieldName: 'LastModifiedById',
        type: 'text'
    }
   
];

export default class SeismicDeletedUsers extends LightningElement {
    @wire(getDeletedUsers) lessonlyusers;

    @track lessonlyusers = [];
    @track columns = columns;
    @track error;
}