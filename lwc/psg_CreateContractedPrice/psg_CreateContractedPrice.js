import { LightningElement, track,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
export default class PSG_CreateContractedPrice extends NavigationMixin(LightningElement) {

    navigateToNewContractedPrice() {
        const defaultValues = encodeDefaultFieldValues({
            //FirstName: 'Morag',
            //LastName: 'de Fault',
            //LeadSource: 'Other'
        });
    
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SBQQ__ContractedPrice__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }
}