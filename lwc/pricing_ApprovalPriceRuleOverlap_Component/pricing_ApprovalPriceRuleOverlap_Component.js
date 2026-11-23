import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import overlapApprovalPriceRule from '@salesforce/apex/Pricing_QuoteLine_AutoApprovalController.isOverlapApprovalPriceRule';
import approvalPriceRuleSuccessMsg from '@salesforce/label/c.Pricing_ApprovalPriceRule_Success_Msg';
import approvalPriceRuleOverlapMsg from '@salesforce/label/c.Pricing_ApprovalPriceRule_Overlap_Msg';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class Pricing_ApprovalPriceRuleOverlap_Component extends LightningElement {
    @api recordId;
    @api invoke(){
        console.log('record:'+this.recordId);
        overlapApprovalPriceRule({ approvalPriceRuleId: this.recordId })
        .then(result => {
            console.log('result:'+result);
            let msg = result;//JSON.stringify(result);
            if(result == 'Success'){
                const toastMessage = new ShowToastEvent({
                title: 'Success',
                message: approvalPriceRuleSuccessMsg,
                variant: 'success',
                mode: 'dismissable'
                });
                this.dispatchEvent(toastMessage);
                getRecordNotifyChange([{ recordId: this.recordId }]);
            }
            else{
                console.log('msgqq:'+msg);
                const toastErrorMessage = new ShowToastEvent({
                title: 'Error',
                message:  msg == 'Please check Products and do Submit Record' || msg == 'You can submit record only when status is in Draft.Please check status.' ? String(msg) : approvalPriceRuleOverlapMsg + ' ' + String(msg),
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