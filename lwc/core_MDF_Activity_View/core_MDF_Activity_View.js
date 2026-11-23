import { LightningElement, api, track } from "lwc";

import Core_MDF_Activity_Type from "@salesforce/label/c.Core_MDF_Activity_Type";
import Core_MDF_Start_Date from "@salesforce/label/c.Core_MDF_Start_Date";
import Core_MDF_End_Date from "@salesforce/label/c.Core_MDF_End_Date";
import Core_MDF_Budget_Amount from "@salesforce/label/c.Core_MDF_Budget_Amount";
import Core_MDF_Activity_Category from "@salesforce/label/c.Core_MDF_Activity_Category";
import Core_MDF_KpiSection_Label from "@salesforce/label/c.Core_MDF_KpiSection_Label";
import Core_MDF_ViewDetails from "@salesforce/label/c.Core_MDF_ViewDetails";
import Core_MDF_PFRPicklistField from "@salesforce/label/c.Core_MDF_PFRPicklistField";
import getLabelApiMapforPicklistfields from "@salesforce/apex/Core_MDF_PartnerFundRequestCreatePage.getLabelApiMapforPicklistfields";
import requestedAmount from "@salesforce/label/c.Core_MDF_Budget_Amount";
import Core_MDF_ApplicationErrorMessage from "@salesforce/label/c.Core_MDF_ApplicationErrorMessage";

export default class Core_MDF_IPA_Activity_View extends LightningElement {
  @api rec;
  @api expndetail;
  @track activeSections;
  @api supportedactivityfld;
  @api showActivityDetailFlds = [];
  showActivityDetailFlds;
  @track callback = true;
  @track picklistApitoLabelReferenceMap = new Map();
  @track activityTypeValue;
  //add all the picklist/multiselect fields in the below object to display the localized value on accordion header
  @track accordionHeaderObj = { Core_MDF_Activity_Types__c: "" };

  activityType = Core_MDF_Activity_Type;
  startDate = Core_MDF_Start_Date;
  endDate = Core_MDF_End_Date;
  activityCategory = Core_MDF_Activity_Category;
  metrics = Core_MDF_KpiSection_Label;
  requestedAmount = Core_MDF_Budget_Amount;
  details = Core_MDF_ViewDetails;
  applicationError = Core_MDF_ApplicationErrorMessage;

  connectedCallback() {
    this.activeSections = this.expndetail;
    this.updatePFRRecord();
  }
  @api
  async updatePFRRecord(updatedPFRList) {
    if (this.picklistApitoLabelReferenceMap.size == 0) {
      await getLabelApiMapforPicklistfields({
        objName: "Core_MDF_Custom_Picklist__c",
        pfrPiclistField: Core_MDF_PFRPicklistField.split(","),
      })
        .then((result) => {
          this.picklistApitoLabelReferenceMap = new Map(Object.entries(result));
        })
        .catch((error) => {
          this.showErrorToast(applicationError, "sticky");
        });
    }
    var suppFld = this.supportedactivityfld;
    var fetchRec = null;

    if (updatedPFRList !== undefined && updatedPFRList !== null) {
      fetchRec = JSON.parse(JSON.stringify(updatedPFRList));
      this.activeSections = "A";
    } else {
      fetchRec = this.rec;
    }
    /* var myNewElement = [];
         for(let i = 0; i < suppFld.length; i++){
             for(var key in fetchRec){
                 if( key !== undefined && suppFld[i].fieldAPIName === key ){
                     myNewElement.push({ 'apiname': key,'label':suppFld[i].fieldLabel, 'value': fetchRec[key]});
                 }
             }
         }
         this.showActivityDetailFlds = [];
         this.showActivityDetailFlds = myNewElement; */

    var myNewElement = [];
    for (let i = 0; i < suppFld.length; i++) {
      for (var key in fetchRec) {
        if (key !== undefined && suppFld[i].fieldAPIName === key) {
          var fieldValue;
          if (fetchRec[key] != null && fetchRec[key].toString().includes(";")) {
            var multiselectValues = fetchRec[key].split(";");
            var localizedArr = [];
            multiselectValues.forEach((element) => {
              if (this.picklistApitoLabelReferenceMap.has(element)) {
                localizedArr.push(this.picklistApitoLabelReferenceMap.get(element));
              }
            });
            if (localizedArr.length > 0) {
              fieldValue = localizedArr.join(";");
            } else {
              fieldValue = fetchRec[key];
            }
          } else {
            fieldValue = this.picklistApitoLabelReferenceMap.has(fetchRec[key]) ? this.picklistApitoLabelReferenceMap.get(fetchRec[key]) : fetchRec[key];
            if (this.accordionHeaderObj.hasOwnProperty(key)) {
              this.accordionHeaderObj[key] = fieldValue;
            }
          }
          //Display the fields in accordion on clone of a proposal only when the value is not null. 
          //Activity Subtype Field is a multiselect picklist field and is in array format, so we have an explicit not blank check for this field.
          if((Array.isArray(fieldValue) && fieldValue.length > 0 && fieldValue[0]!=='') || (fieldValue!==null && fieldValue!== '' && fieldValue!==undefined && !Array.isArray(fieldValue)) ){
              myNewElement.push({ 'apiname': key, 'label': suppFld[i].fieldLabel, 'value': fieldValue });
        }
        }
      }
    }
    this.showActivityDetailFlds = [];
    this.showActivityDetailFlds = myNewElement;
  }

  handleSectionToggle(event) {
    const expandSection = new CustomEvent("showspif", {
      detail: event.detail.openSections,
    });
    this.dispatchEvent(expandSection);
  }

  showErrorToast(errorMessage, mode) {
    const evt = new ShowToastEvent({
      title: "Error!",
      message: errorMessage,
      variant: "error",
      mode: mode,
    });
    this.dispatchEvent(evt);
  }
}