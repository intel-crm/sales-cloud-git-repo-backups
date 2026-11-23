import { LightningElement, api, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import ACCOUNT from '@salesforce/schema/Account';

export default class prm_AdminRegAddressAccSearch extends LightningElement {
    @api addressLabel = 'Address';
    @api required = false;
    @api disabled = false;
    @api usePartialLocks = false;
    @api streetLocked = false;
    @api cityLocked = false;
    @api provinceLocked = false;
    @api countryLocked = false;
    @api postalCodeLocked = false;
    _values = {};
    countries = [];
    states;
    recordTypeId;
    picklistsReady = false;
    errorMessage = '';
    externalError = '';
    internalError = '';
    showValidation = false;

    @api
    get street() { return this._values.street || ''; }
    set street(value) { this.updateValue('street', value); }
    @api
    get city() { return this._values.city || ''; }
    set city(value) { this.updateValue('city', value); }
    @api
    get province() { return this._values.province || ''; }
    set province(value) { this.updateValue('province', value); }
    @api
    get provinceCode() { return this._values.provinceCode || ''; }
    set provinceCode(value) { this.updateValue('provinceCode', value); }
    @api
    get country() { return this._values.country || ''; }
    set country(value) { this.updateValue('country', value); }
    @api
    get countryCode() { return this._values.countryCode || ''; }
    set countryCode(value) { this.updateValue('countryCode', value); }
    @api
    get postalCode() { return this._values.postalCode || ''; }
    set postalCode(value) { this.updateValue('postalCode', value); }

    connectedCallback() {
        Object.entries(this._values).forEach(([name, value]) => {
            this.dispatchEvent(new FlowAttributeChangeEvent(name, value));
        });
    }

    @wire(getObjectInfo, { objectApiName: ACCOUNT })
    loadAccountInfo({ data, error }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.errorMessage = error.body?.message || 'Unable to load Account address metadata.';
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: ACCOUNT, recordTypeId: '$recordTypeId' })
    loadPicklists({ data, error }) {
        if (data) {
            const fields = data.picklistFieldValues;
            if (!fields.BillingCountryCode || !fields.BillingStateCode) {
                this.errorMessage = 'Account country and state picklists are unavailable. Contact your Salesforce administrator.';
                return;
            }
            this.countries = fields.BillingCountryCode.values.map(({ label, value }) => ({ label, value }));
            this.states = fields.BillingStateCode;
            this.picklistsReady = true;
            this.errorMessage = '';
        } else if (error) {
            this.errorMessage = error.body?.message || 'Unable to load country and state options.';
            this.picklistsReady = false;
        }
    }

    get countryOptions() {
        return [{ label: '--None--', value: '' }, ...this.countries];
    }

    get selectedCountryCode() {
        return this.countryCode || this.countries.find(option => option.label === this.country)?.value || '';
    }

    get provinceOptions() {
        const controller = this.states?.controllerValues[this.selectedCountryCode];
        const values = controller === undefined ? [] : this.states.values.filter(
            option => option.validFor.includes(controller)
        ).map(({ label, value }) => ({ label, value }));
        return [{ label: '--None--', value: '' }, ...values];
    }

    get selectedProvinceCode() {
        return this.provinceCode || this.provinceOptions.find(option => option.label === this.province)?.value || '';
    }

    get countryDisplay() {
        return this.country || this.countries.find(option => option.value === this.countryCode)?.label || this.countryCode;
    }

    get provinceDisplay() {
        return this.province || this.provinceOptions.find(option => option.value === this.provinceCode)?.label || this.provinceCode;
    }

    get disableStreet() { return this.disabled || this.streetLocked; }
    get disableCity() { return this.disabled || this.cityLocked; }
    get disableProvince() { return this.disabled || this.provinceLocked; }
    get disableCountry() { return this.disabled || this.countryLocked; }
    get disablePostalCode() { return this.disabled || this.postalCodeLocked; }
    get countryUnavailable() { return this.disableCountry || !this.picklistsReady; }
    get provinceUnavailable() { return this.disableProvince || !this.picklistsReady || !this.selectedCountryCode; }
    get validationMessage() {
        return this.showValidation ? this.externalError || this.internalError : '';
    }

    updateValue(name, value) {
        const nextValue = value || '';
        if (this._values[name] !== nextValue) {
            this._values = { ...this._values, [name]: nextValue };
            this.dispatchEvent(new FlowAttributeChangeEvent(name, nextValue));
        }
    }

    handleFieldChange(event) {
        const name = event.target.dataset.field;
        const locked = {
            street: this.disableStreet, city: this.disableCity,
            postalCode: this.disablePostalCode, country: this.disableCountry,
            province: this.disableProvince
        };
        if (locked[name]) {
            return;
        }
        const value = event.detail.value;
        if (name === 'country') {
            this.updateValue('countryCode', value);
            this.updateValue('country', this.countries.find(option => option.value === value)?.label || '');
            if (!this.provinceLocked) {
                this.updateValue('provinceCode', '');
                this.updateValue('province', '');
            }
        } else if (name === 'province') {
            this.updateValue('provinceCode', value);
            this.updateValue('province', this.provinceOptions.find(option => option.value === value)?.label || '');
        } else {
            this.updateValue(name, value);
        }
    }

    handleAddressChange(event) {
        if (this.disabled) {
            return;
        }
        const { street, city, province, country, postalCode } = event.detail;
        this.updateValue('street', street);
        this.updateValue('city', city);
        this.updateValue('postalCode', postalCode);
        this.updateValue('countryCode', country);
        this.updateValue('country', this.countries.find(option => option.value === country)?.label || '');
        this.updateValue('provinceCode', province);
        this.updateValue('province', this.provinceOptions.find(option => option.value === province)?.label || '');
    }

    @api
    validate() {
        this.internalError = '';
        if (this.disabled) {
            return { isValid: true };
        }
        if (this.errorMessage || !this.picklistsReady) {
            this.internalError = this.errorMessage || 'Please wait for the address options to load.';
        } else if (this.required && (!this.street.trim() || !this.city.trim() || !this.countryDisplay.trim() || !this.postalCode.trim())) {
            this.internalError = 'Complete the missing country, street, city, and zip/postal code fields.';
        } else if (this.selectedProvinceCode && !this.provinceOptions.some(option => option.value === this.selectedProvinceCode)) {
            this.internalError = 'The state/province does not match the selected country. Choose the correct country or clear the account selection.';
        }
        return { isValid: !this.internalError, errorMessage: this.internalError };
    }

    @api
    setCustomValidity(message) {
        this.externalError = message || '';
    }

    @api
    reportValidity() {
        this.showValidation = true;
        this.template.querySelectorAll('lightning-input, lightning-textarea, lightning-combobox, lightning-input-address')
            .forEach(field => field.reportValidity());
    }
}