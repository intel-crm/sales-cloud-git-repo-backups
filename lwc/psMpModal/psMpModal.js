import { LightningElement, api } from 'lwc';

export default class PsMpModal extends LightningElement {
    @api isOpen;
    @api hasHeader;
    @api hasBody;
    @api hasFooter;
    @api fitToContent = false;
    @api useSlimMobileHeader = false;

    openModal() {
        this.isOpen = true
    }

    closeModal() {
        this.isOpen = false
    }


}