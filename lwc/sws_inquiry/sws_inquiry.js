import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, createRecord } from 'lightning/uiRecordApi';
import { getListUi } from 'lightning/uiListApi';
import { refreshApex } from '@salesforce/apex';
import SWS_CLOUD_CREDIT_REQUEST_OBJECT from '@salesforce/schema/SWS_Cloud_Credit_Request__c';

export default class SwsInquiry extends LightningElement {
    @api columns; 
    @track records = [];
    @track draftValues = [];
    wiredRecordsResult;
    @track listViews = [];
    @track selectedListView = 'Inquiry_List'; // Default list view

    //Default Columns
    defaultColumns = [
        { 
            label: 'Cloud Credit Request Name', 
            fieldName: 'recordUrl', 
            type: 'url', 
            typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } 
        },
        { label: 'First Name', fieldName: 'SWS_First_Name__c', type: 'text', editable: true },
        { label: 'Last Name', fieldName: 'SWS_Last_Name__c', type: 'text', editable: true },
        { label: 'Customer Email Address', fieldName: 'SWS_Email__c', type: 'email', editable: true },
        { label: 'Email Verification', fieldName: 'SWS_Email_Verification_fm__c', type: 'text', editable: true },
        { label: 'Company Name', fieldName: 'SWS_Company_Name__c', type: 'text', editable: true },
        { label: 'Use Case', fieldName: 'SWS_Use_Case__c', type: 'text', editable: true },
        { label: 'Replied Back', fieldName: 'SWS_Replied_back__c', type: 'boolean', editable: true }
    ];

    // Use columns property if provided, otherwise use defaultColumns
    get tableColumns() {
        return this.columns ? JSON.parse(this.columns) : this.defaultColumns;
    }

    // Fetch list views dynamically
    @wire(getListUi, { objectApiName: SWS_CLOUD_CREDIT_REQUEST_OBJECT })
    wiredListViews({ error, data }) {
        if (data) {
            this.listViews = data.lists.map(view => ({
                label: view.label,
                value: view.apiName
            }));
        } else if (error) {
            this.showToast('Error', 'Failed to load list views', 'error');
            console.error(error);
        }
    }

    // Fetch records based on selected list view
    @wire(getListUi, { 
        objectApiName: SWS_CLOUD_CREDIT_REQUEST_OBJECT, 
        listViewApiName: '$selectedListView',
         pageSize: 200
    })
    wiredListView(result) {
        this.wiredRecordsResult = result;
        if (result.data) {
            this.records = result.data.records.records.map(record => ({
                Id: record.id,
                Name: record.fields.Name.value,
                recordUrl: `/lightning/r/SWS_Cloud_Credit_Request__c/${record.id}/view`,
                SWS_First_Name__c: record.fields.SWS_First_Name__c.value,
                SWS_Last_Name__c: record.fields.SWS_Last_Name__c.value,
                SWS_Email__c: record.fields.SWS_Email__c.value,
                SWS_Email_Verification_fm__c: record.fields.SWS_Email_Verification_fm__c.value,
                SWS_Company_Name__c: record.fields.SWS_Company_Name__c.value,
                SWS_Use_Case__c: record.fields.SWS_Use_Case__c.value,
                SWS_Replied_back__c: record.fields.SWS_Replied_back__c.value
            }));
        } else if (result.error) {
            this.showToast('Error', 'Error fetching records', 'error');
        }
    }

    // Handle list view change
    handleListViewChange(event) {
        this.selectedListView = event.detail.value;
    }

    // Handle inline editing
    handleSave(event) {
        const recordInputs = event.detail.draftValues.map(draft => ({
            fields: { Id: draft.Id, ...draft }
        }));

        Promise.all(recordInputs.map(recordInput => updateRecord(recordInput)))
            .then(() => {
                this.showToast('Success', 'Records updated successfully', 'success');
                this.draftValues = [];
                return refreshApex(this.wiredRecordsResult);
            })
            .catch(error => {
                this.showToast('Error', 'Error updating records', 'error');
                console.error(error);
            });
    }

    // Handle new record creation
    handleNewRecord() {
        const fields = { Name: 'New Inquiry' };
        const recordInput = { apiName: 'SWS_Cloud_Credit_Request__c', fields };

        createRecord(recordInput)
            .then(() => {
                this.showToast('Success', 'Record created successfully', 'success');
                return refreshApex(this.wiredRecordsResult);
            })
            .catch(error => {
                this.showToast('Error', 'Error creating record', 'error');
                console.error(error);
            });
    }

    // Show toast notifications
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}