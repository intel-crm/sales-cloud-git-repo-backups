import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import createPDO from '@salesforce/apex/PRMCreatePdoFromLead.createPDO';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

const LEAD_FIELDS = [
    'Lead.Email',
    'Lead.Website',
    'Lead.Company',
    'Lead.Core_CountryLabel__c'
];

export default class PRMCreatePdoFromLead extends LightningElement {

    @api recordId;

    // Lead fields
    email = '';
    website = '';
    company = '';
    country = '';

    // Manually entered fields
    opportunityName = '';
    opportunitySummary = '';
    estimatedBudget = '';

    isLoading = false;

    // Retrieve Lead fields
    @wire(getRecord, {
        recordId: '$recordId',
        fields: LEAD_FIELDS
    })
    wiredLead({ error, data }) {

        if (data) {
            this.email = data.fields.Email.value || '';
            this.website = data.fields.Website.value || '';
            this.company = data.fields.Company.value || '';
            this.country =
                data.fields.Core_CountryLabel__c.value || '';
        } else if (error) {
            this.showToast(
                'Error',
                'Unable to retrieve Lead information.',
                'error'
            );
        }
    }

    // Lead field handlers
    handleEmailChange(event) {
        this.email = event.target.value;
    }

    handleWebsiteChange(event) {
        this.website = event.target.value;
    }

    handleCompanyChange(event) {
        this.company = event.target.value;
    }

    handleCountryChange(event) {
        this.country = event.target.value;
    }

    // Manual field handlers
    handleOpportunityNameChange(event) {
        this.opportunityName = event.target.value;
    }

    handleOpportunitySummaryChange(event) {
        this.opportunitySummary = event.target.value;
    }

    handleEstimatedBudgetChange(event) {
        this.estimatedBudget = event.target.value;
    }

    // Save PDO
    handleSave() {

        const inputs = [
            ...this.template.querySelectorAll(
                'lightning-input, lightning-textarea'
            )
        ];

        const isValid = inputs.reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        if (!isValid) {
            return;
        }

        this.isLoading = true;

        const request = {
            leadId: this.recordId,
            email: this.email,
            website: this.website,
            company: this.company,
            country: this.country,
            opportunityName: this.opportunityName,
            opportunitySummary: this.opportunitySummary,
            estimatedBudget: Number(this.estimatedBudget)
        };

        createPDO({ request: request })
            .then(pdoId => {
                this.showToast(
                    'Success',
                    'PDO record created successfully.',
                    'success'
                );

                this.dispatchEvent(
                    new CloseActionScreenEvent()
                );
            })
            .catch(error => {
                this.showToast(
                    'Error',
                    error.body?.message ||
                    'Error creating PDO record.',
                    'error'
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleCancel() {
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}