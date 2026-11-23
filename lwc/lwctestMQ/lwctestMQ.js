/* eslint-disable @lwc/lwc/no-api-reassignments */
/** Documentation for Marquee Component
 * <br>
 * <h2>Marquee Types</h2>
 * <h3>L0</h3><br>
 * <h3>L1</h3><br>
 *
 * @namespace ipaMarquee
 * @property {string} marqueeDataSource=data souce is set to 'Design Attributes', 'Benefit Service'
 * @property {string} title Set the Title for the Marquee
 * @property {string} subtitle Set the Subtitle for the Marquee
 * @property {string} description Set the Description for the Marquee optional item, used in IPA WEB

 * @property {string} rightButtonLabel Set Label for Button on the right panel
 * @property {string} rightButtonCommPage Set Community Page for the Button on the right panel
 * @property {string} rightButtonExternalUrl Set External URL - uses linkout icon

 * @property {string} rightCta1Label Set Label for CTA 1 on the right panel
 * @property {string} rightCta1CommPage Set Community Page for the CTA 1  on the right panel
 * @property {string} rightCta1ExternalUrl Set External URL - uses linkout icon

 * @property {string} rightCta2Label Set Label for CTA 2 on the right panel
 * @property {string} rightCta2CommPage Set Community Page for the CTA 2  on the right panel
 * @property {string} rightCta2ExternalUrl Set External URL - uses linkout icon

 * @author Joshua Gonzalez
*/

import { LightningElement, api, track } from 'lwc';

import { getBenefitProfilelwc } from 'c/lwctestBnftSrvc';

import welcome from '@salesforce/label/c.PMP_Benefits_Welcome';


export default class lwctestMQ extends LightningElement {

    @api marqueeDataSource;

    @api title;
    @api subtitle;
    @api description;

    @api rightButtonLabel;
    @api rightButtonCommPage;
    @api rightButtonExternalUrl;
    @api rightCta1Label;
    @api rightCta1CommPage;
    @api rightCta1ExternalUrl;
    @api rightCta2Label;
    @api rightCta2CommPage;
    @api rightCta2ExternalUrl;

    @track buttonLinkData = {};
    @track cta1LinkData = {};
    @track cta2LinkData = {};

    connectedCallback() {

        this.buttonLinkData = {
            label: this.rightButtonLabel,
            communityPage: this.rightButtonCommPage,
            externalUrl: this.rightButtonExternalUrl
        }

        this.cta1LinkData = {
            label: this.rightCta1Label,
            communityPage: this.rightCta1CommPage,
            externalUrl: this.rightCta1ExternalUrl
        }

        this.cta2LinkData = {
            label: this.rightCta2Label,
            communityPage: this.rightCta2CommPage,
            externalUrl: this.rightCta2ExternalUrl,
        }

        /** If Marquee Data Source is Application State, use redux marquee */

       if (this.marqueeDataSource === 'Benefit Service') {
            this.subtitle = '';
            this.description = '';
            // reset company profile
            this.cta1LinkData = {
                label: this.rightCta1Label,
                communityPage: '',
                externalUrl: ''
            }
            console.log('ipa marquee calling profile');
            this.fetchBenefitProfile();
        }
	}

    async fetchBenefitProfile() {
        const result = await new Promise (resolve => {
            getBenefitProfilelwc().then((value) => {
                resolve(value);
            });
        });
        // add stuff to name and profile
        this.subtitle = welcome + ' ' + result.name;
        this.description = result.title;


        this.cta1LinkData = {
            ...result.companyProfileLink,
            label: this.rightCta1Label
        }
    }

    get classes() {
        return {
            containerClass: "container",
            alignment: this.ifs.hasRightPanel ? "Left" : this.alignment
        };
    }

    isLinkDataComplete(linkData) {
        return linkData.label && (linkData.communityPage || linkData.externalUrl)
    }
    get ifs() {
        return {
            buttonCtaValid: this.isLinkDataComplete(this.buttonLinkData),
            rightCta1Valid:  this.isLinkDataComplete(this.cta1LinkData),
            rightCta2Valid:  this.isLinkDataComplete(this.cta2LinkData),
        }
    }
}