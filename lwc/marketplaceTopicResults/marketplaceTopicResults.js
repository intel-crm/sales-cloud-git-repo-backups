import { LightningElement, api } from 'lwc';
//import getTopicResponse from '@salesforce/apex/PMP_MarketplaceTopics.getTopicResponse';
import USERLANG from '@salesforce/i18n/lang';

export default class marketplaceTopicResults extends LightningElement {
//IPA2.0:TWC729-8114 Topics Removal/Event Removal
    @api searchResponse;

    @api searchParams;


    @api recordId;

    /**
     * sets search params
     * - displays loading cards
     */
//     connectedCallback() {
//      this._searchParams = {
//        category: '',
//        keyword: '',
//        page: 1,
//        sortType: 'relevance',
//        filters: {},
//      };
//      getTopicResponse({
//        requestJSON: JSON.stringify({
//          ...this._searchParams,
//          searchType: 'topics',
//          langCode: USERLANG,
//        }), topicId: this.recordId,
//      }).then((result) => {
//
//        this.searchResponse = JSON.parse(result);
//        this.searchResponse.searched = true;
//      }).catch((error) => {
//        throw error;
//      });
//    }

}