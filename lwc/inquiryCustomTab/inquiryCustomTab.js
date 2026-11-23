import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, createRecord,getRecord} from 'lightning/uiRecordApi';
import Inquiry from '@salesforce/schema/SWS_Cloud_Credit_Request__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecordTypeId } from 'lightning/uiObjectInfoApi';

export default class InquiryCustomTab extends LightningElement {
    @api objectApiName; // API name of the object
    @api columns; // Configurable columns
    @api recordTypeId; // Record Type ID
    @track records = []; // Data for the table
    @track draftValues = []; // Draft values for inline editing

    Inquiries = [];
    error;

    @wire(getObjectInfo, { objectApiName: Inquiry })
    objectInfo({ data, error }) {
        if (data) {
            // Example of static record type for filtering purposes
            this.recordTypeId = data.recordTypeInfos['Inquiry'].recordTypeId;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getRecord, {})
    wiredContacts({ error, data }) {
        if (data) {
            // Filter records by the specific record type id
            this.Inquiries = data.records.filter(inq => inq.RecordTypeId === this.recordTypeId);
            this.error = undefined;
        } else if (error) {
            this.Inquiries = undefined;
            this.error = error;
        }
    }

    /*connectedCallback() {
        // Fetch records from the server (mocked here)
        this.fetchRecords();
    }*/

    fetchRecords() {
        // Mock data fetching
        this.records = [
            { Id: '1', Name: 'Record 1', Field1: 'Value 1', Field2: 'Value 2' },
            { Id: '2', Name: 'Record 2', Field1: 'Value 3', Field2: 'Value 4' }
        ];
    }

    handleSave(event) {
        const recordInputs = event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });

        const promises = recordInputs.map(recordInput => updateRecord(recordInput));

        Promise.all(promises)
            .then(() => {
                this.showToast('Success', 'Records updated successfully', 'success');
                this.draftValues = [];
                this.fetchRecords();
            })
            .catch(error => {
                this.showToast('Error', 'Error updating records', 'error');
            });
    }

    handleNewRecord() {
        const fields = { Name: 'New Record' }; // Add default values if needed
        if (this.recordTypeId) {
            fields.RecordTypeId = this.recordTypeId;
        }
        const recordInput = { apiName: this.objectApiName, fields };
        createRecord(recordInput)
            .then(() => {
                this.showToast('Success', 'Record created successfully', 'success');
                this.fetchRecords();
            })
            .catch(error => {
                this.showToast('Error', 'Error creating record', 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}