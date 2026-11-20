import { LightningElement, api, wire, track } from 'lwc';
import getFormDetails from '@salesforce/apex/Pricing_FieldSetFormController.getFormFieldsAndSectionLabel';
import readOnlyFields from '@salesforce/label/c.Pricing_Tender_QuoteLine_Read_Only_Fields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuoteLineDetails from '@salesforce/apex/Pricing_FieldSetFormController.getQuoteLineDetails';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import readOnlyDateFields from '@salesforce/label/c.Pricing_Tender_QuoteLine_ReadOnly_DateFields';
import clientQuoteLineType from '@salesforce/label/c.Pricing_Tender_CCG_Quote';
const TITLE_TEXT = 'Success!';
const MSG_TEXT = 'Quote Line was saved';
const VAR_TEXT = 'success';
const MODE = 'dismissable';
const VALUE = false;
const isRefreshAccordion = true;

export default class Pricing_Edit_FieldSet_Form extends LightningElement {
    @api recordId;
    @api quoteId;

    @track formValues;
    @track isModalOpen = true;
    @track loadSpinner = true;
    @track saveSpinner = false;
    @track disableButton = false;
    @track isSave = false;
    @track qlPriceEndDate;
    @track consumptionValues;

    connectedCallback() {
        this.getFieldSetFormDetails();
    }

    getFieldSetFormDetails() {
        getFormDetails({ recordId: this.recordId })
            .then(result => {
                let formDetails = JSON.parse(JSON.stringify(result));
                var fieldList = readOnlyFields + ',' + readOnlyDateFields;
                let fieldArray = fieldList.split(',');
                let sdmFastrackIndex;
                let isNotClient;
                for (var i = 0; i < formDetails.length; i++) {
                    for (var j = 0; j < formDetails[i].Fields.length; j++) {
                        if (fieldArray.includes(formDetails[i].Fields[j]["APIName"]) && formDetails[i].Fields[j]["APIName"] != 'Pricing_End_Date_dt__c') {
                            formDetails[i].Fields[j]["isInput"] = false;
                        }
                        if (formDetails[i].Fields[j]["APIName"] == 'Pricing_SDM_Fast_Track__c') {
                            sdmFastrackIndex = formDetails[i].Fields[j];
                        }
                        if (formDetails[i].Fields[j]["APIName"] == 'Pricing_Program_Type_Nm__c' && formDetails[i].Fields[j]["programType"] != clientQuoteLineType) {
                            isNotClient = true;
                        }

                    }
                }

                if (isNotClient && sdmFastrackIndex != undefined) {
                    sdmFastrackIndex["isInput"] = false;
                }
                this.formValues = formDetails;
                this.getQuotelineData();
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });
    }

    getQuotelineData() {
        getQuoteLineDetails({ quoteLineId: this.recordId })
            .then(result => {
                getRecordNotifyChange([{ recordId: this.quoteLineId }]);

                for (var i = 0; i < this.formValues.length; i++) {
                    for (var j = 0; j < this.formValues[i].Fields.length; j++) {
                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_End_Date_dt__c') {
                            this.formValues[i].Fields[j]["fieldValue"] = result.Pricing_End_Date_dt__c;
                        }
                    }
                }
            }
            ).catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });
    }

    handleInputChange(event) {
        if (event.target.label === 'Quote Line Pricing End Date') {
            this.qlPriceEndDate = event.target.value;
        }
        const dateFields = this.template.querySelectorAll('lightning-input-field');
        if (dateFields) {
            dateFields.forEach(field => {
                if (field.fieldName === 'Pricing_End_Date_dt__c') {
                    field.value = this.qlPriceEndDate;
                }
            });
        }

    }

    handleClick(event) {
        let childComp = (event.target.firstElementChild === null) ? event.target : event.target.firstElementChild.firstElementChild;
        childComp.iconName = (childComp.iconName === 'utility:chevronright') ? 'utility:chevrondown' : 'utility:chevronright';
    }

    handleLoad(event) {
        this.loadSpinner = false;
    }

    handleSave(event) {
        /*this.saveSpinner = true;
        this.disableButton = true;*/
        this.isSave = true;

    }

    handleSuccess(event) {
        this.saveSpinner = false;
        this.disableButton = false;
        this.isModalOpen = false;

        const toastMessage = new ShowToastEvent({
            title: TITLE_TEXT,
            message: MSG_TEXT,
            variant: VAR_TEXT,
            mode: MODE
        });
        this.dispatchEvent(toastMessage);
        if (this.isSave === true) {
            const refreshAccordion = new CustomEvent("refreshAccordionEvent", { detail: { isRefreshAccordion } },);
            this.dispatchEvent(refreshAccordion);
            const custEvent = new CustomEvent("refresheventnew");
            this.dispatchEvent(custEvent);
        }

        const closeModalEvent = new CustomEvent("modalOpenEvent", { detail: { VALUE } },);
        this.dispatchEvent(closeModalEvent);
    }

    handleError(event) {
        this.saveSpinner = false;
        this.disableButton = false;
        const scroll = this.template.querySelector('lightning-messages');
        scroll.scrollIntoView();
    }

    handleSubmit(event) {
        this.saveSpinner = true;
        this.disableButton = true;
        event.preventDefault();
        const field = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(field);
    }

    handleCancel(event) {
        this.isModalOpen = false;
        const closeModalEvent = new CustomEvent("modalOpenEvent", { detail: { VALUE } },);
        this.dispatchEvent(closeModalEvent);
    }


}