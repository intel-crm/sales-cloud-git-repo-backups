import { LightningElement, api, wire } from 'lwc';
import getAccountDetails from '@salesforce/apex/PRM_PartnerAccountDetailController.getAccountDetails';
const columns = [
    { label: 'First Name', fieldName: 'firstName' },
    { label: 'Last Name', fieldName: 'lastName' },
];
export default class PRM_PartnerAccountDetail extends LightningElement {
    columns = columns;

    @api recordId;

    @wire(getAccountDetails, { recordId: '$recordId' })
    account;
}