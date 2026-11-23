import { LightningElement, wire } from 'lwc';
import getHotButtons from '@salesforce/apex/AccountPlanControllerLWC.getHotButtons';

export default class AccountPlanSections extends LightningElement {
    // Wire to Apex methods to fetch Hot Buttons and Key Topics data
    @wire(getHotButtons) hotButtons;

    handleAddHotButton() {
        // Logic to add a new Hot Button (e.g., navigate to a new record page)
        console.log('Add Hot Button clicked');
    }

 
}