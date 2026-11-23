import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AddressVerificationModal from 'c/ucd_ACM_Address_Verification_Modal';

export default class Ucd_ACM_Address_Verify_Action extends LightningElement {
    @api recordId;
    isExecuting = false;

    @api async invoke() {
        if (this.isExecuting) {
            return;
        }
        this.isExecuting = true;
        try {
            const result = await AddressVerificationModal.open({
                size: 'medium',
                label: 'Verify Address',
                recordId: this.recordId
            });
            if (result && result.status === 'verified') {
                this.showToast('success', 'Success', 'Address verified and standardized successfully.');
            } else if (result && result.status === 'entered') {
                this.showToast('warning', 'Address Not Standardized', 'Proceeding with the address as entered. Address is not standardized.');
            } else if (result && result.status === 'error') {
                this.showToast('error', 'Error', result.message || 'An error occurred while updating the record.');
            }
        } finally {
            this.isExecuting = false;
        }
    }

    showToast(variant, title, message) {
        this.dispatchEvent(new ShowToastEvent({ variant, title, message }));
    }
}