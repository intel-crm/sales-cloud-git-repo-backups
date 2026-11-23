import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import loadData from "@salesforce/apex/Core_MDF_ApprovalHistoryController.loadData";
  
    
export default class Core_MDF_ApprovalHistoryViewAll extends NavigationMixin(LightningElement) {
      //@track columns = columns;
      @api recordId;
      @track haserror;
      @api identifierTextField1='';
      @api identifierTextField2='';
      @api identifierCheckboxField1='';
      @api identifierCheckboxField2='';
      @track dataLength=0;
      @track dataLoaded=false;
      fullDataSet = [];
      @track columns = [];
      historyHeaderData;
      columnsWithWrapping = [];


      @wire(loadData, {recordId: "$recordId", identifierTextField1:"$identifierTextField1", identifierTextField2:"$identifierTextField2", identifierCheckboxField1:"$identifierCheckboxField1", identifierCheckboxField2:"$identifierCheckboxField2"})
      wiredApprovalHistoryData({data,error}) {
        if (data) {
              this.fullDataSet = data.records;
              this.dataLength = data.records.length;
              this.columns = data.lstDataTableColumns;
              this.columns = this.columns.map(eachrow => ({
                ...eachrow,
                wrapText: true,
                hideDefaultActions : true
              }))
              this.historyHeaderData = data.TableTitle;
              this.dataLoaded=data.MDFound;
              this.haserror=false;
          } else if (error) {
              this.haserror=true;
              this.data=undefined;
        }
     }    

    //This function controls the height of the datatable based on the number of records.
    get setDatatableHeight() {
      if(this.dataLength > 10){
        return 'height:27rem;border-bottom: 1px solid;';
      }
      return '';
  }

}