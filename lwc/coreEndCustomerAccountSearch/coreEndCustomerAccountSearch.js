import {
    LightningElement,
    api,
    wire
} from 'lwc';

import {
    getRecord,
    getFieldValue,
    updateRecord,
    notifyRecordUpdateAvailable
} from 'lightning/uiRecordApi';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import searchAccounts
    from '@salesforce/apex/Core_EndCustomerAccountSearchController.searchAccounts';

import END_CUSTOMER_NAME
    from '@salesforce/schema/Core_Design_Registration__c.Core_End_Customer_Nm__c';

import END_CUSTOMER_COUNTRY
    from '@salesforce/schema/Core_Design_Registration__c.PCC_End_Customer_Country__c';

import END_CUSTOMER_WEBSITE
    from '@salesforce/schema/Core_Design_Registration__c.Core_End_Customer_URL__c';

import END_CUSTOMER_ACCOUNT
    from '@salesforce/schema/Core_Design_Registration__c.Core_End_Customer_Account_Id__c';

import END_CUSTOMER_ACCOUNT_NAME
    from '@salesforce/schema/Core_Design_Registration__c.Core_End_Customer_Account_Id__r.Name';

import DDR_STATUS
    from '@salesforce/schema/Core_Design_Registration__c.Core_Design_Registration_Status_Nm__c';

const RECORD_FIELDS = [
    END_CUSTOMER_NAME,
    END_CUSTOMER_COUNTRY,
    END_CUSTOMER_WEBSITE,
    END_CUSTOMER_ACCOUNT,
    END_CUSTOMER_ACCOUNT_NAME,
    DDR_STATUS
];

const ALLOWED_STATUSES = [
    'Pre-Approved',
    'Design in Review'
];

const COLUMNS = [
    {
        label: 'Account Name',
        fieldName: 'accountName',
        type: 'text',
        wrapText: true,
        initialWidth: 240
    },
    {
        label: 'Country',
        fieldName: 'billingCountry',
        type: 'text',
        initialWidth: 140
    },
    {
        label: 'Website',
        fieldName: 'website',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'website'
            },
            target: '_blank'
        },
        initialWidth: 220
    },
    {
        label: 'Partner Role',
        fieldName: 'partnerRole',
        type: 'text',
        initialWidth: 160
    },
    {
        label: 'IPA Status',
        fieldName: 'ipaStatus',
        type: 'text',
        initialWidth: 110
    },
    {
        label: 'Account Owner',
        fieldName: 'ownerName',
        type: 'text',
        initialWidth: 180
    }
];

export default class CoreEndCustomerAccountSearch
    extends LightningElement {

    @api recordId;

    columns = COLUMNS;
    accounts = [];
    selectedRows = [];

    recordData;
    customerName;
    customerCountry;
    customerWebsite;
    currentStatus;
    selectedAccountId;
    selectedAccountName;

    isLoading = false;
    searchCompleted = false;

    @wire(
        getRecord,
        {
            recordId: '$recordId',
            fields: RECORD_FIELDS
        }
    )
    wiredRecord({ data, error }) {

        if (data) {
            this.recordData = data;

            this.customerName =
                getFieldValue(
                    data,
                    END_CUSTOMER_NAME
                );

            this.customerCountry =
                getFieldValue(
                    data,
                    END_CUSTOMER_COUNTRY
                );

            this.customerWebsite =
                getFieldValue(
                    data,
                    END_CUSTOMER_WEBSITE
                );

            this.currentStatus =
                getFieldValue(
                    data,
                    DDR_STATUS
                );

            this.selectedAccountId =
                getFieldValue(
                    data,
                    END_CUSTOMER_ACCOUNT
                );

            this.selectedAccountName =
                getFieldValue(
                    data,
                    END_CUSTOMER_ACCOUNT_NAME
                );

            this.selectedRows =
                this.selectedAccountId
                    ? [this.selectedAccountId]
                    : [];

        } else if (error) {
            this.showError(error);
        }
    }

    get customerNameDisplay() {
        return this.customerName || 'Not provided';
    }

    get customerCountryDisplay() {
        return this.customerCountry || 'Not provided';
    }

    get customerWebsiteDisplay() {
        return this.customerWebsite || 'Not provided';
    }

    get selectionAllowed() {
        return ALLOWED_STATUSES.includes(
            this.currentStatus
        );
    }

    get hasSelectedAccount() {
        return Boolean(
            this.selectedAccountId
        );
    }

    get hasResults() {
        return this.accounts.length > 0;
    }

    get resultCountLabel() {
        const count = this.accounts.length;

        return count === 1
            ? '1 result'
            : `${count} results`;
    }

    get searchDisabled() {
        return (
            this.isLoading ||
            !this.customerName
        );
    }

    async handleSearch() {

        this.isLoading = true;
        this.searchCompleted = false;
        this.accounts = [];

        try {
            this.accounts = await searchAccounts({
                customerName:
                    this.customerName,
                customerCountry:
                    this.customerCountry,
                customerWebsite:
                    this.customerWebsite
            });

            this.searchCompleted = true;

            this.selectedRows =
                this.selectedAccountId
                    ? [this.selectedAccountId]
                    : [];

        } catch (error) {
            this.showError(error);

        } finally {
            this.isLoading = false;
        }
    }

    async handleRowSelection(event) {

        const selectedRecords =
            event.detail.selectedRows;

        if (
            !selectedRecords ||
            selectedRecords.length === 0
        ) {
            return;
        }

        const selectedAccount =
            selectedRecords[0];

        /*
         * Do nothing if the currently saved Account
         * was selected again.
         */
        if (
            selectedAccount.accountId ===
            this.selectedAccountId
        ) {
            return;
        }

        this.isLoading = true;

        try {
            const fields = {};

            fields.Id = this.recordId;

            fields[
                END_CUSTOMER_ACCOUNT.fieldApiName
            ] = selectedAccount.accountId;

            await updateRecord({
                fields
            });

            this.selectedAccountId =
                selectedAccount.accountId;

            this.selectedAccountName =
                selectedAccount.accountName;

            this.selectedRows = [
                selectedAccount.accountId
            ];

            await notifyRecordUpdateAvailable([
                {
                    recordId: this.recordId
                }
            ]);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message:
                        'End Customer Account was updated to ' +
                        selectedAccount.accountName +
                        '.',
                    variant: 'success'
                })
            );

        } catch (error) {
            this.showError(error);

            this.selectedRows =
                this.selectedAccountId
                    ? [this.selectedAccountId]
                    : [];

        } finally {
            this.isLoading = false;
        }
    }

    showError(error) {

        let message =
            'An unexpected error occurred.';

        if (error?.body?.message) {
            message = error.body.message;

        } else if (
            Array.isArray(error?.body)
        ) {
            message = error.body
                .map((item) => item.message)
                .join(', ');

        } else if (error?.message) {
            message = error.message;
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message,
                variant: 'error'
            })
        );
    }
}