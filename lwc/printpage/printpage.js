import { LightningElement, api } from 'lwc';

export default class PrintAction extends LightningElement {
    @api recordId;

    connectedCallback() {
        // Delay execution slightly so the modal loads first
        setTimeout(() => {
            window.print(); // Opens print dialog
            this.closeAction(); // Auto-closes the action modal
        }, 500);
    }

    closeAction() {
        // Dispatch event to close the modal
        this.dispatchEvent(new CustomEvent('close'));
    }
}