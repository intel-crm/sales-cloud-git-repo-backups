import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchAccounts from '@salesforce/apex/PRM_EndCustomerAccountSearchController.searchAccounts';
import createAccount from '@salesforce/apex/PRM_EndCustomerAccountSearchController.insertAccount';

const DESIGN_REGISTRATION_OBJECT = 'Core_Design_Registration__c';
const PARTNER_DEAL_OBJECT = 'PRM_Partner_Deal_Opportunity__c';

const COLUMNS = [
    { label: 'Account Name', fieldName: 'accountName', type: 'text', wrapText: true, initialWidth: 280 },
    { label: 'Country', fieldName: 'billingCountry', type: 'text', initialWidth: 150 },
    { label: 'Website', fieldName: 'website', type: 'text', initialWidth: 220 },
    { label: 'Account Record Type', fieldName: 'recordTypeName', type: 'text', initialWidth: 190 },
    { label: 'Account Owner', fieldName: 'ownerName', type: 'text', initialWidth: 180 }
];

export default class pRM_EndCustomerAccountSearch extends LightningElement {

    @api recordId;
    @api objectApiName;
    @api sourceNameFieldApiName;
    @api sourceCountryFieldApiName;
    @api sourceWebsiteFieldApiName;
    @api targetAccountLookupFieldApiName;

    columns = COLUMNS;
    accounts = [];
    selectedRows = [];

    customerName;
    customerCountry;
    customerWebsite;

    selectedAccountId;
    lastSearchKey;
    pendingAccountId = null;

    isLoading = false;
    searchCompleted = false;

    // ==========================================
    // RECORD FIELDS CONFIGURATION
    // ==========================================

    get recordFields() {
        console.log('===== RECORD FIELDS CONFIGURATION =====');
        console.log('Record ID:', this.recordId);
        console.log('Object API Name:', this.objectApiName);
        console.log('Name Field:', this.sourceNameFieldApiName);
        console.log('Country Field:', this.sourceCountryFieldApiName);
        console.log('Website Field:', this.sourceWebsiteFieldApiName);
        console.log('Lookup Field:', this.targetAccountLookupFieldApiName);

        if (!this.objectApiName || !this.sourceNameFieldApiName || !this.targetAccountLookupFieldApiName) {
            console.warn('Required field configuration missing.');
            return [];
        }

        const fields = [`${this.objectApiName}.${this.sourceNameFieldApiName}`, `${this.objectApiName}.${this.targetAccountLookupFieldApiName}`];

        if (this.sourceCountryFieldApiName) {
            fields.push(`${this.objectApiName}.${this.sourceCountryFieldApiName}`);
        }

        if (this.sourceWebsiteFieldApiName) {
            fields.push(`${this.objectApiName}.${this.sourceWebsiteFieldApiName}`);
        }

        console.log('Fields requested:', JSON.stringify(fields));
        return fields;
    }

    // ==========================================
    // GET SOURCE RECORD
    // ==========================================

    @wire(getRecord, { recordId: '$recordId', fields: '$recordFields' })
    wiredSourceRecord({ data, error }) {
        console.log('===== WIRED SOURCE RECORD =====');

        if (data) {
            console.log('Source Record:', data);

            this.customerName = data.fields[this.sourceNameFieldApiName]?.value;
            this.customerCountry = this.sourceCountryFieldApiName ? data.fields[this.sourceCountryFieldApiName]?.value : null;
            this.customerWebsite = this.sourceWebsiteFieldApiName ? data.fields[this.sourceWebsiteFieldApiName]?.value : null;
            this.selectedAccountId = data.fields[this.targetAccountLookupFieldApiName]?.value;

            this.selectedRows = this.selectedAccountId ? [this.selectedAccountId] : [];

            console.log('Customer Name:', this.customerName);
            console.log('Customer Country:', this.customerCountry);
            console.log('Customer Website:', this.customerWebsite);
            console.log('Existing Account ID:', this.selectedAccountId);

            const currentSearchKey = [this.objectApiName, this.customerName || '', this.customerCountry || '', this.customerWebsite || ''].join('|');

            console.log('Current Search Key:', currentSearchKey);
            console.log('Previous Search Key:', this.lastSearchKey);

            if (this.customerName && currentSearchKey !== this.lastSearchKey) {
                console.log('Search criteria changed. Starting Account search.');
                this.lastSearchKey = currentSearchKey;
                this.loadMatchingAccounts();
            } else if (!this.customerName) {
                console.warn('Customer Name is empty. Search cancelled.');
                this.accounts = [];
                this.searchCompleted = true;
            }
        } else if (error) {
            console.error('Source Record Error:', error);
            this.searchCompleted = true;
            this.showError(error);
        }
    }

    // ==========================================
    // GETTERS
    // ==========================================

    get isDesignRegistration() {
        return this.objectApiName === DESIGN_REGISTRATION_OBJECT;
    }

    get isPartnerDealOpportunity() {
        return this.objectApiName === PARTNER_DEAL_OBJECT;
    }

    get cardTitle() {
        return this.isPartnerDealOpportunity ? 'Suggested End Customer Accounts' : 'Suggested Intel End Customer Accounts';
    }

    get customerNameDisplay() {
        return this.customerName || 'End Customer Name is not populated.';
    }

    get hasResults() {
        return this.accounts.length > 0;
    }

    get resultCountLabel() {
        const count = this.accounts.length;
        return count === 1 ? '1 result' : `${count} results`;
    }

    // ==========================================
    // SEARCH MATCHING ACCOUNTS
    // ==========================================

    async loadMatchingAccounts() {
        console.log('===== ACCOUNT SEARCH START =====');

        if (!this.customerName || !this.objectApiName) {
            console.warn('Search cancelled: Missing customer name or object API name.');
            this.accounts = [];
            this.searchCompleted = true;
            return;
        }

        console.log('Search Customer Name:', this.customerName);
        console.log('Search Customer Country:', this.customerCountry);
        console.log('Search Customer Website:', this.customerWebsite);
        console.log('Source Object:', this.objectApiName);

        this.isLoading = true;
        this.searchCompleted = false;
        this.accounts = [];

        try {
            const searchParameters = {
                customerName: this.customerName,
                customerCountry: this.customerCountry,
                customerWebsite: this.customerWebsite,
                sourceObjectApiName: this.objectApiName
            };

            console.log('Apex Search Parameters:', JSON.stringify(searchParameters));

            const result = await searchAccounts(searchParameters);

            console.log('Apex Search Response:', JSON.stringify(result));
            console.log('Accounts Returned:', result ? result.length : 0);

            this.accounts = result || [];
            this.searchCompleted = true;
            this.selectedRows = this.selectedAccountId ? [this.selectedAccountId] : [];

            console.log('Final Account Count:', this.accounts.length);

        } catch (error) {
            console.error('Account Search Error:', error);
            console.error('Error Message:', error?.body?.message || error?.message);
            this.searchCompleted = true;
            this.showError(error);
        } finally {
            this.isLoading = false;
            console.log('===== ACCOUNT SEARCH END =====');
        }
    }

    // ==========================================
    // HANDLE ROW SELECTION
    // ==========================================

    handleRowSelection(event) {
        console.log('===== ROW SELECTION =====');
        const selectedRecords = event.detail.selectedRows;
        console.log('Selected Records:', selectedRecords);

        if (selectedRecords && selectedRecords.length > 0) {
            this.pendingAccountId = selectedRecords[0].accountId;
            this.selectedRows = [this.pendingAccountId];
            console.log('Selected Account ID:', this.pendingAccountId);
        } else {
            this.pendingAccountId = null;
            this.selectedRows = [];
            console.log('Account selection cleared.');
        }
    }

    // ==========================================
    // SAVE SELECTED ACCOUNT
    // ==========================================

    async handleSave() {
        console.log('===== SAVE ACCOUNT START =====');

        if (!this.pendingAccountId) {
            this.showToast('Warning', 'Please select an End Customer Account before saving.', 'warning');
            return;
        }

        this.isLoading = true;

        try {
            console.log('Saving Account ID:', this.pendingAccountId);
            console.log('Source Record ID:', this.recordId);
            console.log('Lookup Field:', this.targetAccountLookupFieldApiName);

            const fields = {};
            fields.Id = this.recordId;
            fields[this.targetAccountLookupFieldApiName] = this.pendingAccountId;

            console.log('Update Payload:', JSON.stringify(fields));

            await updateRecord({ fields });

            this.selectedAccountId = this.pendingAccountId;

            await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);

            this.pendingAccountId = null;

            this.showToast('Success', 'End Customer Account updated successfully.', 'success');

        } catch (error) {
            console.error('Save Account Error:', error);
            this.showError(error);
        } finally {
            this.isLoading = false;
            console.log('===== SAVE ACCOUNT END =====');
        }
    }

    // ==========================================
    // CREATE ACCOUNT
    // ==========================================

    async handleCreateAccount() {
        console.log('===== CREATE ACCOUNT START =====');

        console.log('Record ID:', this.recordId);
        console.log('Object API Name:', this.objectApiName);
        console.log('Lookup Field:', this.targetAccountLookupFieldApiName);
        console.log('Customer Name:', this.customerName);
        console.log('Customer Country:', this.customerCountry);
        console.log('Customer Website:', this.customerWebsite);

        if (!this.isPartnerDealOpportunity) {
            console.error('Not a Partner Deal Opportunity.');
            return;
        }

        if (!this.recordId) {
            this.showToast('Error', 'Record ID is missing.', 'error');
            return;
        }

        if (!this.targetAccountLookupFieldApiName) {
            this.showToast('Error', 'Lookup field configuration is missing.', 'error');
            return;
        }

        if (!this.customerName) {
            this.showToast('Error', 'End Customer Name must be populated.', 'error');
            return;
        }

        this.isLoading = true;

        try {
            console.log('STEP 1: Creating Account through Apex.');

            const accountId = await createAccount({ accountName: this.customerName, country: this.customerCountry });

            console.log('Created Account ID:', accountId);

            if (!accountId) {
                throw new Error('Apex returned an empty Account ID.');
            }

            const fields = {};
            fields.Id = this.recordId;
            fields[this.targetAccountLookupFieldApiName] = accountId;

            console.log('STEP 2: Updating source record.');

            await updateRecord({ fields });

            this.selectedAccountId = accountId;
            this.selectedRows = [accountId];

            await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);

            console.log('STEP 3: Refreshing Account search.');

            this.lastSearchKey = null;
            await this.loadMatchingAccounts();

            this.showToast('Success', 'Account created and assigned to End Customer Account lookup.', 'success');

        } catch (error) {
            console.error('Create Account Error:', error);
            console.error('Error Message:', error?.body?.message || error?.message);
            this.showError(error);
        } finally {
            this.isLoading = false;
            console.log('===== CREATE ACCOUNT END =====');
        }
    }

    // ==========================================
    // ERROR HANDLING
    // ==========================================

    showError(error) {
        let message = 'An unexpected error occurred.';

        if (error) {
            if (error.body) {
                if (Array.isArray(error.body)) {
                    message = error.body.map(item => item.message).join(' | ');
                } else if (error.body.message) {
                    message = error.body.message;
                }

                if (error.body.output) {
                    const output = error.body.output;

                    if (output.errors?.length) {
                        message += ' | ' + output.errors.map(item => item.message).join(' | ');
                    }

                    if (output.fieldErrors) {
                        Object.keys(output.fieldErrors).forEach(field => {
                            output.fieldErrors[field].forEach(item => {
                                message += ` | ${field}: ${item.message}`;
                            });
                        });
                    }
                }
            } else if (error.message) {
                message = error.message;
            }
        }

        console.error('FINAL ERROR MESSAGE:', message);
        this.showToast('Error', message, 'error');
    }

    // ==========================================
    // TOAST MESSAGE
    // ==========================================

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}