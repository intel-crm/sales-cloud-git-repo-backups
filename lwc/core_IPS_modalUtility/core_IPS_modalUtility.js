import { LightningElement, track, api } from 'lwc';

export default class Core_IPS_modalUtility extends LightningElement {

    @api modalHeader;
    @api iconName;
    @api bodyContent;
    @api trueBtnLabel;
    @api falseBtnLabel;
    @api isModalHeaderRequired;
    @track headerEmptyStyleClass;

    connectedCallback() {
        if(this.trueBtnLabel === undefined || this.trueBtnLabel === null || this.trueBtnLabel === '') {
            this.trueBtnLabel = "Ok";
        }
        if(this.falseBtnLabel === undefined || this.falseBtnLabel === null || this.falseBtnLabel === '') {
            this.falseBtnLabel = "Ok";
        }
        if(this.isModalHeaderRequired !== undefined && this.isModalHeaderRequired !== null && this.isModalHeaderRequired !== '' ) {
            if(this.isModalHeaderRequired === true || this.isModalHeaderRequired === "true") {
                this.headerEmptyStyleClass = '';
            }
            if(this.isModalHeaderRequired === false || this.isModalHeaderRequired === "false") {
                this.headerEmptyStyleClass = 'slds-modal__header_empty';
            }
        }
    }

    trueHandler() {
        const trueActionsEvent = new CustomEvent("trueclick", {});
        this.dispatchEvent(trueActionsEvent);
    }

    falseHandler() {
        const falseActionsEvent = new CustomEvent("falseclick", {});
        this.dispatchEvent(falseActionsEvent);
    }
}