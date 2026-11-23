import { LightningElement, api, wire } from 'lwc';
import getMessageFromApex from '@salesforce/apex/UCD_OPID_Creation_Association.getMessageFromApex';
export default class UCD_Create_Associate_OPID extends LightningElement {
    @api recordId;
    message;

    // Call Apex method to retrieve message
    connectedCallback() {
        this.retrieveMessage();
    }
    
    retrieveMessage() {
        console.log('came here');
        getMessageFromApex({ recordId: this.recordId })
            .then(result => {
                this.message = result;
            })
            .catch(error => {
                console.error('Error retrieving message:', error);
            });
    }
}