import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateRecordForm extends NavigationMixin(LightningElement) {
    handleSubmit(event) {
        event.preventDefault();
        // Perform any custom validation or handling before submitting the form
        const fields = event.detail.fields;
        // Modify the fields if needed
        // Example: fields.FieldApiName = 'Field Value';
        this.template.querySelector('lightning-record-form').submit(fields);
    }

    handleSuccess(event) {
        const recordId = event.detail.id;
        // Navigate to the newly created record
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }
    handleCancel() {
        // Handle the cancel event if the user cancels the form
        // Optional: perform any cleanup or navigation logic
    }
}