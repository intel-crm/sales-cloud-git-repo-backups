import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Core_IPS_CaseError_LWC extends NavigationMixin(LightningElement) {
    handleNavigateBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }

}