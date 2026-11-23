import { LightningElement,wire,track,api } from 'lwc';  
import {refreshApex} from '@salesforce/apex';  
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getAllQuoteLines from '@salesforce/apex/PSG_QuoteLineDataTableController.fetchQuoteLines';  
//import updateQuoteLines from '@salesforce/apex/PSG_QuoteLineDataTableController.updateQuoteLines'; 

const COLS=[  
 // {label:'Id',fieldName:'Id', type:'text'},  
  {label:'Name',fieldName:'Name', type:'text'},
  {label:'Disty %',fieldName:'PSG_Distributor_Margin_Pct__c', type:'Number'}
];  

export default class DataTableInLwc extends LightningElement {  
  @api recordId;
  @track distyPercent;
  @track qlList=[];
  @track showSpinner=false;
  cols=COLS;  

  //@wire(getAllQuoteLines,{ quoteId: '$recordId'}) quoteLineList; 
  
  connectedCallback(){
    /*console.log('record '+this.recordId);
    getAllQuoteLines({quoteId: this.recordId})  
    .then(result=>{  
      this.quoteLineList = result;
      console.log('result '+result);  
      this.showSpinner=false;
    })  
    .catch(error=>{  
      this.showSpinner=false;
      this.showToast('Error Fetching Data',JSON.stringify(error),'error');
    }) */
  } 
  
  handleChange(event){
    this.distyPercent=event.detail.value;
  }

  /*updateRecord(){ 
    var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();  
    if(selectedRecords.length<1){
      this.showToast('No rows selected','Please select atleast one row to update.','error');
    }
    else{
      this.showSpinner=true; 
      for(var i=0;i<selectedRecords.length;i++){
        var qlRec={...selectedRecords[i]};
        qlRec.PSG_Distributor_Margin_Pct__c=this.distyPercent;
        this.qlList.push(qlRec);
      }
      //console.log('qlList>>'+JSON.stringify(this.qlList));

      updateQuoteLines({quoteLineList: this.qlList})  
      .then(result=>{ 
        this.qlList=[];
        this.template.querySelector('form').reset();
        refreshApex(this.quoteLineList)
          .then(() => this.showSpinner = false)
          .catch(() => this.showSpinner = false);
      })  
      .catch(error=>{  
        this.qlList=[];
        this.showSpinner=false;
        this.showToast('Error Updating Records',JSON.stringify(error),'error');
      })  
    }
  }*/  

  showToast(msgTitle,msg,type){
    this.dispatchEvent(
        new ShowToastEvent({
            title: msgTitle,
            message: msg,
            variant: type,
            mode: 'dismissable'
        }),
    );
}
}