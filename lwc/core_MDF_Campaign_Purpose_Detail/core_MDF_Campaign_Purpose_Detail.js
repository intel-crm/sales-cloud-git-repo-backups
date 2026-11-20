import { LightningElement, wire, api } from 'lwc';
import getAccountWrapper from '@salesforce/apex/Core_MDF_PartnerFundClaim.getCampaignPurposeDetails';
import CAMPAIGN_PURPOSE_HEADER from '@salesforce/label/c.Core_MDF_Campaign_Purpose';
import BRAND_AND_TECHNOLOGY from '@salesforce/label/c.Core_MDF_Brand_and_Technology';
import { getRecord } from 'lightning/uiRecordApi';
import ACTIVITY_FIELD from '@salesforce/schema/PartnerFundClaim.RequestId';
import CAMPAIGN_FIELD from '@salesforce/schema/PartnerFundClaim.Core_MDF_Campaign_Id__c';

export default class Core_MDF_Campaign_Purpose_Detail extends LightningElement {
    @api recordId;
    data;
    error;
    showCampaignPurpose = false;
    campaignPurposeHeader = CAMPAIGN_PURPOSE_HEADER;
    activityId;
    campaignId;
    tableHeader;

    @wire(getRecord, { recordId: '$recordId', fields: [ACTIVITY_FIELD, CAMPAIGN_FIELD] })
    wiredClaim({ data, error }) {
        if (data) {
            this.activityId = data.fields.RequestId.value;
            this.campaignId = data.fields.Core_MDF_Campaign_Id__c.value;
            this.tableHeader = this.campaignId ? `${CAMPAIGN_PURPOSE_HEADER}` : `${CAMPAIGN_PURPOSE_HEADER} (${BRAND_AND_TECHNOLOGY})`
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getAccountWrapper, { claimId: '$recordId', activityId: '$activityId' })
    wiredAccount({ error, data }) {
        if (data) {
            this.data = data;
            this.showCampaignPurpose = data.showTacticMetric; 
            this.error = undefined;
            console.log(this.data);
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
}