import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import PROGRAM_TYPE_FIELD from '@salesforce/schema/SBQQ__Quote__c.Pricing_Program_Type_Nm__c';
import QUOTE_END_DATE_FIELD from '@salesforce/schema/SBQQ__Quote__c.Pricing_ShipmentEndDate_Dt__c';
import { getRecord } from 'lightning/uiRecordApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProducts from '@salesforce/apex/Pricing_QuoteLineController.searchProductsSOQL';
import getQLRecordTypeId from '@salesforce/apex/Pricing_QuoteLineController.getRecordTypeId';
import getDataTableColumns from '@salesforce/apex/Pricing_QuoteLineController.getDataTableColumns';
import standardQuote from '@salesforce/label/c.Pricing_Tender_Standard_Quote';
import standardQuoteLine from '@salesforce/label/c.Pricing_Tender_Standard_QuoteLine';
import smallVolumeQuote from '@salesforce/label/c.Pricing_Tender_Small_Volume_Quote';
import ssdQuote from '@salesforce/label/c.Pricing_Tender_SSD_Quote';
import pmemQuote from '@salesforce/label/c.Pricing_Tender_PMem_Quote';
import financialIncentiveQuote from '@salesforce/label/c.Pricing_Tender_FinancialIncentive_Quote';
import nicQuote from '@salesforce/label/c.Pricing_Tender_NIC_Quote';
import selectProductError from '@salesforce/label/c.Pricing_Tender_Select_Product_Error';
import noProductError from '@salesforce/label/c.Pricing_Tender_No_Products_Error';
import toolTip from '@salesforce/label/c.Pricing_Tender_Product_Search_Tooltip';
import ccgQuote from '@salesforce/label/c.Pricing_Tender_CCG_Quote';
import dataCenterGPUQuote from '@salesforce/label/c.Pricing_Tender_DataCenter_GPU';
import CountrySalesGeo_Error from '@salesforce/label/c.Pricing_Consumption_CountrySalesGeo_Error';

const TITLE_TEXT = 'Error';
const ERROR_VAR_TEXT = 'Error';
const INFO_VAR_TEXT = 'Informational';

export default class Pricing_Manage_New_QuoteLine extends NavigationMixin(LightningElement) {
    label = {
        toolTip
    };
    @api recordId;
    @track openModal;
    @track productRecords;
    @track searchValue = '';
    @track qlRecordTypeId;
    @track disableNext = true;
    @track datatableColumns;
    @track isSpinner = false;
    @track quoteLineType;
    @track isStandardQuote = false;
    @track value = standardQuoteLine;
    @track isSvdQuote = false;
    @track isCcgQuote = false;
    @track isFinancialIncentive = false;
    quoteProgramType;
    endDate;
    typingTimer;                //timer identifier
    doneTypingInterval = 1000;  //time in ms, 1.5 seconds
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    @track consumptionValues = {
        platformValue: "",
        regionValue: "",
        countryValue: "",
        salesGeoValue: "",
        segmentValue: ""
    };

    @track error;

    //Wire method to get Quote Pricing End Date and Quote Line Type for pre-defaulting the value in the Combobox
    @wire(getRecord, { recordId: '$recordId', fields: [QUOTE_END_DATE_FIELD, PROGRAM_TYPE_FIELD] })
    quote({ error, data }) {
        if (data) {
            this.quoteProgramType = data.fields.Pricing_Program_Type_Nm__c.value;

            if (this.quoteProgramType == standardQuote) {
                this.quoteLineType = standardQuoteLine;
                this.isStandardQuote = true;
            }
            else if (this.quoteProgramType == smallVolumeQuote) {
                this.quoteLineType = smallVolumeQuote;
                this.isSvdQuote = true;
            }
            else if (this.quoteProgramType == ccgQuote) {
                this.isCcgQuote = true;
                this.quoteLineType = ccgQuote;
            }
            else if (this.quoteProgramType == financialIncentiveQuote) {
                this.isFinancialIncentive = true;
                this.quoteLineType = financialIncentiveQuote;
            }
            this.endDate = data.fields.Pricing_ShipmentEndDate_Dt__c.value;
            this.getMetadataColumns();
        } else if (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: TITLE_TEXT,
                variant: ERROR_VAR_TEXT,
                message: error.body.message
            }));
        }
    };

    //Wire method to get Quote Line Record Type Id based on Quote Line Type
    @wire(getQLRecordTypeId, { quoteLineType: '$quoteLineType' })
    recordType({ error, data }) {
        if (data) {
            this.qlRecordTypeId = data;
        } else if (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: TITLE_TEXT,
                variant: ERROR_VAR_TEXT,
                message: error.body.message
            }));
        }
    };

    //Wire method to get Data Table columns from metadata based on Quote Line Type
    getMetadataColumns() {
        this.datatableColumns = null;
        getDataTableColumns()
            .then(result => {
                this.isSpinner = false;
                this.disableNext = true;
                this.productRecords = null;
                for (var key in result) {
                    if (key == this.quoteLineType) {
                        this.datatableColumns = result[key];
                        break;
                    }
                }
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: TITLE_TEXT,
                    variant: ERROR_VAR_TEXT,
                    message: error.body.message
                }));
                this.productRecords = null;
                this.isSpinner = false;
            });
    }

    //On click of New Quote Line button
    createRecord() {
        this.openModal = true;
        document.body.style.overflow = 'hidden';
        this.productRecords = null;
        if (this.datatableColumns == null || this.datatableColumns == undefined) {
            this.getMetadataColumns();
        }
    }

    handleKeyUp(event) {
        this.productRecords = null;
        clearTimeout(this.typingTimer);
        this.searchValue = event.target.value;
        if (this.searchValue.length >= 2) {
            this.isSpinner = true;
            this.typingTimer = setTimeout(function () { this.getSearchResults(); }.bind(this), this.doneTypingInterval);
        } else if (this.searchValue.length === 0) {
            this.isSpinner = false;
        }
    }

    handleKeyDown(event) {
        clearTimeout(this.typingTimer);
    }

    //To search the products from the lookup 
    getSearchResults() {
        if (this.searchValue !== '' && this.searchValue !== null && this.quoteLineType != null && this.quoteLineType != '') {
            getProducts({ searchString: this.searchValue, quoteLineType: this.quoteLineType })
                .then(result => {
                    this.productRecords = result;
                    if (this.productRecords.length === 0) {
                        const event1 = new ShowToastEvent({
                            title: "info",
                            variant: INFO_VAR_TEXT,
                            message: noProductError.replace('{{searchValue}}', this.searchValue),
                        });
                        this.dispatchEvent(event1);
                    }
                    this.isSpinner = false;
                })
                .catch(error => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: TITLE_TEXT,
                        variant: ERROR_VAR_TEXT,
                        message: error.body.message
                    }));
                    this.productRecords = null;
                    this.isSpinner = false;
                });
        } else {
            this.productRecords = null;
            this.isSpinner = false;
        }
        this.disableNext = true;
    }

    //Handle next event on product screen to select product 
    handleNext(event) {
        if (this.validateFields()) {
            this.datatableColumns = null;
            this.value = this.quoteLineType = (this.quoteLineType == dataCenterGPUQuote) ? dataCenterGPUQuote : (this.quoteLineType == ssdQuote) ? ssdQuote : (this.quoteLineType == pmemQuote) ? pmemQuote : (this.quoteLineType == nicQuote) ? nicQuote : (this.isStandardQuote) ? standardQuoteLine : (this.isSvdQuote) ? smallVolumeQuote : ccgQuote;
            var product = this.template.querySelector("lightning-datatable").getSelectedRows();
            this.searchValue = null;
            if (product.length > 0) {
                this.openModal = false;
                document.body.style.overflow = 'visible';
                this.showCreateLayout(this.qlRecordTypeId, product[0].Id);
            } else {
                const event = new ShowToastEvent({
                    title: TITLE_TEXT,
                    variant: ERROR_VAR_TEXT,
                    message: selectProductError
                });
                this.dispatchEvent(event);
            }
        } else {
            const event = new ShowToastEvent({
                title: TITLE_TEXT,
                message: this.error,
                variant: ERROR_VAR_TEXT
            });
            this.dispatchEvent(event);
        }

    }

    validateFields() {
        const salesGeo = this.consumptionValues.salesGeoValue.trim() !== '' && this.consumptionValues.salesGeoValue.trim() !== undefined && this.consumptionValues.salesGeoValue.trim() !== null;
        const region = this.consumptionValues.regionValue.trim() !== '' && this.consumptionValues.regionValue.trim() !== undefined && this.consumptionValues.regionValue.trim() !== null;
        const country = this.consumptionValues.countryValue.trim() !== '' && this.consumptionValues.countryValue.trim() !== undefined && this.consumptionValues.countryValue.trim() !== null;

        if ((salesGeo && region && country) || (salesGeo && (region || country))) {
            this.error = CountrySalesGeo_Error;
            return false;
        }
        this.error = '';
        return true;
    }

    //To show create layout for Standard,SVD, SSD, PMem and NIC Quote Line Types.
    showCreateLayout(qlRecordTypeId, productId) {
        const defaultValues = encodeDefaultFieldValues({
            SBQQ__Quote__c: this.recordId,
            Pricing_End_Date_dt__c: this.endDate,
            Pricing_Product_Nm__c: productId,
            Pricing_Consumption_Platform__c: String(this.consumptionValues.platformValue === undefined ? '' : this.consumptionValues.platformValue),
            Pricing_Consumption_Region__c: String(this.consumptionValues.regionValue === undefined ? '' : this.consumptionValues.regionValue),
            Pricing_Consumption_Country__c: String(this.consumptionValues.countryValue === undefined ? '' : this.consumptionValues.countryValue),
            Pricing_Consumption_Sale_Geo__c: String(this.consumptionValues.salesGeoValue === undefined ? '' : this.consumptionValues.salesGeoValue),
            Pricing_Consumption_Segment__c: String(this.consumptionValues.segmentValue === undefined ? '' : this.consumptionValues.segmentValue)
        });

        let recordPage = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SBQQ__QuoteLine__c',
                actionName: 'new'
            },
            state: {
                recordTypeId: qlRecordTypeId,
                defaultFieldValues: defaultValues,
                navigationLocation: 'RELATED_LIST',
            }
        };
            this[NavigationMixin.Navigate](recordPage);
        this.disableNext = true;
    }

    handleRowSelection() {
        this.disableNext = false;
    }

    handleQLTypeSelection(event) {
        this.searchValue = null;
        this.productRecords = null;
        this.disableNext = true;
        this.qlRecordTypeId = null;
        this.value = this.quoteLineType = event.target.value;
        this.isSpinner = true;
        this.getMetadataColumns();
    }

    get options() {
        return [
            { label: standardQuoteLine, value: standardQuoteLine },
            { label: ssdQuote, value: ssdQuote },
            { label: pmemQuote, value: pmemQuote },
            { label: nicQuote, value: nicQuote },
            { label: dataCenterGPUQuote, value: dataCenterGPUQuote }
        ];
    }

    //Close the product screen
    closeModal() {
        this.openModal = false;
        document.body.style.overflow = 'visible';
        this.searchValue = null;
        this.productRecords = null;
        this.qlRecordTypeId = this.isCcgQuote ? this.qlRecordTypeId : null;
        this.datatableColumns = null;
        this.value = this.quoteLineType = (this.quoteLineType == dataCenterGPUQuote) ? dataCenterGPUQuote : (this.quoteLineType == ssdQuote) ? ssdQuote : (this.quoteLineType == pmemQuote) ? pmemQuote : (this.quoteLineType == nicQuote) ? nicQuote : (this.isStandardQuote) ? standardQuoteLine : (this.isSvdQuote) ? smallVolumeQuote : ccgQuote;
        this.disableNext = true;
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = JSON.parse(JSON.stringify(this.productRecords));
        if (cloneData != null || cloneData != undefined) {
            cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        }
        this.productRecords = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    sortBy(field, reverse, primer) {

        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };

    }

    handleConsumptionValueChange(event) {
        this.consumptionValues = event.detail;
    }

}