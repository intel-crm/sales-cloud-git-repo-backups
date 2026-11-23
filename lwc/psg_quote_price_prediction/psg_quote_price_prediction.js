import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import updateQuoteLines from '@salesforce/apex/PSG_Quote_Price_Prediction_Controller.updateQuoteLines';
//import sendQuoteLinesToEndpoint from '@salesforce/apex/PSG_Quote_Price_Prediction_Controller.sendQuoteLinesToEndpoint';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';
import PSG_Pricepredict_css from '@salesforce/label/c.PSG_Pricepredict_css';

export default class PricePrediction extends LightningElement {
    _recordId;
    @track quoteLines = [];
    @track isLoading = false;  
    @track isError = false;
    @track usepredictprice = false;
    @track isrender=true;
    spinnercontent='Loading...';
    

    title = 'Price Guidance';
    info = 'Please checkmark the Quote Lines where “Suggested Resale” can be updated with the “Resale Guidance” price.';
    info2 = 'If no update is needed, please select the Reason For Not Using Price Guidance.';

    disregardingPredictedPriceOptions = [
        { label: 'N/A', value: 'N/A' },
        { label: 'Price Guidance is too low', value: 'Price Guidance is too low' },
        { label: 'Price Guidance is too high', value: 'Price Guidance is too high' },
        { label: 'Not suitable for this OPN/QL type', value: 'Not suitable for this OPN/QL type' },
        { label: 'Competitor pricing', value: 'Competitor pricing' },
        { label: 'Price Guidance inconsistency', value: 'Price Guidance inconsistency' }
    ];
    
    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        if (this._recordId) {
            this.fetchQuoteLines();
        }
    }
    applyCustomStyles() {
        
        const css = `
            ${PSG_Pricepredict_css}
        `;
    
        const style = document.createElement('style');
        style.textContent = css;
        const container = this.template.querySelector('div');
            if (container) {
                container.appendChild(style);
                this.cssLoaded = true;
                console.log('CSS loaded successfully from custom labels');
            } else {
                console.error('Container element not found');
            }
    }

    removeCustomStyles() {
        const styleElements = this.template.querySelectorAll('style');
        styleElements.forEach(style => {
            if (style.textContent.includes(PSG_Pricepredict_css)) {
                style.remove();
                console.log('Custom CSS removed');
            }
        });
        
    }

    renderedCallback() {
        this.applyCustomStyles();
    }

    disconnectedCallback() {
        this.removeCustomStyles();
    }

    fetchQuoteLines() {
        this.isrender = true;
        /*sendQuoteLinesToEndpoint({ quoteId: this._recordId })
            .then(data => {
                if (data.isSuccess) {
                    this.processQuoteLines(data.QlList);
                    this.isError = false;
                } else {
                    this.handleError('Error: Failed to fetch QL details as one or more OPNs in the QLs are not eligible for Price Guidance.');
                }
            })
            .catch(error => {
                this.handleError(error.body.message);
                console.log(error.body.message);
            })
            .finally(() => {
                this.isrender = false; // Stop the loading spinner after data is fetched
            });*/
    }

    processQuoteLines(data) {
        console.log('data-->' + JSON.stringify(data));
        this.quoteLines = data.map(line => {
            const isDisabled = line.price_suggested_resale_amt__c === line.core_cpq_resale_guidance__c;
            let usepredict = line.price_suggested_resale_amt__c === line.core_cpq_resale_guidance__c;
            return {
                ...line,
                core_cpq_disregarding_price_guidance__c: isDisabled ? 'N/A' : line.core_cpq_disregarding_price_guidance__c,
                isDisabled: isDisabled,
                usepredictprice: isDisabled ? isDisabled : usepredict 
            };
        });

        console.log('quotelines-->' + JSON.stringify(this.quoteLines));
        this.isLoading = false; // Stop the loading spinner once processing is complete
    }

    handleUsePricePredictChange(event) {
        const quoteLineId = event.target.dataset.id;
        const value = event.target.checked;
        this.updateQuoteLineField(quoteLineId, 'usepredictprice', value);
        if (value) {
            this.updateQuoteLineField(quoteLineId, 'core_cpq_disregarding_price_guidance__c', 'N/A');
        } else {
            this.updateQuoteLineField(quoteLineId, 'core_cpq_disregarding_price_guidance__c', ' ');
        }
    }

    handleDisregardingPredictedPriceChange(event) {
        const quoteLineId = event.target.dataset.id;
        const value = event.detail.value;
        this.updateQuoteLineField(quoteLineId, 'core_cpq_disregarding_price_guidance__c', value);
    }

    updateQuoteLineField(quoteLineId, fieldName, value) {
        this.quoteLines = this.quoteLines.map(line => {
            if (line.Id === quoteLineId) {
                return { ...line, [fieldName]: value };
            }
            return line;
        });
    }

    handleSave() {
        const contentWrapper = this.template.querySelector('.content-wrapper');
        contentWrapper.classList.add('is-loading');
        let allValid = true;
        let invalidprice=false;
        this.quoteLines.forEach(row => {
                if (row.usepredictprice) {
                    
                     this.updateQuoteLineField(row.Id,'price_suggested_resale_amt__c',row.core_cpq_resale_guidance__c);
            }
            if (row.core_cpq_disregarding_price_guidance__c == ' ' || !row.core_cpq_disregarding_price_guidance__c) {
                allValid = false;
            }
            if(row.core_cpq_disregarding_price_guidance__c == 'N/A' && row.usepredictprice== false){
                invalidprice=true;
            }
        });

        if (invalidprice) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please select a valid Reason other than N/A for not using suggested Price Guidance.',
                variant: 'error'
            }));
            contentWrapper.classList.remove('is-loading');
            return;
        }else if (!allValid && !invalidprice) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please select the “Reason for not using suggested Price Guidance” for the applicable QLs.',
                variant: 'error'
            }));
            contentWrapper.classList.remove('is-loading');
            return;
        }

        this.isLoading = true;

        /*updateQuoteLines({ quoteLines: this.quoteLines })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Suggested Resale is updated with Price Guided Suggested Resale successfully.',
                    variant: 'success'
                }));
                this.dispatchEvent(new CloseActionScreenEvent());
                refreshApex(this.quoteLines);
                
            })
            .catch(error => {
                this.handleError(error.body.message);
            })
            .finally(() => {
                this.isLoading = false;
                contentWrapper.classList.remove('is-loading');
            });*/
    }

    handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleError(errorMessage) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: errorMessage,
            variant: 'error',
        }));
        this.isError = true;
        this.isLoading = false; // Stop the spinner in case of an error
    }
}