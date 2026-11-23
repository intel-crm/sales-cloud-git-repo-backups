import { LightningElement, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class DisplayMessageOnAccountDeactivatedFalse extends LightningElement {
    @api recordId;

    handleLoad(event) {
        const fields = event.detail.records[this.recordId].fields;
        const checkboxFieldValue = fields.Core_Deactivated__c.value;

        if (checkboxFieldValue === false) {
            const toastEvent = new ShowToastEvent({
                title: "Toast Title",
                message: "Checkbox field is set to false!",
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
        }
    }
}