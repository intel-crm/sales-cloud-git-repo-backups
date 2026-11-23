import { LightningElement, api, wire, track } from "lwc";
import getKPIvalues from "@salesforce/apex/Core_MDF_KPIDetailPage.getKPIvalues";
import Core_MDF_ApplicationErrorMessage from "@salesforce/label/c.Core_MDF_KPI_ErrorMsg";
import plannedKPIMetrics from "@salesforce/label/c.Core_MDF_PlannedKPILabel";
import actualKPIMetrics from "@salesforce/label/c.Core_MDF_ActualMetricsLabel";
import ipaPropBasedRecTypeName from "@salesforce/label/c.Core_MDF_IPA_RecordType";
import ipaAccBasedRecTypeName from '@salesforce/label/c.Core_MDF_IPA_AccountBased_RecType_DevName';
import { OLD_KPI_FIELDS_PB, OLD_KPI_FIELDS_AB, OLD_KPI_FIELDS_ALL } from 'c/core_MDF_utilityModule';
import logErrorImperative from '@salesforce/apex/Core_MDF_KPIDetailPage.logErrorImperative'; //Unhandeled Exception fix added by Shravani

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
  @track helpTextResult;

  label = {
    Core_MDF_ApplicationErrorMessage, plannedKPIMetrics, actualKPIMetrics, ipaPropBasedRecTypeName,ipaAccBasedRecTypeName
  };

  connectedCallback() {
    /* eslint-disable no-console*/
    console.log('OUTPUT : constants', OLD_KPI_FIELDS_PB, OLD_KPI_FIELDS_ALL);
    console.log("LWC recordIdinput->" + this.recordIdinput);
    console.log("LWC objectApiNameinput->" + this.objectApiNameinput);

    // eval("$A.get('e.force:refreshView').fire();");

    if (this.recordIdinput !== undefined) {
      this.recordId = this.recordIdinput;
    }
    if (this.objectApiNameinput !== undefined) {
      this.objectApiName = this.objectApiNameinput;
    }

    console.log("requestId RP " + this.RequestId);

    console.log("LWC recordId->" + this.recordId);
    console.log("LWC objectApiName->" + this.objectApiName);
    console.log("LWC displayHeader-> JK" + this.displayHeader);
    console.log('marketingKeyPerfValues', this.marketingKeyPerfValues);
    console.log('programName', this.programName);
    console.log('isProposalBasedActivity', this.isProposalBasedActivity);
    console.log('recordtypeDeveloperName', this.recordtypeDeveloperName);
  }

  @wire(getKPIvalues, {
    recordId: "$recordId",
    objectApiName: "$objectApiName",
    displayHeader: "$displayHeader"
  })
  loaddata({ data, error }) {
    debugger;
    //eval("$A.get('e.force:refreshView').fire();");
    if (data) {
      this.result = data.datamap;
      this.helpTextResult = data.helpTextMap
      console.log("data->" + this.result);
      console.log("dataHelp->" + this.helpTextResult);
      let helpTextMap = data.helpTextMap;
      let fldLabelToAPIName = new Map(Object.entries(data.fldLabelToAPINameMap));
      //fldLabelToAPIName = data.fldLabelToAPINameMap;
      let fieldKeyWithHelpText = [];
      if (helpTextMap != null && helpTextMap != {} && Object.keys(helpTextMap).length > 0) {
        fieldKeyWithHelpText = Object.keys(helpTextMap);
      }
      /*let oldKPIFields = ['Core_MDF_Lead_Quantity_nbr__c', 'Core_MDF_Deployment_Quantity_nbr__c', 'Core_MDF_Other_Quantity_nbr__c', 'Core_MDF_Metrics_txt__c'];
      let oldKPIFieldsForPB = ['Core_MDF_Lead_Quantity_nbr__c', 'Core_MDF_Deployment_Quantity_nbr__c', 'Core_MDF_Other_Quantity_nbr__c'];
      let oldKPIFieldsForAB = ['Core_MDF_Metrics_txt__c'];*/
      for (let key in this.result) {
        // Preventing unexcepted data
        if (this.result.hasOwnProperty(key)) {
          //Added by VB
          if (this.recordtypeDeveloperName == this.label.ipaPropBasedRecTypeName || this.recordtypeDeveloperName == this.label.ipaAccBasedRecTypeName) {
            if (this.displayHeader == this.label.plannedKPIMetrics || this.displayHeader == this.label.actualKPIMetrics) {
              if (fldLabelToAPIName.has(key) && this.isProposalBasedActivity && OLD_KPI_FIELDS_PB.includes(fldLabelToAPIName.get(key)) && this.result[key] !== '') {
                this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
              } else if (fldLabelToAPIName.has(key) && !this.isProposalBasedActivity && OLD_KPI_FIELDS_AB.includes(fldLabelToAPIName.get(key)) && this.result[key] !== '') {
                this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
              } else if (fldLabelToAPIName.has(key) && !OLD_KPI_FIELDS_ALL.includes(fldLabelToAPIName.get(key))) {
                this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
              }
            } else {
              this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
            }
          } else if (this.displayHeader == this.label.actualKPIMetrics) {
            if (fldLabelToAPIName.has(key) && OLD_KPI_FIELDS_ALL.includes(fldLabelToAPIName.get(key)) && this.result[key] !== '') {
              console.log('key', key);
              this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
            } else if (fldLabelToAPIName.has(key) && !OLD_KPI_FIELDS_ALL.includes(fldLabelToAPIName.get(key))) {
              this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
            }
          } else {
            this.KPIdata.push(this.prepareKPIData(fieldKeyWithHelpText, key, this.result, helpTextMap));
          }
        }
      }

      //this.KPIdata.sort((a,b) => a.key.localeCompare(b.key));

      if (this.KPIdata.length !== 0) {
        this.isValidKPIdata = true;
        /* eslint-disable no-console*/
        this.displayLabel = data.displabel;
        console.log("label->" + this.displayLabel);
        console.log("kpidata> line number 76" + JSON.parse(JSON.stringify(this.KPIdata)));
        //Event to indicate Metrics applicable
        const isKpiApplicable = true;

        const kpiActualEvent = new CustomEvent('kpiCompVisibilityEvent', { detail: { isKpiApplicable } });
        this.dispatchEvent(kpiActualEvent);

        // const plannedMetricEvent = new CustomEvent('valuesFromActivityEvent', { detail: {apiNameToValueMap}});
        // this.dispatchEvent(plannedMetricEvent);
      }
    }
    if (error) {
      this.haserror = true;
      /* eslint-disable no-console*/
      console.log(this.error);
      //START: Unhandled exception fix added by Sharavani 
      // Logs error received from Apex and persists it for tracking purposes
      /*const errorMessage = error.body ? error.body.message || JSON.stringify(error.body) : JSON.stringify(error);
        logErrorImperative({
        errorMessage,
        objectApiName: this.objectApiName
    });*/
      const errorPayload = {
          message: error?.body?.message,
          stackTrace: error?.body?.stackTrace,
          exceptionType: error?.body?.exceptionType,
          pageErrors: error?.body?.pageErrors,
          fieldErrors: error?.body?.fieldErrors
      };

      logErrorImperative({
          errorMessage: JSON.stringify(errorPayload),
          objectApiName: this.objectApiName
      });
      //END: Unhandled exception fix added by Sharavani 
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
      console.log("data->" + this.helpTextMap);
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