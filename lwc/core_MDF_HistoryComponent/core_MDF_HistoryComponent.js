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

//getting all the label values to be displayed
const label = {
  Core_MDF_History_Date,
  Core_MDF_History_Field,
  Core_MDF_History_User,
  Core_MDF_History_Original_Value,
  Core_MDF_History_New_Value,
  Core_MDF_ApplicationErrorMessage
};

const columns = [
  { label: label.Core_MDF_History_Date, fieldName: 'createdDate', hideDefaultActions :true},
  { label: label.Core_MDF_History_Field, fieldName: 'field',hideDefaultActions :true},
  { label: label.Core_MDF_History_User, fieldName: 'user',hideDefaultActions :true,},
  { label: label.Core_MDF_History_Original_Value, fieldName: 'oldValue',hideDefaultActions :true,cellAttributes : { iconName: { fieldName: 'customCssClassOld'}}},
  { label: label.Core_MDF_History_New_Value, fieldName: 'newValue',hideDefaultActions :true,cellAttributes : { iconName: { fieldName: 'customCssClassNew'}}},
];


// declare class to expose the component
export default class Core_MDF_HistoryComponent extends LightningElement {
  @api error;
  @api historyHeaderData;
  @api historyData;
  @api objectApiName;
  @api internalUserName;
  @api isInternalUserNameMasked;
  @api fieldsToMask = '';
  @api profileNames;
  @api permSetNames;
  @api customPerms;
  @api recordId;
  @api queryTerm;
  @track haserror = false;

  data = [];
  columns = columns;

// make describe call dynamically based on objectName
@wire(getHistoryHeader, { objectInfo: "$objectApiName",recordId : "$recordId" })
wiredHistoryHeaderData({ data, error }) {
  //alert("<<isInternalUserNameMasked>>"+this.isInternalUserNameMasked);  
  console.log('in wiredHistoryHeaderData');
  console.log('data',data);
  if (data) {
    this.historyHeaderData = data.objectName;
    console.log('historyHeaderData',this.historyHeaderData);
    this.haserror=false;
  } else if (error) {
    this.haserror=true;
    console.log('error',error);
    this.historyHeaderData = undefined;
  }
}

connectedCallback()
{
  const defaultFields = 'Owner';
  if(this.fieldsToMask != '' && this.fieldsToMask != undefined && this.fieldsToMask != null)
  {
    this.fieldsToMask = this.fieldsToMask.concat(';');
    this.fieldsToMask =  this.fieldsToMask.concat(defaultFields);
  }
  else {
    this.fieldsToMask = defaultFields;
   }
}
  

 //, profiles: "$profileNames" , permsets: "$permSetNames" , customperms: "$customPerms"
  @wire(loadData, { recordId: "$recordId", objectInfo: "$objectApiName" , internalUserName: "$internalUserName", fieldsToMask: "$fieldsToMask"})
  wiredHistoryData({data,error}) {
    console.log('in wiredHistoryData');
    if (data) {
      console.log('@@@@'+ data);

      let newData = data.map((item) => 
      Object.assign({}, item, {}))

      newData.forEach(function (d) {          
        if(d.isCheckbox === true && d.oldValue == "true"){
            d.customCssClassOld = 'utility:check';
            d.oldValue='';
          }
        else if(d.isCheckbox === true && d.oldValue == "false"){
          d.customCssClassOld = 'utility:null';
          d.oldValue='';
        }
        if(d.isCheckbox === true && d.newValue == "true"){
          d.customCssClassNew = 'utility:check';
          d.newValue='';
        }
      else if(d.isCheckbox === true && d.newValue == "false"){
        d.customCssClassNew = 'utility:null';
        d.newValue='';
      }

         
        });
        
      this.data = newData;

      // **** Add custom CSS style code on page(document) for dataTable****  
      /*let dataTableGlobalStyle = document.createElement('style');
      dataTableGlobalStyle.innerHTML = `
                                      .redRow{
                                        background-color:#ff8080;   
                                      }
                                      
                                      .boldText{
                                        font-weight:bold !important;
                                      }
                                      `;
      document.head.appendChild(dataTableGlobalStyle);
*/


      //this.historyData = data;
      this.haserror=false;
    } else if (error) {
      console.log('@@@' , error);
      this.haserror=true;
      this.data=undefined;
      //this.historyData = undefined;
    }
    else{
      console.log('@@@1' + error);
      console.log('@@@@1'+ data);
    }
  }
 

  
}