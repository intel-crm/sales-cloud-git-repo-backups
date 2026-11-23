import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getDRStatus from "@salesforce/apex/PCC_Submit_DesignRegistrationController.getDRStatus";

export default class PCC_DisplayDraftStatus extends LightningElement {
    @api recordId;
    displayText = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log('currentPageReference:', currentPageReference);
        
            this.recordId = currentPageReference.attributes.recordId;
            console.log('recordId:', this.recordId);
        }
    }

    connectedCallback() {
        this.fetchDRStatus();
    }

    fetchDRStatus() {
        console.log('recccc iddddddddddd',this.recordId);
        getDRStatus({ recId: this.recordId })
            .then(result => {
                this.displayText = result;
            })
            .catch(error => {
                // Handle error
                console.error(error);
                console.log('Error in fetching status');
            });
    }
}