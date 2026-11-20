import { LightningElement, api, track, wire } from 'lwc';
import getSearchResults from '@salesforce/apex/Pricing_PricingAI_Controller.getSearchResults';
import { getRecord } from 'lightning/uiRecordApi';
import pricingPubSub from 'c/pricingPubSub';
const PAYLOAD = {};
const QLI_FIELDS = [
    'SBQQ__QuoteLine__c.Pricing_Quote_Line_Number__c',
    'SBQQ__QuoteLine__c.Id'
];

export default class PricingSearchComponent extends LightningElement {
    @api objectApiName;
    @api fieldApiName;
    @api searchType;
    @api filterFieldApiName;
    @api filterFieldValue;
    @api header = 'Select Quote Line';

    @track searchKey;
    @track results;
    @track error;
    @track iconname = 'custom:custom26';

    @api selectedRecordId;
    @track showSpinner;
    typingTimer;                //timer identifier
    doneTypingInterval = 1000;  //time in ms, 1 seconds

    //Get Selected QuoteLine values
    @wire(getRecord, { recordId: '$selectedRecordId', fields: QLI_FIELDS })
    wiredRecord({ error, data }) {
        pricingPubSub.fire('loadchart', PAYLOAD, false);
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
        } else if (data) {
            this.searchKey = data.fields.Pricing_Quote_Line_Number__c.value;
            console.log('Search Key: ' + this.searchKey);
            //pricingPubSub.refresh('refreshEventName', this.selectedRecordId);
            const evt = new CustomEvent('recordselect', { detail: { recordId: this.selectedRecordId } });
            this.dispatchEvent(evt);
        }
        //pricingPubSub.fire('loadchart', PAYLOAD, false);
    }

    connectedCallback() {
        this.hideDropDown();
    }



    handleSelect(event) {
        this.searchKey = event.detail.fldValue;
        this.selectedRecordId = event.detail.recordId;
        this.hideDropDown();
        const evt = new CustomEvent('recordselect', { detail: { recordId: this.selectedRecordId } });
        this.dispatchEvent(evt);

    }
    handleKeyUp(event) {
        clearTimeout(this.typingTimer);
        this.searchKey = event.target.value;
        if (this.searchKey.length > 3) {
            this.typingTimer = setTimeout(function () { this.getSrchResults(); }.bind(this), this.doneTypingInterval);
        }
        pricingPubSub.fire('loadchart', PAYLOAD, false);
    }
    handleKeyDown(event) {
        clearTimeout(this.typingTimer);
    }
    handleChange(event) {
        this.searchKey = event.target.value;
        this.hideDropDown();
        if (this.searchKey.length > 3) {
            this.showSpinner = true;
            this.getSrchResults();
        }
    }
    hideDropDown() {
        this.results = { isSuccess: false };
    }
    getSrchResults() {
        this.showSpinner = true;
        this.dispatchEvent(new CustomEvent('valuechange'));
        var sParams = JSON.stringify({  // NOSONAR
            objectName: this.objectApiName,
            fieldName: this.fieldApiName,
            searchType: this.searchType,
            searchText: this.searchKey,
            filterFieldName: this.filterFieldApiName,
            filterFieldValue: this.filterFieldValue
        });
        getSearchResults({ jsonObj: sParams })
            .then(data => {
                this.showSpinner = false;
                this.results = data;
                this.error = undefined;
            })
            .catch(error => {
                this.showSpinner = false;
                this.error = JSON.stringify(error);
                this.hideDropDown();
            })
    }

}