import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class PCC_ValidateDealForm extends LightningElement {
    @api recordId;
    isSubmit = true;

    showSubmissionMsg(event){
        const detail = event.detail;
        const message = event.detail.message;
        if(!detail.recordError){
            if (detail.isSuccess) {
                this.showToast(`Deal Registration ${message} submitted successfully for Approval !!`, 'success',detail.isSuccess);
            } else {
                this.showToast(detail.message, 'error',detail.isSuccess);
            }
        }
    }

    showToast(message, variant,isSubmitted) {
        const toastEvent = new ShowToastEvent({
            title: message,
            message: '',
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
        setTimeout(() => {
            this.dispatchEvent(new CustomEvent('closequickmodal',{ detail: { isDealSubmitted: isSubmitted } }));
        }, 3000);
    }
}