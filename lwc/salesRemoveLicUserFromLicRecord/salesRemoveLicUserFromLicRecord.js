import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import successMsg from '@salesforce/label/c.Sales_RemoveLicUserSuccessMsg';
import failureMsg from '@salesforce/label/c.Sales_RemoveLicUserFailureMsg';
import catchErroMsg from '@salesforce/label/c.Sales_RemoveLicUserUnhandledErr';
import removeLicUserFromUser from '@salesforce/apex/Sales_RemoveLicUserOnLicenseRecordCtrl.removeLicUserFromUser';
import Sales_Succes from '@salesforce/label/c.Sales_Succes';
import Sales_failure from '@salesforce/label/c.Sales_failure';

export default class SalesRemoveLicUserFromLicRecord extends LightningElement {
    @api recordId;
    label = {
        successMsg,
        failureMsg,
        catchErroMsg,
        Sales_failure,
        Sales_Succes
    };
    @api invoke() {//headledd action funciton
        removeLicUserFromUser({ recordId: this.recordId }) //apex method invoked
            .then((result) => {
                if (result) {
                    this.showNotification(this.label.Sales_Succes,successMsg, 'success');
                    this.reload();
                }
                else {
                    this.showNotification(this.label.Sales_failure,failureMsg, 'error');
                }

            })
            .catch((error) => {
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
}