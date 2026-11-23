/* eslint-disable @lwc/lwc/no-api-reassignments */
/** Documentation for Marquee Component
 * <br>
 * <h2>Marquee Types</h2>
    * <h3>L0</h3><br>
    * <h3>L1</h3><br>
 *
 * @namespace ipaMarqueeCompanyProfile
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

 * @author Shubham
*/

import { LightningElement, api, track } from 'lwc';

// temporary font loading resource
//import { loadStyle } from 'lightning/platformResourceLoader';

//import fontResource from '@salesforce/resourceUrl/IpaResources';

import getProfileInfo from '@salesforce/apex/PRM_CompanyProfile_Utility.getProfileInfo';

import welcome from '@salesforce/label/c.PRM_CP_Welcome'; //change as per the apex class

export default class IpaMarqueeCompanyProfile extends LightningElement {

    @api marqueeDataSource;
    @api devFonts = false;

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

    baseLink = {
        label: '',
        externalUrl: '',
        communityPage: '',
        objectPage: '',
        recordId: ''
    };
    
    connectedCallback() {       
        getProfileInfo()
        .then(result => { 
            console.log('data Returned ==>Name==>'+result.name); 
            this.title = result.marqueeTitle;
            this.subtitle = (result.name!='') ?welcome + ' ' + result.name: '';
            this.description = result.title;
            this.buttonLinkData = { ...this.baseLink, ...result.dashboardLink};           
            this.cta1LinkData = { ...this.baseLink, ...result.companyProfileLink};
            this.cta2LinkData = { ...this.baseLink, ...result.myProfileLink};           
            })
        .catch(error => {
            console.log('Error GetProfileInfo ==>'+error);
            this.errorFromImperative = error 
            })

        /*
        this.buttonLinkData = {
            ...this.baseLink,
            label: this.rightButtonLabel,
            communityPage: this.rightButtonCommPage,
            externalUrl: this.rightButtonExternalUrl
        }

        this.cta1LinkData = {
            ...this.baseLink,
            label: this.rightCta1Label,
            communityPage: this.rightCta1CommPage,
            externalUrl: this.rightCta1ExternalUrl
        }

        this.cta2LinkData = {
            ...this.baseLink,
            label: this.rightCta2Label,
            communityPage: this.rightCta2CommPage,
            externalUrl: this.rightCta2ExternalUrl,
        }
        */

        /** If Marquee Data Source is Application State, use redux marquee */

       /*if (this.marqueeDataSource === 'Company Profile') {
            this.title = '';
            this.subtitle = '';
            this.description = '';
            // reset company profile

            //this.fetchCompanyProfile();
        }*/
	} 


    get classes() {
        return {
            containerClass: "container",
            alignment: this.ifs.hasRightPanel ? "Left" : this.alignment
        };
    }

    isLinkDataComplete(linkData) {
        console.log('linkData ==>'+linkData);
        console.log('linkData.label ==>'+linkData.label);
        console.log('linkData.communityPage ==>'+linkData.communityPage);
        console.log('linkData.externalUrl ==>'+linkData.externalUrl);
        console.log('linkData.Condition ==>'+linkData && linkData.label && (linkData.communityPage || linkData.externalUrl));
        return linkData && linkData.label && (linkData.communityPage || linkData.externalUrl)
    }
    get ifs() {
        return {
          
            buttonCtaValid: this.isLinkDataComplete(this.buttonLinkData),
            rightCta1Valid:  this.isLinkDataComplete(this.cta1LinkData),
            rightCta2Valid:  this.isLinkDataComplete(this.cta2LinkData),
           /*
            buttonCtaValid: true,
            rightCta1Valid:  true,
            rightCta2Valid:  true
            */

        }
    }
    /*
    renderedCallback() {
        if (!this.devFonts) {
            //eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(()=>{
                Promise.all([
                    loadStyle(this, fontResource + '/devFonts/site-global-icons/css/site-global-icons.css')
                ]).catch(error => {
                    // eslint-disable-next-line no-console
                    console.log(error);
                });
            }, 2000);
        }
    }
    */
   
}