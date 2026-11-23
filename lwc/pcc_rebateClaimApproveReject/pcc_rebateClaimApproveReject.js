import { LightningElement, api, track } from 'lwc';

export default class pcc_rebateClaimApproveReject extends LightningElement {
    @api recordId; // Record Id passed from Aura component
    @track showModal = true;
    @track records = [];
    @track columns = [];
    @track selectedRows = [];
    @track draftValues = [];
    @track isSaveDisabled = true;

    openModal() {
        // Populate records (dummy data for example)
        this.records = [
            { Id: '001', Name: 'Record 1', Approve__c: false, Reject__c: false },
            { Id: '002', Name: 'Record 2', Approve__c: false, Reject__c: false },
            { Id: '003', Name: 'Record 3', Approve__c: false, Reject__c: false }
        ];

        // Define columns for the datatable
        this.columns = [
            { label: 'Name', fieldName: 'Name', type: 'text', editable: true },
            { label: 'Approve', fieldName: 'Approve__c', type: 'boolean', editable: true },
            { label: 'Reject', fieldName: 'Reject__c', type: 'boolean', editable: true }
        ];

        // Show the modal popup
        this.showModal = true;
    }

    closeModal() {
        // Hide the modal popup
        this.showModal = false;
    }

    handleRowSelection(event) {
        // Enable/disable Save button based on row selection
        this.selectedRows = event.detail.selectedRows;

        if (this.selectedRows.length > 0) {
            this.isSaveDisabled = false;
        } else {
            this.isSaveDisabled = true;
        }
    }

    handleSave() {
        // Handle saving selected rows or draftValues if inline editing is enabled
        // Implement your save logic here

        // Close the modal after save
        this.showModal = false;
    }
}