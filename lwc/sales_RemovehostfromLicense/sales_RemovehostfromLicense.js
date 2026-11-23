import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import successMsg from '@salesforce/label/c.Sales_removeHostSuccMsg';
import failureMsg from '@salesforce/label/c.Sales_RemoveHostFailureMsg';
import catchErroMsg from '@salesforce/label/c.Sales_RemoveLicUserUnhandledErr';
import Sales_avlbeRehostZeroErrMsg from '@salesforce/label/c.Sales_avlbeRehostZeroErrMsg';
import Sales_avlbeRehostNullErrMsg from '@salesforce/label/c.Sales_avlbeRehostNullErrMsg';
import removeHostfromLicenseRecord from '@salesforce/apex/Sales_RemoveLicUserOnLicenseRecordCtrl.removeHostfromLicenseRecord';
import Sales_Succes from '@salesforce/label/c.Sales_Succes';
import Sales_failure from '@salesforce/label/c.Sales_failure';

export default class Sales_RemovehostfromLicense extends LightningElement {
    @api recordId;
    label = {
        successMsg,
        failureMsg,
        catchErroMsg,
        Sales_Succes,
        Sales_failure,
        Sales_avlbeRehostNullErrMsg,
        Sales_avlbeRehostZeroErrMsg

    };
    connectedCallback() {
        removeHostfromLicenseRecord({ recordId: this.recordId }) //apex method invoked
            .then((result) => {
                if (result=='Success') {
                    this.closeQuickAction();
                    this.showNotification(this.label.Sales_Succes,successMsg, 'success');
                    this.reload();
                }
                else if(result=='Failure') {
                    this.closeQuickAction();
                    this.showNotification(this.label.Sales_failure,failureMsg, 'error');
                }
                /*else if(result==this.label.Sales_avlbeRehostNullErrMsg) {
                    this.closeQuickAction();
                    this.showNotification(this.label.Sales_failure,this.label.Sales_avlbeRehostNullErrMsg, 'error');
                }
                else{
                    this.closeQuickAction();
                    this.showNotification(this.label.Sales_failure,this.label.Sales_avlbeRehostZeroErrMsg, 'error');
                }*/
               

            })
            .catch((error) => {
                this.closeQuickAction();
                this.showNotification(this.label.Sales_failure,catchErroMsg, 'error');
            })
    }
    reload() {
        setTimeout(function () {
            location.reload(true);
        }, 2000);
    }

    showNotification(title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }

    closeQuickAction() {
        const closeModal = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeModal);
    }
}