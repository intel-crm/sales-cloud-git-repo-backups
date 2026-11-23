import { LightningElement , api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Test_back extends NavigationMixin(LightningElement) {
    @ api invoke(){
        this.navigateToDefaultPage();
    }
navigateToDefaultPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'PCC_Rebate_Claim_Stage__c', // Object API name, e.g., Account, Contact
                actionName: 'home' // actionName can be 'view', 'edit', or 'clone'
            },
        });
    }
}