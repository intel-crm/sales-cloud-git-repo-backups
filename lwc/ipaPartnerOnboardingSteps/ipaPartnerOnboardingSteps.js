/** Documentation for ipaPartnerOnboardingSteps  Component
 * <br>
 * <h2>Partner Onboarding</h2>
 * <p>This component processes the {@link ipaPartnerOnboardingService.BoardingSteps} Object passed in and renders the {@link ipaPartnerWelcomeMat ipaPartnerWelcomeMat} wrapper the said data.  </p>
 * <p>The steps are rendered as {@link ipaPartnerOnboardingStep ipaPartnerOnboardingStep} For each step this component handles the tracking and marking of the steps completed when the subcomponent triggers the markstepcomplete event as the user goes through each step popup./p>
 * <br>
 * @namespace ipaPartnerOnboardingSteps
 * @property {BoardingSteps} stepsData BoardingSteps data to be rendered
 * @author Joshua Gonzalez
*/
import { LightningElement, api, track } from 'lwc';

export default class IpaPartnerOnboardingSteps extends LightningElement {
    @track eyebrow = '';
    @track description = '';
    @track title = '';
    @track stepType = 'linear';
    @track steps = [];
    @track _stepsData;

    @api set stepsData(stepsData){

        if (stepsData) {
            this._stepsData = stepsData;
            this.eyebrow = stepsData.eyebrow;

            this.title = stepsData.title;
            this.description = stepsData.description
            this.stepType = stepsData.type;
            this.steps = stepsData.steps;
            // update steps
            let prevStepComplete = false;

            this.steps  = stepsData.steps.map((step,index) => {
                let currentStepStatus;

                if (step.completed) {
                    prevStepComplete = true;
                    currentStepStatus = 'completed';
                } else if (!this.ifs.isLinear){
                    currentStepStatus = 'active';
                } else {

                    if (index === 0 || prevStepComplete) {
                        currentStepStatus = 'active';
                    } else {
                        currentStepStatus = 'inactive';
                    }
                    prevStepComplete = false;
                }

                return {
                ...step,
                stepStatus: currentStepStatus,
                index: index,
                isFirst: index === 0,
                isLast: (stepsData.steps.length -1) === index,
                total: stepsData.steps.length,
                stepKey: step.stepId + '-' + currentStepStatus
                }
            });
            // for each step get status
            console.log('steps check',this.steps);
        }

    }

    get stepsData(){
        return this._stepsData;
    }


    /*  step state
        linear
            s1- completed
            s2- active
            s3- inactive
        free
            s1- completed
            s2- active
            s3- active
    */
    markStepComplete({detail}){
        if (detail.stepId) {
            this.completeAStep(detail.stepId);
        }     
    }

    completeAStep(stepId) {
        // update the steps
        let prevStepComplete = false;
        this.steps.forEach((step,index) => {
            let currentStepStatus;

            if (step.completed || step.stepId === stepId) {
                step.completed = true;
                prevStepComplete = true;
                currentStepStatus = 'completed';
            } else if (!this.ifs.isLinear){
                currentStepStatus = 'active';
            } else {
              if (index === 0 || prevStepComplete) {
                  currentStepStatus = 'active';
              } else {
                  currentStepStatus = 'inactive';
              }
              prevStepComplete = false;
            }

            if (step.stepStatus !== currentStepStatus) {
                // console.log('change in status ', step.stepId , step.title,'::::' + step.stepStatus + '==>' + currentStepStatus);
                step.stepStatus = currentStepStatus;
                step.stepKey = step.stepId + '-' + currentStepStatus
            }
        });
    }

    get ifs() {
        return {
            isLinear: this.stepType === 'linear'
        }
    }

}