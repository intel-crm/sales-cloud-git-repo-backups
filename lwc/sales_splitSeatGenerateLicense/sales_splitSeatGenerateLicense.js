import { LightningElement,track } from 'lwc';

export default class Sales_splitSeatGenerateLicense extends LightningElement {

    
   
    navigateToLicenseRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Sales_License__c', // objectApiName is optional
                actionName: 'view'
            }
        });

        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'The selected product license splitted succesfully',
            variant: 'success',
            mode: 'dismissable'
        }); 
        this.dispatchEvent(evt);
    }   

}