import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
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

export default class Ucd_ACM_Address_Verification_Modal extends LightningModal {
    @api recordId;

    @track cleansedAddress = {};
    @track userEnteredAddress = {};
    selectedAddressOption = null;
    saving = false;
    verificationDone = false;
    countryReady = false;
    stateReady = false;
    accountName = '';
    stateCode = '';
    countryCode = '';
    countryMap = {};
    stateData;

    get ready() {
        return this.verificationDone && this.countryReady && this.stateReady;
    }

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountInfo;

    @wire(getPicklistValues, { recordTypeId: '$accountInfo.data.defaultRecordTypeId', fieldApiName: COUNTRY_CODE_FIELD })
    wiredCountryValues({ data }) {
        if (data) {
            const map = {};
            data.values.forEach(v => { map[v.value] = v.label; });
            this.countryMap = map;
            this.countryReady = true;
            this.applyDisplayNames();
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$accountInfo.data.defaultRecordTypeId', fieldApiName: STATE_CODE_FIELD })
    wiredStateValues({ data }) {
        if (data) {
            this.stateData = data;
            this.stateReady = true;
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
            this.close({ status: 'error', message: 'Unable to load the request record: ' + this.reduceError(error) });
        }
    }

    runVerification() {
        addressVerification({
            organizationName: this.accountName,
            streetName: this.userEnteredAddress.streetName,
            countryName: this.countryCode,
            stateName: this.stateCode,
            cityName: this.userEnteredAddress.cityName,
            postalCode: this.userEnteredAddress.postalCode
        })
            .then(result => {
                this.cleansedAddress = result || {};
                this.verificationDone = true;
            })
            .catch(() => {
                this.cleansedAddress = {};
                this.verificationDone = true;
            });
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

    getVal(field) {
        return field && field.value != null ? field.value : '';
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
        event.stopPropagation();
        this.selectedAddressOption = event.currentTarget.dataset.option;
    }

    handleDeselectAddress() {
        this.selectedAddressOption = null;
    }

    handleProceed() {
        const useCleansed = this.selectedAddressOption === 'cleansed' && this.hasCleansedAddress;
        const fields = { Id: this.recordId };
        if (useCleansed) {
            fields.Address__CountryCode__s = this.cleansedAddress.countryCode;
            fields.Address__StateCode__s = this.cleansedAddress.stateCode;
            fields.Address__Street__s = this.cleansedAddress.streetName;
            fields.Address__City__s = this.cleansedAddress.cityName;
            fields.Address__PostalCode__s = this.cleansedAddress.postalCode;
            fields.Standardized_Address_Country_Code__c = this.cleansedAddress.countryCode;
            fields.Standardized_Address_State_Code__c = this.cleansedAddress.stateCode;
            fields.Standardized_Address_Street__c = this.cleansedAddress.streetName;
            fields.Standardized_Address_City__c = this.cleansedAddress.cityName;
            fields.Standardized_Address_Postal_Code__c = this.cleansedAddress.postalCode;
            fields.IsAddressVerified__c = true;
        } else {
            fields.IsAddressVerified__c = false;
        }
        this.saving = true;
        updateRecord({ fields })
            .then(() => {
                this.close({ status: useCleansed ? 'verified' : 'entered' });
            })
            .catch(error => {
                this.saving = false;
                this.close({ status: 'error', message: this.reduceError(error) });
            });
    }

    handleCancel() {
        this.close();
    }

    reduceError(error) {
        if (!error) {
            return 'Unknown error';
        }
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        }
        if (error.body && typeof error.body.message === 'string') {
            return error.body.message;
        }
        if (typeof error.message === 'string') {
            return error.message;
        }
        return JSON.stringify(error);
    }
}