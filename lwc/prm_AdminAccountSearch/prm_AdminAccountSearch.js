import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import searchAccounts from '@salesforce/apex/PRM_AdminAccountSearch.searchAccounts';

const COLUMNS = [
    { label: 'Account Name', fieldName: 'Name', wrapText: true },
    { label: 'Partner Role', fieldName: 'Core_IPA_Partner_Role__c', wrapText: true },
    { label: 'IPA Account', fieldName: 'Core_Intel_Partner_Alliance_PartnerGroup__c', type: 'boolean' },
    { label: 'User Defined Website', fieldName: 'Core_User_Defined_Website__c', wrapText: true }
];

export default class Prm_AdminAccountSearch extends LightningElement {
    @api accountName;
    @api website;
    @api disabled = false;
    _selectedValues = {};
    _existingPartnerRole = '';

    @api
    get existingPartnerRole() { return this._existingPartnerRole; }
    set existingPartnerRole(value) {
        this._existingPartnerRole = value || '';
        this.dispatchEvent(new FlowAttributeChangeEvent('existingPartnerRoleText', this._existingPartnerRole));
    }

    @api
    get existingPartnerRoleText() { return this._existingPartnerRole; }

    connectedCallback() {
        this.dispatchEvent(new FlowAttributeChangeEvent('existingPartnerRoleText', this._existingPartnerRole));
    }

    @api
    get selectedAccountId() { return this._selectedValues.selectedAccountId; }
    set selectedAccountId(value) { this._selectedValues.selectedAccountId = value; }

    @api
    get selectedName() { return this._selectedValues.selectedName; }
    set selectedName(value) { this._selectedValues.selectedName = value; }

    @api
    get selectedWebsite() { return this._selectedValues.selectedWebsite; }
    set selectedWebsite(value) { this._selectedValues.selectedWebsite = value; }

    @api
    get selectedPartnerRole() { return this._selectedValues.selectedPartnerRole; }
    set selectedPartnerRole(value) { this._selectedValues.selectedPartnerRole = value; }

    @api
    get selectedStreet() { return this._selectedValues.selectedStreet; }
    set selectedStreet(value) { this._selectedValues.selectedStreet = value; }

    @api
    get selectedCity() { return this._selectedValues.selectedCity; }
    set selectedCity(value) { this._selectedValues.selectedCity = value; }

    @api
    get selectedState() { return this._selectedValues.selectedState; }
    set selectedState(value) { this._selectedValues.selectedState = value; }

    @api
    get selectedStateCode() { return this._selectedValues.selectedStateCode; }
    set selectedStateCode(value) { this._selectedValues.selectedStateCode = value; }

    @api
    get selectedCountry() { return this._selectedValues.selectedCountry; }
    set selectedCountry(value) { this._selectedValues.selectedCountry = value; }

    @api
    get selectedCountryCode() { return this._selectedValues.selectedCountryCode; }
    set selectedCountryCode(value) { this._selectedValues.selectedCountryCode = value; }

    @api
    get selectedPostalCode() { return this._selectedValues.selectedPostalCode; }
    set selectedPostalCode(value) { this._selectedValues.selectedPostalCode = value; }

    columns = COLUMNS;
    accounts = [];
    selectedRows = [];
    modalOpen = false;
    loading = false;
    errorMessage = '';
    hasMore = false;
    requestVersion = 0;
    _contactEmail;
    _focusModal = false;
    _focusSearch = false;

    renderedCallback() {
        if (this._focusModal && this.modalOpen) {
            this._focusModal = false;
            this.template.querySelector('.slds-modal__close').focus();
        } else if (this._focusSearch && !this.modalOpen) {
            this._focusSearch = false;
            this.template.querySelector('lightning-button').focus();
        }
    }

    @api
    get contactEmail() {
        return this._contactEmail;
    }

    set contactEmail(value) {
        if (this._contactEmail !== undefined && this._contactEmail !== value) {
            this.closeModal();
            this.publishAccount(null);
        }
        this._contactEmail = value;
    }

    get searchDisabled() {
        return this.disabled || this.loading;
    }

    get showClearSelection() {
        return !!this.selectedAccountId && !this.disabled;
    }

    handleClearSelection() {
        this.closeModal();
        this.publishAccount(null);
        this.errorMessage = '';
    }

    get selectionDisabled() {
        return this.loading || this.selectedRows.length !== 1 || this.disabled;
    }

    get hasAccounts() {
        return this.accounts.length > 0;
    }

    get showNoMatches() {
        return !this.loading && !this.errorMessage && !this.hasAccounts;
    }

    async handleSearch() {
        this.errorMessage = '';
        if (!this.accountName || this.accountName.trim().length < 2 || !this.website?.trim()) {
            this.errorMessage = 'Enter an account name (at least two characters) and website before searching.';
            return;
        }
        this.modalOpen = true;
        this._focusModal = true;
        this.loading = true;
        this.accounts = [];
        this.selectedRows = [];
        this.hasMore = false;
        const version = ++this.requestVersion;
        try {
            const result = await searchAccounts({
                accountName: this.accountName,
                website: this.website
            });
            if (version !== this.requestVersion) {
                return;
            }
            this.accounts = result.accounts;
            this.hasMore = result.hasMore;
        } catch (error) {
            if (version === this.requestVersion) {
                this.errorMessage = error.body?.message || error.message || 'Account search failed. Please try again.';
            }
        } finally {
            if (version === this.requestVersion) {
                this.loading = false;
            }
        }
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows.map(account => account.Id);
    }

    handleUseAccount() {
        const account = this.accounts.find(row => row.Id === this.selectedRows[0]);
        if (!account || this.selectionDisabled) {
            this.errorMessage = 'Select one matching account before continuing.';
            return;
        }
        this.publishAccount(account);
        this.closeModal();
    }

    publishAccount(account) {
        const values = {
            selectedName: account?.Name || '',
            selectedWebsite: account?.Core_User_Defined_Website__c || account?.Website || '',
            selectedPartnerRole: account && !account.Core_Intel_Partner_Alliance_PartnerGroup__c
                ? account.Core_IPA_Partner_Role__c || '' : '',
            selectedStreet: account?.BillingStreet || '',
            selectedCity: account?.BillingCity || '',
            selectedState: account?.BillingState || '',
            selectedStateCode: account?.BillingStateCode || '',
            selectedCountry: account?.BillingCountry || '',
            selectedCountryCode: account?.BillingCountryCode || '',
            selectedPostalCode: account?.BillingPostalCode || '',
            selectedAccountId: account?.Id || ''
        };
        this._selectedValues = values;
        Object.entries(values).forEach(([name, value]) => {
            this.dispatchEvent(new FlowAttributeChangeEvent(name, value));
        });
    }

    closeModal() {
        this._focusSearch = this.modalOpen;
        ++this.requestVersion;
        this.modalOpen = false;
        this.loading = false;
    }

    handleKeyDown(event) {
        if (event.key === 'Escape') {
            event.stopPropagation();
            this.closeModal();
        }
    }
}