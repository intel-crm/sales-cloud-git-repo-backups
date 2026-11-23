import { LightningElement, api, wire, track } from "lwc";
import getKPIvalues from "@salesforce/apex/Core_MDF_KPIDetailPage.getKPIvalues";
import Core_MDF_ApplicationErrorMessage from "@salesforce/label/c.Core_MDF_KPI_ErrorMsg";
import plannedKPIMetrics from "@salesforce/label/c.Core_MDF_PlannedKPILabel";
import actualKPIMetrics from "@salesforce/label/c.Core_MDF_ActualMetricsLabel";
import ipaRecTypeName from "@salesforce/label/c.Core_MDF_IPA_RecordType";
import {OLD_KPI_FIELDS_PB, OLD_KPI_FIELDS_AB, OLD_KPI_FIELDS_ALL} from 'c/core_MDF_utilityModule';

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
  @api isProposalBasedActivity;
  @api recordtypeDeveloperName;
  @track result;

  label = {
    Core_MDF_ApplicationErrorMessage, plannedKPIMetrics, actualKPIMetrics,ipaRecTypeName,
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
      let helpTextMap = data.helpTextMap;
      let fldLabelToAPIName = new Map(Object.entries(data.fldLabelToAPINameMap));
      let fieldKeyWithHelpText = [];
      if (helpTextMap != null && helpTextMap != {} && Object.keys(helpTextMap).length > 0) {
        fieldKeyWithHelpText = Object.keys(helpTextMap);
      }
      for (let key in this.result) {
        // Preventing unexcepted data
        if (this.result.hasOwnProperty(key)) {
          //Added by VB
          if (this.recordtypeDeveloperName == this.label.ipaRecTypeName || this.recordtypeDeveloperName == 'Core_MDF_IPA_Account_Based') {
            if (this.displayHeader == this.label.plannedKPIMetrics || this.displayHeader == this.label.actualKPIMetrics) {
              if (fldLabelToAPIName.has(key) && this.isProposalBasedActivity && OLD_KPI_FIELDS_PB.includes(fldLabelToAPIName.get(key)) && this.result[key] !== '') {
                this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
              } else if (fldLabelToAPIName.has(key) && !this.isProposalBasedActivity && OLD_KPI_FIELDS_AB.includes(fldLabelToAPIName.get(key)) && this.result[key] !== '') {
                this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
              } else if(fldLabelToAPIName.has(key) && !OLD_KPI_FIELDS_ALL.includes(fldLabelToAPIName.get(key))){
                this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
              }
            }  else {
              this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
            }
          } else if (this.displayHeader == this.label.actualKPIMetrics) {
            if (fldLabelToAPIName.has(key) && OLD_KPI_FIELDS_ALL.includes(fldLabelToAPIName.get(key)) && this.result[key] !== '') {
              this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
            } else if(fldLabelToAPIName.has(key) && !OLD_KPI_FIELDS_ALL.includes(fldLabelToAPIName.get(key))){
              this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
            }
          } else {
            this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));

          }
        }
      }

      if (this.KPIdata.length !== 0) {
        this.isValidKPIdata = true;
        /* eslint-disable no-console*/
        this.displayLabel = data.displabel;
        console.log("label->" + this.displayLabel);
        //Event to indicate Metrics applicable
        const isKpiApplicable = true;
        const kpiActualEvent = new CustomEvent('kpiCompVisibilityEvent', { detail: { isKpiApplicable } });
        this.dispatchEvent(kpiActualEvent);
      }
    }
    if (error) {
      this.haserror = true;
      /* eslint-disable no-console*/
      console.log(this.error);
    }
  }


  prepareKPIData(fieldKeyWithHelpText, key, result, helpTextMap) {
    let kpiDt;
    if (fieldKeyWithHelpText.includes(key)) {
      kpiDt = { value: result[key], key: key, helpText: helpTextMap[key] };
    } else {
      kpiDt = { value: result[key], key: key };
    }
    return kpiDt;
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