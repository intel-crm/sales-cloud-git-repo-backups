import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getNewColumns from '@salesforce/apex/PCC_ChangeRequest.getNewColumns';
import createDRP from '@salesforce/apex/PCC_ChangeRequest.createDRP';
import { getFieldValue } from 'lightning/uiRecordApi';


// 

import ADDITIONAL_ATTRIBUTE from '@salesforce/schema/Core_Design_Registration_Product__c.PCC_Product_Additional_Attribute__c';
import PRODUCT from '@salesforce/schema/Product_Additional_Attribute__c.Product__c';


import { getRecord } from 'lightning/uiRecordApi';

// get competitor product name
import COMPETITOR_PRODUCT from '@salesforce/schema/Pricing_Competitor_Product__c.Name';

// get product name
import PRODUCT_NAME from '@salesforce/schema/Product_Additional_Attribute__c.Name';

// get dr name

import DR_NAME from '@salesforce/schema/Core_Design_Registration__c.Name';

const COMPETITOR_FIELDS = [COMPETITOR_PRODUCT];
const PRODUCT_FIELDS = [PRODUCT_NAME];
const DR_FIELDS = [DR_NAME];

export default class PCC_CreateProductComponent extends LightningElement {
    objectApiName = 'Core_Design_Registration_Product__c';

    @api competitorProductId;
    @api productAdditionAttrId;


    @api competitorProductName;
    @api productName;
    @api recordTypeId;
    @api drName;

    @api drId;
    changeRequested = true;
    hideRequested = true;
    @api drpRecord;

    @api newlyaddedrecords;

    validate = false;
    @api rowIndex;
    data;
    customColumns = [];
    columnsnew = [];
    @track fieldsAndErrors = [];

    @track startDateValid = false;
    @track errors = {};
    @track page_errors = [];

    @track dealProductId;

    erroTableColumns = [{ label: 'Field Name', fieldName: 'fieldName', wrapText: true }, { label: 'Error Message', fieldName: 'message', wrapText: true }];


    get unknownerrors() {
        console.log('page_errors', this.page_errors);

        return this.page_errors.length > 0 ? true : false;
    }


    // Wire method to get Competitor Product Name
    @wire(getRecord, { recordId: '$competitorProductId', fields: COMPETITOR_FIELDS })
    wiredCompetitorProduct({ error, data }) {
        if (data) {
            this.competitorProductName = data.fields.Name.value;
        } else if (error) {
            console.error('Error fetching competitor product name', error);
        }
    }

    // Wire method to get Product Name
    @wire(getRecord, { recordId: '$productAdditionAttrId', fields: PRODUCT_FIELDS })
    wiredProduct({ error, data }) {
        if (data) {
            this.productName = data.fields.Name.value;
        } else if (error) {
            console.error('Error fetching product name', error);
        }
    }

    // Wire method to get Design Registration (DR) Name
    @wire(getRecord, { recordId: '$drId', fields: DR_FIELDS })
    wiredDr({ error, data }) {
        if (data) {
            this.drName = data.fields.Name.value;
        } else if (error) {
            console.error('Error fetching DR name', error);
        }
    }


    get pageHasErrors() {
        if (this.fieldsAndErrors.length > 0) {
            return true;
        }
        return false;
    }

    @wire(getNewColumns, { featurename: 'newproductscreen' })
    wiredColumns({ data, error }) {
        if (data) {
            data.map(col => {
                this.customColumns.push(this.createColumns(col));
            });
            this.columnsnew = this.customColumns;
            console.log('columns -->', this.columnsnew);
        }
        if (error) {
            console.log('Error -->', error);

        }
    }

    // create custom columns
    createColumns(col) {
        console.log('COlumns -->', col);
        return {
            label: col.Label__c,
            fieldName: col.WrapperFieldName__c,
            type: col.FieldType__c,
            editable: col.UseFieldName__c ? { fieldName: col.EditColumn__c } : col.EditDefaultValue__c,
            disabled: col.UseFieldName__c ? { fieldName: col.Disabled__c } : col.DisableDefaultValue__c,
            typeAttributes: col.typeAttributes__c != null ? JSON.parse(col.typeAttributes__c) : '',
            initialWidth: col.initialWidth__c,
            wrapText: col.wrapText__c,
            resizable: col.Resizable__c,
            cellAttributes: col.cellAttributes__c != null ? JSON.parse(col.cellAttributes__c) : '',
        };
    }


    handleClosePopup() {
        this.dispatchEvent(new CustomEvent('closecreatescreen'));
    }


    connectedCallback() {
        console.log('create component');
        console.log('DR Id -->', this.drId);
        console.log('products received', this.newlyaddedrecords);
        console.log('selected record', this.drpRecord);
        for (let key in this.drpRecord) {
            this.errors[key] = null;
        }
        console.log('Error -->', this.errors);


    }
    handleError(evt) {
        console.log(evt.detail);
        this.validate = false;
        this.dispatchCustomEvent('close');
    }

    dispatchCustomEvent(eventnm) {
        console.log('event fired');

        this.dispatchEvent(new CustomEvent(eventnm));
    }

    onProductChanged(evt) {
        this.productAdditionAttrId = getFieldValue(evt.target.value, ADDITIONAL_ATTRIBUTE);
        // this.productId = getFieldValue(details, PRODUCT);
        console.log('Field Value -->', this.productAdditionAttrId);
    }

    onCompetitorChange(evt) {
        this.competitorProductId = evt.target.value;
    }

    handleSave(event) {
        // Prevent the default submit
        event.preventDefault();
        this.errors = {};
        this.validate = true;
        this.fieldsAndErrors = [];
        // Gather all the input field values into an object
        const fields = {
            // 'PCC_Change_Requested__c':true,
        };
        const requiredFields = [];

        this.template.querySelectorAll('lightning-input-field').forEach(inputField => {
            fields[inputField.fieldName] = inputField.value;
            this.errors[inputField.fieldName] = null;

            // update errors

            if (inputField.required && !inputField.value) {
                requiredFields.push({
                    fieldName: inputField.fieldName,
                    value: inputField.value
                });
            }
        });

        fields['recordTypeId'] = this.recordTypeId;


        console.log('requiredFields -->', requiredFields);

        // Perform validation
        if (this.validateFields(requiredFields)) {
            // If validation passes, submit the form
            this.drpRecord = fields;
            createDRP({ recordDetails: JSON.stringify(fields) })
                .then(result => {
                    console.log('result -->', result);

                    if (result.saved) {
                        let item = {};
                        for (let key in fields) {
                            item[key] = fields[key];
                        }
                        item.edit = 'Edit';
                        item.delete = 'Delete';
                        this.dispatchCustomEvent('close');

                        this.dispatchEvent(new CustomEvent('readrecord', {
                            detail: {
                                columns: this.columnsnew,
                                data: result.product,
                                index: this.rowIndex,
                                productName: this.productName,
                                drName: this.drName,
                                competitorProdName: this.competitorProductName
                            }
                        }));
                        this.validate = false;

                        this.handleClosePopup();
                    } else {
                        let erroredFields = [];

                        // Iterate over the result wrapper list and populate fields and errors
                        result.wrapperLst.forEach(item => {
                            if (item.fieldName !== null && item.fieldName !== undefined && item.fieldName.length > 0) {
                                console.log('inside 249');

                                item.fieldName.map(field => {
                                    this.errors[field] = item.message;
                                })
                            } else {
                                console.log('inside 255');
                                this.page_errors.push(item.message);
                            }


                            let columns = item.fieldName.join(',');
                            console.log('error columm -->', columns);

                            this.fieldsAndErrors.push({ fieldName: columns, message: item.message });
                            erroredFields.push(item.fieldName);
                        });

                        console.log('Error Values -->', this.errors);

                        // flat array
                        erroredFields = [...erroredFields.flat()];
                        if (this.erroredFields.length > 0 || this.page_errors > 0) {
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Error',
                                message: 'This page contains errors. Please review it.',
                                variant: 'error'
                            }));
                        }
                        //  scroll to error
                        const errorDiv = this.template.querySelector('[data-id="error"]');
                        if (errorDiv) {
                            errorDiv.scrollIntoView({ behavior: 'smooth', block: 'start' });
                        }
                    }
                    this.validate = false;
                })
                .catch(error => {
                    this.validate = false;
                    console.log('Errors -->', error);
                });


        } else {
            this.validate = false;
            console.log('validation error');
            // Show an error toast if validation fails
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please fill in all required fields.',
                variant: 'error'
            }));
            this.dispatchCustomEvent('close');
        }
    }

    validateFields(requiredFields) {

        const invalidFields = [];
        const fieldErrors = {};

        // Iterate through each required field and check for missing values
        for (let key in requiredFields) {
            if (!requiredFields[key].value) {
                invalidFields.push(requiredFields[key].fieldName);
                // Add error message for the field
                fieldErrors[requiredFields[key].fieldName] = fieldErrors[requiredFields[key].fieldName] || [];
                fieldErrors[requiredFields[key].fieldName].push({ message: `${requiredFields[key].fieldName} is required.` });
            }
        }

        // Check if there are any invalid fields
        if (invalidFields.length > 0) {
            // Set field-level errors using lightning-record-edit-form's setErrors method
            const fields = this.template.querySelectorAll('lightning-input-field').forEach(element => {
                console.log(' Feild Name -->', element.fieldName);

                if (invalidFields.includes(element.fieldName)) {
                    element.reportValidity();
                }
            });
            console.log('Feilds -->', fields);

        }
        else {
            return true;
        }

    }
}