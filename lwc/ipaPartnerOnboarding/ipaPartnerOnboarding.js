/* eslint-disable @lwc/lwc/no-api-reassignments */
/** Documentation for ipaPartnerOnboarding  Component
 * <br>
 * <p>Ipa Partner Onboarding gets the BoardingSteps Object {@link ipaPartnerOnboardingService.BoardingSteps} from the {@link ipaPartnerOnboardingService.getOnBoardingSteps} based on the type.</p>
 * <p>This component is solely focused on gathering the data that is to be processed and rendered in the {@link ipaPartnerOnboardingSteps ipaPartnerOnboardingSteps} component.</p>

 * @namespace ipaPartnerOnboarding
 * @property {string} type the of the boarding steps to be selected from the builder Partner Role, Post Launch, Test Only-Non Primary
 *
 * @author Joshua Gonzalez
*/
const USE_MOCK = window.location.href.match('mockdata') ? true : false;

import { LightningElement, api, track } from 'lwc';
import IpaResources from '@salesforce/resourceUrl/IpaResources'

import partnerOnboardingTemplate from './ipaPartnerOnboarding.html';
import loadingTemplate from './loading.html';
import { getOnBoardingSteps } from 'c/ipaPartnerOnboardingService';
import { MockPartnerOnboardingService } from 'c/ipaMockData';

export default class IpaPartnerOnboarding extends LightningElement {
    @api type;
    @track result;
    @api backgroundVariant = 'mosaic-l1'

    renderedCallback() {
        let bgUrl = ''
        switch(this.backgroundVariant) {
            case 'classic-blue-gradient':
            case 'blue-steel-solid':
                return
            case 'mosaic-l1':
                bgUrl = IpaResources + '/images/background-marquee-l0.png'
                break
            case 'mosaic-l2':
                bgUrl = IpaResources + '/images/background-marquee-l1.png'
                break
            case 'mosaic-l3':
                bgUrl = IpaResources + '/images/background-marquee-l2.png'
                break
        }
        let el = this.template.querySelector('.marquee-outer-container')
        if (el && bgUrl) el.style.backgroundImage = `url(${bgUrl})`
        console.log('backgroundVariant', this.backgroundVariant);
    }

    connectedCallback(){
        this.fetchOnboardingSteps();
    }

    render() {
        return this.isLoading ? loadingTemplate : partnerOnboardingTemplate;
    }

    async fetchOnboardingSteps() {
        let result;
        try {
            if (USE_MOCK) {
                result = await MockPartnerOnboardingService.getOnBoardingSteps(this.type);
            } else {
                result = await getOnBoardingSteps(this.type);
            }
        } catch(e) {
            console.error('getBenefits error', `${e}`);
        }
        if (result) {
            this.result = result;
        }
        this.isLoading = false;
    }

}