import { LightningElement, api, wire, track } from "lwc";
//import method from the Apex Class
import loadData from "@salesforce/apex/Core_MDF_HistoryController.loadData";
import getHistoryHeader from "@salesforce/apex/Core_MDF_HistoryController.getHistoryHeader";
import Core_MDF_ApplicationErrorMessage from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import Core_MDF_History_Date from '@salesforce/label/c.Core_MDF_History_Date';
import Core_MDF_History_Field from '@salesforce/label/c.Core_MDF_History_Field';
import Core_MDF_History_User from '@salesforce/label/c.Core_MDF_History_User';
import Core_MDF_History_Original_Value from '@salesforce/label/c.Core_MDF_History_Original_Value';
import Core_MDF_History_New_Value from '@salesforce/label/c.Core_MDF_History_New_Value';

// declare class to expose the component
export default class Core_MDF_HistoryComponent extends LightningElement {
  @api error;
  @api historyHeaderData;
  @api historyData;
  @api objectApiName;
  @api internalUserName;
  @api recordId;
  @api queryTerm;
  @track haserror;

  //getting all the label values to be displayed
  label = {
    Core_MDF_History_Date,
    Core_MDF_History_Field,
    Core_MDF_History_User,
    Core_MDF_History_Original_Value,
    Core_MDF_History_New_Value,
    Core_MDF_ApplicationErrorMessage
  };

  @wire(loadData, { recordId: "$recordId", objectInfo: "$objectApiName" , internalUserName: "$internalUserName"})
  wiredHistoryData({data,error}) {
    if (data) {
      this.historyData = data;
      this.haserror=false;
    } else if (error) {
      this.haserror=true;
      this.historyData = undefined;
    }
  }
   
  // make describe call dynamically based on objectName
  @wire(getHistoryHeader, { objectInfo: "$objectApiName" })
  wiredHistoryHeaderData({ data, error }) {
    if (data) {
      this.historyHeaderData = data.objectName;
      this.haserror=false;
    } else if (error) {
      this.haserror=true;
      this.historyHeaderData = undefined;
    }
  }
}