/** Documentation for ipaPartnerOnboardingSteps  Component
 * <br>
 * <h2>Partner Onboarding Step Compoennt</h2>
 * <p>This component processes the {@link ipaPartnerOnboardingService.BoardingStep} Object passed in and renders the {@link ipaPartnerWelcomeTile ipaPartnerWelcomeTile} for the step. This component automatically switches to the completed vs non completed title, as well as renders the subcomponent with the active popup based on the step status.  </p>
 * <br>
 * @namespace ipaPartnerOnboardingStep
 * @property {ipaPartnerOnboardingService.BoardingStep} step BoardingStep data to be rendered
 * @author Joshua Gonzalez
*/
import { LightningElement, api } from 'lwc';

export default class IpaPartnerOnboardingStep extends LightningElement {
    @api step;

    get title() {
        return this.step.completed ? this.step.completedTitle : this.step.title;
    }
    get description() {
        return this.step.completed ? this.step.completedDescription : this.step.description;
    }
    get ifs() {
        return {
            isNotActive: this.step.stepStatus === 'inactive'
        }
    }

    markStepComplete({detail}){
        console.log('here in onboardings');
         this.dispatchEvent(new CustomEvent('markstepcomplete', { detail: detail}));
    }

}