import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import saveConsumptionTxtData from "@salesforce/apex/Pricing_ConsumptionAttr_Controller.saveConsumptionTxtData";
import getConsumptionTxtData from "@salesforce/apex/Pricing_ConsumptionAttr_Controller.getConsumptionTxtData";
import getPlatformAndSalesGeoPickList from "@salesforce/apex/Pricing_ConsumptionAttr_Controller.getPlatformAndSalesGeoPickList";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import COUNTRY_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_End_Customer_Country__c';
import REGION_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Consumption_Region__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import QUOTELINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';
import CountrySalesGeo_Error from '@salesforce/label/c.Pricing_Consumption_CountrySalesGeo_Error';
import getParentQuoteLine from "@salesforce/apex/Pricing_ConsumptionAttr_Controller.getParentQuoteLine";

const CONSUMPTION_PLATFORM = 'Consumption Platform';
const CONSUMPTION_SALESGEO = 'Consumption Sales Geo';
const CONSUMPTION_SEGMENT = 'Consumption Segment';
export default class Pricing_ConsumptionAttributesComponent extends NavigationMixin(LightningElement) {

    saveLabel = 'Save';
    loadSpinner = false;
    @track isDisabled = {
        platformValue: false,
        regionValue: false,
        countryValue: false,
        salesGeoValue: false,
        segmentValue: false
    };

    @track helpText = {
        platformValue: '',
        regionValue: '',
        countryValue: '',
        salesGeoValue: '',
        segmentValue: ''
    };

    @api quoteLineId;
    @api quoteId;
    @api isChangeStyle;
    @api isEdit;
    @api readOnly;
    @track loadRegion = false;
    @track loadCountry = false;
    @track loadPlatformAndSalesGeo = false;
    @track error = [];

    @track platformOptions = [];
    @track regionOptions = [];
    @track countryOptions = [];
    @track salesGeoOptions = [];
    @track segmentOptions = [];

    @track selectedPlatformValue = [];
    @track selectedRegionValues = [];
    @track selectedCountryValues = [];
    @track selectedSalesGeoValues = [];
    @track selectedSegmentValues = [];

    @track consumptionValuesFromApex = [];
    @track parentQuoteLine = [];

    @wire(getObjectInfo, { objectApiName: QUOTELINE_OBJECT })
    objectInfo;

    @wire(getObjectInfo, { objectApiName: QUOTELINE_OBJECT })
    object(result) {
        if (result.data && result.data.fields) {
            this.helpText.platformValue = result.data.fields['Pricing_Consumption_Platform__c'].inlineHelpText;
            this.helpText.regionValue = result.data.fields['Pricing_Consumption_Region__c'].inlineHelpText;
            this.helpText.countryValue = result.data.fields['Pricing_Consumption_Country__c'].inlineHelpText;
            this.helpText.salesGeoValue = result.data.fields['Pricing_Consumption_Sale_Geo__c'].inlineHelpText;
            this.helpText.segmentValue = result.data.fields['Pricing_Consumption_Segment__c'].inlineHelpText;
        } else if (result.error) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    chainQuoteLineId;

    // get Platform and SalesGeo Picklist Value
    @wire(getPlatformAndSalesGeoPickList, { quoteId: '$quoteId' })
    platformAndSalesGeoPickList({ error, data }) {
        if (data) {
            data.forEach(element => {
                if (element.Pricing_Consumption_Type_Nm__c === CONSUMPTION_PLATFORM) {
                    this.platformOptions.push({ label: element.Name, value: element.Name });
                }
                if (element.Pricing_Consumption_Type_Nm__c === CONSUMPTION_SALESGEO) {
                    this.salesGeoOptions.push({ label: element.Name, value: element.Name });
                }
                if (element.Pricing_Consumption_Type_Nm__c === CONSUMPTION_SEGMENT) {
                    this.segmentOptions.push({ label: element.Name, value: element.Name });
                }
            });
            this.isDisabled.platformValue = this.platformOptions.length > 0 ? false : true;
            this.isDisabled.salesGeoValue = this.salesGeoOptions.length > 0 ? false : true;
            this.isDisabled.segmentValue = this.segmentOptions.length > 0 ? false : true;
            if (this.readOnly) {
                this.isDisabled.platformValue = true;
                this.isDisabled.salesGeoValue = true;
                this.isDisabled.segmentValue = true;
            }
            this.loadPlatformAndSalesGeo = true;
            this.chainQuoteLineId = this.quoteLineId;
        }
        else if (error) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    // get picklist vlaue of country
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: COUNTRY_FIELD })
    countryPickListValue({ error, data }) {
        if (data) {
            data.values.forEach(element => {
                const any = { label: element.label, value: element.value };
                this.countryOptions.push(any);
            });
            this.loadCountry = true;
            this.isDisabled.countryValue = this.countryOptions.length > 0 ? false : true;
            if (this.readOnly) {
                this.isDisabled.countryValue = true;
            }
        }
        else if (error) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    // get picklist value of region
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: REGION_FIELD })
    regionPickListValue({ error, data }) {
        if (data) {
            data.values.forEach(element => {
                const any = { label: element.label, value: element.value };
                this.regionOptions.push(any);
            });
            this.loadRegion = true;
            this.isDisabled.regionValue = this.regionOptions.length > 0 ? false : true;
            if (this.readOnly) {
                this.isDisabled.regionValue = true;
            }
        }
        else if (error) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    // get quoteline consumtion data
    async consumptionTxtValue() {
        await getConsumptionTxtData({ quoteLineId: this.quoteLineId })
            .then((data) => {
                this.selectedPlatformValue = data.Pricing_Consumption_Platform__c;
                this.selectedRegionValues = data.Pricing_Consumption_Region__c;
                this.selectedCountryValues = data.Pricing_Consumption_Country__c;
                this.selectedSalesGeoValues = data.Pricing_Consumption_Sale_Geo__c;
                this.selectedSegmentValues = data.Pricing_Consumption_Segment__c;

                this.consumptionValuesFromApex = {
                    platformValue: String(this.selectedPlatformValue),
                    regionValue: String(this.selectedRegionValues),
                    countryValue: String(this.selectedCountryValues),
                    salesGeoValue: String(this.selectedSalesGeoValues),
                    segmentValue: String(this.selectedSegmentValues)
                };
                this.dispatchEvent(new CustomEvent('consumptionvaluechange', {
                    detail: this.consumptionValuesFromApex
                }));
            })
            .catch((error) => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });
    }

    @wire(getParentQuoteLine, { quoteLineId: '$chainQuoteLineId' })
    parentQuoteLineDetails({ error, data }) {
        console.log('parentQuoteLineDetails ' + JSON.stringify(data));
        if (data != null && data != undefined && data != []) {
            this.parentQuoteLine = JSON.parse(JSON.stringify(data));
        }
        else if (error) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    async connectedCallback() {
        await this.consumptionTxtValue();
    }

    handlePlatformValueChange(event) {
        this.selectedPlatformValue = event.detail;
        this.sendValues();
    }

    handleRegionValueChange(event) {
        this.selectedRegionValues = event.detail;
        this.sendValues();
    }

    handleCountryValueChange(event) {
        this.selectedCountryValues = event.detail;
        this.sendValues();
    }

    handleSalesGeoValueChange(event) {
        this.selectedSalesGeoValues = event.detail;
        this.sendValues();
    }

    handleSegmentValueChange(event) {
        this.selectedSegmentValues = event.detail;
        this.sendValues();
    }

    validateChangeRequestConParam() {
        let salesGeoOptions = this.salesGeoOptions.map(item => item.value);
        let platformOptions = this.platformOptions.map(item => item.value);
        let segmentOptions = this.segmentOptions.map(item => item.value);
        let countryOptions = this.countryOptions.map(item => item.value);
        let errors = ['Can not delete the existing '];
        let errorFlg = true;
        if (this.parentQuoteLine != null) {
            let platformOldValues = (this.parentQuoteLine.Pricing_Consumption_Platform__c != null) && (this.parentQuoteLine.Pricing_Consumption_Platform__c != undefined) && (this.parentQuoteLine.Pricing_Consumption_Platform__c != "") ? this.parentQuoteLine.Pricing_Consumption_Platform__c.split(", ") : [];
            let salesGeoOldValues = (this.parentQuoteLine.Pricing_Consumption_Sale_Geo__c != null) && (this.parentQuoteLine.Pricing_Consumption_Sale_Geo__c != undefined) && (this.parentQuoteLine.Pricing_Consumption_Sale_Geo__c != "") ? this.parentQuoteLine.Pricing_Consumption_Sale_Geo__c.split(", ") : [];
            let countryOldValues = (this.parentQuoteLine.Pricing_Consumption_Country__c != null) && (this.parentQuoteLine.Pricing_Consumption_Country__c != undefined) && (this.parentQuoteLine.Pricing_Consumption_Country__c != "") ? this.parentQuoteLine.Pricing_Consumption_Country__c.split(", ") : [];
            let regionOldValues = (this.parentQuoteLine.Pricing_Consumption_Region__c != null) && (this.parentQuoteLine.Pricing_Consumption_Region__c != undefined) && (this.parentQuoteLine.Pricing_Consumption_Region__c != "") ? this.parentQuoteLine.Pricing_Consumption_Region__c.split(", ") : [];
            let segmentOldValues = (this.parentQuoteLine.Pricing_Consumption_Segment__c != null) && (this.parentQuoteLine.Pricing_Consumption_Segment__c != undefined) && (this.parentQuoteLine.Pricing_Consumption_Segment__c != "") ? this.parentQuoteLine.Pricing_Consumption_Segment__c.split(", ") : [];

            if (!regionOldValues.every(oldValue => this.selectedRegionValues.includes(oldValue))) {
                errors.push('Consumption Region');
            }
    
            if (!segmentOldValues.filter(item => segmentOptions.includes(item)).every(oldValue => this.selectedSegmentValues.includes(oldValue))) {
                errors.push('Consumption Segment');
            }

            if (!countryOldValues.filter(item => countryOptions.includes(item)).every(oldValue => this.selectedCountryValues.includes(oldValue))) {
                errors.push('Consumption Country');
            }
    
            // if (!countryOldValues.every(oldValue => this.selectedCountryValues.includes(oldValue))) {
            //     errors.push('Consumption Country');
            // }
    
            if (!salesGeoOldValues.filter(item => salesGeoOptions.includes(item)).every(oldValue => this.selectedSalesGeoValues.includes(oldValue))) {
                errors.push('Consumption Sales Geo');
            }
    
            if (!platformOldValues.filter(item => platformOptions.includes(item)).every(oldValue => this.selectedPlatformValue.includes(oldValue))) {
                errors.push('Consumption Platform');
            }
    
            if (errors.length > 1) {
                errorFlg = false;
                this.error.push(errors.join(', '));
            }
        }        
        return errorFlg;
    }

    // Save Consumption data 
    async handleOnSave() {
        this.loadSpinner = true;
        this.saveLabel = 'Saving...';
        this.error = [];
        // check validation
        if (this.validateFields() && this.validateChangeRequestConParam()) {
            let formatValues = (values) => Array.isArray(values) ? values.map(String).join(', ') : String(values);
            await saveConsumptionTxtData({
                quoteLineId: this.quoteLineId,
                platformValue: (this.selectedPlatformValue === undefined) || (this.selectedPlatformValue === null) ? '' : formatValues(this.selectedPlatformValue),
                regionValue: (this.selectedRegionValues === undefined) || (this.selectedRegionValues === null) ? '' : formatValues(this.selectedRegionValues),
                countryValue: (this.selectedCountryValues === undefined) || (this.selectedCountryValues === null) ? '' : formatValues(this.selectedCountryValues),
                salesGeoValue: (this.selectedSalesGeoValues === undefined) || (this.selectedSalesGeoValues === null) ? '' : formatValues(this.selectedSalesGeoValues),
                segmentValue: (this.selectedSegmentValues === undefined) || (this.selectedSegmentValues === null) ? '' : formatValues(this.selectedSegmentValues)
            })
                .then((result) => {
                    if (result == 'true') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Saved successfully',
                                variant: 'success',
                                mode: 'dismissible'
                            })
                        );
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: result,
                                variant: 'error',
                                mode: 'dismissable'
                            })
                        );
                    }
                })
                .then(_ => {
                    this.consumptionTxtValue();
                })
                .then(_ => {

                    let refreshConsumptionValue = true;
                    this.dispatchEvent(new CustomEvent('refreshconsumptions', {
                        detail: { refreshConsumptionValue }
                    },));
                    this.loadSpinner = false;
                    this.saveLabel = 'Save';
                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error,
                            variant: 'error',
                            mode: 'dismissable'
                        })
                    );
                });
        } else {
            this.loadSpinner = false;
            this.saveLabel = 'Save';
            const event = new ShowToastEvent({
                title: 'Error',
                message: this.error.toString(),
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
        this.loadSpinner = false;
        this.saveLabel = 'Save';
    }

    // send all Consumption values at once to parent comp
    sendValues() {
        let formatValues = (values) => Array.isArray(values) ? values.map(String).join(', ') : String(values);        
        let any = {
            platformValue: formatValues(this.selectedPlatformValue),
            regionValue: formatValues(this.selectedRegionValues),
            countryValue: formatValues(this.selectedCountryValues),
            salesGeoValue: formatValues(this.selectedSalesGeoValues),
            segmentValue: formatValues(this.selectedSegmentValues)
        };
        this.dispatchEvent(new CustomEvent('consumptionvaluechange', {
            detail: any
        }));
    }

    // handle Toggle for icon
    handleClick(event) {
        let childComp = (event.target.firstElementChild === null) ? event.target : event.target.firstElementChild.firstElementChild;
        childComp.iconName = (childComp.iconName === 'utility:chevronright') ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get paddingChange() {
        return this.isChangeStyle === 'true' ? 'class2' : 'class1';
    }

    get sldsStyle() {
        return this.isChangeStyle === 'true' ? 'slds-grid slds-wrap' : 'slds-grid slds-wrap slds-var-p-left_x-large';
    }

    validateFields() {
        const salesGeo = String(this.selectedSalesGeoValues).trim() !== '' && String(this.selectedSalesGeoValues).trim() !== undefined && String(this.selectedSalesGeoValues).trim() !== null;
        const region = String(this.selectedRegionValues).trim() !== '' && String(this.selectedRegionValues).trim() !== undefined && String(this.selectedRegionValues).trim() !== null;
        const country = String(this.selectedCountryValues).trim() !== '' && String(this.selectedCountryValues).trim() !== undefined && String(this.selectedCountryValues).trim() !== null;
        if ((salesGeo && region && country) || (salesGeo && (region || country))) {
            this.error.push(CountrySalesGeo_Error);
            return false;
        }
        return true;
    }

    handleCancel() {
        this.isModalOpen = false;
        const closeModalEvent = new CustomEvent("consumptionclose", { detail: true },);
        this.dispatchEvent(closeModalEvent);
    }

    disconnectedCallback() {
        this.isModalOpen = false;
        const closeModalEvent = new CustomEvent("consumptionclose", { detail: true },);
        this.dispatchEvent(closeModalEvent);
    }
}