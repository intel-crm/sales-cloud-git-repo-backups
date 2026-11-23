/* eslint-disable @lwc/lwc/no-api-reassignments */
/** Documentation for ipaBenefitCardList  Component
 * <br>
 * <p>Ipa Benefit Cardlist gets the  array of {@link ipaBenefitService.Benefit} from the {@link ipaBenefitService.getBenefits} and renders IpaBenefitCard for each data</p>
 * <p>Ipa Benefit Cardlist gets the  description from  {@link ipaBenefitService.BenefitProfile } from the {@link ipaBenefitService.getBenefitProfile}</p>

 * @namespace ipaBenefitCardList
 * @property {string} title the Title for the Component
 * @property {integer} initialMobileCount Used to determine how many benefit cards to show in the mobile breakpoint, defaults to 2
 *
 * @author Joshua Gonzalez
*/


const USE_MOCK = window.location.href.match('mockdata') ? true : false;

import { LightningElement, api, track,wire } from 'lwc';
import { getBenefits } from 'c/ipaBenefitService';

import benefitCardListTemplate from './ipaBenefitCardList.html';
import loadingTemplate from './loading.html';

import showMore from '@salesforce/label/c.IPA_Benefits_ShowMore';
import homeOverviewLink from '@salesforce/label/c.PRM_RedirectToOverViewPage';
import homeNonPrimaryLink from '@salesforce/label/c.PRM_RedirectToPostLaunchNonPrimary';
import redirecturlPrimary from '@salesforce/label/c.PRM_Partner_Admin_Link';
import redirecturlNonPrimary from '@salesforce/label/c.PRM_Non_Partner_Admin_Link';

import manageBenefits from '@salesforce/label/c.IPA_Benefits_Manage_Benefits';

import { getBenefitProfile } from 'c/ipaBenefitService';
import { MockBenefitService } from 'c/ipaMockData';

/*import showMessage from '@salesforce/apex/PRM_RenewalStatus.showMessage';
import renewalLink from '@salesforce/label/c.PRM_RenewalLink';
*/ //IPA2.0 TWC727-3135

import getChannelAssets
    from '@salesforce/apex/PRM_DoceboController.getChannelAssets';


export default class IpaBenefitCardList extends LightningElement {
    @api title = manageBenefits;
    @api description = 'Deprecated'; // deprecated getting description from service
    @api initialMobileCount = 2;

    @track _description = '';
    @track benefits = [];
    @track showAllMobile = false;
    @track isLoading = true;
    //@wire(showMessage) showmessagevalue;
    dashboardUrl;
doceboData;
showDoceboBenefit = false;
    

    /**
     * keep track of current screen size from coreIntcUtilities
     *
     * @type {object}
     * @private
     */
    currentScreen = {};

    /*label = {
        showMore,
        manageBenefits,
        renewalLink
    };*/
    label = {
        showMore,
        manageBenefits
    };//IPA2.0 TWC727-3135

    render() {
        return this.isLoading ? loadingTemplate : benefitCardListTemplate;
    }

    get benefitsMobileShow() {
        return this.benefits && this.benefits.slice(0, this.initialMobileCount);
    }
    get benefitsMobileHide() {
        return this.benefits && this.benefits.slice(this.initialMobileCount);
    }

    /*connectedCallback() {
        // this.fetchBenefitProfile(); // we have merge the callout to single call
        this.fetchBenefits();
    }*/
   async connectedCallback() {
    this.isLoading = true;
    const startTime = Date.now();

    // Start both requests before waiting for either result.
    const results = await Promise.allSettled([
        (async () => {
            console.log('Benefits time start', startTime);
            const res = await this.fetchBenefits();
            console.log('Benefits time end', Date.now() - startTime);
            return res;
        })(),
        (async () => {
            const starttimedocebo = Date.now();
            console.log('Docebo time start', starttimedocebo);
            const res = await this.fetchDoceboCourses();
            console.log('Docebo time end', Date.now() - starttimedocebo);
            return res;
        })()
    ]);

//await this.fetchDoceboCourses();

    // Wait for both even if one fails unexpectedly.
    results.forEach((result, index) => {

        console.log('Result from Promise.allSettled for index', index, result);
        if (result.status === 'rejected') {
            console.error(
                index === 0
                    ? 'Benefits loading failed'
                    : 'Docebo loading failed',
                result.reason
            );
        }
    });

    // Filter only after benefits and Docebo have both finished.
    if (!this.showDoceboBenefit) {
        this.benefits = this.benefits.filter(
            benefit => benefit.title !== 'Recommended Learning'
        );
    }

    // One loading gate for all blades.
    this.isLoading = false;

    console.log('All blades load time (ms):', Date.now() - startTime);
}

async fetchDoceboCourses() {
    const startTime = Date.now();

    try {
        const result = await getChannelAssets();
console.log('result from docebo -',result);
        this.doceboData = result;
        this.showDoceboBenefit =
            result?.userExists === true &&
            Array.isArray(result?.courses) &&
            result.courses.length > 0;
    } catch (error) {
        this.doceboData = undefined;
        this.showDoceboBenefit = false;
        console.error('Docebo error', error);
    } finally {
        console.log('Docebo load time (ms):', Date.now() - startTime);
    }
}
    async fetchBenefits() {
        let result;
        const date1 = new Date();
        const starttime = date1.getTime();
        console.error('BenefitsStarrtime', +starttime);
        try {
            if (USE_MOCK) {
                result = await MockBenefitService.getBenefits();
            } else {
                result = await getBenefits();
            }
        } catch (e) {
            console.error('getBenefits error', `${e}`);
        }
        if (result) {
            if(result.checkAgreementBnft == 'tandcnotpresentPartner Admin' || result.checkAgreementBnft == 'tandcnotpresentPartner Admin Delegate'  ) {
                //Navigate to home page
             
               window.location.href= homeOverviewLink;
             // 'https://www.intel.com/content/www/us/en/secure/partner-alliance/overview.html';
         
            }
            else if(result.checkAgreementBnft ==  'tandcnotpresentEmployee')
            {
                    console.log('Check Agreement4>>>>>'+result.checkAgreementBnft);
                window.location.href= homeNonPrimaryLink;
            }
                else if(result.isUserSubscribedAll=='false'){
                    if(result.checkAgreementBnft == 'tandcpresentPartner Admin' || result.checkAgreementBnft == 'tandcpresentPartner Admin Delegate'){
                        console.log('Check Agreement2>>>>>'+result.checkAgreementBnft);
                        window.location.href= redirecturlPrimary;
                    }
                    else if(result.checkAgreementBnft == 'tandcpresentEmployee'){
                        console.log('Check Agreement1>>>>>'+result.checkAgreementBnft);
                        window.location.href= redirecturlNonPrimary;
                    }
                        
                }
         
        else{
           /* this.benefits = result.benefitInfo;
            this._description = result.summaryDescription;*/
           this.benefits = [...result.benefitInfo];
this._description = result.summaryDescription;
        }
    }
        const date2 = new Date();
        const endtime = date2.getTime();
        console.error('BenefitInfoend', +endtime);
        const calTimeBenefits = endtime - starttime;
        console.error('BenefitInfoDIFF', +calTimeBenefits);
    }

    async fetchBenefitProfile() {
        const date1 = new Date();
        const starttime = date1.getTime();
        console.error('MarqueeStarrtime', +starttime);
        let result;
        try {
            if (USE_MOCK) {
                result = await MockBenefitService.getBenefitProfile();
            } else {
                result = await getBenefitProfile();
            }
        } catch (e) {
            console.error('getBenefitProfile error', `${e}`);
        }
        if (result) {
            this._description = result.benefitDescription;
        }
        const date2 = new Date();
        const endtime = date2.getTime();
        console.error('Marqueeend', +endtime);
        const calTimeBenefits = starttime - endtime;
        console.error('MarqueeDIFF', +calTimeBenefits);
    }

    get isMobile() {
        return this.currentScreen.isMobile;
    }

    get classes() {
        return {
            mobileContainerClass: (this.showAllMobile ? "mobile-show" : "mobile-hide"),
            showMoreMobile: 'slds-hide_medium ' + (this.showAllMobile ? "mobile-hide" : "mobile-show")
        };
    }


    handleShowMore(evt) {
        evt.preventDefault();
        this.showAllMobile = !this.showAllMobile;
    }

    /**
     * screen change (using coreIntcUtilities)
     *
     * @param {event} evt screen change event
     * @private
     */
    handleScreenChange(evt) {
      this.currentScreen = evt.detail.screen;
    }

    renderedCallback() {
        this.dashboardUrl = window.location.origin+'/ipa/s/dashboard';
    }

}