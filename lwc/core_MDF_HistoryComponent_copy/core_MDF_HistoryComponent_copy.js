import { LightningElement, api, wire, track } from "lwc";
//import method from the Apex Class
import loadData from "@salesforce/apex/Core_MDF_HistoryController_copy.loadData";
import getHistoryHeader from "@salesforce/apex/Core_MDF_HistoryController_copy.getHistoryHeader";
import Core_MDF_ApplicationErrorMessage from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import Core_MDF_History_Date from '@salesforce/label/c.Core_MDF_History_Date';
import Core_MDF_History_Field from '@salesforce/label/c.Core_MDF_History_Field';
import Core_MDF_History_User from '@salesforce/label/c.Core_MDF_History_User';
import Core_MDF_History_Original_Value from '@salesforce/label/c.Core_MDF_History_Original_Value';
import Core_MDF_History_New_Value from '@salesforce/label/c.Core_MDF_History_New_Value';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

// declare class to expose the component
export default class HistoryComponentCopy extends LightningElement {
  @api error;
  @api historyHeaderData;
  @api historyData;
  @api objectApiName;
  @api internalUserName;
  @api profileNames;
  @api permSetNames;
  @api customPerms;
  @api recordId;
  @api queryTerm;
  @track haserror;

  // privatepermsets;

  // @api
  // get permset() {
  //   console.log(this.privatepermsets);
  //     return this.privatepermsets;
  // }

  // set permset(value) {
  //   console.log(value);
  //   if(value!==null || value!==''){
  //     this.privatepermsets = value;
  //   }
  //     // this.setAttribute('title', this.privateTitle);
  // }


  //getting all the label values to be displayed
  label = {
    Core_MDF_History_Date,
    Core_MDF_History_Field,
    Core_MDF_History_User,
    Core_MDF_History_Original_Value,
    Core_MDF_History_New_Value,
    Core_MDF_ApplicationErrorMessage
  };

  @wire(getRecord, { recordId: '$recordId', fields: [ 'Core_MDF_Data_Entry_Correction__c' ] })
  getobjectRelatedRecord({ data, error }) {
      
      if (data) {
          console.log('Refreshed');

          eval("$A.get('e.force:refreshView').fire();");

                loadData({ recordId: this.recordId, objectInfo: this.objectApiName , internalUserName: this.internalUserName, profiles: this.profileNames , permsets: this.permSetNames , customperms: this.customPerms })
                .then(result => {
                  console.log('result:'+result);
                    this.historyData = result;
                    this.error = undefined;
                })
                .catch(error1 => {
                    this.error = error1;
                    this.historyData = undefined;
                });

    } 
      else if (error) {

        console.log('not refreshed:'+error);
      }
  }

  


 //, profiles: "$profileNames" , permsets: "$permSetNames" , customperms: "$customPerms"
  @wire(loadData, { recordId: "$recordId", objectInfo: "$objectApiName" , internalUserName: "$internalUserName", profiles: "$profileNames" , permsets: "$permSetNames" , customperms: "$customPerms" })
  wiredHistoryData({data,error}) {
    if (data) {
      console.log(data);
      this.historyData = data;
      this.haserror=false;
    } else if (error) {
      console.log(error);
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