import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class TestPNUM extends NavigationMixin(LightningElement) {
@api selectedPnumOption;
@api isAccountToUserSelected;

connectedCallback() {
    // Store the PageReference in a variable to use in handleClick.
    // This is a plain Javascript object that conforms to the
    // PageReference type by including "type" and "attributes" properties.
    // The "state" property is optional.
    this.pnumHomePageRef = {
        type: "standard__objectPage",
        attributes: {
            "objectApiName": "Core_MDF_Partner_Node_User_Mapping__c",
            "actionName": "home"
        }
    };
}

//To switch component based on selected value from mapping type
onPnumOptionChange(event) {
    const field = event.target.name;
    if (field === 'pnumOption') {
        this.selectedPnumOption = event.target.value;
        //if(event.target.value !=null){ // Need to handle for all listed options
        if(event.target.value === "A2U"){
            this.isAccountToUserSelected = false;
        }else{
            this.isAccountToUserSelected = true; 
        }
    //}
        } 
    }
        

        //To close modal popup
        onCancel(evt){
            // Stop the event's default behavior.
            // Stop the event from bubbling up in the DOM.
            evt.preventDefault();
            evt.stopPropagation();
            // Navigate to the Account Home page.
            this[NavigationMixin.Navigate](this.pnumHomePageRef);
        }
}