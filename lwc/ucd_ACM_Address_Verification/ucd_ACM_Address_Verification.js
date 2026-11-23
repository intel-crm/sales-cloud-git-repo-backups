import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import COUNTRY_CODE_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import STATE_CODE_FIELD from '@salesforce/schema/Account.BillingStateCode';
import addressVerification from '@salesforce/apex/UCD_ACM_AICleansedAddress.addressVerification';

const FIELDS = [
    'Account_Create_Request__c.Account_Name__c',
    'Account_Create_Request__c.Address__Street__s',
    'Account_Create_Request__c.Address__City__s',
    'Account_Create_Request__c.Address__StateCode__s',
    'Account_Create_Request__c.Address__CountryCode__s',
    'Account_Create_Request__c.Address__PostalCode__s',
    'Account_Create_Request__c.IsAddressVerified__c'
];

export default class Ucd_ACM_Address_Verification extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track loaded = false;
    @track showContent = false;
    @track cleansedAddress = {};
    @track userEnteredAddress = {};
    @track selectedAddressOption = null;
    accountName = '';
    stateCode = '';
    countryCode = '';
    countryMap = {};
    stateData;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountInfo;

    @wire(getPicklistValues, { recordTypeId: '$accountInfo.data.defaultRecordTypeId', fieldApiName: COUNTRY_CODE_FIELD })
    wiredCountryValues({ data }) {
        if (data) {
            const map = {};
            data.values.forEach(v => { map[v.value] = v.label; });
            this.countryMap = map;
            this.applyDisplayNames();
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$accountInfo.data.defaultRecordTypeId', fieldApiName: STATE_CODE_FIELD })
    wiredStateValues({ data }) {
        if (data) {
            this.stateData = data;
            this.applyDisplayNames();
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            const f = data.fields;
            this.accountName = this.getVal(f.Account_Name__c);
            this.stateCode = this.getVal(f.Address__StateCode__s);
            this.countryCode = this.getVal(f.Address__CountryCode__s);
            this.userEnteredAddress = {
                streetName: this.getVal(f.Address__Street__s),
                cityName: this.getVal(f.Address__City__s),
                stateName: this.resolveStateName(this.stateCode, this.countryCode),
                stateCode: this.stateCode,
                postalCode: this.getVal(f.Address__PostalCode__s),
                countryName: this.countryMap[this.countryCode] || this.countryCode,
                countryCode: this.countryCode
            };
            this.runVerification();
        } else if (error) {
            this.loaded = false;
            this.showToast('error', 'Error', 'Unable to load the request record: ' + this.reduceError(error));
        }
    }

    reduceError(error) {
        if (!error) {
            return 'Unknown error';
        }
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        }
        if (error.body && Array.isArray(error.body.output && error.body.output.errors)) {
            return error.body.output.errors.map(e => e.message).join(', ');
        }
        if (error.body && typeof error.body.message === 'string') {
            return error.body.message;
        }
        if (typeof error.message === 'string') {
            return error.message;
        }
        return JSON.stringify(error);
    }

    getVal(field) {
        return field && field.value != null ? field.value : '';
    }

    applyDisplayNames() {
        if (!this.userEnteredAddress || !this.userEnteredAddress.countryCode) {
            return;
        }
        this.userEnteredAddress = {
            ...this.userEnteredAddress,
            stateName: this.resolveStateName(this.stateCode, this.countryCode),
            countryName: this.countryMap[this.countryCode] || this.countryCode
        };
    }

    resolveStateName(stateCode, countryCode) {
        if (!stateCode) {
            return stateCode;
        }
        const data = this.stateData;
        if (!data || !data.controllerValues || !Array.isArray(data.values)) {
            return stateCode;
        }
        const key = data.controllerValues[countryCode];
        const match = data.values.find(v => v.value === stateCode
            && Array.isArray(v.validFor) && v.validFor.includes(key));
        return match ? match.label : stateCode;
    }

    get hasCleansedAddress() {
        const c = this.cleansedAddress;
        if (!c || c.verificationStatus === 'Reverted' || c.verificationStatus === 'Unverified') {
            return false;
        }
        return !!(c.streetName || c.cityName || c.stateName || c.postalCode || c.countryName);
    }

    get cleansedBoxClass() {
        const base = 'slds-box slds-box_x-small slds-text-align_center slds-p-around_medium address-box';
        return this.selectedAddressOption === 'cleansed' ? base + ' address-box_selected' : base;
    }

    get userInputBoxClass() {
        const base = 'slds-box slds-box_x-small slds-text-align_center slds-p-around_medium address-box';
        return this.selectedAddressOption === 'userInput' ? base + ' address-box_selected' : base;
    }

    handleAddressBoxClick(event) {
        this.selectedAddressOption = event.currentTarget.dataset.option;
    }

    runVerification() {
        this.loaded = true;
        const ua = this.userEnteredAddress;
        addressVerification({
            organizationName: this.accountName,
            streetName: ua.streetName,
            countryName: this.countryCode,
            stateName: this.stateCode,
            cityName: ua.cityName,
            postalCode: ua.postalCode
        })
            .then(result => {
                this.cleansedAddress = result || {};
                this.selectedAddressOption = null;
                this.loaded = false;
                this.showContent = true;
            })
            .catch(() => {
                this.cleansedAddress = {};
                this.loaded = false;
                this.showContent = true;
                this.showToast('error', 'Error', 'Address verification failed. You can proceed with the entered address.');
            });
    }

    handleProceed() {
        this.loaded = true;
        const fields = { Id: this.recordId };
        const useCleansed = this.selectedAddressOption === 'cleansed' && this.hasCleansedAddress;
        if (useCleansed) {
            fields.Address__CountryCode__s = this.cleansedAddress.countryCode;
            fields.Address__StateCode__s = this.cleansedAddress.stateCode;
            fields.Address__Street__s = this.cleansedAddress.streetName;
            fields.Address__City__s = this.cleansedAddress.cityName;
            fields.Address__PostalCode__s = this.cleansedAddress.postalCode;
            fields.IsAddressVerified__c = true;
        } else {
            fields.IsAddressVerified__c = false;
        }
        updateRecord({ fields })
            .then(() => {
                this.loaded = false;
                if (useCleansed) {
                    this.showToast('success', 'Success', 'Address verified and standardized successfully.');
                } else {
                    this.showToast('warning', 'Address Not Standardized', 'Proceeding with the address as entered. Address is not standardized.');
                }
                this.closeAction();
            })
            .catch(error => {
                this.loaded = false;
                const msg = error && error.body && error.body.message
                    ? error.body.message
                    : 'An error occurred while updating the record.';
                this.showToast('error', 'Error', msg);
            });
    }

    handleCancel() {
        this.closeAction();
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(variant, title, message) {
        this.dispatchEvent(new ShowToastEvent({ variant, title, message }));
    }
}