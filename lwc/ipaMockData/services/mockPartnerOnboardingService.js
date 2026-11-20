import { mockBoardingSteps } from '../objects/boardingSteps';
import { mockSubComponent } from '../objects/boardingSubComponent';


export const getOnBoardingSteps = (type) => {
    console.log('%cMockPartnerOnboarding Data:  (getOnBoardingSteps)  ', 'color: #1798c1; font-weight: bold', type, mockBoardingSteps(type));
    return Promise.resolve(mockBoardingSteps(type));
}

export const getSubComponentData = (type) => {
  console.log('%cMockPartnerOnboarding Data:  (getSubComponentData)  ', 'color: #1798c1; font-weight: bold', type, mockSubComponent(type));
    return Promise.resolve(mockSubComponent(type));
}

export const submitTermsAndConditions = (stepId, data) => {
    console.log(`%cMockPartnerOnboarding Data:  (submitTermsAndConditions)  `, 'color: #1798c1; font-weight: bold',
    stepId, data);
    return Promise.resolve({success: true, messageId: stepId, data: data });
}

export const markAsCompleted = (stepId, action) => {
    console.log(`%cMockPartnerOnboarding Data:  (markMessageAsRead)  `, 'color: #1798c1; font-weight: bold',
    stepId, action);
    // step id and true (a button is clicked)
    return Promise.resolve({success: true, stepId: stepId, type: action});
}


export const submitCommunitySelection = (stepId, community) => {
    console.log(`%cMockPartnerOnboarding Data:  (submitCommunitySelection)  `, 'color: #1798c1; font-weight: bold',
    stepId, community);
    // step id and true (a button is clicked)
    return Promise.resolve({success: true, stepId: stepId, community: community});
}