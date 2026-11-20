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
        // console.log('ipapartnerOnboardinstep.markStepComplete', detail);
         this.dispatchEvent(new CustomEvent('markstepcomplete', { detail: detail}));
    }
    /*
        active
            showsubComponent
        inactive
            tile-no-actions
        completed
            component: link-out
                showsubComponent
            component: other
                showsubComponent
    */


}