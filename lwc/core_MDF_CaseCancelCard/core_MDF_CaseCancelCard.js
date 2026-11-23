import { LightningElement, api } from 'lwc';

export default class Core_MDF_CaseCancelCard extends LightningElement {
    @api recordId;

    commentValue = '';
    canCancel = true;
    isLoading = false;
    isModalOpen = false;

    get disableConfirm() {
        return this.isLoading || !this.commentValue;
    }

    handleClick() {
        this.isModalOpen = true;
    }

    handleJustificationChange(event) {
        this.commentValue = event.target.value;
    }

    closeModal() {
        this.isModalOpen = false;
        this.commentValue = '';
    }

    callCancelCase() {
        this.closeModal();
    }
}