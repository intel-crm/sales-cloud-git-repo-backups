import { LightningElement, api, track } from "lwc";
import getResults from "@salesforce/apex/UCD_GenericAcctSearch_SBR.getResults";
import searchUserLabel from "@salesforce/label/c.Core_MDF_LWC_SearchUser_Label";
import WarningLabel from "@salesforce/label/c.UCD_UserSearchError";

export default class LwcCustomLookupUser extends LightningElement {
  //Object Name
  @api objectName = "User";
  //Field Name
  @api fieldName = "Name";
  //To hold selected record ID
  @api selectRecordId = "";
  //To hold selected record name
  @api selectRecordName;
  //To hold result Array
  @api searchRecords = [];
  //Is field required on front end
  @api required = false;
  //To show retrieved result in drop down
  @api txtclassname =
    "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
  //search icon
  @track iconFlag = true;
  //cross icon
  @track clearIconFlag = false;
  //on selection of record, to make it read only
  @api inputReadOnly = false;
  //error message to display on not selecting a user
  @api WarningLabelValue = WarningLabel;

  // Expose the labels to use in the template.
  label = {
    searchUserLabel
  };
  //On Load
  connectedCallback(){
    this.resetData();
    //this.inputReadOnly = true;
  }
  //Fired on OnChange of input
  searchField(event) {
    var currentText = event.target.value;
    console.log('Search', currentText);
    
    //To fetch similar records as per search
    getResults({
      searchObjectName: this.objectName,
      searchFieldName: this.fieldName,
      value: currentText
    })
      .then(result => {
        this.searchRecords = result;

        this.txtclassname =
          result.length > 0
            ? "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open"
            : "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";

        if (this.selectRecordId != null && this.selectRecordId.length > 0) {
          this.iconFlag = false;
          this.clearIconFlag = true;
        } else {
          this.iconFlag = true;
          this.clearIconFlag = false;
        }
      })
  }
  //Called when user selects a record from searched drop down results, event passes select record name & Id
  setSelectedRecord(event) {
    var currentText = event.currentTarget.dataset.id;
    var selectName = event.currentTarget.dataset.name;
    this.txtclassname =
      "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
    this.iconFlag = false;
    this.clearIconFlag = true;
    this.selectRecordName = event.currentTarget.dataset.name;
    this.selectRecordId = currentText;
    this.inputReadOnly = true;
    const selectedEvent = new CustomEvent("selected", {
      detail: { recordName: selectName, recordId: currentText }
    });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }
  //On click of cross icon, reseting the internal variables & external screen
  @api
  resetData() {
    this.template.querySelectorAll('lightning-input').forEach(each => {
      each.value = '';
    });
    this.selectRecordName = '';
    this.selectRecordId = '';
    this.searchRecords = '';
    this.inputReadOnly = false;
    this.iconFlag = true;
    this.clearIconFlag = false;
    this.txtclassname =
      "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
    const selectedEvent = new CustomEvent("remove", {
      detail: { recordId: null }
    });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }
}