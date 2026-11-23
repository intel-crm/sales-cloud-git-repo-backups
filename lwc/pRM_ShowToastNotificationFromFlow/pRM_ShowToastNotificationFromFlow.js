import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {FlowNavigationEvent} from 'lightning/flowSupport';

export default class PRM_ShowToastNotificationFromFlow extends LightningElement {

    @api toastTitle;
    @api toastVariant;
    @api toastMessage;
    @api toastMode = 'sticky';
    @track showNotification = true;

    connectedCallback() {
        this.showToast();
        this.closeNotification();
    }

    closeNotification() {
        this.dispatchEvent(new FlowNavigationEvent());
    }

    showToast() {

        const toastEvent = new ShowToastEvent({
            title: 'Success!',
            message: 'The operation was completed successfully.',
            variant: 'success',
            mode: 'sticky' // Options: 'dismissable', 'pester', 'sticky'
        });

        // Dispatch the toast event
        this.dispatchEvent(toastEvent);

        // if (this.toastMessage && this.toastType) {
        //     const toastEvent = new ShowToastEvent({
        //         title: this.toastTitle || 'Notification',
        //         message: this.toastMessage,
        //         variant: this.toastVariant,
        //         mode: this.toastMode
        //     });

        //     this.dispatchEvent(toastEvent);
        // }
    }
}