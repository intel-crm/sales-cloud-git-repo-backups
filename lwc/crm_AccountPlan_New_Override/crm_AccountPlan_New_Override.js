import { LightningElement } from 'lwc';

export default class AccountPlanModalForm extends LightningElement {
    showModal = true;

    handleCancel() {
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleSuccess(event) {
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('close'));

        // Optional: Navigate to new record
        // const recordId = event.detail.id;
    }
}