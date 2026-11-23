import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import successTxt from '@salesforce/label/c.Sales_Order_Success';
import successMsg from '@salesforce/label/c.Sales_Order_Success_Msg';
//import findRecords from "@salesforce/apex/Sales_OrderController.findRecords";

export default class Sales_AddLicensedUser extends NavigationMixin(LightningElement) {

    label = {
        successTxt,
        successMsg,
        errorMsg,
    };
    connectedCallback() {
        loadStyle(this, AddLicensedUser);

    }
    renderedCallback() {

        Promise.all([
            loadStyle(this, Orderstylingsheet)
        ]).then(() => {
            console.log('Files loaded');
        })
            .catch(error => {
                console.log(error.body.message);
            });

    }

    navigateToObjectHome() {
        // Navigate to the Order object home page.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Sales_License__c',
                actionName: 'home'
            }
        });
    }


     //Record Creation 
     handleSuccess(event) {
        console.log('this.iserror>>' + this.iserror);
        //if(this.iserror!=true){
        const evt = new ShowToastEvent({
            variant: 'success',
            title: this.label.successTxt,
            message: this.label.successMsg,
        });
        this.dispatchEvent(evt);
        console.log('this.redirect>>' + this.redirect);
        if (this.redirect == true) {
            var recId = event.detail.id;
            console.log('License record', event.detail.id);
            // navigate to order record page
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recId,
                    objectApiName: 'Sales_License__c', // objectApiName is optional
                    //set lic user field on license
                    actionName: 'view'
                }
            });
        }

        if (this.resetpage == true) {
            //this.handleReset();
            eval("$A.get('e.force:refreshView').fire();");
        }
    }

    //method to set account value at the time of submition
    handleSubmit(event) {
        event.preventDefault();       // stop the form from submitting
        let fields = event.detail.fields;

        console.log('Feilds -->' + JSON.stringify(fields));
        console.log('Inside handle submit');
        console.log('Inside Error check method');
        //fields.AccountId = this.accountVal;
    }

    handleError(event){
        console.log('Error>>'+JSON.stringify(event.detail));
        console.log('Error1>>'+JSON.stringify(event.detail.detail));
        /*const evt = new ShowToastEvent({
            title: 'Error!',
            message: event.detail.detail,
            variant: 'error',
           // mode:'dismissable'
        });
        this.dispatchEvent(evt);*/
    }




}