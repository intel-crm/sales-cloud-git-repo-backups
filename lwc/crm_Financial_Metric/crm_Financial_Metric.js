import { LightningElement, track, api } from 'lwc';
import getFinancialMetrics from '@salesforce/apex/FinancialMetricController.getFinancialMetrics';
import saveFinancialMetrics from '@salesforce/apex/FinancialMetricController.saveFinancialMetrics';
import getYearPicklistValues from '@salesforce/apex/FinancialMetricController.getYearPicklistValues';
import getMetricTypePicklistValues from '@salesforce/apex/FinancialMetricController.getMetricTypePicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

let rowIdCounter = 1;

export default class FinancialMetricsTable extends LightningElement {
    @api recordId;
    @track metrics = [];
    @track yearOptions = [];
    @track metricOptions = [];

    connectedCallback() {
        this.loadPicklistValues();
        this.loadMetrics();
    }

    loadPicklistValues() {
        getYearPicklistValues().then(result => {
            this.yearOptions = result.map(item => ({ label: item, value: item }));
        });

        getMetricTypePicklistValues().then(result => {
            this.metricOptions = result.map(item => ({ label: item, value: item }));
        });
    }

    loadMetrics() {
        getFinancialMetrics({ accountPlanId: this.recordId })
            .then(result => {
                this.metrics = result.map((item, index) => ({
                    id: item.Id || `temp-${index + 1}`,
                    CRM_Year__c: item.CRM_Year__c,
                    CRM_Metric__c: item.CRM_Metric__c,
                    CRM_Value__c: item.CRM_Value__c,
                    CRM_Account_Plan__c: this.recordId
                }));
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error loading data',
                    message: error.body.message,
                    variant: 'error'
                }));
            });
    }

    handleAddRow() {
        this.metrics = [
            ...this.metrics,
            {
                id: `temp-${rowIdCounter++}`,
                CRM_Year__c: '',
                CRM_Metric__c: '',
                CRM_Value__c: null,
                CRM_Account_Plan__c: this.recordId
            }
        ];
    }

    handleFieldChange(event) {
        const field = event.target.dataset.field;
        const rowId = event.target.dataset.id;
        const value = event.target.value;

        this.metrics = this.metrics.map(row => {
            if (row.id === rowId) {
                return { ...row, [field]: value };
            }
            return row;
        });
    }

    handleSave() {
        const metricsToSave = this.metrics.map(({ id, ...fields }) => ({
            ...fields,
            CRM_Account_Plan__c: this.recordId
        }));

        saveFinancialMetrics({ metrics: metricsToSave })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Financial metrics saved successfully',
                    variant: 'success'
                }));
                this.loadMetrics();
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error saving metrics',
                    message: error.body.message,
                    variant: 'error'
                }));
                console.error('Save error:', JSON.stringify(error));
            });
    }
}