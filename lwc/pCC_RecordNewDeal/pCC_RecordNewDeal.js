import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CORE_DESIGN_REGISTRATION_OBJECT from '@salesforce/schema/Core_Design_Registration__c';

export default class NewRecordButton extends NavigationMixin(LightningElement) {
    recordTypeId;
    recordTypeName = 'Deal Registration - Draft'; 
    @wire(getObjectInfo, { objectApiName: CORE_DESIGN_REGISTRATION_OBJECT })
    objectInfo({ error, data }) {
        if (data) {
            const recordTypes = data.recordTypeInfos;
            this.recordTypeId = Object.keys(recordTypes).find(
                rtId => recordTypes[rtId].name === this.recordTypeName
            );
        } else if (error) {
            console.error('Error retrieving object info:', error);
        }
    }

    navigateToNewRecord() {
        if (this.recordTypeId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Core_Design_Registration__c', 
                    actionName: 'new'
                },
                state: {
                    recordTypeId: this.recordTypeId
                }
            });
        } else {
            console.error('Record Type ID is not available.');
        }
    }
}