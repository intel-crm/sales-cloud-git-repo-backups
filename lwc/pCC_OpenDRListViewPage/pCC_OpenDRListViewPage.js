import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ButtonExample extends NavigationMixin(LightningElement) {
    handleButtonClick() {
        // Generate a URL for the page you want to open
        const pageReference = {
            type: 'standard__webPage',
            attributes: {
                //url: '/partneradmin/s/core-design-registration/Core_Design_Registration__c/Default'
                url: '/partneradmin/s/design-distribution-stage'
            }
        };
        
        // Open the page in a new tab
        this[NavigationMixin.Navigate](pageReference, true);
    }
}