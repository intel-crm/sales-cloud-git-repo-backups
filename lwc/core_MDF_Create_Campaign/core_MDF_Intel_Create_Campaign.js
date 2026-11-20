import { LightningElement, track, wire, api } from 'lwc';
import Core_MDF_PFR_None_Translation from '@salesforce/label/c.Core_MDF_PFR_None_Translation';

export default function fetchPicklistFields(fldname,scontrolvalues,sfieldcompletevalues,campaignPicValues){
        var controllingFieldValues = JSON.stringify(scontrolvalues).slice(1, -1);
        var confieldmap = new Object();
        //console.log('controllingFieldValues--'+controllingFieldValues);
        if (controllingFieldValues != "") {
            var res = controllingFieldValues.split(",");
  
            for (var index = 0; index < res.length; index++) {
                var keyvalue = res[index].split(":");
                confieldmap[keyvalue[1]] = keyvalue[0].slice(1, -1);
            }
        }
        var sValues;
        var childPickField = new Object();
        var ParPickField = []; //new Array();
        //console.log('sfieldcompletevalues--'+sfieldcompletevalues);
        for (var i = 0; i < sfieldcompletevalues.length; i++) {
            if (sfieldcompletevalues[i].validFor.length > 0) {
                for (var j = 0; j < sfieldcompletevalues[i].validFor.length; j++) {
                    var key = confieldmap[sfieldcompletevalues[i].validFor[j]];
                        if (key in childPickField) {
                            childPickField[key].push({
                            class: "optionClass",
                            label: sfieldcompletevalues[i].label,
                            value: sfieldcompletevalues[i].value
                            });
                        } else {
                            sValues = new Array();
                            sValues.push({
                            class: "optionClass",
                            label: sfieldcompletevalues[i].label,
                            value: sfieldcompletevalues[i].value
                            });
                            childPickField[key] = sValues;
                        }
                    }
                } 
            else {
            if (ParPickField.length == 0) {
                if (fldname != "Core_MDF_Reimbursement_Rate_pct__c" && fldname != "Core_MDF_Country_nm__c") {
                ParPickField.push({
                class: "optionClass",
                label: Core_MDF_PFR_None_Translation,
                value: ""
                });
                }
            }
            //console.log('ParPickField--'+ParPickField);
            ParPickField.push({
            class: "optionClass",
            label: sfieldcompletevalues[i].label,
            value: sfieldcompletevalues[i].value
            });
            }            
        } 
        //console.log('ParPickField--'+JSON.stringify(ParPickField));
        if (ParPickField.length > 0) {
            if (fldname == "Core_MDF_TargetAudience__c") {
                campaignPicValues["Core_MDF_Audience__c"] = ParPickField;
            }
            if (fldname == "Core_MDF_ProductType__c") {
                campaignPicValues["Core_MDF_Product_Type__c"] = ParPickField;
            }
            if (fldname == "Core_MDF_Brand__c") {
                campaignPicValues["Core_MDF_Brand__c"] = ParPickField;
            }
            if (fldname == "Core_MDF_Technology__c") {
                campaignPicValues["Core_MDF_Technology__c"] = ParPickField;
            }
            if (fldname == "Core_MDF_Priority__c") {
                campaignPicValues["Core_MDF_IPA_Priority_nm__c"] = ParPickField;
            }
            if (fldname == "Core_MDF_Ecosystem_Partner__c") {
                campaignPicValues["Core_MDF_Ecosystem_Partner_Nm__c"] = ParPickField;
            }
            if (fldname == "Core_MDF_Industry__c") {
                campaignPicValues["Core_MDF_Industry_Nm__c"] = ParPickField;
            }
            /*
            if (fldname == "Core_MDF_Country_nm__c") {
                component.set("v.CountryPicklistValues", ParPickField);
                this.localizeCountry(component, ParPickField);
            }
            if (fldname == "Core_MDF_Reimbursement_Rate_pct__c") {
                component.set("v.ReimbursementRateVal", ParPickField);
            } else if (fldname == "Core_MDF_ProductType__c") {
                component.set("v.ProductTypes", ParPickField);
            }
            if (fldname == "Core_MDF_Activity_Types__c") {
                component.set("v.ActivityTypes", ParPickField);
            }*/
        }
       /* else {
            if (fldname == "Core_MDF_Brand__c") {
                component.set("v.BrandTypes", childPickField);
                this.fetchBrandType(component);
            } */
            /*if (fldname == "Core_MDF_Activity_Types__c") {
                component.set("v.ActivityTypes", childPickField);
                this.fetchActType(component);
            }
            if (fldname == "Core_MDF_Activity_Sub_Type_nm__c") {
                component.set("v.ActivitySubTypes", childPickField);
                this.fetchActSubType(component);
            }
            if (fldname == "Core_MDF_ProductType__c") {
                component.set("v.ProductTypes", childPickField);
                this.fetchProdType(component);
            }
            
            if (fldname == "Core_MDF_Event_Format_Nm__c") {
                component.set("v.eventFormats", childPickField);
                component.set("v.setEventFormatOptionOnload", true);
                this.fetchEventFormat(component);
            }
        } */

}
    
  /*  showBudgetErrorToast(ErrorMessage)
    {
        const evt1 = new ShowToastEvent({
          title: 'Warning!',
          message: ErrorMessage,
          mode: 'pester',
          type: 'warning',
      });
   } */