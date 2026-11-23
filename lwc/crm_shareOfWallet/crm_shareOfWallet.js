import { LightningElement, api, wire, track } from 'lwc';
import getShareOfWalletData from '@salesforce/apex/CRM_ShareOfWalletController.getShareOfWalletData';
import saveShareOfWalletData from '@salesforce/apex/CRM_ShareOfWalletController.saveShareOfWalletData';
import deleteShareOfWalletRecord from '@salesforce/apex/CRM_ShareOfWalletController.deleteShareOfWalletRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class crmShareOfWallet extends LightningElement {
    @api recordId;
    @track rows = [];
    wiredSowData;

    withOptions = [
        { label: '--None--', value: '' },
        { label: 'Us', value: 'Us' },
        { label: 'Executes Internally', value: 'Executes Internally' },
        { label: 'Competitor', value: 'Competitor' },
        { label: 'Unknown', value: 'Unknown' },
        { label: "Don't Do", value: "Don't Do" }
    ];

    offeringOptions = [
        { label: 'Creative Services', value: 'Creative Services' },
        { label: 'Direct Mail', value: 'Direct Mail' },
        { label: 'Digital Marketing', value: 'Digital Marketing' },
        { label: 'SEO', value: 'SEO' },
        { label: 'Web Development', value: 'Web Development' },
        { label: 'Print Large Format', value: 'Print Large Format' },
    ];

    @wire(getShareOfWalletData, { recordId: '$recordId' })
    wiredData(result) {
        this.wiredSowData = result;
        const { data, error } = result;
        if (data) {
            this.rows = data.map(record => ({
                id: record.Id,
                year: record.CRM_Year__c || '',
                offering: record.CRM_Offering__c || '',
                spend: record.CRM_Spend__c || '',
                with: record.CRM_With__c || '',
                competitor: record.CRM_Competitor__c || '',
                contractEndDate: record.CRM_Contract_End_Date__c || '',
                comments: record.CRM_Comments__c || ''
            }));

            if (this.rows.length === 0) {
                this.addDummyRow();
            }
        } else if (error) {
            this.showToast('Error', 'Failed to load data', 'error');
            console.error('Error fetching data:', error);
        }
    }

    addDummyRow() {
        this.rows = [{
            id: 'dummy_' + Date.now(),
            year: '',
            offering: '',
            spend: '',
            with: '',
            competitor: '',
            contractEndDate: '',
            comments: ''
        }];
    }

    handleInputChange(event) {
        const { field, id } = event.target.dataset;
        const value = event.target.value;

        this.rows = this.rows.map(row =>
            row.id === id ? { ...row, [field]: value } : row
        );
    }

    handleAddRow() {
        this.rows = [...this.rows, {
            id: 'new_' + Date.now(),
            year: '',
            offering: '',
            spend: '',
            with: '',
            competitor: '',
            contractEndDate: '',
            comments: ''
        }];
    }

    handleDeleteRow(event) {
        const rowId = event.target.dataset.id;
        if (rowId.startsWith('dummy_')) return;

        deleteShareOfWalletRecord({ recordId: rowId })
            .then(() => refreshApex(this.wiredSowData))
            .catch(error => console.error('Error deleting record:', error));

        this.rows = this.rows.filter(row => row.id !== rowId);
    }

    handleSave() {
        const recordsToSave = this.rows
            .filter(row => row.id.startsWith('dummy_') ? Object.values(row).some(value => value !== '') : true)
            .map(row => ({
                Id: row.id.startsWith('dummy_') || row.id.startsWith('new_') ? null : row.id,
                CRM_Year__c: row.year,
                CRM_Offering__c: row.offering,
                CRM_Spend__c: row.spend,
                CRM_With__c: row.with,
                CRM_Competitor__c: row.competitor,
                CRM_Contract_End_Date__c: row.contractEndDate,
                CRM_Comments__c: row.comments,
                CRM_Account_Plan__c: this.recordId
            }));
    
        if (recordsToSave.length === 0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning',
                message: 'No valid data to save',
                variant: 'warning'
            }));
            return;
        }
    
        saveShareOfWalletData({ sowRecords: recordsToSave })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Data saved successfully',
                    variant: 'success'
                }));
    
                setTimeout(() => {
                    window.location.reload(); // ✅ Refresh the page after saving
                }, 1000);
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to save data',
                    variant: 'error'
                }));
                console.error('Error saving data:', error);
            });
    }
    
    
}