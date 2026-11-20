import { LightningElement, api, track } from 'lwc';

export default class IpaPartnerOnboardingSubComponent extends LightningElement {
    @track _step;
    @track component;
    @track linkData;
    @track componentData;

    @api set step(step) {
        this._step = step;
        this.component = step.component;
        this.linkData = step.linkData;
    }

    get step(){
        return this._step;
    }

    markStepComplete({detail}){
        // console.log('ipapartnerOnboardinsubcomponent.markStepComplete', detail);
         this.dispatchEvent(new CustomEvent('markstepcomplete', { detail: detail}));
    }

    get ifs() {
        return {
            isLinkOut: this.component === 'link-out',
            isViewConfirmation: this.component && this.component === 'c-ipa-partner-modal-view-confirmation',
            isTermsAndConditions: this.component && this.component === 'c-ipa-partner-modal-terms-and-conditions',
            isCommunitiesPicklist: this.component && this.component === 'c-ipa-partner-modal-communities',
            isAcceptableDomains: this.component && this.component === 'c-ipa-partner-modal-acceptable-domains'
        }
    }

}