import { LightningElement,track,api,wire } from 'lwc';
import getVirtualAndNodeAccount from '@salesforce/apex/Core_MDF_OutcomeContribution_Controller.getVirtualAndNodeAccount';


export default class Core_MDF_OutcomeContribution_Breakdown extends LightningElement {


     @api recordId; // Automatically available when used on a record page
    @track accountNames = [];
    hardcodedId = '0CwDz000000ClDxKAK'; // 👈 your hardcoded Id
        totalAmount = 1000;

   connectedCallback() {
        // Call Apex method with hardcoded Id
        this.loadAccountNames();
    }

    loadAccountNames() {
        getVirtualAndNodeAccount({ recordId: this.hardcodedId })
            .then(result => {
                // Convert list of names into combobox options
                this.accountNames = result.map(name => ({ label: name, value: name }));
                console.log('Account options:', this.accountNames);
            })
            .catch(error => {
                console.error('Error fetching data:', error);
            });
    }

     @track contributions = [
        { id: 1, accountNode: '', amount: null, percent: null }
    ];
   
    get showDelete() {
        return this.contributions.length > 1;
    }

    // Handle account selection
    handleAccountChange(event) {
        const id = event.target.dataset.id;
        const value = event.detail.value;
        this.updateRow(id, { accountNode: value });
    }

    // When Amount changes → auto-calc Percent
    handleAmountChange(event) {
        const id = event.target.dataset.id;
        const amount = parseFloat(event.target.value) || 0;
        const percent = ((amount / this.totalAmount) * 100).toFixed(2);
        this.updateRow(id, { amount, percent });
    }

    // When Percent changes → auto-calc Amount
    handlePercentChange(event) {
        const id = event.target.dataset.id;
        const percent = parseFloat(event.target.value) || 0;
        const amount = ((percent / 100) * this.totalAmount).toFixed(2);
        this.updateRow(id, { percent, amount });
    }

    // Add a new row
    handleAddRow() {
        const newId = this.contributions.length + 1;
        this.contributions = [
            ...this.contributions,
            { id: newId, accountNode: '', amount: null, percent: null }
        ];
    }

    // Delete a row
    handleDeleteRow(event) {
        const id = event.target.dataset.id;
        this.contributions = this.contributions.filter(row => row.id != id);
    }

    // Helper to update a row reactively
    updateRow(id, updates) {
        this.contributions = this.contributions.map(row =>
            row.id == id ? { ...row, ...updates } : row
        );
    }


}