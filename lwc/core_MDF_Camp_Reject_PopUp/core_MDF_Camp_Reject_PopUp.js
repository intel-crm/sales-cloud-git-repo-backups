import { LightningElement, api } from "lwc";

export default class ExploreModalsLWC extends LightningElement {
  @api recordId;
  statusVal ='';
  terminal_rejection=false;

  handlePopup() {
    this.template.querySelector("section").classList.remove("slds-hide");
    this.template
      .querySelector("div.modalBackdrops")
      .classList.remove("slds-hide");
  }

  handleCancel() {
    this.template.querySelector("section").classList.add("slds-hide");
    this.template
      .querySelector("div.modalBackdrops")
      .classList.add("slds-hide");
  }
  onSubmitHandler(event){
    const fields = event.detail.fields;
    // this.statusVal = 'Rejected';
    // fields.Status = this.statusVal;
    this.terminal_rejection = true;
    fields.Core_MDF_Terminal_Rejection__c = this.terminal_rejection;
    this.template.querySelector("lightning-record-edit-form").submit(fields);
  }
}