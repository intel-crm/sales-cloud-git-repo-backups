import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class OverrideNewAccountPlan extends NavigationMixin(LightningElement) {
    handleSuccess(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                objectApiName: 'AccountPlan',
                actionName: 'view'
            }
        });
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'AccountPlan',
                actionName: 'home'
            }
        });
    }
}