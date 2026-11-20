import { LightningElement, api } from 'lwc';

export default class RfpSummaryCollapsible extends LightningElement {
    @api recordId;
    @api objectApiName;

    // collapsed by default
    isOpen = false;

    toggleSection() {
        this.isOpen = !this.isOpen;
    }

    get sectionClass() {
        return `slds-section ${this.isOpen ? 'slds-is-open' : ''}`;
    }

    get chevronIcon() {
        return this.isOpen ? 'utility:chevrondown': 'utility:chevronright';
    }
}