/* eslint-disable @lwc/lwc/no-api-reassignments */
/** Documentation for Marquee Partner Component
 *
 * @namespace ipaMarquee
 * @property {string} marqueeDataSource=data souce is set to 'Design Attributes', 'Benefit Service' Use Design Attributes
 * @property {string} title Set the Title for the Marquee
 * @property {string} subtitle Set the Subtitle for the Marquee
 * @property {string} description Set the Description for the Marquee optional item, used in IPA WEB
 * @property {string} pageType Set a custom pageType for use in the backend ipaBenefitService to differentiate data between marquee types

 * @property {string} rightButtonLabel Set Label for Button on the right panel
 * @property {string} rightButtonCommPage Set Community Page for the Button on the right panel
 * @property {string} rightButtonExternalUrl Set External URL - uses linkout icon

 * @property {string} rightCta1Label Set Label for CTA 1 on the right panel
 * @property {string} rightCta1CommPage Set Community Page for the CTA 1  on the right panel
 * @property {string} rightCta1ExternalUrl Set External URL - uses linkout icon

 * @property {string} rightCta2Label Set Label for CTA 2 on the right panel
 * @property {string} rightCta2CommPage Set Community Page for the CTA 2  on the right panel
 * @property {string} rightCta2ExternalUrl Set External URL - uses linkout icon
 * @property {string} analyticsPageType Analytics data in JSON string format

 * @author Joshua Gonzalez
*/
const USE_MOCK = window.location.href.match('mockdata') ? true : false;

import { LightningElement, api, track, wire } from 'lwc';

import { getBenefitProfile } from 'c/ipaBenefitService';

import { MockBenefitService } from 'c/ipaMockData';

import { getIpaBreadcrumbs } from 'c/ipaBreadcrumbsServiceIpa';

import { callAnalytics, getAnalyticsData } from 'c/ipaAnalyticsService';

import welcome from '@salesforce/label/c.IPA_Benefits_Welcome';

import releaseNotification from '@salesforce/label/c.Maintenance_Notification';

import isLoggedInUserInternalUser from "@salesforce/apex/IPABenefitUtility.checkInternalUser"
import IPASecureHomepageLink from '@salesforce/label/c.IPA_Secure_Homepage_Link';
import UserId from '@salesforce/user/Id';


export default class IpaMarqueePartner extends LightningElement {

    @api marqueeDataSource;

    @api title;
    @api subtitle;
    @api description;
    @api pageType;

    @api rightButtonLabel;
    @api rightButtonCommPage;
    @api rightButtonExternalUrl;
    @api rightCta1Label;
    @api rightCta1CommPage;
    @api rightCta1ExternalUrl;
    @api rightCta2Label;
    @api rightCta2CommPage;
    @api rightCta2ExternalUrl;
    @api analyticsPageType;

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
    label = {
        releaseNotification
    };
    showNotification = false;
    isRedirect;

    /**
    * Indicates if the page analytics have already been called.
    * @type {boolean}
    * @private
    */
    analyticsCalled = false;

    /**
    * Indicates if the breadcrumb data has already been retrieved and rendered.
    * @type {boolean}
    * @private
    */
    breadcrumbsRendered = false;
    currentUrl = '';

    connectedCallback() {
        this.currentUrl = window.location.href;
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

        /** If Marquee Data Source is Application State, use redux marquee */

        
        if (this.marqueeDataSource === 'Benefit Service') {
            this.title = '';
            this.subtitle = '';
            this.description = '';
            // reset company profile

            this.fetchBenefitProfile();
        }

        if(releaseNotification != null && releaseNotification !='Running') {
            this.showNotification = true;
        }
	}

    @wire(isLoggedInUserInternalUser, { userId: UserId, currentUrl: '$currentUrl'})
    internalUserCheck(response) {
        if (response.data) {
            this.isRedirect = response.data;
            if (this.isRedirect === 'true') {
                const url = IPASecureHomepageLink + "/accessdenied"; 
                window.open(url, "_self");
            }
        } else if (response.error) {
            console.error('Error checking user:', response.error);
        }
    }

     async fetchBenefitProfile() {
        let result;
        try {
            console.log('ipaMarqueePartner mock ==>'+USE_MOCK, 'pageType ==>'+this.pageType);
            if (USE_MOCK) {
                result = await MockBenefitService.getBenefitProfile(this.pageType);
            } else {
                result = await getBenefitProfile(this.pageType);
            }
        } catch(e) {
            console.error('getBenefitProfile error', `${e}`);
        }
        if (result){
            // add stuff to name and profile
            this.title = result.marqueeTitle;
            this.subtitle = welcome + ' ' + result.name;
            this.description = result.title;
            this.buttonLinkData = { ...this.baseLink, ...result.dashboardLink};
            this.cta1LinkData = { ...this.baseLink, ...result.companyProfileLink};
            this.cta2LinkData = { ...this.baseLink, ...result.myProfileLink};
        }
    }

    get classes() {
        return {
            containerClass: "container",
            alignment: this.ifs.hasRightPanel ? "Left" : this.alignment
        };
    }

    isLinkDataComplete(linkData) {
        return linkData && linkData.label && (linkData.communityPage || linkData.externalUrl)
    }
    get ifs() {
        return {
            buttonCtaValid: this.isLinkDataComplete(this.buttonLinkData),
            rightCta1Valid:  this.isLinkDataComplete(this.cta1LinkData),
            rightCta2Valid:  this.isLinkDataComplete(this.cta2LinkData),
        }
    }



    /**
    * Called during render of the component lifecycle. Used to get the breadcrumbs
    * and call the method to render them.
    * @private
    */
    renderedCallback() {
      // Only invoke the breadcrumb logic the first time the component is rendered
      if (!this.breadcrumbsRendered) {
        this.breadcrumbsRendered = true;
        this.renderBreadcrumbs();
      }

      if (!this.analyticsCalled) {
        this.analyticsCalled = true;
        callAnalytics(this.analyticsPageType, 'IPA', false);
      }
    }



    /**
    * Gets the breadcrumbs and calls the component method to render them.
    * @private
    */
    renderBreadcrumbs() {
      // Call the service to get the breadcrumbs. Not sure if this is actually going
      // to be a promise, so keeping it simple for now.
      getIpaBreadcrumbs().then((breadcrumbs) => {
        const breadcrumbsComponent = this.template.querySelector('c-core-intc-breadcrumbs');
        if (breadcrumbsComponent) {
          breadcrumbs.analyticsData = getAnalyticsData(this.analyticsPageType, 'IPA');
          breadcrumbsComponent.renderBreadcrumbs(breadcrumbs);
        } else {
          console.error('coreIntcBreadcrumbs not found in ipaMarqueePartner');
        }
      });
    }

}