import { LightningElement,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class DealReg_NavigateToListViewPage extends NavigationMixin(LightningElement){

    handleListViewNavigation() {
        // Navigate to the Core_Design_Registration__c object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Core_Design_Registration__c',
                actionName: 'list'
            },
            state: {
                // 'filterName' is a property on 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                // or by 18 char '00BT0000002TONQMA4'
                filterName: 'Default?Core_Design_Registration__c-filterId=00BDf00000AJJUWMA5' 
            }
        });
    }
}