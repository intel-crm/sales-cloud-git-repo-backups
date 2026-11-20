/**
 * getOnBoardingSteps
 * <br>
 * <h4>3 Types</h4>
 * <ul>
 * <li><b>natural-grouping</b> - for the steps on the natural grouping preboard</li>
 * <li><b>partner-role</b> - for the steps on the tier and role confirmation preboard</li>
 * <li><b>post-launch</b> - for the steps on the post launch</li>
 * </ul>
 *
 * @example
 * getOnBoardingSteps("natural-grouping");
 * getOnBoardingSteps("partner-role");
 * getOnBoardingSteps("post-launch");
 *
 * @returns {ipaPartnerOnboardingService.BoardingSteps}
 * @function getOnBoardingSteps
 * @param  {string} type the type of steps natural-grouping, partner-role, post-launch
 * @memberof ipaPartnerOnboardingService
 */

import MockData from "c/ipaMockData";
import {ipaOnboardingSteps} from './ipaOnboardingStepsUtility';
import {subComponent} from './ipaOnboardingSubComponentUtility';
import helpers from './helpers/index';
import getSubComponentDataPostLaunch from "@salesforce/apex/PRM_IPAPartnerOnboarding_CTRL.getSubComponentDataPostLaunch";
import submitTermsAndCondtion from "@salesforce/apex/PRM_IPAPartnerOnboarding_CTRL.submitTermsAndCondtion";
import submitCommunityEnrollmentRequest from "@salesforce/apex/PRM_IPAPartnerOnboarding_CTRL.submitCommunityEnrollmentRequest";
import getStepCompletionStatus from "@salesforce/apex/PRM_IPAPartnerOnboarding_CTRL.getStepCompletionStatus";

import getResponsibilitiesConfirmationData from '@salesforce/apex/EPUM_ContactEntitlement_Util.getResponsibilitiesConfirmationData';
import MEMBER_IMAGES from '@salesforce/resourceUrl/EPUM_MemberLogo';
import GOLD_IMAGES from '@salesforce/resourceUrl/EPUM_GoldLogo';
import TITANIUM_IMAGES from '@salesforce/resourceUrl/EPUM_TitaniumLogo';
//import IPARefresh from '@salesforce/label/c.PRM_IPARefresh'; //IPA2.0-TWC727-2913
//const  ipaRefresh = IPARefresh.toLowerCase() === 'true'; //IPA2.0-TWC727-2913
export const getOnBoardingSteps = (type) => {
	let isStepOneDone;
	let isStepTwoDone;
	let stepStatus;
	let resultData = ipaOnboardingSteps(type);
	if (type == 'Post Launch' || type == 'Test Only-Non Primary' ) {
	return getStepCompletionStatus()
		.then(result => {
			stepStatus = JSON.parse(result);
			isStepOneDone = stepStatus.stepOneCompleted;
			//if(!ipaRefresh)isStepTwoDone = stepStatus.stepTwoCompleted;//IPA2.0 -TWC727-2913
			resultData.steps[0].completed = isStepOneDone;
			//if(!ipaRefresh)resultData.steps[1].completed = isStepTwoDone;   //IPA2.0 -TWC727-2913
			return Promise.resolve(resultData);
		})
		.catch(error => {
			console.log("this.error" + JSON.stringify(error));
			//return Promise.reject(error);
		});
	}
	else{
		return Promise.resolve(ipaOnboardingSteps(type));
	}
	//console.log('isStepOne'+isStepOneDone);
	
	//resultData.steps[0].completed = isStepOneDone;
	
	//return Promise.resolve(MockData.BoardingSteps(type));
};

/**
 * getSubComponentData
 * <br>
 * <h4>6 Types</h4>
 * <ul>
 * <li><b>grouping-confirmation</b> - data for the subcomponent step used on the on the natural grouping confirmation - preboard</li>
 * <li><b>tier-confirmation</b> - data for the subcomponent step on the  tier confirmation - preboard</li>
 * <li><b>responsibilities-confirmation</b> - data for the subcomponent step on the responsibility confirmation - preboard</li>
 * <li><b>terms-and-conditions</b> - data for the subcomponent terms and conditions step on the post launch </li>
 * <li><b>community-picklist</b> - data for the subcomponent commuinty(optional) step on the post launch </li>
 * <li><b>acceptable-domains</b> - data for the subcomponent acceptable domains  step on the post launch </li>
 * </ul>
 *
 * @example
 * getSubComponentData("grouping-confirmation");
 * getSubComponentData("tier-confirmation");
 * getSubComponentData("terms-and-conditions");
 * getSubComponentData("responsibilities-confirmation");
 * getSubComponentData("community-picklist");
 * getSubComponentData("acceptable-domains");
 *
 * @returns {ipaPartnerOnboardingService.BoardingSubcomponent}
 * @function getSubComponentData
 * @param  {string} type the type of message
 * @memberof ipaPartnerOnboardingService
 */
export const getSubComponentData = (type) => {
	if (type == 'terms-and-conditions' ||  type == 'terms-and-conditions-non-primary'|| type == 'community-picklist' || type == 'community-picklist-non-primary' ) {
		let resultdata;
		return getSubComponentDataPostLaunch({
				type: type
			}).then((result) => {
				if (result != undefined && result != null) {
					resultdata = JSON.parse(result);
					//resultdata.stepId = (Math.random().toString(36).substr(2, 9) + Date.now().toString(36)).toUpperCase();
					resultdata.stepId = helpers.id();
					return Promise.resolve(resultdata);
				}
			})
			.catch((error) => {
				console.log("this.error" + JSON.stringify(error));
				//return Promise.reject(error);
			});
  } 
  else if(type=='acceptable-domains' ){
    return Promise.resolve(subComponent(type));
  }
  else if(type=='responsibilities-confirmation'){
	let resultdata;
	  return getResponsibilitiesConfirmationData()
	  .then((result) => {
		if (result != undefined && result != null) {
			resultdata = JSON.parse(result);
			resultdata.stepId = helpers.id();
			
			if (resultdata.imageUrl == 'Member') {
				resultdata.imageUrl = MEMBER_IMAGES;
			} else if (resultdata.imageUrl == 'Gold') {
				resultdata.imageUrl = GOLD_IMAGES;
			} else if (resultdata.imageUrl == 'Titanium') {
				resultdata.imageUrl = TITANIUM_IMAGES;
			}
			console.log('AVK Test log 2');
			console.log(resultdata);
			return Promise.resolve(resultdata);
		}
	})
	.catch((error) => {
		console.log("this.error" + JSON.stringify(error));
		//return Promise.reject(error);
	});
  }
  else {
		console.log('Mock Data:  (getSubComponentData)  ', type, MockData.BoardingSubComponentData(type));
		return Promise.resolve(MockData.BoardingSubComponentData(type));
	}
};

/** Checkbox Submit Data
 * Data used to represent a group card in the pre boarding pages
 * @typedef CheckboxSubmitData
 * @property {string} fieldId the id of the field
 * @property {string} value the value of the of the field, currently we only have checkbox
 * @property {boolean} checked is the chekbox checked value
 * @memberof ipaPartnerOnboardingService
 */

/**
 * Submit Terms and Condition
 * @function submitTermsAndConditions
 * @param  {string} stepId the message id to be post back
 * @param  {ipaPartnerOnboardingService.CheckboxSubmitData[]} data fields for the checkbox
 * @returns {Object} success or failure of the promise
 * @memberof ipaPartnerOnboardingService
 *
 * @example
 * submitTermsAndConditions("UniqueStepId", [
          {
            fieldId: "XX-1",
            value: "checkbox-terms-conditions",
            checked: true,
          },
          {
            fieldId: "XX-2",
            value: "checkbox-gdpr",
            checked: true
          }
        ]);
 */
export const submitTermsAndConditions = (stepId, data) => {
	console.log(
		`%cMock Data:  (submitTermsAndConditions)  `,
		"color: #1798c1; font-weight: bold",
		stepId,
		data
	);
	let resultdata;
	return submitTermsAndCondtion({
			stepId: stepId,
			data: JSON.stringify(data)
		}).then((result) => {
			if (result != undefined && result != null) {
				resultdata = JSON.parse(result);
				resultdata.data = data;
				return Promise.resolve(resultdata);
			}
		})
		.catch((error) => {
			console.log("this.error" + JSON.stringify(error));
			//return Promise.reject(error);
		});

	//return Promise.resolve({ success: true, messageId: stepId, data: data });
};

/**
 * Mark as Completed given the step id and the component only being read only type
 * @function markAsCompleted
 * @param  {string} stepId the message id to be post back
 * @param  {boolean} action the action is true if it came from user clicking close button
 * @returns {Object} success or failure of the promise
 * @memberof ipaPartnerOnboardingService
 *
 * @example
 * markAsCompleted("UniqueStepId", true);
 */
export const markAsCompleted = (stepId, action) => {
	console.log(
		`%cMock Data:  (markMessageAsRead)  `,
		"color: #1798c1; font-weight: bold",
		stepId,
		action
	);
	// step id and true (a button is clicked)
	return Promise.resolve({
		success: true,
		stepId: stepId,
		type: action
	});
};

/**
 * Mark as Completed given the step id and the component only being read only type
 * @function submitCommunitySelection
 * @param  {string} stepId the message id to be post back
 * @param {ipaPartnerOnboardingService.Community[]} community array of multiselect values selected by the user
 * @returns {Object} success or failure of the promise
 * @memberof ipaPartnerOnboardingService
 *
 * @example
 * submitCommunitySelection("UniqueStepId",[
          {
            name: "Iot Solutions",
            id: "unique-id-1",
            selected: true
          },
          {
            name: "Cloud Service Providers",
            id: "unique-id-2",
            selected: true
          },
          {
            name: "FPGA",
            id: "unique-id-3",
            selected: true
          }
        ]);
*/
export const submitCommunitySelection = (stepId, community) => {
	console.log(
		`%cMock Data:  (submitCommunitySelection)  `,
		"color: #1798c1; font-weight: bold",
		stepId,
		community
	);
	let resultdata;
	console.log('communitydata' + JSON.stringify(community));
	return submitCommunityEnrollmentRequest({
			stepId: stepId,
			community: JSON.stringify(community)
		}).then((result) => {
			if (result != undefined && result != null) {
				resultdata = JSON.parse(result);
				resultdata.community = community;
				return Promise.resolve(resultdata);
			}
		})
		.catch((error) => {
			console.log("this.error" + JSON.stringify(error));
			//return Promise.reject(error);
		});

	// step id and true (a button is clicked)
	/*return Promise.resolve({
	  success: true,
	  stepId: stepId,
	  community: community
	});*/
};