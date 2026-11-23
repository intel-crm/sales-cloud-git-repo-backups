import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

// Hardcoded Record Type ID
const HARD_CODED_RECORD_TYPE_ID = '012D30000007OcxIAE'; // Replace with your actual Record Type ID

export default class NewRecordButton extends NavigationMixin(LightningElement) {
    navigateToNewRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Core_Design_Registration__c', // Replace with your object API name
                actionName: 'new'
            },
            state: {
                recordTypeId: HARD_CODED_RECORD_TYPE_ID
            }
        });
    }
}