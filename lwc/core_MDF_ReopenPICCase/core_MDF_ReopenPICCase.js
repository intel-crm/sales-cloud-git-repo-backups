import reopenCase from '@salesforce/apex/Core_MDF_ClaimReviewCaseProcessHelper.reopenCase';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, track, wire, api } from 'lwc';
import Core_MDF_Error_Msg from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import Core_MDF_Success_Msg from '@salesforce/label/c.Core_MDF_CCF_DCF_SUCCESS';
import Core_MDF_ReopenPICCaseBtnLabel from '@salesforce/label/c.Core_MDF_ReopenPICCaseBtnLabel';
import Core_MDF_ReopenPICCaseHeading from '@salesforce/label/c.Core_MDF_ReopenPICCaseHeading';



export default class Core_MDF_ReopenPICCase extends LightningElement {
    @api recordId;
    @track toBeReopened = false;
    errorMsg = Core_MDF_Error_Msg;
    successMsg = Core_MDF_Success_Msg;

    reopenCaseBtnLabel = Core_MDF_ReopenPICCaseBtnLabel;
    reopenCaseHeading = Core_MDF_ReopenPICCaseHeading;

    handleReopenCase(event)
    {
        reopenCase({ recordId: this.recordId })
            .then((result) => {
                console.log('result'+ result);
               
                if(result == 'true'){
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: this.successMsg,
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    // Notify LDS that you've changed the record outside its mechanisms.
                    getRecordNotifyChange([{recordId: this.recordId}]); 
                }
                else{
                    //show application error
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    
                }
                
            })
            .catch((error) => {
               //show application error
               const evt = new ShowToastEvent({
                title: 'Error',
                message: this.errorMsg,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            });
    }
}