/**
 * Library for Mock Data for IPA Marketplace Components
 * <br><h4>Object List</h4>
 * <ul>
 *     <li>{@link ipaBenefitService.Benefit Benefit}</li>
 *     <li>{@link ipaBenefitService.BenefitProfile BenefitProfile}</li>
 *     <li>{@link ipaBenefitService.PartnerSupportFooter PartnerSupportFooter}</li>
 *     <li>{@link ipaPartnerOnboardingService.BoardingSteps BoardingSteps}</li>
 *     <li>{@link ipaPartnerOnboardingService.BoardingSubcomponent BoardingSubComponentData}</li>
 *     <li>{@link Contact Contact}</li>
 *     <li>{@link SearchFilter SearchFilter}</li>
 *     <li>{@link SearchFiltersGrouping SearchFiltersGrouping}</li>
 *     <li>{@link SearchResultsGrouping SearchResultsGrouping}</li>
 *     <li>{@link Link Link}</li>
 *     <li>{@link ipaBenefitService.Metric Metric}</li>
 *     <li>{@link Partner Partner}</li>
 *     <li>{@link ipaBenefitService.PartnerMessages PartnerMessages}</li>
 *     <li>{@link ipaBenefitService.PartnerQuicklinks PartnerQuicklinks}</li>
 *     <li>{@link Product Product}</li>
 *     <li>{@link Specialty Specialty}</li>
 *     <li>{@link Taxonomy Taxonomy}</li>
 * @namespace ipaMockData
 */

import { mockAttribute } from './objects/attribute';
import { mockBenefits } from './objects/benefit';
import { mockBenefitProfile } from './objects/benefitProfile';
import { mockBoardingSteps } from './objects/boardingSteps';
import { mockSubComponent } from './objects/boardingSubComponent';
import { mockPartnerSupportFooter } from './objects/partnerSupportFooter';
import { mockPartnerMessages } from './objects/partnerMessages';
import { mockPartnerQuickLinks } from './objects/partnerQuicklinks';
import { mockPartner } from './objects/partner';
import { mockProduct } from './objects/product';
import { mockSpecialties } from './objects/specialty';
import { mockTaxonomy } from './objects/taxonomy';


const Mocks = {
    Attribute: mockAttribute,
    Benefits: mockBenefits,
    BenefitProfile: mockBenefitProfile,
    BoardingSteps: mockBoardingSteps,
    BoardingSubComponentData: mockSubComponent,
    Partner: mockPartner,
    PartnerMessages: mockPartnerMessages,
    PartnerQuickLinks: mockPartnerQuickLinks,
    PartnerSupportFooter: mockPartnerSupportFooter,
    Product: mockProduct,
    Specialties: mockSpecialties,
    Taxonomy: mockTaxonomy
}

const MockData = {};
for (let mock of Object.keys(Mocks)) MockData[mock] = (params, log = false) => {
    if (!Mocks[mock]) throw new TypeError(`"${mock}" not found in Mock Data`);
    let data = Mocks[mock](params);
    if (log) {
        console.log(`%cMock Data:  (${mock})  `, 'color: #1798c1; font-weight: bold',
            params, JSON.parse(JSON.stringify(data)));
    }
    return data;
}

export default MockData;

import mockSearchService from './services/mockSearchService';
export const MockSearchService = mockSearchService;

import mockCampaignService from './services/mockCampaignService';
export const MockCampaignService = mockCampaignService;

import mockTaxonomyService from './services/mockTaxonomyService';
export const MockTaxonomyService = mockTaxonomyService;

import { getBenefits, getPartnerMessages, markMessageAsRead, getPartnerQuickLinks, getBenefitProfile, getSupportFooter } from './services/mockBenefitService';
export const MockBenefitService = {
    getBenefits,
    getBenefitProfile,
    getSupportFooter,
    getPartnerMessages,
    getPartnerQuickLinks,
    markMessageAsRead
}

import { getOnBoardingSteps, getSubComponentData, submitTermsAndConditions, markAsCompleted, submitCommunitySelection } from './services/mockPartnerOnboardingService';
export const MockPartnerOnboardingService = {
    getOnBoardingSteps,
    getSubComponentData,
    submitTermsAndConditions,
    markAsCompleted,
    submitCommunitySelection
}