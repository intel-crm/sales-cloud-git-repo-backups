import { mockBenefits } from '../objects/benefit';
import { mockBenefitProfile } from '../objects/benefitProfile';
import { mockPartnerSupportFooter } from '../objects/partnerSupportFooter';
import { mockPartnerMessages } from '../objects/partnerMessages';
import { mockPartnerQuickLinks } from '../objects/partnerQuicklinks';


export const getPartnerMessages = () => {
    console.log(`%cMockBenefitService Data:  (getPartnerMessages)  `, 'color: #1798c1; font-weight: bold',
    mockPartnerMessages);
    return Promise.resolve(mockPartnerMessages());
}

export const markMessageAsRead = (messageId, type) => {
    console.log(`%cMockBenefitService Data:  (markMessageAsRead)  `, 'color: #1798c1; font-weight: bold',
    messageId, type);
    return Promise.resolve({success: true, messageId: messageId, type: type});
}

export const getBenefitProfile = (pageType) => {
    console.log(`%cMockBenefitService Data:  (getBenefitProfile)  `, 'color: #1798c1; font-weight: bold',
    mockBenefitProfile(), 'pageType:'+ pageType);
    return Promise.resolve(mockBenefitProfile());
}

export const getBenefits = () => {
    console.log(`%cMockBenefitService Data:  (getBenefitService)  `, 'color: #1798c1; font-weight: bold',
    mockBenefits());
    return Promise.resolve(mockBenefits());
}

export const getPartnerQuickLinks = () => {
    console.log(`%cMockBenefitService Data:  (getPartnerQuickLinks)  `, 'color: #1798c1; font-weight: bold',
    mockPartnerQuickLinks());
    return Promise.resolve(mockPartnerQuickLinks());
}

export const getSupportFooter = () => {
    console.log(`%cMockBenefitService Data:  (getSupportFooter)  `, 'color: #1798c1; font-weight: bold',
     mockPartnerSupportFooter());
    return Promise.resolve(mockPartnerSupportFooter());
}