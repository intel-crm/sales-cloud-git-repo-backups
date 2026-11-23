import { LightningElement, wire, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import QUOTE_OBJECT from '@salesforce/schema/SBQQ__Quote__c';
import QUOTE_TYPE from '@salesforce/schema/SBQQ__Quote__c.Pricing_Program_Type_Nm__c';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from "@salesforce/user/Id";
import getAccountId from '@salesforce/apex/Pricing_Manage_Small_Volume_Deal.getAccount';
import isProgramTypeSelectionAllowed from '@salesforce/apex/Pricing_Manage_Small_Volume_Deal.isRecordTypeSelectionAllowed';
import capSizeCheck from '@salesforce/apex/Pricing_Manage_Small_Volume_Deal.capSizeCheck';
import getQuoteTypes from '@salesforce/apex/Pricing_Manage_Small_Volume_Deal.getQuoteTypes';
import capSizeError from '@salesforce/label/c.Pricing_Tender_Cap_Size_Quarter_Limit_Error';
import smallVolumeQuote from '@salesforce/label/c.Pricing_Tender_Small_Volume_Quote';
import standardQuote from '@salesforce/label/c.Pricing_Tender_Standard_Quote';
import ccgQuote from '@salesforce/label/c.Pricing_Tender_CCG_Quote';
import FiQuotes from '@salesforce/label/c.Pricing_Tender_FinancialIncentive_Quote';
import isActiveSVD from '@salesforce/apex/Pricing_Manage_Small_Volume_Deal.getSVDQuoteActiveStatus';
export default class Pricing_Manage_New_Quote extends NavigationMixin(LightningElement) {
 
    @track selectedValue;
    @track isOpenModal;
    @track recordTypeId;
    @track quoteTypes = [];
    @track contactId;
    @track accountId;
    @track errorMsg = '';
    @track resultValue;
    @track msgColor;
    @track disableNextButton = false;
 
    @wire(getObjectInfo, { objectApiName: QUOTE_OBJECT })
    objectInfo;
 
    @wire(isActiveSVD, {})
    isSVDActive;
 
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: QUOTE_TYPE, isActive: '$isSVDActive' })
    Values({ error, data }) {
        console.log('testing:');
        if (data) {
            let quoteOptionType = [];
            let allowSVD = JSON.parse(JSON.stringify(this.isSVDActive.data));
            for (let i = 0; i < data.values.length; i++) {
                quoteOptionType.push({
                    label: data.values[i].label,
                    value: data.values[i].value
                })
            }
            this.quoteTypes = quoteOptionType.filter(quoteType => {
                return quoteType.label != FiQuotes;
            });
            if (!allowSVD) {
                this.quoteTypes = this.quoteTypes.filter(q => q.value !== smallVolumeQuote);
            }
            getAccountId({ userId: USER_ID })
                .then(result => {
                    console.log('result:'+result != null);
                    if (result != null) {
                        console.log('entering:');
                        this.accountId = result;
                        this.getQuoteTypesMethod();
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.error('Error @ getAccountId ', JSON.stringify(this.error));
                });
        }
        else if (error) {
            console.error('Error @ getPicklistValues ', JSON.stringify(error));
        }
        this.selectedValue = ccgQuote;
    }
 
    //Method to get Quote type label , message and message color
    getQuoteTypesMethod() {
        getQuoteTypes({ quoteTypeJSON: JSON.stringify(this.quoteTypes), accId: this.accountId })
            .then(result => {
                console.log('this.quoteTypes:'+JSON.stringify(this.quoteTypes));
                if (result != null) {
                    this.quoteTypes = result;
                    for (let i = 0; i < this.quoteTypes.length; i++) {
                        if ((this.quoteTypes[i].label === smallVolumeQuote || this.quoteTypes[i].label === 'Client' || this.quoteTypes[i].label === 'Data Center') && this.quoteTypes[i].color !== 'none') {
                            //this.msgColor = true;
                            if (this.quoteTypes[i].color == 'red') {
                                //return 'messageColorRed';
                                this.quoteTypes[i].color = 'red-text'
                            } else if (this.quoteTypes[i].color == 'blue') {
                                //return 'messageColorBlue';
                                this.quoteTypes[i].color = 'blue-text'
                            }
                        }
                    }
                }
            })
            .catch(error => {
                console.error('Error @ getQuoteTypesMethod ', JSON.stringify(error));
                this.error = error;
            });
 
    }
    //Get message color for SVD
    /*get messageColor() {
        if (this.quoteTypes != null && this.quoteTypes.length > 0) {
            for (let i = 0; i < this.quoteTypes.length; i++) {
                if ((this.quoteTypes[i].label === smallVolumeQuote || this.quoteTypes[i].label === 'Client' || this.quoteTypes[i].label === 'Data Center') && this.quoteTypes[i].color !== 'none') {
                    if (this.quoteTypes[i].color == 'red') {
                        return 'messageColorRed';
                    } else if (this.quoteTypes[i].color == 'blue') {
                        return 'messageColorBlue';
                    }
                }
            }
        }
    }*/
 
    handleChange(event) {
        this.selectedValue = event.target.value;
        this.errorMsg = '';
    }
 
    handleNext() {
        this.errorMsg = '';
        this.disableNextButton = true;
        capSizeCheck({ accId: this.accountId })
            .then(result => {
                if (result != null) {
                    this.resultValue = result.split(":");
                    let capSize = Number(this.resultValue[1]);  // NOSONAR
                    if (this.resultValue[0] === 'true') {
                        this.getSelectedRecordTypeValue();
                    } else if (this.resultValue[0] === 'false' && (this.selectedValue === standardQuote || this.selectedValue === ccgQuote)) {
                        this.getSelectedRecordTypeValue();
                    }
                    else if (this.resultValue[0] === 'false' && this.selectedValue === smallVolumeQuote) {
                        this.errorMsg = capSizeError + ' (' + capSize + ' Quotes).';
                    }
                }
            })
            .catch(error => {
                console.log('error', error);
                this.error = error;
            });
    }
 
    get disableButton() {
        let disable = this.disableNextButton == true ? true : false;
        return disable;
    }
 
    getSelectedRecordTypeValue() {
        this.errorMsg = '';
        const rtis = this.objectInfo.data.recordTypeInfos;
        if (this.recordTypeId !== '' || this.recordTypeId !== null) {
            this.recordTypeId = Object.keys(rtis).find(recordType => rtis[recordType].name == this.selectedValue);
            this.isOpenModal = false;
            this.showRecordForm();
        }
    }
 
    openModal() {
        this.errorMsg = '';
        this.disableNextButton = false;
        isProgramTypeSelectionAllowed({ accId: this.accountId })
            .then(result => {
                 if (result === false) {
                    this.isOpenModal = true;
                     this.quoteTypes = this.quoteTypes.filter(quoteType => quoteType.label != smallVolumeQuote);
                }
                else {
                    this.isOpenModal = true;
                }
            })
            .catch(error => {
                this.error = error;
                console.log('error @ isProgramTypeSelectionAllowed ===>', error);
            });
 
    }
 
    showRecordForm() {
        this.errorMsg = '';
        console.log('Show recordTypeId', this.recordTypeId);
        let recordPage = {  // NOSONAR
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SBQQ__Quote__c',
                actionName: 'new',
                nooverride: '1'
            },
            state: {
                recordTypeId: this.recordTypeId
            }
        };
        try{ 
            console.log('Navigate to record page', recordPage);
            this[NavigationMixin.Navigate](recordPage);
        
        }catch(error){
            console.log('Error in navigating to record page', error);
        }
        
        this.selectedValue = ccgQuote;

    }
 
    closeModal() {
        this.errorMsg = '';
        this.isOpenModal = false;
        this.selectedValue = ccgQuote;
        this.disableNextButton = false;
    }
}