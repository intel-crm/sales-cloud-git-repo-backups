/** Documentation for ipaSupportFooter  Component
 * <br>
 * <p>Ipa Support Footer gets the  {@link ipaBenefitService.PartnerSupportFooter} object from the {@link ipaBenefitService.getSupportFooter}</p>
 * <p> From the Object the rendering fo the title as well as  each of the {@link ipaBenefitService.PartnerSupportCard} with dynamic content in column format.
 * </p>
 * <h4>Rendered Columns</h4>
 * <ul>
 * <li><b>< 768</b> - 1 Column Layout</li>
 * <li><b>>= 992</b> - 3 Column Layout</li>
 * <li><b>>= 1200</b> - 4 Column Layout</li>
 * </ul>

 * @namespace ipaSupportFooter
 * @author Joshua Gonzalez
*/
const USE_MOCK = window.location.href.match('mockdata') ? true : false;

import { LightningElement, track } from 'lwc';

import supportFooterTemplate from './ipaSupportFooter.html';
import loadingTemplate from './loading.html';
import { getSupportFooter } from 'c/ipaBenefitService';
import { MockBenefitService } from 'c/ipaMockData';

export default class IpaSupportFooter extends LightningElement {
    @track isLoading = true;
    @track title = '';
    @track cards = [];

    connectedCallback(){
        this.fetchSupportFooter();
    }
    render() {
        return this.isLoading ? loadingTemplate : supportFooterTemplate;
    }

    async fetchSupportFooter() {
        let result;
        try {
            if (USE_MOCK) {
                result = await MockBenefitService.getSupportFooter();
            } else {
                result = await getSupportFooter();
            }
        } catch(e) {
            console.error('getSupportFooter error', `${e}`);
        }
        if (result) {
            this.title = result.title;
            this.cards  = result.cards.map((card,cardIndex) => {
                // add ids to tree
                let content = card.content.map((item, contentIndex) => ({
                        ...item,
                        id: 'content-' + cardIndex + '-' + contentIndex,
                        isLinks:  (item.type === 'links'),
                        isText:  (item.type === 'text'),
                        isRichText:  (item.type === 'richtext'),
                        body: (item.type === 'links') ? this.addIds(item.body, 'link-' + cardIndex + '-' + contentIndex) : item.body
                }));
                return {
                    ...card,
                    id: 'card-' + cardIndex,
                    content: content
                }
            });
        }
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


}