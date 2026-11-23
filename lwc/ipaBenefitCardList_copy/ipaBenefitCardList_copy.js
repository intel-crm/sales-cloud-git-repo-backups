/* eslint-disable @lwc/lwc/no-api-reassignments */
/** Documentation for IpaBenefitCardList Card Component
 *
 * @namespace IpaBenefitCardList
*/

import { LightningElement, api, track } from 'lwc';
// temporary font loading resource
import { loadStyle } from 'lightning/platformResourceLoader';
import fontResource from '@salesforce/resourceUrl/IpaResources';
import { getState } from 'c/ipaRedux';
import showMore from '@salesforce/label/c.PMP_Benefits_ShowMore';
import { getBenefitProfile } from 'c/ipaBenefitService_copy1';
import { getBenefits } from 'c/ipaBenefitService_copy1';
//import getBenefits from '@salesforce/apex/IPABenefitUtility.getBenefitsInfo';
//import getBenefitProfile from "@salesforce/apex/IPABenefitUtility.getProfileInfo"
import UserId from '@salesforce/user/Id';

export default class IpaBenefitCardList_copy extends LightningElement {
    @api title = 'Manage Benefits';
    @api description = 'Deprecated'; // deprecated getting description from service
    @api initialMobileCount = 2;
    @api devFonts = false;
    @track _description = '';
    @track benefits = [];
    @track showAllMobile = false;
    @track showMore = showMore;

    get benefitsMobileShow() {
        return this.benefits && this.benefits.slice(0, this.initialMobileCount);
    }
    get benefitsMobileHide() {
        return this.benefits && this.benefits.slice(this.initialMobileCount);
    }

    connectedCallback() {
        this.fetchBenefitProfile();
        this.fetchBenefits();
    }

    async fetchBenefits() {
        const result = await new Promise(resolve => {
            // eslint-disable-next-line @lwc/lwc/no-async-operation'0058A000004AfMzQAK'
            setTimeout(() => {
                getBenefits().then((value) => {
                    resolve(value);
                });
            }, 2000);
        });
        this.benefits = result;

        console.log('benefits', result);
    }

    async fetchBenefitProfile() {
        const result = await new Promise(resolve => {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                getBenefitProfile().then((value) => {
                    resolve(value);
                });
            }, 2000);
        });

        this._description = result.benefitDescription;
    }

    get isMobile() {
        return getState().ui.breakpoint.isMobile;
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

    renderedCallback() {
        if (this.devFonts) {
            //eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                Promise.all([
                    loadStyle(this, fontResource + '/devFonts/site-global-icons/css/site-global-icons.css')
                ]).catch(error => {
                    // eslint-disable-next-line no-console
                    console.log(error);
                });
            }, 2000);
        }
    }

}