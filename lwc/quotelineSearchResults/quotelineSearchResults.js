import { LightningElement, wire, api, track } from 'lwc';
import getFields from '@salesforce/apex/Pricing_QuoteLineDetailsController.getFields';
import getQuoteLines from '@salesforce/apex/Pricing_QuoteLineDetailsController.getQuoteLines';
import getFieldSetForProduct from '@salesforce/apex/Pricing_QuoteLineDetailsController.getFieldSetForProduct';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { publish, MessageContext } from 'lightning/messageService';
import QuoteLineMC from '@salesforce/messageChannel/QuoteLineMessageChannel__c';
import pricingPubSub from 'c/pricingPubSub';
import Pricing_Tender_Write_In_Product from '@salesforce/label/c.Pricing_Tender_Write_In_Product';

const SUCCESS_TITLE = 'Success';
const SUCCESS_VARIANT = 'success';
const ERROR_TITLE = 'Error';
const ERROR_VARIANT = 'error';

export default class QuotelineSearchResults extends LightningElement {
    quoteId = '';
    @track quotelines;
    selectedQuotelineId = '';
    error = undefined;
    @api recordId;
    @track showReadOnlyQL = false;
    @track isLoading = false;
    @track metaData = [];

    @track productName;

    @wire(MessageContext) messageContext;

    wiredQuotelines() {
        this.notifyLoading(true);
        getQuoteLines({ recordId: this.recordId })
            .then(result => {
                this.notifyLoading(false);
                this.quotelines = result;
                console.log('This.quotelines => ' + JSON.stringify(this.quotelines));
                // formatdate
                this.quotelines.forEach(ql => {
                    ql.Pricing_End_Date_dt__c = this.formatDateToMmDmYyyy(ql.Pricing_End_Date_dt__c);
                    ql.Pricing_Approved_End_Date_Dt__c = this.formatDateToMmDmYyyy(ql.Pricing_Approved_End_Date_Dt__c);
                });

            })
            .catch(error => {
                this.notifyLoading(false);
                this.error = error;
                this.quotelines = undefined;

            });
    }

    formatDateToMmDmYyyy(strDate) {
        if(strDate == '' || strDate == null || strDate == undefined)
        {
            return '';
        }else{
            var date = new Date(strDate);
            var year = date.getFullYear();
            var month = (1 + date.getMonth()).toString();
            month = month.length > 1 ? month : '0' + month;
            var day = date.getDate().toString();
            day = day.length > 1 ? day : '0' + day;
            return month + '/' + day + '/' + year;
        }        
    }

    @wire(getFields)
    wiredBoats(result) {

        this.wiredQuotelines();
        /*this.quotelines = result;
        if (result.error) {
            this.error = result.error;
            this.quotelines = undefined;
        }
        this.isLoading = false;
        this.notifyLoading(this.isLoading);*/
    }


    @wire(getFieldSetForProduct)
    getMetaData({ error, data }) {
        if (data) {
            this.metaData = data;
        } else if (error) {
            console.error('Error:', error);
        }
    }

    connectedCallback() {
        pricingPubSub.register('showReadOnlyQLEvent', this.showReadOnlyQLEvent.bind(this));
        pricingPubSub.register('refreshevent', this.refreshevent.bind(this));
    }

    showReadOnlyQLEvent(quoteId, closeModal) {
        console.log('showReadOnlyQLEvent:', quoteId, closeModal);
        if (quoteId != null && closeModal == false) {
            this.quoteId = quoteId;
            this.showReadOnlyQL = true;
            let quote = this.quotelines.find(ele => ele.Id == quoteId);           
            this.productName = quote.SBQQ__ProductName__c == Pricing_Tender_Write_In_Product ? quote.Pricing_Other_Product_Nm__c : quote.SBQQ__ProductName__c;
        }
    }

    refreshevent(status) {
        console.log('refreshevent:', status);
        this.wiredQuotelines();
    }

    updateSelectedTile(event) {
        this.selectedQuotelineId = event.detail.boatId;
        this.sendMessageService(this.selectedQuotelineId);
    }

    handleSave(event) {
        //code
    }

    @api
    async refresh() {
        this.isLoading = true;
        this.notifyLoading(this.isLoading);
        await refreshApex(this.quotelines);
        this.isLoading = false;
        this.notifyLoading(this.isLoading);
    }


    notifyLoading(isLoading) {
        if (isLoading) {
            this.dispatchEvent(new CustomEvent('loading'));
        } else {
            this.dispatchEvent(CustomEvent('doneloading'));
        }
    }

    sendMessageService(quoteLineId) {
        publish(this.messageContext, QuoteLineMC, { recordId: quoteLineId });
    }

    closeModal() {
        this.showReadOnlyQL = false;
    }

    onClickCancel() {
        this.showReadOnlyQL = false;
    }

    refresh() {
        this.wiredQuotelines();
    }
}