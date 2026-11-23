import { LightningElement } from "lwc";
/*import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import getBaseLicenseRecords from "@salesforce/apex/Sales_ApplyRenewalController.getBaseLicenseRecords";
import applyRenewals from "@salesforce/apex/Sales_ApplyRenewalController.applyRenewals";
import validateRenewalrecord from "@salesforce/apex/Sales_ApplyRenewalController.validateRenewalrecord";
import existingrenewal from '@salesforce/label/c.Sales_existing_renewal_seat';
import SalesApplyrenewalheading from '@salesforce/label/c.Sales_Apply_renewal_heading';
import Salesrenewalseat from '@salesforce/label/c.Sales_renewal_seat';
import SalesLicenseFilter from '@salesforce/label/c.Sales_License_Filter';
import SalesLicenseSplit from '@salesforce/label/c.Sales_License_Split';
import SalesNotEnoughLicense from '@salesforce/label/c.Sales_NotEnough_License';
import SalesNotActiveMaintainance from '@salesforce/label/c.Sales_NotActive_Maintainance';
import SalesNotRenewLicense from '@salesforce/label/c.Sales_NotRenew_License';
import SalesFoundationToAnotherProduct from '@salesforce/label/c.Sales_FoundationToAnotherProduct';
import SalesNoBaseLicensetoRenew from '@salesforce/label/c.Sales_NoBaseLicense_toRenew';
import SalesSomethingWrong from '@salesforce/label/c.Sales_Something_Wrong';
import SalesNoofSeatsToRenew from '@salesforce/label/c.Sales_No_of_SeatsTo_Renew';
import SalesZeroAvailableQuantity from '@salesforce/label/c.Sales_Zero_Available_Quantity';
import SalesLicensedCancelledStatus from '@salesforce/label/c.Sales_Licensed_CancelledStatus';
import SalesSuccessMessageforRenewedLicense from '@salesforce/label/c.Sales_Success_Messagefor_RenewedLicense';
import SalesBaseLicensetoRenewError from '@salesforce/label/c.Sales_Base_License_toRenew_Error';
import SalesNotEnoughLicError from '@salesforce/label/c.Sales_Not_EnoughLic_Error';
import SalesLicenseNotEqualRenewalError from '@salesforce/label/c.Sales_License_NotEqual_Renewal_Error';
import SalesNoofSeats from '@salesforce/label/c.Sales_No_of_Seats';
import SalesNoofseatsGreater from '@salesforce/label/c.Sales_No_of_seats_Greater';
import SalesSeatsNotGreaterError from '@salesforce/label/c.Sales_Seats_Not_Greater_Error';
const FIELDS = [
        "Sales_License__c.Id",
        "Sales_License__c.Name",
        "Sales_License__c.Sales_License_Expiration_Date_Dt__c",
        "Sales_License__c.Sales_License_Avbl_Rehost_Nbr__c",
        "Sales_License__c.Sales_License_Avbl_Qty_Nbr__c",
        "Sales_License__c.Sales_License_Status__c",
        "Sales_License__c.Sales_License_Product__c",
        "Sales_License__c.Sales_License_Product__r.Name",
        "Sales_License__c.Sales_License_Product__r.Core_OPN__c",
        "Sales_License__c.Sales_License_Maintenance_Exp_Dt__c",
        "Sales_License__c.Sales_License_Quantity__c",
        "Sales_License__c.Sales_Tool_License_Type__c",
        "Sales_License__c.Sales_License_Host_Node_Id__r.Name",
        "Sales_License__c.Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c",
        "Sales_License__c.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c",
        "Sales_License__c.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c",
        "Sales_License__c.Sales_License_Web_Display_Flag__c",
        "Sales_License__c.Sales_License_Activation_Code__c",
];
const columns = [
        { label: "License Name", fieldName: "Name", type: "text" },
        { label: "Product", fieldName: "prodName" },
        { label: "Part Number", fieldName: "prodOpn" },
        {
                label: "Maintenance Expiration",
                fieldName: "Sales_License_Maintenance_Exp_Dt__c",
                type: "date",
        },
        { label: "# Seats", fieldName: "Sales_License_Quantity__c", type: "text" },
        {
                label: "Rehost Available",
                fieldName: "Sales_License_Avbl_Rehost_Nbr__c",
                type: "text",
        },
        {
                label: "Primary Computer Id",
                fieldName: "HostPrimaryCompId",
                type: "text",
        },
        {
                label: "Primary Computer Name",
                fieldName: "HostPrimaryCompName",
                type: "text",
        },
];
const baseLicenseColumns = [
        { label: "License Name", fieldName: "Name", type: "text" },
        { label: "Product", fieldName: "prodName" },
        { label: "Part Number", fieldName: "prodOpn" },
        {
                label: "Maintenance Expiration",
                fieldName: "Sales_License_Maintenance_Exp_Dt__c",
                type: "date",
        },
        {
                label: "# Seats (Prior to split)",
                fieldName: "Sales_License_Quantity__c",
                type: "text",
        },
        {
                label: "# Seats (After split)",
                fieldName: "afterRenewalSeatsCount",
                type: "text",
        },
        {
                label: "# Seats (After split on Renewed license)",
                fieldName: "afterRenewalSeatsCountOnNewLicense",
                type: "text",
        },
];
//Labels
import errorMsg from "@salesforce/label/c.Sales_Error_Message"; //Error title
import SystemModstamp from "@salesforce/schema/Account.SystemModstamp";*/
export default class sales_ApplyRenewal extends LightningElement{
        /*@api baseLicenseColumns = baseLicenseColumns;
        @track selectedValue;
        @track tempData = [];
        @track dataReturn = [];
        @api recordId;
        renewalLicense;
        showRenewalLicenseValidationErr = false;
        @api noOfSeatsToRenew;
        errorMsg;
        @track data = [];
        @api baseLicensedata = [];
        isRenewalLicenseInvalid = true;
        errorMsgForBaseLicenses;
        selectedlicenses;
        today = new Date();
        @api columns = columns;
        @track isLoaded = false;
        @api selectedbaseLicenses;
        @track baselicense=true;
        @api isfoundationfound = false;
        @track isfoundationcheck = false;
        label = {existingrenewal,SalesApplyrenewalheading,Salesrenewalseat,SalesLicenseFilter,SalesLicenseSplit,SalesNotEnoughLicense,SalesNotActiveMaintainance,
                SalesNotRenewLicense,SalesFoundationToAnotherProduct,SalesNoBaseLicensetoRenew,SalesSomethingWrong,SalesNoofSeatsToRenew,
                SalesZeroAvailableQuantity,SalesLicensedCancelledStatus,SalesSuccessMessageforRenewedLicense,SalesBaseLicensetoRenewError,
                SalesNotEnoughLicError,SalesLicenseNotEqualRenewalError,SalesNoofSeats,SalesNoofseatsGreater,SalesSeatsNotGreaterError}; 
            
        @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
        wireRecord(result)
        {
                if (result.data)
                {
                        this.renewalLicense = result.data;
                        var isfoundation = false;
                        console.log(
                                "productid:" + this.renewalLicense.fields.Sales_License_Product__c.value
                        );
                        // this.isfoundationfound = this.checkrenewallicense(this.renewalLicense.fields.Sales_License_Product__c.value);
                        console.log("check foundation" + isfoundation);
                        console.log(
                                "checkIfRenewalLicenseIsValid Data --> " +
                                JSON.stringify(this.renewalLicense)
                        );
                        console.log("Today date : " + this.today.getDate());
                        var isRenewalLicenseValid = true;
                        /*   if (this.renewalLicense.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value !== 'RENEWAL') {
                                isRenewalLicenseValid = false;
                                this.errorMsg = 'This license record is not applicable for Renewal';
                            } else */
                        /*if (this.renewalLicense.fields.Sales_License_Avbl_Qty_Nbr__c.value <= 0)
                        {
                                console.log("check avail qty is 0");
                                isRenewalLicenseValid = false;
                                this.errorMsg = this.label.SalesNotEnoughLicense;
                                       
                        }
                        else if (this.renewalLicense.fields.Sales_License_Maintenance_Exp_Dt__c.value < this.today)
                        {
                                isRenewalLicenseValid = false;
                                this.errorMsg = this.label.SalesNotActiveMaintainance;
                        }
                        else if (this.renewalLicense.fields.Sales_License_Status__c.value == "Licensed" ||
                                this.renewalLicense.fields.Sales_License_Status__c.value == "Cancelled")
                        {
                                console.log("check status");
                                isRenewalLicenseValid = false;
                                this.errorMsg = this.label.SalesNotRenewLicense;
                        }
                        validateRenewalrecord(
                                {
                                        renewalprodId: this.renewalLicense.fields.Sales_License_Product__c.value,
                                })
                                .then((result) =>
                                {
                                        console.log(JSON.stringify(result));
                                        if (result == false)
                                        {
                                                this.isfoundationcheck = true;
                                                this.isfoundationfound = true;
                                                this.errorMsg = this.label.SalesFoundationToAnotherProduct;
                                                console.log("check if foundation found inside if" + this.isfoundationcheck);
                                        }
                                        if (isRenewalLicenseValid == false)
                                        {
                                                this.showRenewalLicenseValidationErr = true;
                                        }
                                        else
                                        {
                                                getBaseLicenseRecords(
                                                        {
                                                                licRecordId: this.recordId,
                                                        })
                                                        .then((result) =>
                                                        {
                                                                //console.log('Payload from apex'+JSON.stringify(result));
                                                                if (result != undefined && JSON.stringify(result) !== "[]")
                                                                {
                                                                        //result.length() > 0)
                                                                        this.data = result;
                                                                        this.data.forEach(function(item)
                                                                        {
                                                                                console.log("item -->" + JSON
                                                                                        .stringify(item)
                                                                                );
                                                                                if (item.Sales_License_Host_Node_Id__c ==
                                                                                        undefined)
                                                                                {
                                                                                        item.HostPrimaryCompId =
                                                                                                "  ";
                                                                                        item.HostPrimaryCompName =
                                                                                                "  ";
                                                                                }
                                                                                else
                                                                                {
                                                                                        item.HostPrimaryCompId =
                                                                                                item
                                                                                                .Sales_License_Host_Node_Id__r
                                                                                                .Name;
                                                                                        item.HostPrimaryCompName =
                                                                                                item
                                                                                                .Sales_License_Host_Node_Id__r
                                                                                                .Sales_Computer_Name_Txt__c;
                                                                                }
                                                                        });
                                                                        console.log("Data fetched ->" + JSON.stringify(this
                                                                                .data));
                                                                        if (this.data != undefined)
                                                                        {
                                                                                console.log("In prepareDatatable");
                                                                                let tempRecords = JSON.parse(JSON.stringify(this
                                                                                        .data));
                                                                                console.log("Temp Records" + tempRecords);
                                                                                tempRecords = tempRecords.map((row) =>
                                                                                {
                                                                                        return {
                                                                                                ...row,
                                                                                                prodName: row
                                                                                                        .Sales_License_Product__r
                                                                                                        .Name,
                                                                                                prodOpn: row
                                                                                                        .Sales_License_Product__r
                                                                                                        .Core_OPN__c,
                                                                                        }; //
                                                                                });
                                                                                this.data = tempRecords;
                                                                                console.log(
                                                                                        "data after processing" + JSON
                                                                                        .stringify(this.data)
                                                                                );
                                                                                this.showRenewalLicenseValidationErr = false;
                                                                                this.isLoaded = true;
                                                                        }
                                                                        //this.prepareTableData();
                                                                        this.isRenewalLicenseInvalid = false;
                                                                }
                                                                else if (result != undefined && JSON.stringify(result) == "[]")
                                                                {
                                                                        //result.length == 0
                                                                        this.errorMsg =this.label.SalesNoBaseLicensetoRenew;
                                                                        this.showRenewalLicenseValidationErr = true;
                                                                }
                                                                else
                                                                {
                                                                        const evt = new ShowToastEvent(
                                                                        {
                                                                                title: "Error",
                                                                                message: this.label.SalesSomethingWrong,
                                                                                variant: "error",
                                                                                mode: "dismissable",
                                                                        });
                                                                        this.dispatchEvent(evt);
                                                                }
                                                        })
                                                        .catch((error) =>
                                                        {
                                                                console.log("Getting error" + JSON.stringify(error));
                                                                const evt = new ShowToastEvent(
                                                                {
                                                                        title: "Error",
                                                                        message: error.body.message,
                                                                        variant: "error",
                                                                        mode: "dismissable",
                                                                });
                                                                this.dispatchEvent(evt);
                                                        });
                                        }
                                        console.log("result " + result);
                                })
                                .catch((error) =>
                                {
                                        console.log("error" + error);
                                });
                }
                else if (result.error)
                {
                        const evt3 = new ShowToastEvent(
                        {
                                title: "Error",
                                message: result.error.body.message,
                                variant: "error",
                                mode: "dismissable",
                        });
                        this.dispatchEvent(evt3);
                }
        }
        prepareTableData()
        {
                if (this.data != undefined)
                {
                        console.log("In prepareDatatable");
                        let tempRecords = JSON.parse(JSON.stringify(this.data));
                        console.log("Temp Records" + tempRecords);
                        tempRecords = tempRecords.map((row) =>
                        {
                                return {
                                        ...row,
                                        prodName: row.Sales_License_Product__r.Name,
                                        prodOpn: row.Sales_License_Product__r.Core_OPN__c,
                                }; //
                        });
                        this.data = tempRecords;
                        console.log("data after processing" + JSON.stringify(this.data));
                        /*for (let i = 0; i < this.data.length; i++) {
                      //i = i + 1;
                      var licRec = this.data[i];
                      console.log('data table records iteration -->'+JSON.stringify(licRec));
                      let dataRec = {
                          prodName: licRec.Sales_License_Product__r.Name,
                          prodOpn: licRec.Sales_License_Product__r.Core_OPN__c,
                          maintExp: licRec.Sales_License_Maintenance_Exp_Dt__c,
                          noOfSeats: licRec.Sales_License_Quantity__c,
                          rehostAvl: licRec.Sales_License_Avbl_Rehost_Nbr__c,
                         // compName:  licRec.Sales_License_Host_Node_Id__r.Name
      
                      }
                      this.baseLicensedata.push(dataRec);
                  }
                  console.log('baseLicensedata : '+JSON.stringify(this.baseLicensedata));*/
                        /*this.showRenewalLicenseValidationErr = false;
                        this.isLoaded = true;
                }
        }
        handlebaseLicSelected()
        {
                var el = this.template.querySelector("lightning-datatable");
                this.selectedbaseLicenses = el.getSelectedRows();
                console.log(
                        "Inside base license table --> " + JSON.stringify(this.selectedbaseLicenses)
                );
                if (JSON.stringify(this.selectedbaseLicenses) == "[]")
                {
                        this.selectedbaseLicenses = undefined;
                }
                else if (this.noOfSeatsToRenew == undefined)
                {
                        this.selectedbaseLicenses = undefined;
                        //this.baselicense=false;
                        const evt = new ShowToastEvent(
                        {
                                title: "Info",
                                message: this.label.SalesNoofSeatsToRenew,
                                variant: "info",
                                mode: "dismissable",
                        });
                        this.dispatchEvent(evt);
                        //this.baselicense=true;
                        this.handlebaseLicSelected();    
                }
                else {
                        this.CheckBaseLicenseList();
                }
                
                /*if (
                        this.selectedbaseLicenses != undefined &&
                        JSON.stringify(this.selectedbaseLicenses) != "[]" 
                       
                )
                {
                       var subtractValue = this.noOfSeatsToRenew;
                        this.selectedbaseLicenses.forEach(function(item)
                        {
                                item.afterRenewalSeatsCount =
                                        parseInt(item.Sales_License_Quantity__c) - subtractValue;
                                item.afterRenewalSeatsCountOnNewLicense = subtractValue;
                        });
                        //Removing all base Licenses that aren't eligible for Renewal. (No of Seats to renew >= # Seats present on base license)
                        var finalList = [];
                        for (var i = 0; i < this.selectedbaseLicenses.length; i++)
                        {
                                if (
                                        this.selectedbaseLicenses[i].afterRenewalSeatsCount < 1 ||
                                        isNaN(this.selectedbaseLicenses[i].afterRenewalSeatsCount)
                                )
                                {
                                        continue;
                                }
                                else
                                {
                                        finalList.push(this.selectedbaseLicenses[i]);
                                }
                        }
                        this.selectedbaseLicenses = finalList;
                        if (JSON.stringify(this.selectedbaseLicenses) == "[]")
                        {
                                this.selectedbaseLicenses = undefined;
                        }
                        console.log(
                                "base license table --> " + JSON.stringify(this.selectedbaseLicenses)
                        );
                        
                }*/
               
                
                

        /*}
        checkrenewallicense(prodId)
        {
                var isTrue;
                validateRenewalrecord(
                        {
                                renewalprodId: prodId,
                        })
                        .then((result) =>
                        {
                                isTrue = result;
                                return result;
                                console.log("result " + result);
                        })
                        .catch((error) =>
                        {
                                isTrue = false;
                                console.log("error" + error);
                                return false;
                        });
                //   return isTrue;
        }
        checkIfRenewalLicenseIsValid()
        {
                var isfoundation = false;
                console.log(
                        "productid:" + this.renewalLicense.fields.Sales_License_Product__c.value
                );
                // this.isfoundationfound = this.checkrenewallicense(this.renewalLicense.fields.Sales_License_Product__c.value);
                console.log("check foundation" + isfoundation);
                console.log(
                        "checkIfRenewalLicenseIsValid Data --> " +
                        JSON.stringify(this.renewalLicense)
                );
                console.log("Today date : " + this.today.getDate());
                var isRenewalLicenseValid = true;
                /*   if (this.renewalLicense.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value !== 'RENEWAL') {
                        isRenewalLicenseValid = false;
                        this.errorMsg = 'This license record is not applicable for Renewal';
                    } else */
                /*if (
                        this.renewalLicense.fields.Sales_License_Avbl_Qty_Nbr__c.value <= 0
                )
                {
                        console.log("check avail qty is 0");
                        isRenewalLicenseValid = false;
                        this.errorMsg =this.label.SalesZeroAvailableQuantity;
                             
                }
                else if (
                        this.renewalLicense.fields.Sales_License_Maintenance_Exp_Dt__c.value <
                        this.today
                )
                {
                        isRenewalLicenseValid = false;
                        this.errorMsg =this.label.SalesNotActiveMaintainance;
                               
                }
                else if (
                        this.renewalLicense.fields.Sales_License_Status__c.value == "Licensed" ||
                        this.renewalLicense.fields.Sales_License_Status__c.value == "Cancelled"
                )
                {
                        console.log("check status");
                        isRenewalLicenseValid = false;
                        this.errorMsg = this.label.SalesNotRenewLicense;
                }
                validateRenewalrecord(
                        {
                                renewalprodId: this.renewalLicense.fields.Sales_License_Product__c.value,
                        })
                        .then((result) =>
                        {
                                console.log(JSON.stringify(result));
                                if (result == false)
                                {
                                        this.isfoundationcheck = true;
                                        this.isfoundationfound = true;
                                        this.errorMsg = this.label.SalesFoundationToAnotherProduct;
                                        console.log(
                                                "check if foundation found inside if" + this.isfoundationcheck
                                        );
                                     //   return isRenewalLicenseValid;
                                }
                                console.log("result " + result);
                        })
                        .catch((error) =>
                        {
                                console.log("error" + error);
                        });
                console.log("foundation check" + this.isfoundationfound);
                console.log("check if foundation found" + this.isfoundationcheck);
                console.log("is isRenewalLicenseValid" + isRenewalLicenseValid);
                return isRenewalLicenseValid;
        }
        handleOnConfirmBtnClick()
        {
                if (this.validateBaseLicensesSelected() == false)
                {
                        const evt3 = new ShowToastEvent(
                        {
                                title: "Error",
                                message: this.errorMsgForBaseLicenses,
                                variant: "error",
                                mode: "dismissable",
                        });
                        this.dispatchEvent(evt3);
                }
                else
                {
                        applyRenewals(
                                {
                                        licensesList: this.selectedlicenses,
                                        noOfSeatsToRenew: this.noOfSeatsToRenew,
                                        renewalLic: this.recordId,
                                })
                                .then((result) =>
                                {
                                        //if (result != undefined && result.data == 'Success') {
                                        const evt = new ShowToastEvent(
                                        {
                                                title: "Success",
                                                message: this.label.SalesSuccessMessageforRenewedLicense,
                                                variant: "Success",
                                                mode: "dismissable",
                                        });
                                        this.dispatchEvent(evt);
                                        this.handleOnCancelBtnClick();
                                        this.reloadPage();
                                        //}
                                })
                                .catch((error) =>
                                {
                                        console.log("error" + error);
                                        const evt = new ShowToastEvent(
                                        {
                                                title: "Error",
                                                message: error.body.message,
                                                variant: "error",
                                                mode: "dismissable",
                                        });
                                        this.dispatchEvent(evt);
                                });
                }
        }
        validateBaseLicensesSelected()
        {
                var isValid = true;
                var el = this.template.querySelector("lightning-datatable");
                var selectedlicenses = [];
                this.selectedlicenses = el.getSelectedRows();
                if (
                        this.selectedlicenses == undefined ||
                        JSON.stringify(this.selectedlicenses) == "[]"
                )
                {
                        //this.selectedlicenses.length() == 0
                        this.errorMsgForBaseLicenses =this.label.SalesBaseLicensetoRenewError;
                               
                        isValid = false;
                        return isValid;
                }
                var errorArray = [];
                var noOfSeatsSelected = 0;
                var availqty = 0;
                this.selectedlicenses.forEach((element) =>
                {
                        noOfSeatsSelected = noOfSeatsSelected + element.Sales_License_Quantity__c;
                });
                if (noOfSeatsSelected < this.noOfSeatsToRenew)
                {
                        this.errorMsgForBaseLicenses =this.label.SalesLicenseNotEqualRenewalError;
                        isValid = false;
                        return isValid;
                }else if(this.noOfSeatsToRenew==0){
                        this.errorMsgForBaseLicenses = this.label.SalesNoofseatsGreater;
                        
                isValid = false;
                return isValid;
                }
                console.log("no of seats to renew" + this.noOfSeatsToRenew);
                console.log(
                        "avail qty" +
                        this.renewalLicense.fields.Sales_License_Avbl_Qty_Nbr__c.value
                );
                if (
                        this.noOfSeatsToRenew >
                        this.renewalLicense.fields.Sales_License_Avbl_Qty_Nbr__c.value
                )
                {
                        console.log("Check available qty");
                        this.errorMsgForBaseLicenses =this.label.SalesSeatsNotGreaterError;
                               
                        isValid = false;
                        return isValid;
                }
        }
        handleOnCancelBtnClick()
        {
                this.closeQuickAction();
                // this.dispatchEvent(new CloseActionScreenEvent());
        }
        closeQuickAction()
        {
                const closeModal = new CustomEvent("close");
                // Dispatches the event.
                this.dispatchEvent(closeModal);
        }
        inputChange(event)
        {
                this.noOfSeatsToRenew = event.target.value;
                console.log("entered value -->" + this.noOfSeatsToRenew);
        }
        loadTableRecords()
        {
                getBaseLicenseRecords(
                        {
                                licRecordId: this.recordId,
                        })
                        .then((result) =>
                        {
                                //console.log('Payload from apex'+JSON.stringify(result));
                                if (result != undefined && JSON.stringify(result) !== "[]")
                                {
                                        //result.length() > 0)
                                        console.log("Passing data to table" + JSON.stringify(result));
                                        this.data = result;
                                        this.prepareTableData();
                                        this.isRenewalLicenseInvalid = false;
                                }
                                else if (result != undefined && JSON.stringify(result) == "[]")
                                {
                                        //result.length == 0
                                        this.errorMsg = this.label.SalesNoBaseLicensetoRenew;
                                               
                                        this.showRenewalLicenseValidationErr = true;
                                }
                                else
                                {
                                        const evt = new ShowToastEvent(
                                        {
                                                title: "Error",
                                                message: this.label.SalesSomethingWrong,
                                                variant: "error",
                                                mode: "dismissable",
                                        });
                                        this.dispatchEvent(evt);
                                }
                        })
                        .catch((error) =>
                        {
                                console.log("Getting error" + JSON.stringify(error));
                                const evt = new ShowToastEvent(
                                {
                                        title: "Error",
                                        message: error.body.message,
                                        variant: "error",
                                        mode: "dismissable",
                                });
                                this.dispatchEvent(evt);
                        });
        }
        onchangeHandle(event)
        {
                if (
                        this.tempData == null ||
                        this.tempData == undefined ||
                        (this.tempData != null && this.tempData.length == 0)
                )
                {
                        this.tempData = this.data;
                }
                this.dataReturn = [];
                this.selectedValue = event.target.value;
                let currentList = this.tempData;
                let currentList1 = this.tempData;
                if (
                        this.selectedValue.length > 0 &&
                        this.selectedValue !== undefined &&
                        this.selectedValue !== null
                )
                {
                        let concat = "";
                        let concat1="";
                        let cnt = 0;
                        for (let index = 0; index < currentList.length; index++)
                        {
                                if (currentList[index].Sales_License_Host_Node_Id__c != null)
                                {
                                        console.log(
                                                "onchangeHandle 1 " +
                                                currentList[index].Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c
                                        );
                                        concat += currentList[index].Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c;
                                        //console.log('concatenated String :'+concat);
                                        if (concat != null && concat != "" && concat != undefined)
                                        {
                                                concat = concat.toString().toLowerCase() + "" + index;
                                        }
                                        console.log("onchangeHandle 2 " + concat);
                                        console.log("onchangeHandle 4 " + this.selectedValue.toLowerCase());
                                        console.log(concat);
                                        if (concat.includes(this.selectedValue.toLowerCase()))
                                        {
                                                //this.isDataAvailable = true;
                                                console.log("found :" + index);
                                                this.dataReturn.push(currentList[index]);
                                                //  cnt++;
                                        }
                                }
                                concat = null;    
                        }
                        for (let index = 0; index < currentList1.length; index++){
         
                                if (currentList1[index].Sales_License_Host_Node_Id__c != null)
                                {
                                        console.log(
                                        "onchangeHandle 5 " +
                                        currentList1[index].Sales_License_Host_Node_Txt__c
                                         );
                                        concat1 += currentList1[index].Sales_License_Host_Node_Txt__c;
                                        //console.log('concatenated String :'+concat);
                                        if (concat1 != null && concat1 != "" && concat1 != undefined)
                                        {
                                                concat1 = concat1.toString().toLowerCase() + "" + index;
                                        }
                                        console.log("onchangeHandle 6 " + concat1);
                                        console.log("onchangeHandle 7 " + this.selectedValue.toLowerCase());
                                        console.log(concat1);
                                        if (concat1.includes(this.selectedValue.toLowerCase()))
                                                {
                                                                            //this.isDataAvailable = true;
                                                                            console.log("found :" + index);
                                                                            this.dataReturn.push(currentList1[index]);
                                                                            //  cnt++;
                                                }
                                 }
                                concat1 = null;
                            }
                        if (this.dataReturn.length <= 0)
                        {
                                //this.isDataAvailable = false;
                        }
                }
                else
                {
                        this.loadTableRecords();
                }
                if (this.selectedValue.length === 0)
                {
                        //this.isDataAvailable = true;
                        this.dataReturn = this.data;
                }
                else
                {
                        this.data = this.dataReturn;
                }
        }
        reloadPage(){

                setTimeout(function() {
                location.reload(true);
                }, 2000);    
            }
        CheckBaseLicenseList(){
                if (
                        this.selectedbaseLicenses != undefined &&
                        JSON.stringify(this.selectedbaseLicenses) != "[]" 
                       
                )
                console.log(
                        "Inside CheckBaseLicenseList --> " + JSON.stringify(this.selectedbaseLicenses)
                );
                {
                        var subtractValue = this.noOfSeatsToRenew;
                        this.selectedbaseLicenses.forEach(function(item)
                        {
                                item.afterRenewalSeatsCount =
                                        parseInt(item.Sales_License_Quantity__c) - subtractValue;
                                item.afterRenewalSeatsCountOnNewLicense = subtractValue;
                        });
                        //Removing all base Licenses that aren't eligible for Renewal. (No of Seats to renew >= # Seats present on base license)
                        var finalList = [];
                        for (var i = 0; i < this.selectedbaseLicenses.length; i++)
                        {
                                if (
                                        this.selectedbaseLicenses[i].afterRenewalSeatsCount < 1 ||
                                        isNaN(this.selectedbaseLicenses[i].afterRenewalSeatsCount)
                                )
                                {
                                        continue;
                                }
                                else
                                {
                                        finalList.push(this.selectedbaseLicenses[i]);
                                }
                        }
                        this.selectedbaseLicenses = finalList;
                        if (JSON.stringify(this.selectedbaseLicenses) == "[]")
                        {
                                this.selectedbaseLicenses = undefined;
                        }
                        console.log(
                                "base license table --> " + JSON.stringify(this.selectedbaseLicenses)
                        );
                        
                }
        }*/
}