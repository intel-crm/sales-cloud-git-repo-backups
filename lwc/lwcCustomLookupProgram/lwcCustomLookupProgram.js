import { LightningElement, track } from "lwc";
import fetchUserPrograms from "@salesforce/apex/Core_MDF_LWC_AccountUserController.fetchUserAccessiblePrograms";
import defaultSelectValue from "@salesforce/label/c.Core_MDF_SearchProgram_Label";

export default class LwcCustomLookupProgram extends LightningElement {
  //To Hold Available Program Map
  @track ProgramMap = [];
  //Available Programs 
  @track availableProgramMap;
  //DropDown
  @track selectedValue = defaultSelectValue;
  // Expose the labels to use in the template.
  label = {
    defaultSelectValue //defaultSelectValue
  };
  //Called onload
  connectedCallback() {
    //find Programs
    fetchUserPrograms({
    })
      .then(result => {
        if (result !== null || result !== undefined) {
          //Getting all available program list
          this.ProgramMap.push({
            label: defaultSelectValue,
            value: 'select'
          });
            for (let key in result) {
              if (result.hasOwnProperty(key)) {
                //Creating the array of all available programs
                this.ProgramMap.push({
                  label: result[key],
                  value: key
                });
              }
            }
            this.availableProgramMap = this.ProgramMap;
          }
        });
    }
    //Called on Program Change
    handleChange(event) {
        this.selectedValue = event.detail.value;
        this.setSelectedRecord();
    }
    //Called from HandleChange
    setSelectedRecord() {
      var programType = this.selectedValue;
      const programSelectedEvent = new CustomEvent("program", {
        detail: { programName: programType }
      });
      // Dispatches the event.
      this.dispatchEvent(programSelectedEvent);
    }
    //Focus Event
    focusEvent() {
      const focusedEvent = new CustomEvent("focus", {
        detail: { focused: "focus" }
      });
      // Dispatches the event.
      this.dispatchEvent(focusedEvent);
    }
}