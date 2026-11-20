/** Documentation for ipaPartnerQuickLinks  Component
 * <br>
 * <p>Ipa Support Footer gets the  {@link ipaBenefitService.PartnerQuicklinks} object from the {@link ipaBenefitService.getPartnerQuickLinks}</p>
 * <p> From the Object the rendering fo the title as well as  each of the {@link SimpleCard} data.
 * </p>
 * <h4>Rendered Columns</h4>
 * <ul>
 * <li><b>< 768</b> - 1 Column Layout</li>
 * <li><b>>= 768</b> - 2 Column Layout</li>
 * <li><b>>= 1200</b> - 3 Column Layout</li>
 * </ul>

 * @namespace ipaPartnerQuickLinks
 * @author Joshua Gonzalez
*/
const USE_MOCK = window.location.href.match('mockdata') ? true : false;

import { LightningElement, track } from 'lwc';

import quickLinksTemplate from './ipaPartnerQuickLinks.html';
import loadingTemplate from './loading.html';
import { getPartnerQuickLinks } from 'c/ipaBenefitService';
import { MockBenefitService } from 'c/ipaMockData';

export default class IpaPartnerQuickLinks extends LightningElement {
    @track isLoading = true;
    @track title = '';
    @track cards = [];
    @track cardTemplateType = 'Icon Horizontal';

    connectedCallback(){
        this.fetchQuickLinks();
    }
    render() {
        return this.isLoading ? loadingTemplate : quickLinksTemplate;
    }

    async fetchQuickLinks() {
        let result;
        try {
            if (USE_MOCK) {
                result = await MockBenefitService.getPartnerQuickLinks();
            } else {
                result = await getPartnerQuickLinks();
            }
        } catch(e) {
            console.error('getPartnerQuickLinks error', `${e}`);
        }

        if (result){
            this.title = result.title;
            this.cards  =  result && result.cards ?  result.cards.map((card,cardIndex) => ({
                ...card,
                id: 'card-' + cardIndex,
                icon: card.icon ? card.icon + ' round-reverse-color ' : card.icon,
            })): [];
        }
        // for QA testing only DELETE AFTER TESTING AND INTEGRATOIN WHEN GOING TO PROD START DELETE
        if (window.location.search.indexOf('simulatenoquicklinks') > -1){
            console.log('Simluating No Quicklink Cards');
            this.cards = [];
        }
        // for QA testing only DELETE AFTER TESTING AND INTEGRATOIN WHEN GOING TO PROD END DELETE

        this.isLoading = false;
    }

    addIds(arr, prefix){
        if (arr && arr.length > 0) {
            return arr.map((item,index) => ({
                ...item,
                id: prefix + '-' + index
            }));
        }
        return arr;
    }

    get ifs() {
        return {
            hasLinks: this.cards && this.cards.length > 0
        }
    }

}