/** Documentation for ipaPartnerOnboardingSubComponent  Component
 * <br>
 * <h2>Partner Onboarding</h2>
 * <p>This component processes the {@link ipaPartnerOnboardingService.BoardingStep} Object passed in and renders the 3 different types of modal or the 1 linkout link. The Welcome Tile slot passed in the slot is passed to the other modals or rendered directly here.</p>
 *
 * <h4>Modal Types</h4>
 * <ul>
 * <li>{@link ipaPartnerModalCommunities ipaPartnerModalCommunities}</li>
 * <li>{@link ipaPartnerModalTermsAndConditions ipaPartnerModalTermsAndConditions}</li>
 * <li><{@link ipaPartnerViewConfirmation ipaPartnerViewConfirmation}</li>
 * <br>
 * @namespace ipaPartnerOnboardingSubComponent
 * @property {ipaPartnerOnboardingService.BoardingStep} step BoardingSteps data to be rendered
 * @property {Slot} tile slot for the tile to be rendered usually it is an ipaPartnerWelcometile

 * @author Joshua Gonzalez
*/
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
        console.log('in T&C');
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