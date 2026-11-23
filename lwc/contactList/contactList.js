import { LightningElement, wire, track } from 'lwc';
import getContactList from '@salesforce/apex/ManageUsers_Controller.getContactList';
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
];

export default class ContactList extends LightningElement {
    @wire(getDeletedUsers) lessonlyusers;

    @track lessonlyusers = [];
    @track columns = columns;
    @track error;
}