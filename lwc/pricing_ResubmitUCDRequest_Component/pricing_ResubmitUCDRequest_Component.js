import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import resubmitUCDRequest from '@salesforce/apex/Pricing_UCD_IQR_FormRequest.resubmitUCDRequest';
import resubmitUCDRequestSuccessMsg from '@salesforce/label/c.Pricing_Tender_Resubmit_UCD_Request_Success_Msg';
import resubmitUCDRequestValidation from '@salesforce/label/c.Pricing_Tender_Resubmit_UCD_Request_Validation_Error_Msg';

export default class Pricing_ResubmitUCDRequest_Component extends LightningElement {
    @api recordId;
    @api invoke(){
        let quoteIds = [];
        quoteIds.push(this.recordId);
        resubmitUCDRequest({ quoteIdList: quoteIds })
        .then(result => {
            if(result == true){
                const toastMessage = new ShowToastEvent({
                title: 'Success',
                message: resubmitUCDRequestSuccessMsg,
                variant: 'success',
                mode: 'dismissable'
                });
                this.dispatchEvent(toastMessage);
            }
            else{
                const toastErrorMessage = new ShowToastEvent({
                title: 'Error',
                message: resubmitUCDRequestValidation,
                variant: 'error',
                mode: 'dismissable'
                });
                this.dispatchEvent(toastErrorMessage);
            }
        })
        .catch(error => {
            const toastMessageException= new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(toastMessageException);
        });
    }
}