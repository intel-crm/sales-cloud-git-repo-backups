import {LightningElement, wire,track,api} from 'lwc';
import getProducts from '@salesforce/apex/Retail_CPQ_ExhibitList.getIVRProducts';
import { refreshApex } from '@salesforce/apex';
import sendProduct from '@salesforce/apex/Retail_CPQ_ExhibitList.saveChildIVRquoteExhibitList';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord } from 'lightning/uiRecordApi';
const COLS=[  
    {label:'Product Name',fieldName:'Name', type:'text'}  ,
    {label:'PROCESSOR NUMBER',fieldName:'Core_Processor_Number_Nm__c',initialWidth: 160}  ,
    {label:'Product Series',fieldName:'Core_Product_Series__c', type:'text'}  ,
  ];
  const FIELDS = ['SBQQ__Product__c'];
export default class Retail_CPQ_ProductExhibitList extends LightningElement {
    //tableData;
    @track tableData = [];
    @track tableDataTemp = [];
    @track tableDataSelectionTemp = [];
    @track tempSearchQuoteLineList = [];
    @track dataReturn= [];
    @track selectedValue;
    @track endsWithSelectedValue;
    columns=COLS;
    @api recordId;
    @track spinnerOn=false;
    @track oldQuoteLineList = [];
    @track selection = [];
    @track wiredAccountList = [];
    @track refreshOff=false;
    @track selectionTemp = [];
    //@track actualQuoteLineMap = {};
   
    //@track disableSave=true;
    //Connected Callback which will execute on component load.
    connectedCallback(){

       
        console.log('inside Connectedcallback apexrefresh12');
        this.spinnerOn=true;
        this.fetchtierdetails();
    }
    renderedCallback() {
        /*if(this.refreshOff == false){
            console.log('inside renderedCallback');
           return refreshApex(this.wiredAccountList); 
            this.refreshOff = true;
            
        }*/
        console.log('inside renderedCallback');
       
    }
    fetchtierdetails(){
        getProducts({quoteLineId: this.recordId})
        .then(result=>{
            console.log('result101'+result);
            this.spinnerOn=false;
            //this.tableData=JSON.parse(JSON.stringify(result.tierList));
            this.isdata=false
            this.tableData = JSON.parse(JSON.stringify(result.productList));
            this.tableDataTemp = JSON.parse(JSON.stringify(result.productList));
            this.tableDataSelectionTemp = JSON.parse(JSON.stringify(result.productList));;
            this.selection = JSON.parse(JSON.stringify(result.selectedIdSet));
            //map from array with key as ID
            //var myMap2 = new Map();
            var myMap = {};
            const instance = this;
                this.tableData.forEach(function(quoteLine){
                   myMap[quoteLine.Id] = quoteLine;
                    
                })
                this.actualQuoteLineMap = myMap;
                this.spinnerOn=false;
                
        })
        .catch(error=>{ 
            console.log('insideError123'+error);

            this.spinnerOn=false;
        })
    }
    // to solve refresh issue on update of product
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        console.log('insodeGetRec'+data);
            if (data) {
                this.fetchtierdetails();
            }
        
    }
    /*@wire(getProducts, {quoteLineId: '$recordId'})
    getProducts(result) {
      
        this.wiredAccountList = result;
        if (result.data) {
            console.log('FileData: ' + JSON.stringify(result.data)+"lengths "+result.data.length)
            this.isdata=false
            this.tableData = result.data.productList;
            this.tableDataTemp = result.data.productList;
            this.tableDataSelectionTemp = result.data.productList;
            this.selection = result.data.selectedIdSet;
            //map from array with key as ID
            //var myMap2 = new Map();
            var myMap = {};
            const instance = this;
                this.tableData.forEach(function(quoteLine){
                   myMap[quoteLine.Id] = quoteLine;
                    
                })
                this.actualQuoteLineMap = myMap;
        } 
        else{
            if(result.error){
                console.log('error++++++++++: ', result.error)
            }
        }
        this.spinnerOn=false;
       
    }*/

   closeModal() {

        /*this.dispatchEvent(new CloseActionScreenEvent());
        eval("$A.get('e.force:refreshView').fire();")
        this.dispatchEvent(new CloseActionScreenEvent());

        console.log('outsideeval2');
        console.log('inCloseModal'+JSON.stringify(this.selection) )
        console.log('FileData:inCloseModal ' + JSON.stringify(this.wiredAccountList.data))
           
         eval("$A.get('e.force:closeQuickAction').fire();")
        return refreshApex(this.wiredAccountList); */
       window.location.reload();
       //uncomment below for non reload method 
      /* this.spinnerOn=true;
       this.fetchtierdetails();
       this.spinnerOn=false;*/
        
        
    }
    saveData(){
        //added for persistence
       this.oldQuoteLineList = [];
       const instance = this;

       const filterMap = new Map(Object.entries(this.actualQuoteLineMap));
       //this.quoteLineList = JSON.parse(JSON.stringify(result.quoteLineList));
        this.selection.forEach(function(selectedIdKey){
            if(filterMap.has(selectedIdKey)){
                instance.oldQuoteLineList.push(filterMap.get(selectedIdKey));
            }
        });
        console.log("Selected Line"+JSON.stringify(this.oldQuoteLineList));
        sendProduct({ProductList : this.oldQuoteLineList,quoteLineId : this.recordId})  
        .then(result=>{ 
            this.dispatchEvent(new CloseActionScreenEvent());
            window.location.reload();    

        })  
    .catch(error=>{ })

    this.dispatchEvent(new CloseActionScreenEvent());
    
    }
    get dataPresent(){
        return this.tableData.length>0;
    }
    //on change of search
    onchangeHandle(event){
        this.spinnerOn=false;
        if((this.tempSearchQuoteLineList == null || this.tempSearchQuoteLineList == undefined) || 
           (this.tempSearchQuoteLineList != null && this.tempSearchQuoteLineList.length == 0)){
            this.tempSearchQuoteLineList =  this.tableData;
        }
        this.dataReturn = [];
        let endsWith;
        this.selectedValue = event.target.value;
        let currentList = this.tempSearchQuoteLineList;
        if(this.endsWithSelectedValue != null && this.endsWithSelectedValue  != undefined && this.endsWithSelectedValue  != ''){
            endsWith = this.endsWithSelectedValue;
        }else{
            endsWith = '';
        }
        
        if((this.selectedValue.length > 0 && this.selectedValue!== undefined && this.selectedValue !== null) || 
            (endsWith.length > 0 && endsWith!== undefined && endsWith !== null)){
            let concat ='';
            let cnt = 0;
            for (let index = 0; index < currentList.length; index++) {
                console.log('onchangeHandle 1');
                concat+= currentList[index].Core_Processor_Number_Nm__c;
                //console.log('concatenated String :'+concat);
                concat = concat.toLowerCase();
                console.log('onchangeHandle 2 '+concat);
                console.log('onchangeHandle 4 '+this.selectedValue.toLowerCase());
                console.log(concat);
                if(concat.startsWith(this.selectedValue.toLowerCase()) && concat.endsWith(endsWith.toLowerCase())){
                    //this.isDataAvailable = true;
                    console.log('found :'+index);
                    this.dataReturn.push(currentList[index]);
                  //  cnt++;
                }                concat='';
                
            }
            if(this.dataReturn.length <= 0){
               // this.isDataAvailable = false;
            }
            
        }else{
            //this.connectedCallback();
            this.tableData = this.tableDataTemp;
            this.spinnerOn=false;
        }
        if(this.selectedValue.length === 0 && endsWith.length===0){
            //this.isDataAvailable = true;
            this.dataReturn = this.tableData;
        }else{
            this.tableData = this.dataReturn;
        }
        //console.log('---selection---OnchangeHandle'+JSON.stringify(this.selection));

        if(this.selection != null && this.selection  != undefined && this.selection  != ''){
            console.log('---selection---Commented'+JSON.stringify(this.selection));
            
            if(this.tableData != null && this.tableData  != undefined && this.tableData  != ''){
                

                //console.log('---querySelector---datatable'+JSON.stringify(this.template.querySelector('[data-id="datarow"]').DataTable()));
                if(this.tableDataSelectionTemp != null && this.tableDataSelectionTemp  != undefined && this.tableDataSelectionTemp  != ''){
                    this.template.querySelector(// added for persistance
                        '[data-id="datarow"]'
                    ).selectedRows = this.selection;
                }
                //this.selectionTemp = this.selection;
               
            }
            this.tableDataSelectionTemp = this.tableData;
        }

    } 
    // on change of ends with
    onchangeEndsWithHandle(event){
        //var startsWith = document.getElementById("searchTxt").value;
        console.log('startsWithquerySele'+this.selectedValue);
        var endsWith = event.target.value;
        console.log('endsWith'+endsWith);

        this.spinnerOn=false;
        if((this.tempSearchQuoteLineList == null || this.tempSearchQuoteLineList == undefined) || 
           (this.tempSearchQuoteLineList != null && this.tempSearchQuoteLineList.length == 0)){
            this.tempSearchQuoteLineList =  this.tableData;
        }
        this.dataReturn = [];
        let startsWith;
        this.endsWithSelectedValue = event.target.value;
        let currentList = this.tempSearchQuoteLineList;
        if(this.selectedValue != null && this.selectedValue  != undefined && this.selectedValue  != ''){
            startsWith = this.selectedValue;
        }else{
            startsWith = '';
        }
        
        if((this.endsWithSelectedValue.length > 0 && this.endsWithSelectedValue!== undefined && this.endsWithSelectedValue !== null) ||
            (startsWith.length > 0 && startsWith!== undefined && startsWith !== null)){
            let concat ='';
            let cnt = 0;
            for (let index = 0; index < currentList.length; index++) {
                console.log('onchangeHandle 1');
                concat+= currentList[index].Core_Processor_Number_Nm__c;
                //console.log('concatenated String :'+concat);
                concat = concat.toLowerCase();
                console.log('onchangeHandle 2 '+concat);
                console.log('onchangeHandle 4 '+this.endsWithSelectedValue.toLowerCase());
                console.log(concat);
                if(concat.startsWith(startsWith.toLowerCase()) && concat.endsWith(this.endsWithSelectedValue.toLowerCase())){
                    //this.isDataAvailable = true;
                    console.log('found :'+index);
                    this.dataReturn.push(currentList[index]);
                  //  cnt++;
                }                concat='';
                
            }
            if(this.dataReturn.length <= 0){
               // this.isDataAvailable = false;
            }
            
        }else{
            //this.connectedCallback();
            this.tableData = this.tableDataTemp;
            this.spinnerOn=false;
        }
        if(this.endsWithSelectedValue.length === 0 && startsWith.length===0){
            //this.isDataAvailable = true;
            this.dataReturn = this.tableData;
        }else{
            this.tableData = this.dataReturn;
        }
        //console.log('---selection---OnchangeHandle'+JSON.stringify(this.selection));

        if(this.selection != null && this.selection  != undefined && this.selection  != ''){
            console.log('---selection---Commented'+JSON.stringify(this.selection));
            
            if(this.tableData != null && this.tableData  != undefined && this.tableData  != ''){
                

                //console.log('---querySelector---datatable'+JSON.stringify(this.template.querySelector('[data-id="datarow"]').DataTable()));
                if(this.tableDataSelectionTemp != null && this.tableDataSelectionTemp  != undefined && this.tableDataSelectionTemp  != ''){
                    this.template.querySelector(// added for persistance
                        '[data-id="datarow"]'
                    ).selectedRows = this.selection;
                }
                //this.selectionTemp = this.selection;
               
            }
            this.tableDataSelectionTemp = this.tableData;
        }
    }
    //added for persistence row selection in quotelinedata tables
    rowSelection(evt) {        console.log('---underRowSelection---');
        // List of selected items from the data table event.
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selection);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();
    
        
        this.tableData.map((event) => {
            loadedItemsSet.add(event.Id);
        });
        
        if (evt.detail.selectedRows) {
            evt.detail.selectedRows.map((event) => {
                updatedItemsSet.add(event.Id);
            });
    
    
            // Add any new items to the selection list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });        
        }
        console.log('---updatedItemsSet---'+(this.updatedItemsSet));
        console.log('---selectedItemsSet---'+(this.selectedItemsSet));

        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });
        var filtered = [...selectedItemsSet];
        this.selection = filtered;
        console.log('---selection---'+JSON.stringify(this.selection));
    }
    async refresh() {
        await refreshApex(this.wiredAccountList);
    }
   /* refresh() {
        return refreshApex(this.wiredAccountList); 
    }  */ 
}