import { LightningElement, api, track } from 'lwc';
import getFormDetails from '@salesforce/apex/Pricing_FieldSetFormController.getFormFieldsAndSectionLabel';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class Pricing_ReadOnly_FieldSet_Form extends LightningElement {
    @api recordId;
    @api quoteId;
    @track formValues = [];
    @track iconName = 'utility:chevrondown';

    connectedCallback() {
        this.getFieldSetFormDetails();
    }

    getFieldSetFormDetails() {
        getFormDetails({ recordId: this.recordId })
            .then(result => {
                console.log('Raw result- pricing_readonly_Fieldset_Form.js :'+JSON.stringify(result));
                getRecordNotifyChange([{ recordId: this.recordId }]);
                if(result !== undefined && result !== '' && result !== null){
                    this.formValues = result;
                }
                this.formValues[0]['sectionLabel'] = 'FirstElement';
            })
            .catch(error => {
                console.error('error @ getFieldSetFormDetails', JSON.stringify(error));
            });
    }

    handleClick(event) {
        let childComp = (event.target.firstElementChild === null) ? event.target : event.target.firstElementChild.firstElementChild;
        childComp.iconName = (childComp.iconName === 'utility:chevronright') ? 'utility:chevrondown' : 'utility:chevronright';
    }

}