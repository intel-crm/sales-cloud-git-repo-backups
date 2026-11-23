//Imports
import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class LwcTest extends NavigationMixin(
  LightningElement
) {
  //Boolean must be default to false
  //Flag to toggle component based on action 
  @api isUserToAccountSelected;

  //Onload function
  connectedCallback() {
    // Store the PageReference in a variable
    this.pnumHomePageRef = {
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Core_MDF_Partner_Node_User_Mapping__c",
        actionName: "home"
      },
      state: {
        filterName: "Recent"
      }
    };
  }

  //To switch component based on selected value from action dropdown
  onPnumOptionChange(event) {
    //Hold element/field name
    const fieldName = event.target.name;
    if (fieldName === "pnumAction") {
      //Check field value
      if (event.target.value === "A2U") {
        //If account to user action selected
        this.isUserToAccountSelected = false;
      } else {
         //If user to account action selected
        this.isUserToAccountSelected = true;
      }
    }
  }

    //Navigate to account user home page on close/cancel modal popup
    onCancel() {
      this[NavigationMixin.Navigate](this.pnumHomePageRef);
    }
}