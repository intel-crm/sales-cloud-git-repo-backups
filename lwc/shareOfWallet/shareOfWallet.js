import { LightningElement, track, api } from 'lwc';
import saveShareOfWalletData from '@salesforce/apex/CRM_ShareOfWalletController.saveShareOfWalletData';
import getShareOfWalletData from '@salesforce/apex/CRM_ShareOfWalletController.getShareOfWalletData';
import getDashboardId from '@salesforce/apex/CRM_ShareOfWalletController.getDashboardId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ShareOfWallet extends LightningElement {
    @track rows = [];
    rowId = 0;
    @api dashboardId;  // Public property to accept the dashboardId dynamically
    dashboardUrl = '';  // Initialize the dashboardUrl property

    // Options for "With" picklist
    withOptions = [
        { label: '--None--', value: '' },
        { label: 'Us', value: 'Us' },
        { label: 'Executes Internally', value: 'Executes Internally' },
        { label: 'Competitor', value: 'Competitor' },
        { label: 'Unknown', value: 'Unknown' },
        { label: "Don't Do", value: "Don't Do" }
    ];

    // Fetch existing rows and dashboard ID on component load
    connectedCallback() {
        this.fetchRows();
        this.fetchDashboardId(); // Fetch the dashboard ID
    }

    // Fetch the dashboard ID
    fetchDashboardId() {
        getDashboardId()
            .then(result => {
                this.dashboardId = result; // Set the dashboardId from the Apex result
                console.log('Fetched Dashboard ID:', this.dashboardId);
            })
            .catch(error => {
                console.error('Error fetching dashboard ID:', error);
                this.showToast('Error', 'Failed to load dashboard ID. Please try again.', 'error');
            });
    }
    
    get dashboardUrl() {
        if (this.dashboardId) {
            console.log('Dashboard ID exists, URL will be set');
            return `/lightning/r/Dashboard/${this.dashboardId}/view`;
        }
        return ''; // Return an empty string if dashboardId is not set
    }

    // Fetch Share of Wallet data
    fetchRows() {
        getShareOfWalletData()
            .then(data => {
                this.rows = data.map(record => ({
                    id: record.Id,
                    year: record.Year__c || '',
                    offering: record.Offering__c || '',
                    spend: record.Spend__c || '',
                    with: record.With__c || '',
                    competitor: record.Competitor__c || '',
                    contractEndDate: record.Contract_End_Date__c || '',
                    comments: record.Comments__c || ''
                }));
                this.updateRowId();
            })
            .catch(error => {
                console.error('Error fetching data:', error);
                this.showToast('Error', 'Failed to load data. Please try again.', 'error');
            });
    }

    updateRowId() {
        // Ensure rowId is always higher than existing row IDs
        const maxId = this.rows.reduce((max, row) => {
            const id = parseInt(row.id, 10);
            return !isNaN(id) && id > max ? id : max;
        }, 0);
        this.rowId = maxId;
    }

    handleAddRow() {
        this.rows = [
            ...this.rows,
            {
                id: ++this.rowId,
                year: '',
                offering: '',
                spend: '',
                with: '',
                competitor: '',
                contractEndDate: '',
                comments: ''
            }
        ];
    }

    handleDeleteRow(event) {
        const rowId = event.target.dataset.id;

        // Check if rowId is a Salesforce ID or a temporary local ID
        this.rows = this.rows.filter(row => row.id !== rowId && row.id !== parseInt(rowId, 10));
    }

    handleInputChange(event) {
        const { field, id } = event.target.dataset;
        const value = event.target.value;

        this.rows = this.rows.map(row =>
            row.id === parseInt(id) || row.id === id ? { ...row, [field]: value } : row
        );
    }

    handleSave() {
        const recordsToSave = this.rows.map(row => ({
            Id: row.id && String(row.id).startsWith('a') ? row.id : null,
            Year__c: row.year,
            Offering__c: row.offering,
            Spend__c: row.spend,
            With__c: row.with,
            Competitor__c: row.competitor,
            Contract_End_Date__c: row.contractEndDate,
            Comments__c: row.comments
        }));

        saveShareOfWalletData({ sowRecords: recordsToSave })
            .then(() => {
                this.showToast('Success', 'Share of Wallet data saved successfully!', 'success');
                this.fetchRows(); // Reload rows after saving
            })
            .catch(error => {
                console.error('Error saving data:', error);
                const message = error.body && error.body.message ? error.body.message : 'Failed to save data';
                this.showToast('Error', message, 'error');
            });
    }

    handleCancel() {
        this.fetchRows(); // Reload original data on cancel
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}