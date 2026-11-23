import { LightningElement,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLicenseHostId from '@salesforce/apex/Sales_GetComputerDetailsForCompanion_bot.getLicenseHostId';
import returnHostIdDetail from '@salesforce/apex/Sales_LicenseGenIntegration_Utility.returnHostIdDetail';
import validateTemporaryNICId from '@salesforce/apex/Sales_GenerateTemporaryLicense.validateTemporaryNICId';
import SalesLicenseFileFailureMsg from '@salesforce/label/c.Sales_LicenseFileFailure_Msg';
import Saleslicensetempmsg from '@salesforce/label/c.Sales_license_temp_msg';
import SalesAssignPrimaryCompErr from '@salesforce/label/c.Sales_AssignPrimaryCompErr';
import Sales_Order_Success from '@salesforce/label/c.Sales_Order_Success';
import Sales_Failuremsg from '@salesforce/label/c.Sales_Failuremsg';
import Sales_ermsg from '@salesforce/label/c.Sales_ermsg';


export default class Sales_GenerateTempLicCheckoutOnLic extends LightningElement {
    @api recordId;
    licPrimaryComputerId;
    eventType='isTempLicenseGen';
    label={
        SalesLicenseFileFailureMsg,
        SalesLicensefileemailmsg,
        Saleslicensetempmsg,
        SalesAssignPrimaryCompErr,
        Sales_ermsg,
        Sales_Failuremsg,
        Sales_Succmsg,
        Sales_Order_Success
    };
    connectedCallback() {
        console.log('License recordId>>>>' + this.recordId);
        getLicenseHostId({ recId: this.recordId })
                .then((result) => {
                        console.log('result-->' + result);
                        this.licPrimaryComputerId = result;
                        console.log('licPrimaryComputerId>>>'+this.licPrimaryComputerId);
                        //if computer is not associated to license show error that please assign computer
                        if (this.licPrimaryComputerId == null) {
                                this.closeQuickAction();
                                this.fireToastEvent(this.label.Sales_ermsg,this.label.SalesAssignPrimaryCompErr, 'error', 'sticky');
                        }
                        else {
                            this.verifyLicenseGen();
                        }
                })
                .catch((error) => {
                        this.closeQuickAction();
                        this.fireToastEvent(this.label.Sales_ermsg, error.body.message, 'error', 'sticky');
                });
    }
verifyLicenseGen(){
        console.log('checking validateTemporaryNICId' + this.licPrimaryComputerId);   
        validateTemporaryNICId({ hostRecordId: this.licPrimaryComputerId})    //pass record Id
        .then((res) => {
                if(res == true){
                        
                        this.generateTempLicense();
                }
                else{
                        this.closeQuickAction();
                        this.fireToastEvent(this.label.Sales_Failuremsg, this.label.Saleslicensetempmsg, 'error', 'dismissable');   
                }
        })
        .catch((error) => {
                this.closeQuickAction();
                this.fireToastEvent(this.label.Sales_ermsg, error.body.message, 'error', 'sticky');
        });
}
generateTempLicense(){
    //call license generation
    console.log('host record id>>'+this.licPrimaryComputerId);
    returnHostIdDetail({ input: this.licPrimaryComputerId, inputType: 'HostId',eventType:this.eventType })    //pass record Id and type 
    .then((result) => {
            if (result) {
                    //if method return exception
                    this.closeQuickAction();
                    this.fireToastEvent(this.label.Sales_Failuremsg, this.label.SalesLicenseFileFailureMsg ,'error', 'dismissable');
                   // this.reloadPage();
            }
            else {
                    console.log('inside success!!!');
                    this.closeQuickAction();
                    this.fireToastEvent(this.label.Sales_Order_Successg, this.label.SalesLicensefileemailmsg, 'success', 'dismissable');
                   // this.reloadPage();
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
}

closeQuickAction() {
        const closeModal = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeModal);
}
}