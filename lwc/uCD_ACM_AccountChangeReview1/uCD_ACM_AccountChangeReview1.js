import { LightningElement, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { getDataConnectorSourceFields } from 'lightning/analyticsWaveApi';
export default class UCD_ACM_AccountChangeReview1 extends LightningElement {
    error;
    records;
    @wire(getRelatedListRecords, {
        parentRecordId: 'aCq2D0000006GmOSAU',
        relatedListId: 'Account_Change_Review',
        fields: ['Account_Change_Review__r.Name'],
        where : {New_Unified_ID__c	: "1234567"} 
    })
    listInfo({ error, data }) {
        if (data) {
            console.log('alert' + data)
            this.records = data.records;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }
}