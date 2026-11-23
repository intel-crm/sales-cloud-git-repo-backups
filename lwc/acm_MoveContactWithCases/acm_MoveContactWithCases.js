import { LightningElement, track, wire } from 'lwc';
import getCurrentContact from '@salesforce/apex/ACM_MoveContactWithCases_Controller.getCurrentContact';
import getAllAccounts from '@salesforce/apex/ACM_MoveContactWithCases_Controller.getAllAccounts';
import getContactsByAccount from '@salesforce/apex/ACM_MoveContactWithCases_Controller.getContactsByAccount';
import updateCasesOnSave from '@salesforce/apex/ACM_MoveContactWithCases_Controller.updateCasesOnSave';

export default class Acm_moveContactWithCases extends LightningElement {
    @track currentContact = {};
    @track accountOptions = [];
    @track contactOptions = [];
    @track targetAccountId = '';
    @track targetContactId = '';
    @track errorMessage = '';

    connectedCallback() {
        this.loadCurrentContact();
        this.loadAllAccounts();
    }

    loadCurrentContact() {
        getCurrentContact({ contactId: '003XXXXXXXXXXXX' }) // Replace with dynamic Contact ID
            .then(result => {
                this.currentContact = {
                    Name: result.Name,
                    AccountName: result.Account?.Name || 'N/A',
                };
            })
            .catch(error => {
                console.error('Error fetching contact:', error);
                this.errorMessage = 'Failed to fetch current contact details.';
            });
    }

    loadAllAccounts() {
        getAllAccounts()
            .then(result => {
                this.accountOptions = result.map(account => ({
                    label: account.Name,
                    value: account.Id,
                }));
            })
            .catch(error => {
                console.error('Error fetching accounts:', error);
                this.errorMessage = 'Failed to load accounts.';
            });
    }

    handleAccountChange(event) {
        this.targetAccountId = event.detail.value;
        this.loadContactsByAccount();
    }

    loadContactsByAccount() {
        if (!this.targetAccountId) return;
        getContactsByAccount({ accountId: this.targetAccountId })
            .then(result => {
                this.contactOptions = result.map(contact => ({
                    label: contact.Name,
                    value: contact.Id,
                }));
            })
            .catch(error => {
                console.error('Error fetching contacts:', error);
                this.errorMessage = 'Failed to load contacts for the selected account.';
            });
    }

    handleContactChange(event) {
        this.targetContactId = event.detail.value;
    }

    handleSave() {
        if (!this.targetAccountId || !this.targetContactId) {
            this.errorMessage = 'Please select both an account and a contact.';
            return;
        }

        updateCasesOnSave({ 
            targetAccountId: this.targetAccountId, 
            targetContactId: this.targetContactId 
        })
            .then(() => {
                this.errorMessage = '';
                alert('Cases moved successfully!');
            })
            .catch(error => {
                console.error('Error saving changes:', error);
                this.errorMessage = 'Failed to save changes.';
            });
    }

    handleCancel() {
        // Implement your cancel logic, such as navigating back
        this.errorMessage = '';
    }
}