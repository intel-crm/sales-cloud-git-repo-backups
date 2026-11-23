import { LightningElement, wire, api } from 'lwc';
import getAccountWrapper from '@salesforce/apex/Core_MDF_PartnerFundClaim.getCampaignPurposeDetails';
import CAMPAIGN_PURPOSE_HEADER from '@salesforce/label/c.Core_MDF_Campaign_Purpose';
import BRAND_AND_TECHNOLOGY from '@salesforce/label/c.Core_MDF_Brand_and_Technology';
import BUSINESS_PURPOSE from '@salesforce/label/c.Core_MDF_Business_Purpose';
import MARKETING_PURPOSE from '@salesforce/label/c.Core_MDF_Marketing_Purpose';
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
    purposeRows = [];

    @wire(getRecord, { recordId: '$recordId', fields: [ACTIVITY_FIELD, CAMPAIGN_FIELD] })
    wiredClaim({ data, error }) {
        if (data) {
            this.activityId = data.fields.RequestId.value;
            this.campaignId = data.fields.Core_MDF_Campaign_Id__c.value;
            this.tableHeader = this.campaignId ? `${CAMPAIGN_PURPOSE_HEADER}` : `${CAMPAIGN_PURPOSE_HEADER} (${BRAND_AND_TECHNOLOGY})`
            /*if (this.campaignId) {
                this.tableHeader = `${CAMPAIGN_PURPOSE}`;
            } else {
                this.tableHeader = `${ACTIVITY_PURPOSE} (${BRAND_TECH})`;
            }*/
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getAccountWrapper, {claimId: '$recordId',activityId: '$activityId'})
    wiredAccount({ error, data }) {
        if (data) {
            this.data = data;
            this.purposeRows = [];
            if (
                data.isCcfDcfPurpose
                && Array.isArray(data.purposeRows)
            ) {
                var purposeOrder = {
                    business: 1,
                    marketing: 2
                };

                this.purposeRows = data.purposeRows
                    .filter(function(row) {
                        var outcomeType = row.outcomeType
                            ? row.outcomeType.toLowerCase()
                            : '';

                        return outcomeType === 'business'
                            || outcomeType === 'marketing';
                    })
                    .sort(function(firstRow, secondRow) {
                        var firstType = firstRow.outcomeType.toLowerCase();
                        var secondType = secondRow.outcomeType.toLowerCase();

                        return purposeOrder[firstType]
                            - purposeOrder[secondType];
                    })
                    .map(function(row) {
                        var outcomeType =
                            row.outcomeType.toLowerCase();

                        return {
                            ...row,
                            purposeLabel:
                                outcomeType === 'marketing'
                                    ? MARKETING_PURPOSE
                                    : BUSINESS_PURPOSE
                        };
                    });
            }
            this.showCampaignPurpose = data.showTacticMetric;
            
            /*
            * CCF/DCF must not show "(Brand and Technology)".
            * Existing IPA header behavior remains unchanged.
            */
            this.tableHeader = data.isCcfDcfPurpose
                ? CAMPAIGN_PURPOSE_HEADER
                : (
                    this.campaignId
                        ? CAMPAIGN_PURPOSE_HEADER
                        : `${CAMPAIGN_PURPOSE_HEADER} (${BRAND_AND_TECHNOLOGY})`
                );

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
}