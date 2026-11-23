import { LightningElement,track,api,wire } from 'lwc';
import getProducts from '@salesforce/apex/Retail_CPQ_ExhibitList.getAllRetailProducts'; 
import saveExList from '@salesforce/apex/Retail_CPQ_ExhibitList.saveMasterExList'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const COLS=[  
    {label:'Product Name',fieldName:'Name', type:'text'}  ,
    {label:'PROCESSOR NUMBER',fieldName:'Core_Processor_Number_Nm__c',type:'text'}  ,
    {label:'Product Series',fieldName:'Core_Product_Series__c', type:'text'},
];

export default class retail_masterExList extends LightningElement {
    @api recordId;
    @track tableData;
    columns=COLS;
    @track selection=[];
    @track showSpinner=false;
    @track dataPresent=false;
    @track tableDataTemp;
    @track tableDataSelectionTemp;
    @track generationCurrentList;
    @track tempSearcProductList;
    @track generationFilterSet;
    @track dataReturn= [];
    @track selectedValue=[];   
    @track endsWithSelectedValue;
    @track selectionTemp = [];
    @track selectedRows =[];
    connectedCallback(){
        console.log('Inside connectedcallback');
        this.showSpinner=true;
        this.getAllProducts();
    }
    getAllProducts(){
        getProducts({groupId:this.recordId})
        .then(result=>{
            this.dataPresent=true;
            this.tableData=JSON.parse(JSON.stringify(result.productList));
            this.selection=result.selectedIdSet;
            console.log('TableData'+this.tableData);
            console.log('SelectionSet'+this.selection);
            this.tableDataTemp = result.productList;
            this.tableDataSelectionTemp = result.productList;
            //when no generations are selected in filter,we consider all generations
            this.generationCurrentList =result.productList;
           this.generationSet =result.generationFilterSet;
            this.picklistvalueselected=this.generationSet.map(type=>{
                return {
                    label:type,
                    value:type
                }
            })
             var myMap = {};
            const instance = this;
                this.tableData.forEach(function(quoteLine){
                    //instance.actualQuoteLineMap.set(quoteLine.Id,quoteLine );
                   // myMap2.set(quoteLine.Id,{ ...quoteLine });
                   myMap[quoteLine.Id] = quoteLine;
                    //instance.actualQuoteLineMap[quoteLine.Id] = quoteLine;
                })
                this.actualQuoteLineMap = myMap;
            this.showSpinner=false;
        })
        .catch(error=>{
            this.dataPresent=false;
            console.log('Error'+JSON.stringify(error));
            this.showSpinner=false;

        })
        
        

        
    }
    saveData(){
        this.showSpinner=true;
        this.selectedRows = [];
        const instance = this;
 
        const filterMap = new Map(Object.entries(this.actualQuoteLineMap));
        console.log('selectedhas1111 '+filterMap);
        //this.quoteLineList = JSON.parse(JSON.stringify(result.quoteLineList));
         this.selection.forEach(function(selectedIdKey){
            console.log('selected'+selectedIdKey);
            console.log('selectedhas'+filterMap.has(selectedIdKey));
             if(filterMap.has(selectedIdKey)){
                 instance.selectedRows.push(filterMap.get(selectedIdKey));
             }
         });
        //onsole.log('SelectedRows'+JSON.stringify(this.template.querySelector('lightning-datatable').getSelectedRows()));
        //const selectedRows=this.template.querySelector('lightning-datatable').getSelectedRows();
        saveExList({ProductList : this.selectedRows,productGrpId:this.recordId})
        .then(result=>{
            this.showSpinner=false;
            this.showToast('Success','Exhibit List Saved Successfully','success');
            //this.connectedCallback();
            window.location.reload();
        })
        .catch(error=>{
            this.showToast('Error',JSON.stringify(error),success);
            this.showSpinner=false;
        })
    }
    //get dataPresent(){
        //return this.tableData.length>0;
    //}
    rowSelection(evt) { 
        this.showSpinner=true;       
        console.log('---underRowSelection---');
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
        this.showSpinner=false;
    }
    showToast(msgTitle,msg,type){
        console.log('In Toast');
        this.dispatchEvent(
            new ShowToastEvent({
                title: msgTitle,
                message: msg,
                variant: type,
                mode: 'dismissable'
            }),
        );
    }
    onchangeHandle(event){
        this.spinnerOn=false;
        if((this.tempSearcProductList == null || this.tempSearcProductList == undefined) || 
           (this.tempSearcProductList != null && this.tempSearcProductList.length == 0)){
            this.tempSearcProductList =  this.tableData;
        }
        this.dataReturn = [];
        let endsWith;
        this.selectedValue = event.target.value;
       // let currentList = this.tempSearcProductList;
       let currentList = this.generationCurrentList;
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
            //this.tableData = this.tableDataTemp;
            this.tableData = this.generationCurrentList;
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
        if((this.tempSearcProductList == null || this.tempSearcProductList == undefined) || 
           (this.tempSearcProductList != null && this.tempSearcProductList.length == 0)){
            this.tempSearcProductList =  this.tableData;
        }
        this.dataReturn = [];
        let startsWith;
        this.endsWithSelectedValue = event.target.value;
        //let currentList = this.tempSearcProductList;
        let currentList = this.generationCurrentList;
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
            //this.tableData = this.tableDataTemp;
            this.tableData = this.generationCurrentList;
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
    handlePickListValueChange(event){
        // Set of selected generations.
        this.selectedGenValue=new Set(event.target.value);
        if((this.tempSearcProductList == null || this.tempSearcProductList == undefined) || 
           (this.tempSearcProductList != null && this.tempSearcProductList.length == 0)){
            this.tempSearcProductList =  this.tableData;
        }
        this.dataReturn = [];
        let startsWith;
        let endsWith;
        let currentGenerationList = this.tempSearcProductList;
        if((this.selectedValue != null && this.selectedValue  != undefined && this.selectedValue  != '') && (this.endsWithSelectedValue != null && this.endsWithSelectedValue  != undefined && this.endsWithSelectedValue  != '')){
            startsWith = this.selectedValue;
            endsWith=this.endsWithSelectedValue;
        }else if((this.selectedValue != null && this.selectedValue  != undefined && this.selectedValue  != '')){
            startsWith = this.selectedValue;
            endsWith='';
        }else if((this.endsWithSelectedValue != null && this.endsWithSelectedValue  != undefined && this.endsWithSelectedValue  != '')){
            endsWith=this.endsWithSelectedValue;
            startsWith = '';
        }else{
            startsWith = '';
            endsWith='';
        }
        let currentList = [];
        let generationSelectedWithNoProducts = false;
        //firstly filter currentList based on Generation Level
        if(this.selectedGenValue.size > 0){
            let generationDataTabledata ='';
           
            for (let index = 0; index < currentGenerationList.length; index++) {
                
                generationDataTabledata= currentGenerationList[index].Core_Product_Series__c;
                //console.log('checkUndefiened'+generationDataTabledata);
                if(generationDataTabledata != null && generationDataTabledata  != undefined && generationDataTabledata  != ''){
                        generationDataTabledata = generationDataTabledata.toLowerCase();
                    
                    // Add any new items to the selection list
                    this.selectedGenValue.forEach((generationSelected) => {
                        generationSelectedWithNoProducts = true;
                        generationSelected = generationSelected.toLowerCase();
                        console.log('generationDataTabledataInsideLoop2'+generationDataTabledata+'SetVal'+generationSelected+'generationSelectedWithNoProducts'+generationSelectedWithNoProducts);
                        
                        if(generationDataTabledata.includes(generationSelected)){
                            currentList.push(currentGenerationList[index]);
                        }
                        
                    });
                }
            }
        }
        //currentList is null when Generation is null or with that generation no prodcuts exist
        console.log('currentList.length'+currentList.length+'generationSelectedWithNoProducts'+generationSelectedWithNoProducts);
        if(currentList.length>0){
            this.generationCurrentList = currentList;
        }else if(generationSelectedWithNoProducts == true && currentList.length<=0){
            currentList = [];
            this.generationCurrentList = currentList;
        }
        else{
            currentList = this.tableDataTemp;
            this.generationCurrentList = currentList;
        }

        console.log('this.generationCurrentList 1'+this.generationCurrentList);
        if(( startsWith.length > 0 && startsWith!== undefined && startsWith !== null) || (endsWith.length > 0 && endsWith!== undefined && endsWith !== null)||(currentList.length>0)){
            let concat ='';
            let cnt = 0;
            for (let index = 0; index < currentList.length; index++) {
                console.log('onchangeHandle 1');
                concat+= currentList[index].Core_Processor_Number_Nm__c;
                concat = concat.toLowerCase();
                console.log('onchangeHandle 2 '+concat);
                console.log('onchangeHandlestartsWith '+startsWith+'onchangeHandleEndsWith'+endsWith);
                console.log(concat);
                if(concat.startsWith(startsWith.toLowerCase()) && concat.endsWith(endsWith.toLowerCase())){
                    console.log('found :'+index);
                    this.dataReturn.push(currentList[index]);
                }
                concat='';
                
            }
            if(this.dataReturn.length <= 0){
               // this.isDataAvailable = false;
            }
            
        }else{
            this.tableData = this.generationCurrentList;
            this.spinnerOn=false;
        }
        if(endsWith.length === 0 && startsWith.length===0 && this.selectedGenValue.size===0){
            //this.isDataAvailable = true;
            this.tableData = this.tableDataTemp;
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

}