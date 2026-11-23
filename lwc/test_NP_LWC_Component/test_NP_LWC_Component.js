import { LightningElement, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import CAMPAIGN_OBJECT from '@salesforce/schema/Campaign';
import NAME_FIELD from '@salesforce/schema/Campaign.Name';
import ACCOUNT_FIELD from '@salesforce/schema/Campaign.Core_MDF_Account__c';
import MARKET_FIELD from '@salesforce/schema/Campaign.Core_MDF_Market__c';


export default class Test_NP_LWC_Component extends LightningElement {
    //@track _selected = [];

    /*@wire(getObjectInfo, { objectApiName: CAMPAIGN_OBJECT })
    objectInfo;*/

    @wire(getPicklistValues, { recordTypeId: '012g0000000E6O1AAK', fieldApiName: MARKET_FIELD})
    CountryValues;

    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    // Handling the change event
    handleChange(event) {
        this._selected = event.detail.value;
    }

    // objectApiName is "Account" when this component is placed on an account record page
   /* @api objectApiName;
    fields = [NAME_FIELD, ACCOUNT_FIELD, MARKET_FIELD];
    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Campaign created",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);
    }*/
}