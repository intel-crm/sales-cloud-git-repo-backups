import { LightningElement, api, wire, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getFormDetails from '@salesforce/apex/Core_FieldSetFormController.getFormFieldsAndSectionLabel';

import { CloseActionScreenEvent } from 'lightning/actions';//added
import { NavigationMixin } from 'lightning/navigation';//added

export default class Core_ReadOnly_FieldSet_Form extends NavigationMixin(LightningElement){
    @api recordId;
    @api objectApiName;
    @track formValues = [];
    @track iconName = 'utility:chevrondown';
    @track isLoading = false;
    @api showEditField;

    @api invokedFromAura;
    
    connectedCallback() {
        this.getFieldSetFormDetails();
    }

    getFieldSetFormDetails() {
        console.log('record id is', this.recordId);
        console.log('objectApiName is', this.objectApiName);
        this.isLoading = true;
        getFormDetails({ recordId: this.recordId })
            .then(result => {
                this.formValues = result;
                this.isLoading = false;
                JSON.parse(JSON.stringify(this.formValues));
                console.log('result===>', JSON.stringify(result));
            })
            .catch(error => {
                console.log('error===>', JSON.stringify(error));
            });
    }

    handleClick(event) {
        let childComp = (event.target.firstElementChild === null) ? event.target : event.target.firstElementChild.firstElementChild;
        childComp.iconName = (childComp.iconName === 'utility:chevronright') ? 'utility:chevrondown' : 'utility:chevronright';
    }
   
    handleSubmit(event) {
        this.isLoading = true;
    }

   
    handleSuccess(event) {
        console.log('Inside handle success lwc');
        this.isLoading = false;
        this.showEditField = false;
        const evnt = new ShowToastEvent({
        title : 'Success',
        message : 'Record is saved successfully',
        variant : 'Success',
        mode : 'dismissable'
        });
        this.dispatchEvent(evnt);
        eval("$A.get('e.force:refreshView').fire();");
    }

    handleError(event) {
        console.log('error===>');
        const scroll = this.template.querySelector('lightning-messages');
        scroll.scrollIntoView();
    }

    handleEdit(event) {
        this.showEditField = !this.showEditField;
    }

    handleCancelButtonClick(event) {
             this.showEditField = false;
        
    }
    
    navigatetoRecordPage(){
        this[NavigationMixin.Navigate]({
                 type: "standard__recordPage",
                 attributes: {
                    recordId: this.recordId,
                    objectApiName: this.objectApiName,
                    actionName: "view"
                 }
              });
    }
}