import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getHostId from '@salesforce/apex/Sales_LicenseGenIntegration_Utility.returnHostIdDetail';
import hostRelatedLicensesCount from '@salesforce/apex/Sales_LicenseGenIntegration_Utility.hostRelatedLicensesCount';
import SalesHostForLicenseGeneration from '@salesforce/label/c.Sales_HostForLicenseGeneration';
import SalesLicenseFileGenFailed from '@salesforce/label/c.Sales_LicenseFileGenFailed';
import SalesSuccessLicFile from '@salesforce/label/c.Sales_SuccessLicFile';
import SalesErrorMessage from '@salesforce/label/c.Sales_Error_Message';
import Sales_Failuremsg from '@salesforce/label/c.Sales_Failuremsg';
import Sales_Order_Success from '@salesforce/label/c.Sales_Order_Success';


export default class Sales_LicenseGenerationIntegration extends LightningElement {
        @api recordId;
        @track showModal = false;
        @api inputType;
        @api input;
        eventType='';
        label={
                SalesHostForLicenseGeneration,
                SalesLicenseFileGenFailed,
                SalesSuccessLicFile,
                SalesErrorMessage,
                Sales_Failuremsg,
                Sales_Order_Success

        }
        connectedCallback() {
                console.log('@@recordId' + this.recordId);
                this.checkhostRelatedLicensesCount();
                

        }

        checkhostRelatedLicensesCount(){
                console.log('checkhostRelatedLicensesCount --> @@recordId' + this.recordId);   
                hostRelatedLicensesCount({ hostRecordId: this.recordId})    //pass record Id
                .then((res) => {
                        if(res > 0){
                                //this.validateTemporaryNICId();
                                this.verifyLicenseGen();
                        }
                        else{
                                this.closeQuickAction();
                                this.fireToastEvent(this.label.Sales_Failuremsg,this.label.SalesHostForLicenseGeneration, 'error', 'dismissable');   
                        }
                })
                .catch((error) => {
                        this.closeQuickAction();
                        this.fireToastEvent(this.label.SalesErrorMessage, error.body.message, 'error', 'sticky');
                });
        }
        verifyLicenseGen() {
                console.log('@@recordId' + this.recordId);
                getHostId({ input: this.recordId, inputType: 'HostId',eventType:this.eventType})    //pass record Id and type 
                        .then((result) => {
                                if (result) {
                                        //if method return exception
                                        this.closeQuickAction();
                                        this.fireToastEvent(this.label.Sales_Failuremsg, this.label.SalesLicenseFileGenFailed, 'error', 'dismissable');
                                        this.reloadPage();
                                }
                                else {
                                        this.closeQuickAction();
                                        this.fireToastEvent(this.label.Sales_Order_Success, this.label.SalesSuccessLicFile, 'success', 'dismissable');
                                        this.reloadPage();
                                }
                        })
                        .catch((error) => {
                                this.closeQuickAction();
                                this.fireToastEvent(this.label.SalesErrorMessage, error.body.message, 'error', 'sticky');
                        });
        }

        fireToastEvent(title, message, variant, mode) {
                const event = new ShowToastEvent({
                        title: title,
                        message: message,
                        variant: variant,
                        mode: mode
                });
                this.dispatchEvent(event);
        }

        reloadPage() {
                setTimeout(function () {
                        //eval("$A.get('e.force:refreshView').fire();");
                        location.reload(true);
                }, 2000);
                /*window.setTimeout(function(){ 
                        location.reload(true);
                }, 2000);*/
        }

        closeQuickAction() {
                const closeModal = new CustomEvent('close');
                // Dispatches the event.
                this.dispatchEvent(closeModal);
        }

}