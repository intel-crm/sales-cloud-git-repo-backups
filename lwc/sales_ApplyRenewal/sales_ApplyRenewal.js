import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import getBaseLicenseRecords from "@salesforce/apex/Sales_ApplyRenewalController.getBaseLicenseRecords";
import applyRenewals from "@salesforce/apex/Sales_ApplyRenewalController.applyRenewals";
import validateRenewalrecord from "@salesforce/apex/Sales_ApplyRenewalController.validateRenewalrecord";
//import checkOrderAndOrderProduct from '@salesforce/apex/Sales_SplitSeatsOnLicenseController.checkOrderAndOrderProduct';
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
import Sales_Confirm from '@salesforce/label/c.Sales_Confirm';
import Sales_Cancel from '@salesforce/label/c.Sales_Cancel';
import Sales_Part_Number from '@salesforce/label/c.Sales_Part_Number';
import sales_compid from '@salesforce/label/c.sales_compid';
import Sales_Maitenance_Exp from '@salesforce/label/c.Sales_Maitenance_Exp';
import Sales_ofseat from '@salesforce/label/c.Sales_ofseat';
import Sales_Product from '@salesforce/label/c.Sales_Product';
import Sales_Primary_Computer_Name from '@salesforce/label/c.Sales_Primary_Computer_Name';
import Sales_Rehost_Available from '@salesforce/label/c.Sales_Rehost_Available';
import Sales_Prior_Seat from '@salesforce/label/c.Sales_Prior_Seat';
import Sales_After_Split from '@salesforce/label/c.Sales_After_Split';
import Sales_After_Renewal_Lic from '@salesforce/label/c.Sales_After_Renewal_Lic';
import Sales_SeatsLessAvailquantity from '@salesforce/label/c.Sales_SeatsLessAvailquantity';
import checkUserPermissionSet from '@salesforce/apex/Sales_ApplyRenewalController.checkUserPermissionSet';
import Sales_Bypass_Permissionset from '@salesforce/label/c.Sales_Bypass_Permissionset';
import SalesEmployeeEvaluationError from '@salesforce/label/c.Sales_Employee_Evaluation_Error';
import Sales_ContractCheckOnLicense from '@salesforce/label/c.Sales_ContractCheckOnLicense';
import Sales_AccessCheckMsg from '@salesforce/label/c.Sales_AccessCheckMsg';
import userId from '@salesforce/user/Id';
import validateUserAccess from '@salesforce/apex/Sales_ValidateUserEditAccess.validateUserAccess';


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
        "Sales_License__c.Sales_License_Type__c",
        "Sales_License__c.Sales_License_Host_Node_Id__r.Name",
        "Sales_License__c.Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c",
        "Sales_License__c.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c",
        "Sales_License__c.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c",
        "Sales_License__c.Sales_License_Web_Display_Flag__c",
        "Sales_License__c.Sales_License_Activation_Code__c",
        "Sales_License__c.Sales_License_Contract_Txt__c"
];
const columns = [
        { label: "License Name", fieldName: "Name", type: "text" },
        { label: Sales_Product, fieldName: "prodName" },
        { label: Sales_Part_Number, fieldName: "prodOpn" },
        {
                label: Sales_Maitenance_Exp,
                fieldName: "Sales_License_Maintenance_Exp_Dt__c",
                type: "date-local",
        },
        { label: Sales_ofseat, fieldName: "Sales_License_Quantity__c", type: "text" },
        {
                label: Sales_Rehost_Available,
                fieldName: "Sales_License_Avbl_Rehost_Nbr__c",
                type: "text",
        },
        {
                label: sales_compid,
                fieldName: "HostPrimaryCompId",
                type: "text",
        },
        {
                label: Sales_Primary_Computer_Name,
                fieldName: "HostPrimaryCompName",
                type: "text",
        },
];
const baseLicenseColumns = [
        { label: "License Name", fieldName: "Name", type: "text" },
        { label: Sales_Product, fieldName: "prodName" },
        { label: Sales_Part_Number, fieldName: "prodOpn" },
        {
                label: Sales_Maitenance_Exp,
                fieldName: "Sales_License_Maintenance_Exp_Dt__c",
                type: "date-local",
        },
        {
                label: Sales_Prior_Seat,
                fieldName: "Sales_License_Quantity__c",
                type: "text",
        },
        {
                label: Sales_After_Split,
                fieldName: "afterRenewalSeatsCount",
                type: "text",
        },
        {
                label: Sales_After_Renewal_Lic,
                fieldName: "afterRenewalSeatsCountOnNewLicense",
                type: "text",
        },
];
//Labels
import errorMsg from "@salesforce/label/c.Sales_Error_Message"; //Error title
import SystemModstamp from "@salesforce/schema/Account.SystemModstamp";
export default class sales_ApplyRenewal extends NavigationMixin(
        LightningElement
)
{
        @api baseLicenseColumns = baseLicenseColumns;
        @track selectedValue;
        @track tempData = [];
        @track dataReturn = [];
        @track finaldata = [];
        @track final = [];
        @api recordId;
        renewalLicense;
        @api showModal=false;
        showRenewalLicenseValidationErr = false;
        @api noOfSeatsToRenew;
        errorMsg;
        @track data = [];
        @api baseLicensedata = [];
        isRenewalLicenseInvalid = true;
        errorMsgForBaseLicenses;
        ischeck=false;
        selectedlicenses;
        today = new Date();
        @api columns = columns;
        @track isLoaded = false;
        @api selectedbaseLicenses;
        @api finalselectedbaseLicenses;
        @api isfoundationfound = false;
        @track isfoundationcheck = false;
        @track isCOS_Telesales = false;
        @track isOrder = false;
        @track userId = userId;

        label = {existingrenewal,SalesApplyrenewalheading,Salesrenewalseat,SalesLicenseFilter,SalesLicenseSplit,SalesNotEnoughLicense,SalesNotActiveMaintainance,
                SalesNotRenewLicense,SalesFoundationToAnotherProduct,SalesNoBaseLicensetoRenew,SalesSomethingWrong,SalesNoofSeatsToRenew,
                SalesZeroAvailableQuantity,SalesLicensedCancelledStatus,SalesSuccessMessageforRenewedLicense,SalesBaseLicensetoRenewError,Sales_ContractCheckOnLicense,
                SalesNotEnoughLicError,SalesLicenseNotEqualRenewalError,SalesNoofSeats,SalesNoofseatsGreater,SalesSeatsNotGreaterError,Sales_Confirm,Sales_Cancel,Sales_SeatsLessAvailquantity,Sales_Bypass_Permissionset,SalesEmployeeEvaluationError,
		Sales_AccessCheckMsg
		}; 
        connectedCallback(){
     this.validateUserAccessLogic();
        console.log('inside Connected callback');
        
        }   

      /*  checkorderdetails(){
                checkOrderAndOrderProduct({recordId:this.recordId})
                 .then((result) => {
                        this.isOrder=result;
                        if(this.isOrder==true){
                            console.log('order n order product blank');
                            this.errorMsg=this.label.Sales_optionalproducterror;
                           // this.showNotificationerror(this.label.Sales_Err,this.label.Sales_optionalproducterror,'error');		
                        }
                    })
                    .catch((error) => {
                        
                    });

            }*/

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
                        var dd = this.today.getDate();
                        var mm = this.today.getMonth()+1;
                        var yyyy = this.today.getFullYear();
                        if(dd<10){
                                dd='0'+dd
                        } 
                        if(mm<10){
                                mm='0'+mm
                        } 
                        this.today = yyyy+'-'+mm+'-'+dd;
                        /*   if (this.renewalLicense.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value !== 'RENEWAL') {
                                isRenewalLicenseValid = false;
                                this.errorMsg = 'This license record is not applicable for Renewal';
                            } else */
                      // this.checkorderdetails();
                      if (this.renewalLicense.fields.Sales_License_Contract_Txt__c.value!=null){
                        isRenewalLicenseValid = false;
                        console.log("check contract is present");
                        this.errorMsg =this.label.Sales_ContractCheckOnLicense;
                      }

                     else  if (this.renewalLicense.fields.Sales_License_Avbl_Qty_Nbr__c.value <= 0)
                        {
                                console.log("check avail qty is 0");
                                isRenewalLicenseValid = false;
                                this.errorMsg =this.label.SalesNotEnoughLicense;
                        }
                        //logic added for Bypassing validation for COS and Telesales User-TWC3144-49
                        else if ((this.renewalLicense.fields.Sales_License_Maintenance_Exp_Dt__c.value < this.today || 
                                this.renewalLicense.fields.Sales_License_Maintenance_Exp_Dt__c.value == null) &&  (this.isCOS_Telesales ==false))
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
                        else if (
                                this.renewalLicense.fields.Sales_License_Type__c.value == "Evaluation" ||
                                this.renewalLicense.fields.Sales_License_Type__c.value == "Employee"
                        )
                        {
                                console.log("check status");
                                isRenewalLicenseValid = false;
                                this.errorMsg = this.label.SalesEmployeeEvaluationError;
                        }
                        validateRenewalrecord(
                                {
                                        renewalprodId: this.renewalLicense.fields.Sales_License_Product__c.value,
                                })
                                .then((result) =>
                                {
                                        console.log('Foundation product: '+JSON.stringify(result));
                                        if (!result)
                                        {

                                                //this.ischeck=true;
                                                this.isfoundationcheck = true;
                                                this.isfoundationfound = true;
                                                const evt = new ShowToastEvent(
                                                        {
                                                                title: "Error",
                                                                message: this.label.SalesFoundationToAnotherProduct,
                                                                variant: "error",
                                                                mode: "sticky",
                                                        });
                                                        this.dispatchEvent(evt);
                                                        this.closeQuickAction();
                                                        this.showModal = true;

                                                //this.errorMsg = "This product is foundation to another product";
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
                        this.showRenewalLicenseValidationErr = false;
                        this.isLoaded = true;
                }
        }
        handlebaseLicSelected()
        {
                var el = this.template.querySelector("lightning-datatable");
                this.selectedbaseLicenses = el.getSelectedRows();
                console.log('this.selectedbaseLicenses-->'+this.selectedbaseLicenses.length);
                //console.log('this.selectedbaseLicenses-->'+this.selectedbaseLicenses);
                if (JSON.stringify(this.selectedbaseLicenses) == "[]")
                {
                        this.selectedbaseLicenses = undefined;
                        this.finalselectedbaseLicenses=false;
                }
                else if (this.noOfSeatsToRenew == undefined)
                {
                        this.selectedbaseLicenses = undefined;
                        const evt = new ShowToastEvent(
                        {
                                title: "Info",
                                message: this.label.SalesNoofSeatsToRenew,
                                variant: "info",
                                mode: "dismissable",
                        });
                        this.dispatchEvent(evt);
                }
                else if (
                        this.selectedbaseLicenses != undefined  &&
                        JSON.stringify(this.selectedbaseLicenses) != "[]"
                )
                {
                        console.log("size of selected item"+this.selectedbaseLicenses.length);
                        if(this.selectedbaseLicenses.length==1 &&  this.selectedbaseLicenses[0].Sales_License_Quantity__c > this.noOfSeatsToRenew){
                                this.finalselectedbaseLicenses=this.selectedbaseLicenses;
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
                        console.log(
                                "this.selectedbaseLicenses--> " + JSON.stringify(this.selectedbaseLicenses)
                        );
                        if (JSON.stringify(this.selectedbaseLicenses) == "[]")
                        {
                                this.selectedbaseLicenses = undefined;
                                this.finalselectedbaseLicenses=false;
                        }
                        console.log(
                                "base license table --> " + JSON.stringify(this.selectedbaseLicenses)
                        );
                        }
                        console.log("size of selected item"+this.selectedbaseLicenses.length);
                        if(this.selectedbaseLicenses.length>1 ){
                                this.finalselectedbaseLicenses=false;
                        }
                }
        }
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
                console.log("maintainance date " + this.renewalLicense.fields.Sales_License_Maintenance_Exp_Dt__c.value);
                var isRenewalLicenseValid = true;
                /*   if (this.renewalLicense.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value !== 'RENEWAL') {
                        isRenewalLicenseValid = false;
                        this.errorMsg = 'This license record is not applicable for Renewal';
                    } else */
                    console.log("maintainance date " + this.renewalLicense.fields.Sales_License_Maintenance_Exp_Dt__c.value);
                    if (
                        this.renewalLicense.fields.Sales_License_Avbl_Qty_Nbr__c.value <= 0
                )
                {
                        console.log("check avail qty is 0");
                        isRenewalLicenseValid = false;
                        this.errorMsg =this.label.SalesZeroAvailableQuantity;
                                
                }
                else if (
                        this.renewalLicense.fields.Sales_License_Maintenance_Exp_Dt__c.value <
                        this.today)
                {
                        console.log("check maintainance date " + this.renewalLicense.fields.Sales_License_Maintenance_Exp_Dt__c.value);
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
                        this.errorMsg = this.label.SalesLicensedCancelledStatus;
                }
                else if (
                        this.renewalLicense.fields.Sales_License_Type__c.value == "Evaluation" ||
                        this.renewalLicense.fields.Sales_License_Status__c.value == "Employee"
                )
                {
                        console.log("check status");
                        isRenewalLicenseValid = false;
                        this.errorMsg = this.label.SalesEmployeeEvaluationError;
                }
                validateRenewalrecord(
                        {
                                renewalprodId: this.renewalLicense.fields.Sales_License_Product__c.value,
                        })
                        .then((result) =>
                        {
                                console.log(JSON.stringify(result));
                                if (!result)
                                {
                                        this.isfoundationcheck = true;
                                        this.isfoundationfound = true;
                                        //this.errorMsg = "This product is foundation to another product";
                                        const evt = new ShowToastEvent(
                                                {
                                                        title: "Error",
                                                        message: this.label.SalesFoundationToAnotherProduct,
                                                        variant: "error",
                                                        mode: "sticky",
                                                });
                                                this.dispatchEvent(evt);
                                                this.showModal = true;
                                                this.closeQuickAction();

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
        { this.isRenewalLicenseInvalid = true;
                if (this.validateBaseLicensesSelected() == false)
                {      this.isRenewalLicenseInvalid = false;
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
                                        contactforFile:'',
                                })
                                .then((result) =>
                                {        this.isRenewalLicenseInvalid = true;
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
                                        this.isRenewalLicenseInvalid = false;
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
                // added as part of US1104179
                else  if ((this.renewalLicense.fields.Sales_License_Avbl_Qty_Nbr__c.value > this.noOfSeatsToRenew) && (this.renewalLicense.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value !== 'RENEWAL')&&(this.renewalLicense.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value !== 'ADD SEAT'))
                {
                        console.log("643");
                        console.log('TOOL TYPE'+this.renewalLicense.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value);
                        console.log('seats'+ this.noOfSeatsToRenew);
                        console.log('available quantity'+this.renewalLicense.fields.Sales_License_Avbl_Qty_Nbr__c.value);
                        this.errorMsgForBaseLicenses =this.label.Sales_SeatsLessAvailquantity;
                        isValid = false;
                        return isValid;
                       
                } 
                else if(this.selectedlicenses != undefined &&
                        JSON.stringify(this.selectedlicenses) != "[]" && 
                        this.selectedlicenses.length == 1 && this.selectedlicenses[0].Sales_License_Quantity__c < this.noOfSeatsToRenew)
                {
                        this.errorMsgForBaseLicenses =this.label.SalesNotEnoughLicError;
                       
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
                }else if(noOfSeatsSelected > this.noOfSeatsToRenew && this.selectedlicenses.length > 1){
                        this.errorMsgForBaseLicenses =this.label.SalesNoofSeats;
                        isValid = false;
                        return isValid;
                }                
                else if(this.noOfSeatsToRenew<=0){
                        this.errorMsgForBaseLicenses =this.label.SalesNoofseatsGreater;
                       
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
        {       console.log('CLOSE');
                this.closeQuickAction();
                // this.dispatchEvent(new CloseActionScreenEvent());
        }
        closeQuickAction()
        {        console.log('close 739');
                const closeModal = new CustomEvent("close");
                // Dispatches the event.
                this.dispatchEvent(closeModal);
        
                
        }
        inputChange(event)
        {
                this.noOfSeatsToRenew = event.target.value;
                console.log("entered value -->" + this.noOfSeatsToRenew);
                this.handlebaseLicSelected();
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
        onchangeHandle(event)
        {
                //this.finaldata=this.data;
                if (
                        this.tempData == null ||
                        this.tempData == undefined ||
                        (this.tempData != null && this.tempData.length == 0)
                )
                {
                        this.tempData = this.data;
                        this.final= this.data;
                        
                }
                this.dataReturn = [];
                this.selectedValue = event.target.value;
                console.log('textboxvalue'+this.selectedValue);
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
                }/*else
                {
                        this.loadTableRecords();
                }*/
               if (this.selectedValue.length === 0)
                {
                        //this.loadTableRecords();
                        //this.isDataAvailable = true;
                        this.data = this.final;
                        console.log(
                                "final array " +
                                JSON.stringify(this.data)
                        );
                        //this.loadTableRecords();
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
	    closeQuickAction() {
                    console.log('close 914');
                const closeModal = new CustomEvent('close');
                // Dispatches the event.
                this.dispatchEvent(closeModal);
                this.reloadPage();
                }
//logic added for Bypassing validation for COS and Telesales User-TWC3144-49
                checkUser(){
                        checkUserPermissionSet()
                            .then((result) => {
                               
                                if(result == true){
                                    this.isCOS_Telesales=true;
                                    console.log("COS/Telesales User",+result+'cosuser'+this.isCOS_Telesales);
                             }
                             else{
                               
                                this.isCOS_Telesales=false;
                                console.log(" Not COS/Telesales User",+result+'cosuser'+this.isCOS_Telesales);
                               
                             }
                        });
        }

        validateUserAccessLogic() {
                console.log('824');
                validateUserAccess({ userID: this.userId, recordId: this.recordId })
                        .then((result) => {
                                console.log('result =' + result);
                                if (result == false) {
                                        console.log('user doesnt have access to the record');
                                        //this.closeQuickAction();
                                        const evt = new ShowToastEvent({
                                                variant: 'error',
                                                title: 'Failure',
                                                mode: 'sticky',
                                                message: this.label.Sales_AccessCheckMsg,
                                        });
                                        //
                                        //this.fireToastEvent('Failure!','You cannot modify this record !! ','error','Sticky');
                                        this.dispatchEvent(evt);
                                        this.closeQuickAction();
                                }
                                else{
                                        this.checkUser();
                                }
                        })
        }

}