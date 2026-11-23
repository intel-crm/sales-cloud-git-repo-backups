import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const FIELDS = ['Sales_Host__c.Id'];

export default class SalesLicenseGeneration extends LightningElement {
    @api recordId;

    /*@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ data, error }) {
        this.closeQuickAction();
        if (data) {
            getHostId({ recId: this.recordId, selectedField: 'HostId',isOrderTrigger:false })
                .then((result) => {
                    if (result) {
                        this.closeQuickAction();
                        this.fireToastEvent('Failure!', 'License File Generation Failed.', 'error', 'dismissable');
                        this.reloadPage();
                    }
                    else {
                        this.closeQuickAction();
                        this.fireToastEvent('Success!', 'license file will be generated and sent by email shortly.', 'success', 'dismissable');
                        this.reloadPage();
                    }
                })
                .catch((error) => {
                    this.closeQuickAction();
                    this.fireToastEvent('Error!', error.body.message, 'error', 'sticky');
                });

            console.log('data' + JSON.stringify(data));
            console.log('id:' + this.recordId);
        }
        if (error) {
            console.log('error' + error);
        }
    };



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
        }, 2000);
    }

    closeQuickAction() {
        const closeModal = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeModal);
    }
*/

}