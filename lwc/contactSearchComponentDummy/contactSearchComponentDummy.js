import { LightningElement, wire } from 'lwc';
import fetchAllContacts from '@salesforce/apex/ContactControllerDummy.fetchAllContacts';
import getFilteredContacts from '@salesforce/apex/ContactControllerDummy.getFilteredContacts';
import getAllContacts from '@salesforce/apex/ContactControllerDummy.getAllContacts';

export default class ContactSearchComponentDummy extends LightningElement {
    searchTerm = '';          // Search term entered by the user
    contacts = [];            // List to store contacts retrieved from Apex
    error;                    // For error handling

    // Handle input change to update the searchTerm
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    // Call Apex to fetch filtered contacts based on the searchTerm
    handleSearch() {
        getFilteredContacts({ searchTerm: this.searchTerm })
            .then((result) => {
                this.contacts = result; // Store the filtered contacts in the component's state
            })
            .catch((error) => {
                this.error = error; // Handle errors if any
                console.error('Error fetching filtered contacts:', error);
            });
    }

    // Call Apex to get all contacts from the global list
    // fetchContacts() {
    //     fetchAllContacts()
    //         .then((result) => {
    //             this.contacts = result; // Store all contacts in the component's state
    //         })
    //         .catch((error) => {
    //             this.error = error; // Handle errors if any
    //             console.error('Error fetching all contacts:', error);
    //         });
    // }

    @wire(fetchAllContacts)
    wiredRecord({ error, data }) {
        if (data) {
            this.contacts = data;
        } else if (error) {
            console.error('Error fetching record data: ', error);
        }
    }
}