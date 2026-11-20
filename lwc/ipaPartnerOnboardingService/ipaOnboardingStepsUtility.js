/** Boarding Steps
 * Data used to represent a the boarding steps data in thepre boarding/ pre launch pages
 * @typedef BoardingSteps
 * @property {string} type  whether the steps are supposed to be "linear"=in order/ "free" - can jump from one step to another
 * @property {string} eyebrow the text above the title of the boarding steps
 * @property {string} title the title of the Boarding steps
 * @property {string} description the description of the Boarding Steps
 * @property {ipaPartnerOnboardingService.BoardingStep[]} steps the different steps
 * @memberof ipaPartnerOnboardingService

 */

/** BoardingStep
 * Data used to represent a Boarding Step in the pre boarding/pre launch pages
 * @typedef BoardingStep
 * @property {string} stepId the unique id for the step, to be called for in the service to mark the step as completed
 * @property {string} component the component that would be initialized when the step is clicked and the popup is created, each component will call its own service to get the data related to it different types will be added here () link-out = the step will be a link to another page
 * @property {string} componentData the type of date to be retrieved
 * @property {string} title the title of the Boarding step as displayed before completion
 * @property {string} description the description of the Boarding step as displayed before completion
 * @property {string} completedTitle the title of the Boarding step as displayed after completion
 * @property {string} completedDescription the description of the Boarding step as displayed after completion
 * @property {string} modalTitle the title of the modal to be displayed on the header bar
 * @property {boolean} completed the completion state of the step
 * @property {Link} linkData when the component is link-out type it will make the step an ipa-link linking to the specific page
 * @memberof ipaPartnerOnboardingService
 */

import helpers from './helpers/index';
import stepOneTitle from '@salesforce/label/c.PRM_Onboarding_PostLaunch_Step1_Title';
import stepOneDesc from  '@salesforce/label/c.PRM_Onboarding_PostLaunch_Step1_Description';
import completed from '@salesforce/label/c.PRM_Onboarding_PostLaunch_Completed_Title';
import stepOneCompDesc from '@salesforce/label/c.PRM_Onboarding_PostLaunch_Step1_CompletedDescription';
import stepOneModal from '@salesforce/label/c.PRM_Onboarding_Step1_ModalTitle';
import stepTwoTitle from '@salesforce/label/c.PRM_Onboarding_PostLaunch_Step2_Title';
import stepTwoDesc from '@salesforce/label/c.PRM_Onboarding_PostLaunch_Step2_Description';
import steptwoCompDesc from '@salesforce/label/c.PRM_Oboarding_PostLaunch_Step2_CompletedDescription';
import stepTwoModal from '@salesforce/label/c.PRM_Onboarding_PostLaunch_Step2_ModalTitle';
import stepThreeTitle from '@salesforce/label/c.PRM_Onboarding_Step3_Title';
import stepThreeDesc from '@salesforce/label/c.PRM_Onboarding_step3_Description';
import stepThreeCompDesc from '@salesforce/label/c.PRM_Onboarding_Step3_CompletedDescription';
import stepThreeModal from '@salesforce/label/c.PRM_Onboarding_AcceptableDomain_Title';
import stepFourTitle from '@salesforce/label/c.PRM_Onboarding_Step4_Title';
import stepFourDesc from '@salesforce/label/c.PRM_Onboarding_Step4_Description';
import stepFourCompDesc from '@salesforce/label/c.PRM_Onboarding_Step4_CompletedDescription';
import stepFourModal from '@salesforce/label/c.PRM_Onboarding_Step4_ModalTitle';
import nonPrimaryStep1Title from '@salesforce/label/c.PRM_Onboarding_NonPrimary_Step1_Title';
import postLaunchTitle from '@salesforce/label/c.PRM_Onboarding_PostLaunch_Title';
import postLaunchDesc from '@salesforce/label/c.PRM_Onboarding_PostLaunch_Description';
import postLaunchEyebrow from '@salesforce/label/c.PRM_Onboarding_PostLaunch_Eyebrow';
//import IPARefresh from '@salesforce/label/c.PRM_IPARefresh'; //IPA2.0-TWC727-2913 // IPA Switch Removal
// const  ipaRefresh = IPARefresh.toLowerCase() === 'true';//IPA2.0-TWC727-2913 // IPA Switch Removal
export const ipaOnboardingSteps = (type) => {

    let allSample = {
        type: "linear",
        eyebrow: "Intel Partner Alliance",
        title: "More Benefits are coming your way",
        description: "Get a jump on accessing the expanded business building benefits",
        steps:[
            {
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-terms-and-conditions",
                componentData: "terms-and-conditions",
                title: "Accept terms and conditions",
                description: "Please review and accept the terms and conditions and confirm your communication preferences",
                completedTitle: "Completed",
                completedDescription: "You've accepted the terms and conditoins and confirmed your communication preferences",
                completed: false,
                modalTitle: "Accept Terms and conditions"
            },
            {
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-communities",
                componentData: "community-picklist",
                title: "Please select your community (optional)",
                description: "Select Communities to see more relevant content and to receive only the most valuable insights",
                completedTitle: "Completed",
                completedDescription: "You've chosen your community",
                completed: false,
                modalTitle: "Communities"
              },
            {
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-view-confirmation",
                componentData: "grouping-confirmation",
                title: "Please verify your company grouping",
                description: "Your new Intel Partner Alliance account will be based on this information",
                completedTitle: "Completed",
                completedDescription:"You've verified your company grouping",
                completed: false,
                modalTitle: "AMAX US Division - 123457"
            },
            {
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-view-confirmation",
                componentData: "tier-confirmation",
                title: "Please verify your membership tier and role ",
                description: "Your new Intel Partner Alliance account will be based on this information",
                completedTitle:"Completed",
                completedDescription:"You've verified your membership tier and role",
                completed: false,
                modalTitle: "AMAX Engineering Corporation",
            },
            {
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-view-confirmation",
                componentData: "responsibilities-confirmation",
                title: "Please verify your membership tier and role ",
                description: "Your new Intel Partner Alliance account will be based on this information",
                completedTitle:"Completed",
                completedDescription:"You've verified your membership tier and role",
                completed: false,
                modalTitle: "Verify Roles and responsibilities",
            },

              {
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-view-confirmation",
                componentData: "acceptable-domains",
                title: "Acceptable Domains (Optional)",
                description: "Define whitelisted domains to make it easy for your team to join",
                completedTitle: "Completed ",
                completedDescription: "You've completed the viewing whitelisted domains",
                completed: false,
                modalTitle: "Acceptable Domains (Optional)"
              },

            {
                stepId: helpers.id(),
                component: "link-out",
                componentData: "",
                title: "Continue to ITP Program",
                description: "Go to your current partner program and benefits.",
                completedTitle:"Continue to ITP Program",
                completedDescription:"Go to your current partner program and benefits.",
                completed: false,
                modalTitle: "",
                linkData: {
                        label: "linkout",
                        externalUrl: "http://www.intel.com/#continue-to-itp-program",
                        communityPage: "",
                        objectPage: "",
                        recordId: ""
                      }
              }
        ]
    }
    let naturalGrouping = {
        type: "linear",
        eyebrow: "Intel Partner Alliance",
        title: "More Benefits are coming your way",
        description: "Get a jump on accessing the expanded business building benefits",
        steps:[
            {
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-view-confirmation",
                componentData: "grouping-confirmation",
                title: "Please verify your company grouping",
                description: "Your new Intel Partner Alliance account will be based on this information",
                completedTitle: "Completed",
                completedDescription:"You've verified your company grouping",
                completed: false,
                modalTitle: "AMAX US Division - 123457"
            },
            {
                stepId: helpers.id(),
                component: "link-out",
                componentData: "",
                title: "Continue to ITP Program",
                description: "Go to your current partner program and benefits.",
                completedTitle:"Continue to ITP Program",
                completedDescription:"Go to your current partner program and benefits.",
                completed: false,
                modalTitle: "",
                linkData: {
                        label: "linkout",
                        externalUrl: "http://www.intel.com/#continue-to-itp-program",
                        communityPage: "",
                        objectPage: "",
                        recordId: ""
                      }
              }
        ]
    }

    let partnerRole = {
        type: "linear",
        eyebrow: "Intel Partner Alliance",
        title: "More Benefits are coming your way",
        description: "Get a jump on accessing the expanded business building benefits",
        steps:[
            {
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-view-confirmation",
                componentData: "tier-confirmation",
                title: "Please verify your membership tier and role ",
                description: "Your new Intel Partner Alliance account will be based on this information",
                completedTitle:"Completed",
                completedDescription:"You've verified your membership tier and role",
                completed: false,
                modalTitle: "AMAX Engineering Corporation",
            },
            {
                stepId: helpers.id(),
                component: "link-out",
                title: "Continue to ITP Program",
                description: "Go to your current partner program and benefits.",
                completedTitle:"Continue to ITP Program",
                completedDescription:"Go to your current partner program and benefits.",
                completed: false,
                modalTitle: "",
                linkData: {
                        label: "linkout",
                        externalUrl: "http://www.intel.com/#continue-to-itp-program",
                        communityPage: "",
                        objectPage: "",
                        recordId: ""
                      }
              }
        ]
    }

    let postLaunch =  {
        type: "linear",
        eyebrow: postLaunchEyebrow,
        title: postLaunchTitle,
        description: postLaunchDesc,
        steps:[
            {
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-terms-and-conditions",
                componentData: "terms-and-conditions",
                title: stepOneTitle,
                description: stepOneDesc,
                completedTitle: completed,
                completedDescription: stepOneCompDesc,
                completed: false,
                modalTitle: stepOneModal
              },
               /* ...(!ipaRefresh ? [{ //IPA2.0-TWC727-2913
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-communities",
                componentData: "community-picklist",
                title: stepTwoTitle,
                description: stepTwoDesc,
                completedTitle: completed,
                completedDescription: steptwoCompDesc,
                completed: false,
                modalTitle: stepTwoModal
              }]:[]),*/ // // IPA Switch Removal
              {
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-view-confirmation",
                componentData: "acceptable-domains",
                title: stepThreeTitle,
                description: stepThreeDesc,
                completedTitle: completed,
                completedDescription: stepThreeCompDesc,
                completed: false,
                modalTitle: stepThreeModal
              },
             {
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-view-confirmation",
                componentData: "responsibilities-confirmation",
                title: stepFourTitle,
                description: stepFourDesc,
                completedTitle: completed,
                completedDescription: stepFourCompDesc,
                completed: false,
                modalTitle: stepFourModal,
            }
        ]
    }

    let postLaunchNonPrimary =  {
        type: "linear",
        eyebrow: postLaunchEyebrow,
        title: postLaunchTitle,
        description: postLaunchDesc,
        steps:[
            {
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-terms-and-conditions",
                componentData: "terms-and-conditions-non-primary",
                title: nonPrimaryStep1Title,
                description: stepOneDesc,
                completedTitle: completed,
                completedDescription: stepOneCompDesc,
                completed: false,
                modalTitle: stepOneModal
              },
               /*...(!ipaRefresh ? [{ //IPA2.0-TWC727-2913
                stepId: helpers.id(),
                component: "c-ipa-partner-modal-communities",
                componentData: "community-picklist-non-primary",
                title: stepTwoTitle,
                description: stepTwoDesc,
                completedTitle: completed,
                completedDescription: steptwoCompDesc,
                completed: false,
                modalTitle: stepTwoModal
              }]:[])*/ // IPA Switch Removal
        ]
    }

    switch (type) {
        case 'Natural Grouping':
            return naturalGrouping;

        case 'Partner Role':
            return partnerRole;

        case 'Post Launch':
            return postLaunch;

        case 'Test Only-Non Primary':
            return postLaunchNonPrimary;

        default:
            return allSample;
    }
}