import { LightningElement, api } from 'lwc';
import {
    FlowNavigationBackEvent,
    FlowNavigationNextEvent
} from 'lightning/flowSupport';

export default class CoreMDFFlowNavigationButtons extends LightningElement {
    @api backLabel = 'Back';
    @api nextLabel = 'Next';
    @api showBack;
    @api showNext;
    @api disableNext = false;
    @api availableActions = [];

    get isBackVisible() {
        return this.showBack !== false && this.availableActions.includes('BACK');
    }

    get isNextVisible() {
        return this.showNext !== false && this.availableActions.includes('NEXT');
    }

    handleBack() {
        if (this.availableActions.includes('BACK')) {
            this.dispatchEvent(new FlowNavigationBackEvent());
        }
    }

    handleNext() {
        if (this.availableActions.includes('NEXT')) {
            this.dispatchEvent(new FlowNavigationNextEvent());
        }
    }
}