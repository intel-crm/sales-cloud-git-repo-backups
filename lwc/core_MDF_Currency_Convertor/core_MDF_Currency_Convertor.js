import { LightningElement, track,wire } from 'lwc';
import CURRENCY_CONVERTER_TITLE from '@salesforce/label/c.Core_MDF_Currency_Converter_Title';
import CURRENCY_CONVERTER_HELP from '@salesforce/label/c.Core_MDF_Currency_Converter_Help';
import COPY_AMOUNT_LABEL from '@salesforce/label/c.Core_MDF_Copy_Amount_Label';
import COPY_AMOUNT_CLIPBOARD_LABEL from '@salesforce/label/c.Core_MDF_Currency_Clipboard';
import SUCCESS_LABEL from '@salesforce/label/c.Core_MDF_Success';
import AMOUNT_LABEL_NAME from '@salesforce/label/c.Core_MDF_Amount';
import NO_VALUE_TITLE from '@salesforce/label/c.Core_MDF_No_Value_Title';
import FAILED_VALUE_LABEL from '@salesforce/label/c.Core_MDF_Copy_FailedLabel';
import AMOUNT_COPIED_MESSAGE from '@salesforce/label/c.Core_MDF_ConvertedAmountClipboard';
import CONVERTED_AMOUNT_DETAILS from '@salesforce/label/c.Core_MDF_Converted_Amount_Detail';
import CURRENCY_CONVERT_LABEL from '@salesforce/label/c.Core_MDF_Currency_Convert_Label';
import ORIGINAL_CONVERTED_MESSAGE from '@salesforce/label/c.Core_MDF_Original_Converted_Message';
import NO_CONVERSION from '@salesforce/label/c.Core_MDF_No_Conversion';
import COPY_FAILED_MESSAGE from '@salesforce/label/c.Core_MDF_Copy_Failed_Message';
import NO_VALUE_MESSAGE from '@salesforce/label/c.Core_MDF_No_Value_Message';
import COPIED_LABEL from '@salesforce/label/c.Core_MDF_Copied';
import CURRENCY_LABEL_NAME from '@salesforce/label/c.Core_MDF_Budget_Currency';
import USD_LABEL_NAME from '@salesforce/label/c.Core_MDF_PFR_Output_Currency';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PARTNER_FUND_REQUEST_OBJECT from '@salesforce/schema/PartnerFundRequest';
import CURRENCY_FIELD from '@salesforce/schema/PartnerFundRequest.Core_MDF_Budget_Currency_cd__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExchangeRateForAnyInputAndOutputCurrency from '@salesforce/apex/Core_MDF_CCP_Multicurrency.getExchangeRateForAnyInputAndOutputCurrency';

export default class CurrencyConverter extends LightningElement {

    @track selectedCurrency = '';
    @track amount = '';
    @track convertedAmount = '';
    @track copyIcon = 'utility:copy';
    @track copyLabel = 'Copy Amount';
    @track currencyOptions = [];
    
    currencyConverterHeader = CURRENCY_CONVERTER_TITLE;
    currencyConverterHelp = CURRENCY_CONVERTER_HELP;
    amountLabel = AMOUNT_LABEL_NAME;
    currencyLabel = CURRENCY_LABEL_NAME;
    usdLabel = USD_LABEL_NAME;
    copyAmountLabel = COPY_AMOUNT_LABEL;
    copyAmountTooltipLabel = COPY_AMOUNT_CLIPBOARD_LABEL;
    noValueTitle = NO_VALUE_TITLE;
    noValueMessage = NO_VALUE_MESSAGE;
    successLabel = SUCCESS_LABEL;
    copiedLabel = COPIED_LABEL;
    amountCopiedLabel = AMOUNT_COPIED_MESSAGE;
    failedLabel = FAILED_VALUE_LABEL;
    failedMessage = COPY_FAILED_MESSAGE;
    convertedAmountDetail = CONVERTED_AMOUNT_DETAILS;
    noConversionLabel = NO_CONVERSION;
    currencyConvertLabel = CURRENCY_CONVERT_LABEL;
    originalConvertedMessage = ORIGINAL_CONVERTED_MESSAGE;

    @wire(getObjectInfo, { objectApiName: PARTNER_FUND_REQUEST_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: CURRENCY_FIELD
    })
    currencyPicklistValues({ data, error }) {
        if (data) {
            this.currencyOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error fetching currency picklist values', error);
        }
    }

    handleCurrencyChange(event) {
        this.selectedCurrency = event.detail.value;
        if (this.amount) {
            this.calculateAmount();
        }
    }

    handleAmountChange(event) {
        let value = event.target.value;

        // Allow empty value
        if (value === '') {
            setTimeout(() => {
                this.amount = '';
                this.convertedAmount = '';
            }, 1000);
            return;
        }

        // Split integer and decimal parts
        const parts = value.split('.');

        // If more than one decimal point → revert
        if (parts.length > 2) {
            event.target.value = this.amount ?? '';
            return;
        }

        // If decimal part exists and exceeds 2 digits → revert
        if (parts.length === 2 && parts[1].length > 2) {
            event.target.value = this.amount ?? '';
            return;
        }

        // If value is negative → revert
        if (Number(value) < 0) {
            event.target.value = this.amount ?? '';
            return;
        }

        // Valid value
        this.amount = value;

        if (this.selectedCurrency) {
            this.calculateAmount();
        }
    }

    getStartOfWeek(date) {
        return new Date();
    }

    calculateAmount() {
        if (
            this.amount === null ||
            this.amount === '' ||
            this.selectedCurrency === ''
        ) {
            return;
        }

        const weekStartDate = this.getStartOfWeek(new Date()); // compute start of week
        const inputPayload = [{
            inputCurrency: this.selectedCurrency,
            outputCurrency: 'USD',
            inputAmount: parseFloat(this.amount),
            inputDate: weekStartDate
        }];
        getExchangeRateForAnyInputAndOutputCurrency({ inputList: inputPayload })
            .then(result => {
                const value = Object.values(result)[0];
                if (value && value.convertedAmount !== undefined) {
                    this.convertedAmount = value.convertedAmount;
                } else {
                    this.convertedAmount = '';
                }
            })
            .catch(error => {
                console.error('Exchange rate error', error);
                console.error('Error details:', error.body ? error.body.message : error.message);
                this.convertedAmount = '';
            });
    }

    // Fallback copy method using temporary textarea
    fallbackCopyTextToClipboard(text) {
        const textArea = document.createElement("textarea");
        textArea.value = text;
        
        // Avoid scrolling to bottom
        textArea.style.top = "0";
        textArea.style.left = "0";
        textArea.style.position = "fixed";
        textArea.style.opacity = "0";
        
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        
        try {
            const successful = document.execCommand('copy');
            document.body.removeChild(textArea);
            return successful;
        } catch (err) {
            console.error('Fallback: Oops, unable to copy', err);
            document.body.removeChild(textArea);
            return false;
        }
    }

    // Main copy method with modern API and fallback
    async copyTextToClipboard(text) {
        if (!navigator.clipboard) {
            return this.fallbackCopyTextToClipboard(text);
        }
        
        try {
            await navigator.clipboard.writeText(text);
            return true;
        } catch (err) {
            console.error('Async: Could not copy text: ', err);
            // Fallback to the older method
            return this.fallbackCopyTextToClipboard(text);
        }
    }

    async handleCopyAmount() {
        if (!this.convertedAmount) {
            // Handle empty case
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.noValueTitle,
                    message: this.noValueMessage,
                    variant: 'warning'
                })
            );
            return;
        }

        try {
            const success = await this.copyTextToClipboard(this.convertedAmount.toString());
            
            if (success) {
                // UI feedback (icon + text)
                this.copyIcon = 'utility:check';
                this.copyLabel = this.copiedLabel;

                // Toast message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.successLabel,
                        message: this.amountCopiedLabel.replace('{0}', this.convertedAmount),
                        variant: 'success'
                    })
                );

                // Reset after 2 seconds
                setTimeout(() => {
                    this.copyIcon = 'utility:copy';
                    this.copyLabel = this.copyAmountLabel;
                }, 2000);
            } else {
                throw new Error('Copy operation failed');
            }
        } catch (error) {
            console.error('Copy failed:', error);
            
            // Show error toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.failedLabel,
                    message: this.copyFailedMessage.replace('{0}', this.convertedAmount),
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }
    }

    // Optional: Handle view amount 
   handleViewAmount() {
        if (this.convertedAmount) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.convertedAmountDetail,
                    message: this.originalConvertedMessage
            .replace('{0}', this.amount)
            .replace('{1}', this.selectedCurrency)
            .replace('{2}', this.convertedAmount),
                    variant: 'info',
                    mode: 'sticky'
                })
            );
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.noConversionLabel,
                    message: this.currencyConvertLabel,
                    variant: 'warning'
                })
            );
        }
    }
}