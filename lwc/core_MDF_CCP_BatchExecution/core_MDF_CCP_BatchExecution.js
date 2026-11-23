import { LightningElement,wire,track } from 'lwc';
import getBatchJobs from '@salesforce/apex/Core_MDF_BatchExecution_Controller.getBatchJobs';
import getBatch from '@salesforce/apex/Core_MDF_BatchExecution_Controller.getBatch';
import runBatchClass from '@salesforce/apex/Core_MDF_BatchExecution_Controller.runBatchClass';
import checkParameterForSelectedBatch from '@salesforce/apex/Core_MDF_BatchExecution_Controller.checkParameterForSelectedBatch';
import checkBatchStatus from '@salesforce/apex/Core_MDF_BatchExecution_Controller.checkBatchStatus';

import TickerSymbol from '@salesforce/schema/Account.TickerSymbol';

const batchDetailCol = [
    { label: 'Batch ID', fieldName: 'batchId', type: 'text' },
    { label: 'Batch Status', fieldName: 'batchStatus', type: 'text' },
    { label: 'Completed Date', fieldName: 'batchCompletedDate', type: 'text' }
];
export default class Core_MDF_CCP_BatchExecution extends LightningElement {
    fulldata;
    errorMsg;
    options;
    selected;
    amount;
    batchId;
    error;
    paramSize=0;
    hasParams=false;
    batchParamName =[];
    @track batchName='';
    @track LoadingText=false;
    @track BatchesName=[];
    @track valueselected;
    @track recId;
    @track selectedIds = [];
    batchStatus ='';
    paramInput = {paramName : '' , paramVal: ''};
    batchInputs = []; unique = [];

    @track data=[];
    @track columns=[];

    // @wire(getBatchJobs)  
    // wiredRecs( value ) { 
    //         const { data, error } = value;
    //         if(data && data.length >0)
    //         {
    //         this.fulldata= data;
    //         let options = [];
    //         console.log('All Batch Jobs',this.fulldata);
    //         data.forEach(r => {
    //                 options.push({
    //                   label: r,
    //                   value: r,
    //                 });
    //               });
    //               this.options = options; 
    //               console.log('Options',this.options); 
    //          }
    //         else
    //         {
    //         this.errorMsg = error;
    //         console.log('Error',this.errorMsg);
    //         } 
            
    // }
    handleChange(event)
    {
       

    }

    handleParamChange(event)
    {
        this.paramInput.paramName = event.target.label;
            this.paramInput.paramVal = event.target.value;

            if(this.batchInputs.length > 0){
                for(var i=0;i<this.batchInputs.length;i++){
                    if(this.batchInputs[i].key == this.paramInput.paramName){
                        this.batchInputs[i].value = this.paramInput.paramVal;
                        break;
                    }
                    
                }
                if(i == this.batchInputs.length){
                    this.batchInputs.push({value:this.paramInput.paramVal, key:this.paramInput.paramName});

                }
            }
            else{
                this.batchInputs.push({value:this.paramInput.paramVal, key:this.paramInput.paramName});

            }
            
           
            console.log('this.batchInputs:'+this.batchInputs);
            

            
        
      
    }

    checkParam(){

        checkParameterForSelectedBatch({ batchName: this.selected})
        .then((data) => {
            this.batchParamName=[];
            this.hasParams = true;
            console.log('data.batchParamName size='+data.batchParamName.length);
            for(var i=0;i<data.batchParamName.length;i++){
                this.batchParamName.push(data.batchParamName[i]);
            }
            this.paramSize =  this.batchParamName.length;
            console.log('param size='+this.paramSize);

        })
        .catch(error => {
            console.log(error);
          
        });
    }

    handleAmountChange(e) {
        this.amount = e.detail.value;
    }
    handleClick()
    {
        runBatchClass({ name: this.selected,batchSize: this.amount , paramInput:this.batchInputs })
            .then((result) => {
                this.batchId = result;
                console.log('Batch Executed',this.batchId);
            })
            .catch((error) => {
                this.error = error;
            });
    }

    checkBatchStatus()
    {
        checkBatchStatus({ batchJobId: this.batchId })
            .then((result) => {
                this.columns = batchDetailCol;
                this.data = result;
            })
            .catch((error) => {
                this.error = error;
            });
    }

    searchBatch(event) {


        this.data = [];
        

        this.batchName=event.target.value;
        this.LoadingText = true;
        console.log('line 155 batchname is '+this.batchName);
        getBatch({batchName:this.batchName})
        .then(result => {
          this.BatchesName=result;
          console.log("Batches are"+this.BatchesName);
          this.LoadingText = false;
          this.dynamiClassname =  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
          console.log('length'+result.length);
          if( result.length == 0) 
          {
            this.messageFlag = true;
            console.log('no record');
           }
           else 
           {
            this.messageFlag = false;
            console.log('record present');
           }
    })
    .catch(error => {
        console.log('-------error-------------'+error);
        console.log(error);
    });
        
    }

    setSelectedRecord(event) {
        this.selected=event.currentTarget.dataset.id;
        console.log('selected batch class is'+this.selected);
        this.dynamiClassname =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        this.hasParams = false;
        this.batchInputs = [];
        this.batchId='';
        this.showSuccessIcon=false;
        this.batchStatus='';
    


        this.checkParam();

        
    }

}