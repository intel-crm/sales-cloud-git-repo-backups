import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import loadData from "@salesforce/apex/Core_MDF_ApprovalHistoryController.loadData";
import Core_MDF_Step_Name from '@salesforce/label/c.Core_MDF_Step_Name';
import Core_MDF_Date from '@salesforce/label/c.Core_MDF_Date';
import Core_MDF_AH_Status from '@salesforce/label/c.Core_MDF_AH_Status';
import Core_MDF_Assigned_To from '@salesforce/label/c.Core_MDF_Assigned_To';
import Core_MDF_Actual_Approver from '@salesforce/label/c.Core_MDF_Actual_Approver';
import Core_MDF_Comments from '@salesforce/label/c.Core_MDF_Comments';
    
    
    //getting all the label values to be displayed
    const label = {
        Core_MDF_Step_Name,
        Core_MDF_Date,
        Core_MDF_AH_Status,
        Core_MDF_Assigned_To,
        Core_MDF_Actual_Approver,
        Core_MDF_Comments
      };
      
      
      
    
export default class Core_MDF_ApprovalHistoryViewAll extends NavigationMixin(LightningElement) {
      @api recordId;
      @track haserror;
      @api identifierTextField1='';
      @api identifierTextField2='';
      @api identifierCheckboxField1='';
      @api identifierCheckboxField2='';
      @track dataLength=0;
      @track dataLoaded=false;
      @track isShowModal = false;
    
      data = [];
      fullDataSet = [];
      @track columns = [];
      historyHeaderData;
      @wire(loadData, {recordId: "$recordId", identifierTextField1:"$identifierTextField1", identifierTextField2:"$identifierTextField2", identifierCheckboxField1:"$identifierCheckboxField1", identifierCheckboxField2:"$identifierCheckboxField2"})
      wiredApprovalHistoryData({data,error}) {
        if (data) {
              this.fullDataSet = data.records;
              this.data = data.records;
              this.dataLength = data.records.length;
              this.columns = data.lstDataTableColumns;
              this.historyHeaderData = data.TableTitle;
              this.dataLoaded=data.MDFound;
              this.haserror=false;
          } else if (error) {
              this.haserror=true;
              this.data=undefined;
        }
     }    
}