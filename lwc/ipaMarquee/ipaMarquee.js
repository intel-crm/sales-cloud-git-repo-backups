import { LightningElement, api, track} from 'lwc';

import PartnerProgramMember from '@salesforce/label/c.PMP_L2_Marquee_Intel_Prartner_Program_Member';
import SignIn from '@salesforce/label/c.PMP_Sign_In';
import LearnMore from '@salesforce/label/c.PMP_Learn_More';

import { subscribe} from 'c/ipaRedux';

import { getBenefitProfile } from 'c/ipaBenefitService';

import welcome from '@salesforce/label/c.PMP_Benefits_Welcome';


export default class ipaMarquee extends LightningElement {
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
   

    @track linkData = {};

    @track buttonLinkData = {};
    @track cta1LinkData = {};
    @track cta2LinkData = {};
    @track cta3LinkData = {};

    label = {
        PartnerProgramMember,
        SignIn,
        LearnMore
    };

    connectedCallback() {
       this.linkData = {
           label: this.ctaLabel,
           communityPage: this.ctaCommPage,
           externalUrl: this.ctaExternalUrl,
       }

       if (this.ifs.hasRightPanel){
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
            this.fetchBenefitProfile();
        }
	}

    async fetchBenefitProfile() {
        const result = await new Promise (resolve => {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(()=>{
                getBenefitProfile().then((value) => {
                    resolve(value);
                });
            }, 2000);
        });
        // add stuff to name and profile
        this.subtitle = welcome + ' ' + result.name;
        this.description = result.title;


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
            rightCta1Valid:  this.isLinkDataComplete(this.cta1LinkData),
            rightCta2Valid:  this.isLinkDataComplete(this.cta2LinkData),
        }
    }
}