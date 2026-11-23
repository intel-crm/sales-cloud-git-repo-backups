import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'SBQQ__Quote__c.Pricing_AI_RFP_Scraping_Status__c',
    'SBQQ__Quote__c.Pricing_AI_Scraping_Recommendation_Nm__c'
];

export default class Pricing_Quote_RFP_AI_Section extends LightningElement {
    @api recordId;
    isExpanded = false;
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    quote;

    get aiRfpScrapingStatus() {
        console.log('AI RFP STATUS:'+this.quote.data?.fields?.Pricing_AI_RFP_Scraping_Status__c?.value);
        return this.quote.data?.fields?.Pricing_AI_RFP_Scraping_Status__c?.value;
    }

    get aiScrapingRecommendation() {
        console.log('AI RFP RECOMMENDATION:'+this.quote.data?.fields?.Pricing_AI_Scraping_Recommendation_Nm__c?.value);
        return this.quote.data?.fields?.Pricing_AI_Scraping_Recommendation_Nm__c?.value;
    }

    get buttonIcon() {
        return this.isExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    handleToggle() {
        this.isExpanded = !this.isExpanded;
    }
}