import { LightningElement, api, wire, track } from "lwc";
import getKPIvalues from "@salesforce/apex/Core_MDF_KPIDetailPage.getKPIvalues";
import Core_MDF_ApplicationErrorMessage from "@salesforce/label/c.Core_MDF_KPI_ErrorMsg";

export default class Core_MDF_KPIDetailSection extends LightningElement {
  @track KPIdata = [];
  @api recordId;
  @api objectApiName;
  @track isValidKPIdata = false;
  @track haserror = false;
  @api recordIdinput;
  @api objectApiNameinput;
  @api displayLabel;
  @api displayHeader;
  @track result;

  label = {
    Core_MDF_ApplicationErrorMessage,
  };

  connectedCallback() {
    /* eslint-disable no-console*/
    console.log("LWC recordIdinput->" + this.recordIdinput);
    console.log("LWC objectApiNameinput->" + this.objectApiNameinput);

    // eval("$A.get('e.force:refreshView').fire();");

    if (this.recordIdinput !== undefined) {
      this.recordId = this.recordIdinput;
    }
    if (this.objectApiNameinput !== undefined) {
      this.objectApiName = this.objectApiNameinput;
    }

    console.log("LWC recordId->" + this.recordId);
    console.log("LWC objectApiName->" + this.objectApiName);
    console.log("LWC displayHeader->" + this.displayHeader);
  }


  @wire(getKPIvalues, {
    recordId: "$recordId",
    objectApiName: "$objectApiName",
    displayHeader: "$displayHeader"
  })
  loaddata({ data, error }) {
    //eval("$A.get('e.force:refreshView').fire();");
    if (data) {
      this.result = data.datamap;
      console.log("data->" + this.result);
      for (let key in this.result) {
        // Preventing unexcepted data
        if (this.result.hasOwnProperty(key)) {
          // Filtering the data in the loop
          this.KPIdata.push({ value: this.result[key], key: key });
        }
      }

      if (this.KPIdata.length !== 0) {
        this.isValidKPIdata = true;
        /* eslint-disable no-console*/
        this.displayLabel = data.displabel;
        console.log("label->" + this.displayLabel);
      }
    }
    if (error) {
      this.haserror = true;
      /* eslint-disable no-console*/
      console.log(this.error);
    }
  }


  @api LoadKPI(srecordId, sobjectApiName, sHeaderName) {
    this.KPIdata = [];

    getKPIvalues({
      recordId: srecordId,
      objectApiName: sobjectApiName,
      displayHeader: sHeaderName
    }).then(data => {
      this.result = data.datamap;
      console.log("data->" + this.result);
      for (let key in this.result) {
        // Preventing unexcepted data
        if (this.result.hasOwnProperty(key)) {
          // Filtering the data in the loop
          this.KPIdata.push({ value: this.result[key], key: key });
        }
        if (this.KPIdata.length !== 0) {
          this.isValidKPIdata = true;
          /* eslint-disable no-console*/
          this.displayLabel = data.displabel;
          console.log("label->" + this.displayLabel);
        }
      }
      /* eslint-disable no-console*/
      console.log(this.KPIdata);
    });
  }


}