import { LightningElement , api, wire } from 'lwc';
/*import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import validateTemporaryNICId from '@salesforce/apex/Sales_GenerateTemporaryLicense.validateTemporaryNICId';
import getHostId from '@salesforce/apex/Sales_LicenseGenIntegration_Utility.returnHostIdDetail';
import SalesLicenseFileFailureMsg from '@salesforce/label/c.Sales_LicenseFileFailure_Msg';
import Saleslicensetempmsg from '@salesforce/label/c.Sales_license_temp_msg';
import SalesAssignPrimaryCompErr from '@salesforce/label/c.Sales_AssignPrimaryCompErr';
import SalesFileGenSuccess from '@salesforce/label/c.Sales_File_Gen_Success';
import SalesHostGenValidation from '@salesforce/label/c.Sales_Host_Gen_Validation';
import Sales_Succmsg from '@salesforce/label/c.Sales_Succmsg';
import Sales_Failuremsg from '@salesforce/label/c.Sales_Failuremsg';
import  Sales_ermsg from '@salesforce/label/c.Sales_ermsg';
*/


export default class Sales_GenerateTemporaryLicenseComponent extends LightningElement {
    @api recordId;
    /*@api licPrimaryComputerId;
    @api inputType;
    @api input;
    eventType='';
    label={
        SalesLicenseFileFailureMsg,   
        Saleslicensetempmsg,
        SalesAssignPrimaryCompErr,
        SalesFileGenSuccess,
        SalesHostGenValidation,
        Sales_Succmsg,
        Sales_Failuremsg,
        Sales_ermsg
    }

    connectedCallback() {
            console.log('@@TemporaryrecordId' + this.recordId);
            //this.validateTemporaryNICId();
    }

    /*validateTemporaryNICId(){
        console.log('checking validateTemporaryNICId' + this.recordId);   
        validateTemporaryNICId({ hostRecordId: this.recordId})    //pass record Id
        .then((res) => {
                if(res == true){
                        
                        this.verifyLicenseGen();
                }
                else{
                        this.closeQuickAction();
                        this.fireToastEvent(this.label.Sales_Failuremsg, this.label.SalesHostGenValidation, 'error', 'dismissable');   
                }
        })
        .catch((error) => {
                this.closeQuickAction();
                this.fireToastEvent(this.label.Sales_ermsg, error.body.message, 'error', 'sticky');
        });
}*/
        /*verifyLicenseGen() {
        console.log('@@recordId' + this.recordId);
        getHostId({ input: this.recordId, inputType: 'HostId',eventType:this.eventType })    //pass record Id and type 
                .then((result) => {
                        if (result) {
                                //if method return exception
                                this.closeQuickAction();
                                this.fireToastEvent(this.label.Sales_Failuremsg, this.label.SalesLicenseFileFailureMsg, 'error', 'dismissable');
                                this.reloadPage();
                        }
                        else {
                                this.closeQuickAction();
                                this.fireToastEvent(this.label.Sales_Succmsg, this.label.SalesFileGenSuccess, 'success', 'dismissable');
                                this.reloadPage();
                        }
                })
                .catch((error) => {
                        this.closeQuickAction();
                        this.fireToastEvent(this.label.Sales_ermsg, error.body.message, 'error', 'sticky');
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
    /*}

    closeQuickAction() {
            const closeModal = new CustomEvent('close');
            // Dispatches the event.
            this.dispatchEvent(closeModal);
    }*/
}