import { LightningElement, api, wire, track } from 'lwc';
import getCustomerDivisions from '@salesforce/apex/Pricing_CustomerDivisionComp_cntrl.getCustomerDivision';
import updateCustomerDivisions from '@salesforce/apex/Pricing_CustomerDivisionComp_cntrl.updateQuoteCustomerDivision';
import CustomerDivisionValue from '@salesforce/apex/Pricing_CustomerDivisionComp_cntrl.getCustomerDivisionValue';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import statusPrecedence from '@salesforce/apex/Pricing_CustomerDivisionComp_cntrl.getstatusPrecedenceNumber';
import { getRecordNotifyChange, getRecord } from 'lightning/uiRecordApi';
import saveButton from '@salesforce/label/c.Pricing_Save_Button_Label';
import QUOTE_OBJECT from '@salesforce/schema/SBQQ__Quote__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import LightningConfirm from 'lightning/confirm';
const FIELDS = ["SBQQ__Quote__c.Pricing_On_Hold_Cb__c"];
export default class Pricing_CustomerDivisionComponent extends NavigationMixin(LightningElement) {

    @track error;
    @api recordId;
    @track disableButton = true;
    @track saveLabel = saveButton;
    @track loadSpinner = false;
    @track options = [];
    @track selectedValue;
    @track selectedValues = [];
    @track label = 'Account Division';
    @track disabled = false;
    @track value;
    @track values = [];
    @track optionData;
    @track displayText = '';
    @track showDropdown = false;
    @track divisionValues = '';
    @track showTitle = '';
    @track helptext = '';

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    getQuoteData({ error, data }) {
        if (data) {
            let quoteData = JSON.parse(JSON.stringify(data));
            this.disabled = quoteData.fields.Pricing_On_Hold_Cb__c.value; // Hold value to disabled flag
        } else if (error) {
            console.error('Error @ getQuoteData ' + error);
        }
    }

    @wire(CustomerDivisionValue, { recordId: '$recordId' })
    csValue({ error, data }) {
        if (data) {
            getRecordNotifyChange([{ recordId: this.recordId }]);
            this.selectedValues = data.split(';');
            this.showTitle = data;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getObjectInfo, { objectApiName: QUOTE_OBJECT })
    object(result) {
        if (result.data) {
            this.helptext = result.data.fields['Pricing_Account_Division_Nm__c'].inlineHelpText;
        }
    }

    @wire(getCustomerDivisions, { recordId: '$recordId' })
    customerDivisions({ error, data }) {
        this.getStatusPrecedenceNumber();
        if (data) {
            for (let i = 0; i < data.length; i++) {
                this.options = [...this.options, { value: data[i].Name, label: data[i].Name }];
            }
            this.setOptionValues();
        } else if (error) {
            this.error = error;
        }
    }

    getStatusPrecedenceNumber() {
        statusPrecedence({ recordId: this.recordId })
            .then(result => {
                getRecordNotifyChange([{ recordId: this.recordId }]);
                if (result) {
                    this.disabled = result;
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleReset() {
        LightningConfirm.open({
            label: 'Warning',
            message: 'The Account Division has been changed for this Quote. Please make sure your selection is correct. Selecting a specific Account Division will limit customer billings to the approved Sold-To addresses for the selected Division only. This cannot be changed once the quote has been submitted.',
            theme: 'warning'
        }).then((result) => {
            if (result) {
                this.loadSpinner = true;
                this.disableButton = true;
                this.selectedValue = '';
                updateCustomerDivisions({
                    recordId: this.recordId,
                    accountDivision: this.selectedValue,
                }).then((result) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Saved successfully',
                            variant: 'success',
                            mode: 'dismissible'
                        })
                    );
                    for (let i = 0; i < this.optionData.length; i++) {
                        this.optionData[i].selected = false;
                    }
                    this.selectedValues = null;
                    this.values.length = 0;
                    this.showTitle = '';
                    this.displayText = '';
                    this.loadSpinner = false;
                    this.disableButton = true;
                    eval("$A.get('e.force:refreshView').fire();");
                })
                    .catch((error) => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                        this.loadSpinner = false;
                        this.disableButton = true;
                        eval("$A.get('e.force:refreshView').fire();");
                    });
            }
        });
    }

    handleSave() {
        LightningConfirm.open({
            label: 'Warning',
            message: 'The Account Division has been changed for this Quote. Please make sure your selection is correct. Selecting a specific Account Division will limit customer billings to the approved Sold-To addresses for the selected Division only. This cannot be changed once the quote has been submitted.',
            theme: 'warning'
        }).then((result) => {
            if (result) {
                this.loadSpinner = true;
                this.disableButton = true;
                this.saveLabel = 'Saving...';
                this.divisionValues = this.values != null ? this.values.join(';') : null;
                this.showTitle = this.divisionValues;
                updateCustomerDivisions({
                    recordId: this.recordId,
                    accountDivision: this.divisionValues,
                }).then((result) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Saved successfully',
                            variant: 'success',
                            mode: 'dismissible'
                        })
                    );
                    this.loadSpinner = false;
                    this.disableButton = false;
                    this.saveLabel = saveButton;
                    eval("$A.get('e.force:refreshView').fire();");
                })
                    .catch((error) => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                        this.loadSpinner = false;
                        this.disableButton = false;
                        this.saveLabel = saveButton;
                        eval("$A.get('e.force:refreshView').fire();");
                    });
            }
        });
    }

    setOptionValues() {
        this.showDropdown = false;
        let optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
        let values = this.selectedValues ? (JSON.parse(JSON.stringify(this.selectedValues))) : null;
        if (values) {
            let count = 0;
            for (let i = 0; i < optionData.length; i++) {
                if (values.includes(optionData[i].value)) {
                    optionData[i].selected = true;
                    count++;
                }
            }
            this.displayText = count > 0 ? count + ' Option(s) Selected' : '';
        }
        this.values = values;
        this.optionData = optionData;
    }

    selectItem(event) {
        let selectedVal = event.currentTarget.dataset.id;
        if (selectedVal) {
            let count = 0;
            let options = JSON.parse(JSON.stringify(this.optionData));
            for (let i = 0; i < options.length; i++) {
                if (options[i].value === selectedVal) {
                    if (this.values.includes(options[i].value)) {
                        this.values.splice(this.values.indexOf(options[i].value), 1);
                    } else {
                        this.values.push(options[i].value);
                    }
                    options[i].selected = options[i].selected ? false : true;
                }
                if (options[i].selected) {
                    count++;
                }
            }
            this.optionData = options;
            this.displayText = count > 0 ? count + ' Option(s) Selected' : '';
            this.disableButton = count > 0 ? false : true;
            event.preventDefault();
        }
    }

    showOptions() {
        if (this.disabled == false && this.options) {
            let options = JSON.parse(JSON.stringify(this.optionData));
            for (let i = 0; i < options.length; i++) {
                options[i].isVisible = true;
            }
            if (options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
    }

    handleBlur() {
        this.showDropdown = false;
    }

}