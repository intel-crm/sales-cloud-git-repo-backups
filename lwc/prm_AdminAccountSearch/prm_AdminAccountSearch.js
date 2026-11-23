import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

import searchAccounts from '@salesforce/apex/PRM_AdminAccountSearch.searchAccounts';
import getAccountTypePicklistValues from '@salesforce/apex/PRM_AdminAccountSearch.getAccountTypePicklistValues';

const COLUMNS = [
    { label: 'Account Name', fieldName: 'Name', wrapText: true },
    { label: 'Partner Role', fieldName: 'Core_IPA_Partner_Role__c', wrapText: true },
    {
        label: 'IPA Account',
        fieldName: 'Core_Intel_Partner_Alliance_PartnerGroup__c',
        type: 'boolean'
    },
    {
        label: 'User Defined Website',
        fieldName: 'Core_User_Defined_Website__c',
        wrapText: true
    },
    {
        label: 'Account Type',
        fieldName: 'accountTypeLabel',
        wrapText: true
    }
];

export default class Prm_AdminAccountSearch extends LightningElement {

    @api accountName;
    @api website;
    @api disabled = false;

    _selectedValues = {};
    _existingPartnerRole = '';

    // Account Type picklist mapping
    accountTypeMap = {};
    accountTypeMapPromise;

    @api
    get existingPartnerRole() {
        return this._existingPartnerRole;
    }

    set existingPartnerRole(value) {
        this._existingPartnerRole = value || '';

        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'existingPartnerRoleText',
                this._existingPartnerRole
            )
        );
    }

    @api
    get existingPartnerRoleText() {
        return this._existingPartnerRole;
    }

    connectedCallback() {

        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'existingPartnerRoleText',
                this._existingPartnerRole
            )
        );

        // Load Account Type picklist values
        this.accountTypeMapPromise = getAccountTypePicklistValues()
            .then(result => {
                this.accountTypeMap = result || {};

                console.log(
                    'Account Type Picklist Map:',
                    JSON.stringify(this.accountTypeMap)
                );
            })
            .catch(error => {
                console.error(
                    'Error loading Account Type picklist:',
                    error
                );

                this.accountTypeMap = {};
            });
    }

    @api
    get selectedAccountId() {
        return this._selectedValues.selectedAccountId;
    }

    set selectedAccountId(value) {
        this._selectedValues.selectedAccountId = value;
    }

    @api
    get selectedName() {
        return this._selectedValues.selectedName;
    }

    set selectedName(value) {
        this._selectedValues.selectedName = value;
    }

    @api
    get selectedWebsite() {
        return this._selectedValues.selectedWebsite;
    }

    set selectedWebsite(value) {
        this._selectedValues.selectedWebsite = value;
    }

    @api
    get selectedPartnerRole() {
        return this._selectedValues.selectedPartnerRole;
    }

    set selectedPartnerRole(value) {
        this._selectedValues.selectedPartnerRole = value;
    }

    @api
    get selectedStreet() {
        return this._selectedValues.selectedStreet;
    }

    set selectedStreet(value) {
        this._selectedValues.selectedStreet = value;
    }

    @api
    get selectedCity() {
        return this._selectedValues.selectedCity;
    }

    set selectedCity(value) {
        this._selectedValues.selectedCity = value;
    }

    @api
    get selectedState() {
        return this._selectedValues.selectedState;
    }

    set selectedState(value) {
        this._selectedValues.selectedState = value;
    }

    @api
    get selectedStateCode() {
        return this._selectedValues.selectedStateCode;
    }

    set selectedStateCode(value) {
        this._selectedValues.selectedStateCode = value;
    }

    @api
    get selectedCountry() {
        return this._selectedValues.selectedCountry;
    }

    set selectedCountry(value) {
        this._selectedValues.selectedCountry = value;
    }

    @api
    get selectedCountryCode() {
        return this._selectedValues.selectedCountryCode;
    }

    set selectedCountryCode(value) {
        this._selectedValues.selectedCountryCode = value;
    }

    @api
    get selectedPostalCode() {
        return this._selectedValues.selectedPostalCode;
    }

    set selectedPostalCode(value) {
        this._selectedValues.selectedPostalCode = value;
    }

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
            this.template.querySelector('.slds-modal__close')?.focus();

        } else if (this._focusSearch && !this.modalOpen) {
            this._focusSearch = false;
            this.template.querySelector('lightning-button')?.focus();
        }
    }

    @api
    get contactEmail() {
        return this._contactEmail;
    }

    set contactEmail(value) {

        if (
            this._contactEmail !== undefined &&
            this._contactEmail !== value
        ) {
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
        return (
            this.loading ||
            this.selectedRows.length !== 1 ||
            this.disabled
        );
    }

    get hasAccounts() {
        return this.accounts.length > 0;
    }

    get showNoMatches() {
        return (
            !this.loading &&
            !this.errorMessage &&
            !this.hasAccounts
        );
    }

    // Search matching accounts
    async handleSearch() {

        this.errorMessage = '';

        if (
            !this.accountName ||
            this.accountName.trim().length < 2 ||
            !this.website?.trim()
        ) {
            this.errorMessage =
                'Enter an account name (at least two characters) and website before searching.';
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

            // Fetch matching accounts from Apex
            const result = await searchAccounts({
                accountName: this.accountName,
                website: this.website
            });

            if (version !== this.requestVersion) {
                return;
            }

            // Wait for picklist mapping to load
            await this.accountTypeMapPromise;

            if (version !== this.requestVersion) {
                return;
            }

            // Convert Account Type API value to display label
            this.accounts = (result.accounts || []).map(account => {

                const apiValue =
                    account.Core_Customer_Aggregation_Type__c;

                const displayLabel =
                    this.accountTypeMap[apiValue] || apiValue || '';

                return {
                    ...account,
                    accountTypeLabel: displayLabel
                };
            });

            this.hasMore = result.hasMore;

            console.log(
                'Account Type Map:',
                JSON.stringify(this.accountTypeMap)
            );

            console.log(
                'Accounts with Display Labels:',
                JSON.stringify(this.accounts)
            );

        } catch (error) {

            if (version === this.requestVersion) {
                this.errorMessage =
                    error.body?.message ||
                    error.message ||
                    'Account search failed. Please try again.';
            }

        } finally {

            if (version === this.requestVersion) {
                this.loading = false;
            }
        }
    }

    // Handle datatable row selection
    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows.map(
            account => account.Id
        );
    }

    // Use selected account
    handleUseAccount() {

        const account = this.accounts.find(
            row => row.Id === this.selectedRows[0]
        );

        if (!account || this.selectionDisabled) {
            this.errorMessage =
                'Select one matching account before continuing.';
            return;
        }
        console.log(account+'account...');
        this.publishAccount(account);
        this.closeModal();
    }

    // Publish selected account details to Salesforce Flow
    publishAccount(account) {
console.log( account.Core_IPA_Partner_Role__c+' account.Core_IPA_Partner_Role__c');
const role=account.Core_IPA_Partner_Role__c;
        const values = {

            selectedName: account?.Name || '',

            selectedWebsite:
                account?.Core_User_Defined_Website__c ||
                account?.Website ||
                '',

            selectedPartnerRole:
                account &&
                account.Core_Intel_Partner_Alliance_PartnerGroup__c
                && !role.includes(';')
                ? account.Core_IPA_Partner_Role__c || ''
                : '',

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

            this.dispatchEvent(
                new FlowAttributeChangeEvent(name, value)
            );
        });
    }

    // Close modal
    closeModal() {

        this._focusSearch = this.modalOpen;

        ++this.requestVersion;

        this.modalOpen = false;
        this.loading = false;
    }

    // Handle Escape key
    handleKeyDown(event) {

        if (event.key === 'Escape') {
            event.stopPropagation();
            this.closeModal();
        }
    }
}