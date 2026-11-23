/* eslint-disable @lwc/lwc/no-api-reassignments */
/** Documentation for Marquee Component
 * <br>
 * <h2>Marquee Types</h2>
 * <h3>L0</h3><br>
 * <h3>L1</h3><br>
 *
 * @namespace ipaMarquee
 * @property {boolean} dynamicMarquee=false Set to true to set Marquee data dynamically
 * @property {string} marqueeDataSource=data souce is set to 'Design Attributes', 'Application State', and 'Benefit Service'
 * @property {string} title Set the Title for the Marquee
 * @property {string} subtitle Set the Subtitle for the Marquee
 * @property {string} description Set the Description for the Marquee optional item, used in IPA WEB
 * @property {string} ctaLabel Set Label for Link
 * @property {string} ctaExternalUrl Set External URL - uses linkout icon
 * @property {string} ctaCommPage Set Community Page
 * @property {boolean} showCaret=false Show right arrow icon on link
 * @property {boolean} showSignIn=false Show sign in details
 * @property {boolean} showSearch=false Show search box
 * @property {string} alignment=Left Set Left alignment or Center alignment

 * @property {layout} layout=Single, RightPanelLinks ( has right links and buttons)

 * @property {string} rightButtonLabel Set Label for Button on the right panel
 * @property {string} rightButtonCommPage Set Community Page for the Button on the right panel
 * @property {string} rightButtonExternalUrl Set External URL - uses linkout icon

 * @property {string} rightCta1Label Set Label for CTA 1 on the right panel
 * @property {string} rightCta1CommPage Set Community Page for the CTA 1  on the right panel
 * @property {string} rightCta1ExternalUrl Set External URL - uses linkout icon

 * @property {string} rightCta2Label Set Label for CTA 2 on the right panel
 * @property {string} rightCta2CommPage Set Community Page for the CTA 2  on the right panel
 * @property {string} rightCta2ExternalUrl Set External URL - uses linkout icon

 * @author Fawn Stevens
*/
import { LightningElement, api, track, wire } from 'lwc';

import PartnerProgramMember from '@salesforce/label/c.PMP_L2_Marquee_Intel_Prartner_Program_Member';
import SignIn from '@salesforce/label/c.PMP_Sign_In';
import LearnMore from '@salesforce/label/c.PMP_Learn_More';

import { subscribe, dispatch } from 'c/ipaRedux';

import { CurrentPageReference } from 'lightning/navigation';

import { getBenefitProfile } from 'c/ipaBenefitService_copy1';

import welcome from '@salesforce/label/c.PMP_Benefits_Welcome';

//import getProfileBenefit from "@salesforce/apex/IPABenefitUtility.getProfileInfo";
import UserId from '@salesforce/user/Id';
export default class ipaMarquee_copy extends LightningElement {

    @api title;
    @api subtitle;
    @api description;
    @api ctaLabel;
    @api ctaExternalUrl;
    @api ctaCommPage;
    @api showCaret;
    @api showSignIn;
    @api showSearch;
    @api alignment;
    @api dynamicMarquee;
    @api marqueeDataSource;

    // right panel new components
    @api layout = 'Single';
    @api rightButtonLabel;
    @api rightButtonCommPage;
    @api rightButtonExternalUrl;
    @api rightCta1Label;
    @api rightCta1CommPage;
    @api rightCta1ExternalUrl;
    @api rightCta2Label;
    @api rightCta2CommPage;
    @api rightCta2ExternalUrl;
    @track profileDataBanner

    @track linkData = {};

    @track buttonLinkData = {};
    @track cta1LinkData = {};
    @track cta2LinkData = {};
    @track profileData = [];
    @wire(CurrentPageReference)
    wiredPageRef(pageReference) {
        dispatch('changeUI', {
            pageReference
        });
    }

    label = {
        PartnerProgramMember,
        SignIn,
        LearnMore
    };

    connectedCallback() {
        /** Subscribe to data to get Marquee title & subtitle
        * @function ipaMarquee#subscribe
        */
        console.log('ipa marquee connectted' + UserId);
        this.linkData = {
            label: this.ctaLabel,
            communityPage: this.ctaCommPage,
            externalUrl: this.ctaExternalUrl,
        }

        if (this.ifs.hasRightPanel) {
            console.log('hasRightPanel');
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
        }

        /** If Marquee Data Source is Application State, use redux marquee */
        console.log('ipa marquee calling ' + JSON.stringify(this.marqueeDataSource));
        if (this.marqueeDataSource === 'Application State') {
            this._sub = subscribe('ui.marquee', ({ title, subtitle, showCaret, linkData }) => {
                this.title = title;
                this.subtitle = subtitle;
                this.showCaret = showCaret;
                this.linkData = linkData;
            });
        } else if (this.marqueeDataSource === 'Benefit Service') {
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
        // this.fetchBenefitProfile();
        console.log('ipa marquee connectted2');


    }



    async fetchBenefitProfile() {
        const result = await new Promise(resolve => {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            console.log('UserId' + UserId);
            setTimeout(() => {
                //getBenefitProfile().then((value) => {
                getBenefitProfile().then((value) => {
                    // var jsonObject = JSON.parse(value);
                    //  console.log('ResolveValue' + JSON.stringify(value));
                    resolve(value);
                });
            }, 2000);
        });
        console.log('result' + JSON.stringify(result));
        // add stuff to name and profile
        this.subtitle = welcome + ' ' + result.name;
        this.description = result.responsibility;//title


        this.cta1LinkData = {
            ...result.companyProfileLink,
            label: this.rightCta1Label
        }
    }


    disconnectedCallback() {
        if (this._sub) this._sub();
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
            hasRightPanel: this.layout === 'RightPanelLinks',
            buttonCtaValid: this.isLinkDataComplete(this.buttonLinkData),
            rightCta1Valid: this.isLinkDataComplete(this.cta1LinkData),
            rightCta2Valid: this.isLinkDataComplete(this.cta2LinkData),
        }
    }
}