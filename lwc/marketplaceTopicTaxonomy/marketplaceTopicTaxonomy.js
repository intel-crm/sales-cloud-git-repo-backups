import { LightningElement,api,wire } from 'lwc';
//import getTopics from '@salesforce/apex/PMP_MarketplaceTopics.getAggregatedTopics';

export default class MarketplaceTopicTaxonomy extends LightningElement {
//IPA2.0:TWC729-8114 Topics Removal/Event Removal
//    @api listTopics = [];
//    columns = [
//        {label: 'Topic Name', fieldName:'topicUrl', type:'url',
//        typeAttributes: {
//            label: {
//                fieldName: 'topicName'
//            }
//        }},
//    ];
//    /**
//     * Connected callback - subscribes to current search and breakpoint data
//     *
//     * @private
//     */
//
//     connectedCallback() {
//        getTopics().then((result) => {
//            this.listTopics = result;
//            if(this.listTopics){
//                this.listTopics.forEach(item => item['topicUrl'] = '/imp/s/topic/' +item['topicId']);
//            }
//        })
//        .catch((error) => {
//            this.error = error;
//        });
//      }
}