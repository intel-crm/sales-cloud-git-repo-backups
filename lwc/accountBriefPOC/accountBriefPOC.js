import { LightningElement, api, track } from 'lwc';
import getChildRecords from '@salesforce/apex/AccountBriefSummaryController.getChildRecords'; // Apex method to fetch child records
import saveChildRecords from '@salesforce/apex/AccountBriefSummaryController.saveChildRecords'; // Apex method to save child records
import generatePDF from '@salesforce/apex/AccountBriefSummaryController.generatePDF'; // Apex method to generate PDF

export default class DynamicRowsComponent extends LightningElement {
    @api recordId; // Parent record ID
    @track rows = []; // Array of rows to dynamically add
    @track childRecords = []; // Child records fetched from Apex
    rowId = 1; // Counter to generate unique row IDs

    // Fetch child records attached to the parent record
    connectedCallback() {
        this.fetchChildRecords();
    }

    // Fetch child records via Apex
    fetchChildRecords() {
        getChildRecords({ parentId: this.recordId })
            .then((result) => {
                this.childRecords = result || [];
            })
            .catch((error) => {
                console.error('Error fetching child records', error);
            });
    }

    // Method to add a new row with empty fields
    handleAddRow() {
        const newRow = { 
            id: this.rowId++, 
            Account_Brief_Summary__c: '', 
            Meeting_Invite__c: '', 
            Attendees__c: '' 
        };
        this.rows = [...this.rows, newRow]; // Add the new row to the array
    }

    // Handle input field changes and update the respective row
    handleFieldChange(event) {
        const field = event.target.dataset.field;
        const rowId = parseInt(event.target.dataset.id, 10);
        const value = event.target.value;

        // Find the index of the row to update
        const rowIndex = this.rows.findIndex((row) => row.id === rowId);
        if (rowIndex !== -1) {
            const updatedRow = { ...this.rows[rowIndex], [field]: value };
            this.rows = [
                ...this.rows.slice(0, rowIndex), 
                updatedRow, 
                ...this.rows.slice(rowIndex + 1)
            ]; // Replace the updated row in the array
        }
    }

    // Save the newly added rows to the parent object
    handleSave() {
        saveChildRecords({ parentId: this.recordId, rows: this.rows })
            .then(() => {
                // Clear the rows after successful save, maintaining the initial empty state
                this.rows = [];
                this.fetchChildRecords(); // Refresh the child records from Apex
                console.log('Rows saved successfully.');
            })
            .catch((error) => {
                console.error('Error saving rows', error);
            });
    }
     // Method to download PDF
     handleDownloadPDF() {
        generatePDF({ parentId: this.recordId })
            .then((pdfUrl) => {
                // Open the PDF in a new window to initiate the download
                window.open(pdfUrl, '_blank');
            })
            .catch((error) => {
                console.error('Error generating PDF:', error);
            });
    }
}