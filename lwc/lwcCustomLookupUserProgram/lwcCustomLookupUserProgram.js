import { LightningElement, api, track } from "lwc";
// eslint-disable-next-line no-unused-vars
import fetchUserPrograms from "@salesforce/apex/Core_MDF_LWC_AccountUserController.fetchUserAccessiblePrograms";

export default class LwcCustomLookupUserProgram extends LightningElement {
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
  @track txtclassname =
    "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
  //search icon
  @track iconFlag = true;
  //cross icon
  @track clearIconFlag = false;
  //on selection of record, to make it read only
  @track inputReadOnly = false;

  // Expose the labels to use in the template.
  label = {
    //searchUserLabel
  };

  //Testing DropDown
  @track valueK = 'select';
    get optionsK() {
        return [
            { label: 'Select', value: 'select' },
            { label: 'Client CoMarketing Fund', value: 'Client CoMarketing Fund' },
            { label: 'Data Center CoMarketing Fund', value: 'Data Center CoMarketing Fund' },
            { label: 'Service Provider CoMarketing Fund', value: 'Service Provider CoMarketing Fund' },
            { label: 'Client CoMarketing Fund Boost', value: 'Client CoMarketing Fund Boost' },
            { label: 'Retail Marketing Funds', value: 'Retail Marketing Funds' },
        ];
    }
    handleChangeK(event) {
        this.valueK = event.detail.value;
        window.console.log('this.valueK::'+this.valueK);
        this.setSelectedRecord();
    }
    //Called from HandleChange
    setSelectedRecord() {
      var programType = this.valueK;
      window.console.log('Inside first event::'+this.valueK);
      const programSelectedEvent = new CustomEvent("program", {
        detail: { programName: programType }
      });
      // Dispatches the event.
      this.dispatchEvent(programSelectedEvent);
    }
}