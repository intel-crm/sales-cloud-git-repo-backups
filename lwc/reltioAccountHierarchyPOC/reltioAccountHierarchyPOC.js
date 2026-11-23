import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAccountsAndContacts from '@salesforce/apex/UCD_ReltioAccountHierarchyController.getReltioHierarchy';

export default class ReltioAccountHierarchyPOC extends LightningElement {
    accountsWithContacts = [];
    @wire(getAccountsAndContacts)
    wiredAccounts({ data, error }) {
        if (data) {
            this.accountsWithContacts = data;
            console.log('data===>'+JSON.stringify(data));
            

        } else if (error) {
            console.error('Error fetching accounts and contacts', error);
        }
    }
}