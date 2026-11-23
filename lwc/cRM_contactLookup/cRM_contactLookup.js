import { LightningElement, track, wire,api } from 'lwc';
import searchContacts from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchUsers'; // searchContacts

export default class CRM_contactLookup extends LightningElement {
    @track searchTerm = '';
    @track contacts = [];
    @track showDropdown = false;
    @api labelName;

    @wire(searchContacts, { searchTerm: '$searchTerm' })
    wiredContacts({ error, data }) {
        if (data) {
            console.log('inside wiredContacts', data);
            this.contacts = data;
        } else if (error) {
            console.error('Error fetching contacts:', error);
        }
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        console.log('Search Term:', this.searchTerm);
        /*clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
        this.searchTerm = searchTerm;
        console.log('Search Term:', this.searchTerm);
    }, 300); // Adjust the delay as needed*/
    }

    handleFocus() {
        this.showDropdown = true;
    }

    handleBlur() {
        //this.showDropdown = false;
        //Consider adding a delay or condition to prevent immediate hiding
        setTimeout(() => {
            this.showDropdown = false;
        }, 200);
    }

    handleSelect(event) {
        const contactId = event.currentTarget.dataset.id;
        const selectedContact = this.contacts.find(contact => contact.Id === contactId);
        console.log('Selected Contact:', selectedContact);
        const selectEvent = new CustomEvent('contactselect', {
            detail: { contactId, contactName: selectedContact.Name }
        });
        this.dispatchEvent(selectEvent);
        this.searchTerm = selectedContact.Name;
        this.showDropdown = false;
    }
}