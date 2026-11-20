import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Prm_flowToastNotification extends LightningElement {
    @api toastTitle;
    @api toastVariant;
    @api toastMessage;
    @api toastMode = 'sticky';
    @track showNotification = true;

    connectedCallback() {
        this.showToast();
    }


    showToast() {

        const toastEvent = new ShowToastEvent({
            title: this.toastTitle,
            message: this.toastMessage,
            variant:this.toastVariant,
            mode: this.toastMode
        });

        this.dispatchEvent(toastEvent);
    }
}