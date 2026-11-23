import { LightningElement, track, api } from 'lwc';
import accountFieldLabel from "@salesforce/label/c.Core_MDF_LWC_SelectAccount_Label";

export default class Core_MDF_AccountOnboard extends LightningElement {

     //Flag to toggle Spinner
  @track loaded = true;
 //To hold Account Record Id
  @api recordId;
   //To Hold Program Name
   @api programName; 

  // Expose the labels to use in the template.
  label = {
    accountFieldLabel
  };
  connectedCallback() {
    
}

//programSelected
programSelected(event) {
  this.template.querySelector("c-lwc-custom-lookup").resetData();
  this.resetAllData();
  this.programName = event.detail.programName;
  //On selection of select - disable input 
  if(event.detail.programName === 'select'){
    this.template.querySelector("c-lwc-custom-lookup").inputReadOnly = true;
    this.inputDisable = true;
  }else{
    this.template.querySelector("c-lwc-custom-lookup").inputReadOnly = false;
    this.inputDisable = false;
  }
}

  // Function called on account record selection from lookup.This is the selected account record
  selectedRecord(event) {
    this.loaded = !this.loaded;
    if (event.detail.recordId != null) {
      //Selected account record Id
      this.recordId = event.detail.recordId;
      //To populate users list on account select from lookup search
      //this.populateLookupUsers(this.recordId);
    } else {
      this.loaded = !this.loaded;
      //reset data
     // this.resetAllData();
    }
  }
}