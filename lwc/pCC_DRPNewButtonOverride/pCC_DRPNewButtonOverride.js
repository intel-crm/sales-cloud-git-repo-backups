import { LightningElement, api, wire ,track} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

// Import the necessary fields for the "Core_Design_Registration_Product__c" object
import CORE_ACTIVE_STATUS_FIELD from '@salesforce/schema/Core_Design_Registration_Product__c.Core_Active_Status__c';
import CORE_DR_ELIGIBLE_STATUS_FIELD from '@salesforce/schema/Core_Design_Registration_Product__c.Core_DR_Eligible_Status__c';
import CORE_LOCKED_IND_FIELD from '@salesforce/schema/Core_Design_Registration_Product__c.Core_Locked_Ind__c';
import CORE_THROW_VALIDATION_FIELD from '@salesforce/schema/Core_Design_Registration_Product__c.Core_ThrowValidation__c';
import CREATED_DATE_FIELD from '@salesforce/schema/Core_Design_Registration_Product__c.CreatedDate';
import ID_FIELD from '@salesforce/schema/Core_Design_Registration_Product__c.Id';
import IS_DELETED_FIELD from '@salesforce/schema/Core_Design_Registration_Product__c.IsDeleted';
import LAST_MODIFIED_DATE_FIELD from '@salesforce/schema/Core_Design_Registration_Product__c.LastModifiedDate';
import NAME_FIELD from '@salesforce/schema/Core_Design_Registration_Product__c.Name';
import SYSTEM_MODSTAMP_FIELD from '@salesforce/schema/Core_Design_Registration_Product__c.SystemModstamp';

export default class PCC_DRPNewButtonOverride extends LightningElement {
    @api recordId;
    fieldValues = [];
    @track designRegistration = '';
    @track productO = '';
    @track quantity = '';
    @track targetResalePrice = '';
    @track targetResalePriceNote = '';
    @track oemName = '';
    @track writeInOemName = '';
    @track competitorName = '';
    @track competitorOemName = '';
    @track competitorSystemModel = '';
    @track competitorWriteInOemName = '';
    @track writeInCompetitorProduct = '';

    @track showModal = true;

    handleCancel() {
        this.showModal = false;
    }
    // Retrieve record data dynamically
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            CORE_ACTIVE_STATUS_FIELD,
            CORE_DR_ELIGIBLE_STATUS_FIELD,
            CORE_LOCKED_IND_FIELD,
            CORE_THROW_VALIDATION_FIELD,
            CREATED_DATE_FIELD,
            ID_FIELD,
            IS_DELETED_FIELD,
            LAST_MODIFIED_DATE_FIELD,
            NAME_FIELD,
            SYSTEM_MODSTAMP_FIELD
        ]
    })
    wiredRecord({ error, data }) {
        if (data) {
            this.fieldValues = [
                { fieldApiName: CORE_ACTIVE_STATUS_FIELD.fieldApiName, label: 'Active Status', type: 'checkbox', required: true, value: getFieldValue(data, CORE_ACTIVE_STATUS_FIELD) },
                { fieldApiName: CORE_DR_ELIGIBLE_STATUS_FIELD.fieldApiName, label: 'DR Eligible Status', type: 'checkbox', required: true, value: getFieldValue(data, CORE_DR_ELIGIBLE_STATUS_FIELD) },
                { fieldApiName: CORE_LOCKED_IND_FIELD.fieldApiName, label: 'Locked', type: 'checkbox', required: true, value: getFieldValue(data, CORE_LOCKED_IND_FIELD) },
                { fieldApiName: CORE_THROW_VALIDATION_FIELD.fieldApiName, label: 'Core_ThrowValidation', type: 'checkbox', required: true, value: getFieldValue(data, CORE_THROW_VALIDATION_FIELD) },
                { fieldApiName: CREATED_DATE_FIELD.fieldApiName, label: 'Created Date', type: 'datetime', required: true, value: getFieldValue(data, CREATED_DATE_FIELD) },
                { fieldApiName: ID_FIELD.fieldApiName, label: 'Record ID', type: 'id', required: true, value: getFieldValue(data, ID_FIELD) },
                { fieldApiName: IS_DELETED_FIELD.fieldApiName, label: 'Deleted', type: 'checkbox', required: true, value: getFieldValue(data, IS_DELETED_FIELD) },
                { fieldApiName: LAST_MODIFIED_DATE_FIELD.fieldApiName, label: 'Last Modified Date', type: 'datetime', required: true, value: getFieldValue(data, LAST_MODIFIED_DATE_FIELD) },
                { fieldApiName: NAME_FIELD.fieldApiName, label: 'Design Registration Line ID', type: 'text', required: true, value: getFieldValue(data, NAME_FIELD) },
                { fieldApiName: SYSTEM_MODSTAMP_FIELD.fieldApiName, label: 'System Modstamp', type: 'datetime', required: true, value: getFieldValue(data, SYSTEM_MODSTAMP_FIELD) }
            ];
        } else if (error) {
            // Handle error
        }
    }

    // Handle changes to input fields
    handleChange(event) {
        const fieldApiName = event.target.name;
        const value = event.target.value;

        // Update the corresponding field value
        const updatedFieldValues = this.fieldValues.map(field => {
            if (field.fieldApiName === fieldApiName) {
                return { ...field, value };
            }
            return field;
        });

        this.fieldValues = updatedFieldValues;
    }

    // Handle the save button click
    handleSave() {
        this.showModal = false;
        // Implement logic to save the data (use Apex or any other suitable method)
        // You can access the field values from this.fieldValues array
    }
}