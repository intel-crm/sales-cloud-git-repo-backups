import { LightningElement, api, wire, track } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import getMessageFromApex from '@salesforce/apex/UCD_OPID_Creation_Association.getMessageFromApex';
import { refreshApex } from '@salesforce/apex';
export default class UCD_Create_Associate_OPID extends LightningElement {
    @api recordId;
    message;
    @track showMessage = true;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            console.log('record id', this.recordId);
        }
    }

    // Call Apex method to retrieve message
    connectedCallback() {
        this.retrieveMessage();
    }
    
    retrieveMessage() {
        getMessageFromApex({ recordId: this.recordId })
            .then(result => {
                if(result){
                    this.message = result;
                }
                else {
                    this.showMessage = false;
                }
            })
            .catch(error => {
                console.error('Error retrieving message:', error);
            });
    }
    disconnectedCallback() {
        return refreshApex(this.message);
    }
}