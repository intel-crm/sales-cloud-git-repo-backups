import { LightningElement,api,wire,track} from 'lwc';
import getAllocationDetails from '@salesforce/apex/Allocation_VisibilityController.getAllocationDetails';
import getTotalAllocations from '@salesforce/apex/Allocation_VisibilityController.getTotalAllocations';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import selectBudgetType from '@salesforce/label/c.Core_MDF_Placeholder_Value';
import pfaDetails from '@salesforce/label/c.Core_MDF_PFA_Details';
import accountNode from '@salesforce/label/c.Core_MDF_Account_Node';
import Program from '@salesforce/label/c.Core_MDF_Bulk_Claim_Program';
import budgetType from '@salesforce/label/c.Core_MDF_Budget_Type_PFA';
import startDate from '@salesforce/label/c.Core_MDF_Start_Date';
import endDate from '@salesforce/label/c.Core_MDF_End_Date';
import Amount from '@salesforce/label/c.Core_MDF_Amount';
import activityReservedAmount from '@salesforce/label/c.Core_MDF_Total_Act_Alloc_Amount';
import activityAvailableAmount from '@salesforce/label/c.Core_MDF_Unallocated_Act_Amount';
import claimReservedAmount from '@salesforce/label/c.Core_MDF_Total_Approved_Fund_Claims';
import claimAvailableAmount from '@salesforce/label/c.Core_MDF_Unalloc_PFC_Amount';
import all from '@salesforce/label/c.Core_MDF_All_BudgetTypes';
import errorMsg from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import noRecords from '@salesforce/label/c.Core_MDF_NoRecordsToDisplay';
import itemsToDisplay from '@salesforce/label/c.Core_MDF_Display_Msg';
import ContactMobile from '@salesforce/schema/Case.ContactMobile';



export default class Allocation_VisibilityController extends LightningElement {
    targetDatatable;
    @track showTable=false;
    @track sortBy;
    @track sortDirection;
    @track error;
    @api allocToExport;
    @api allocList ; //Used to store total records
    @api allocToDisplay; //To display in datatable 
    @api recordCount;
    @track searchAllocName='';
    @track selectedValue='';
    @api budgetTypeValues=[];
    @api budgetList=[]; //this will hold key , value pair
    @api programList=[]; //this will hold label,value,selected attributes
    @track value='';
    @track isSpinner =true;
    @track hasdata=true; //make it false and check
    @track totalNumberOfRows;
    @track loadMoreStatus='';
    @track selectedMultiValues=[];
    @track countr=0;
    allbudgets=[];
    allprograms=[];
    //Expose the labels to use it in template of html file
    label ={
        selectBudgetType,
        pfaDetails,
        budgetType,
        noRecords,
        itemsToDisplay
    };
    @track columns =[
        { label:  Program,fieldName : 'programName',type: 'text',sortable  : true},
        { label:  accountNode,fieldName : 'accountURL',type: 'url', typeAttributes: { label: { fieldName: 'accountName' }, target: '_blank'},sortable  : true},
        { label:  budgetType,fieldName : 'budgetType',type: 'text',sortable  : true},
        { label:  startDate,fieldName : 'startDate',type : 'Date',sortable : true},
        { label:  endDate,fieldName : 'endDate',type : 'Date',sortable : true},
        { label:  Amount,fieldName : 'amount',type: 'currency',sortable  : true},
        { label:  activityReservedAmount,fieldName : 'totalActivityAllocAmount',type: 'currency',sortable  : true},
        { label:  activityAvailableAmount,fieldName : 'unallocatedActAmount',type: 'currency',sortable  : true},
        { label:  claimReservedAmount,fieldName : 'totalApprovedFundClaims',type: 'currency',sortable  : true},
        { label:  claimAvailableAmount,fieldName : 'unallocatedClaimAmount',type: 'currency',sortable  : true},
    ];
    get options(){
        return this.budgetList;
    }
    @wire(getTotalAllocations,{sortField : '' , direction : ''})
        wiredAlloc({error,data}){
            if(data){
                this.allocToExport = data;
                this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
            }
        }

    @wire(getAllocationDetails, {offsetCount :0 , sortField : '' , direction : ''})
    wiredAllocations({error,data}) 
    {   
        if (data) {
            this.allocList = data;
            this.allocToDisplay = data;
            //this.showTable = true;
            this.recordCount = data.length;
            this.hasdata=true;
            console.log('Entered data method');
            if(this.allocList.length>0){
            //this.totalNumberOfRows=this.allocList.length;
            this.isSpinner=false;
            //this.hasdata =true;
            let budgetTypes=[];
            let programValues=[];
            //Looping over returned total records and filtering out unique budget types
            for(var i=0;i<this.allocList.length;i++){
                console.log('Entered for loop');
                if(!budgetTypes.includes(this.allocList[i].budgetType)){
                    budgetTypes.push(this.allocList[i].budgetType);
                    console.log('Inside loop'+JSON.stringify(budgetTypes));
                    this.budgetList = [...this.budgetList,{label:this.allocList[i].budgetType,value :this.allocList[i].budgetType,selected : false}];
                     
                }
                if(!programValues.includes(this.allocList[i].programName)){
                    programValues.push(this.allocList[i].programName);
                    console.log('Inside for loop of programs' +JSON.stringify(programValues));
                    this.programList =[...this.programList,{label:this.allocList[i].programName,value:this.allocList[i].programName,selected:false}];
                }
            } 
            console.log('budget Type values out of forloop' +JSON.stringify(budgetTypes));
            this.budgetList.push({label:all,value:all,selected:false});
            this.programList.push({label:all,value:all,selected:false});
            this.allbudgets=[...this.budgetList];
            this.allprograms=[...this.programList];
            console.log('budget list to be parsed'+JSON.stringify(this.budgetList));
            //budgetTypes.push(all);
            //this.budgetTypeValues=[...budgetList];
           // console.log('Final budget Types' +JSON.stringify(this.budgetTypeValues));
            console.log('map values size:' +JSON.stringify(this.budgetList));
        }
        else if(this.allocList.length === 0){
            console.log('Entered into else- no records');
            this.hasdata=false;
            this.isSpinner=false;
            
        }
        } else if (error) {
            this.showTable=false;
            this.isSpinner = false;
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: errorMsg,
                    message: data,
                    variant: 'error'
                }),
            );
        }                     
   }
   //Capture the event fired from the paginator component
     handlePaginatorChange(event){
        this.template.querySelector('lightning-datatable').selectedRows = []; //event.detail.selectedRows;
        this.allocToDisplay = event.detail;
      }
    
    //sorting logic
    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;
        console.log('this.sortBy---------'+this.sortBy);
        // sort direction
        this.sortDirection = event.detail.sortDirection;
        console.log('this.sortDirection----------'+this.sortDirection);
        this.countr = 0;
        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(JSON.stringify(event.detail.fieldName), JSON.stringify(event.detail.sortDirection));
        this.targetDatatable.enableInfiniteLoading = true;
    }
    sortData(fieldname, direction) {
        console.log(fieldname + '++++++'+ direction);
        getAllocationDetails({offsetCount : 0 , sortField : fieldname , direction : direction})
        .then(result => {
            this.allocToDisplay = result;
        })
        .catch(error => {
                this.error = error;
        })
      /*  // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.allocToDisplay));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.allocToDisplay = parseData;    */

    }
    handlePicklistChange(event) {
        this.selectedValue=event.detail.value ;
        if(this.selectedValue === all){
            console.log('If All is selected' +JSON.stringify(this.selectedValue));
            this.allocToDisplay = this.allocList;
        }
        else{
            console.log( 'New Value selected is ' + JSON.stringify(this.selectedValue) );  
            this.filter();
        }
        this.recordCount = this.allocToDisplay.length;
        console.log('Record count for All Value' +JSON.stringify(this.recordCount));
        // Calling Paginator function to handle Pagination when a search is made
        this.template.querySelector("c-paginator").handlePaginationOnSearch(this.allocToDisplay, this.recordCount);
  

    }
    filter(){
        if(this.selectedValue!=null && this.selectedValue!= '' && this.selectedValue != 'undefined'){
            console.log('Inside filter method');
            this.allocToDisplay = this.allocList;
            if(this.allocToDisplay!=null && this.allocToDisplay!='' && this.allocToDisplay!= 'undefined'){
                let recs=[];
                for(var index = 0; index< this.allocToDisplay.length; index++){
                    if (this.allocToDisplay[index].budgetType === this.selectedValue) {
                        recs.push(this.allocToDisplay[index]);
                        console.log('Inside if condition' +JSON.stringify(this.allocToDisplay[index].budgetType));
                    }
                }
                console.log( 'Recs are ' + JSON.stringify( recs ) );
                this.allocToDisplay = recs;
            }
        }
        else{
            console.log('Else part of filter method');
            this.allocToDisplay=this.allocList;
        }
        this.recordCount = this.allocToDisplay.length;
        // Calling Paginator function to handle Pagination when a search is made
        this.template.querySelector("c-paginator").handlePaginationOnSearch(this.allocToDisplay, this.recordCount);
  
    }
    //For infinite scrolling   
    loadMoreData(event) {
            event.preventDefault();
            console.log('Inside load more befre countr' +JSON.stringify(this.countr));
            // increase the offset count by 20 on every loadmore event
            this.countr = this.countr + 5;
            //Display a spinner to signal that data is being loaded
            event.target.isLoading = true;
            //Set the onloadmore event taraget to make it visible to imperative call response to apex.
            this.targetDatatable = event.target;
            //Display "Loading" when more data is being loaded
            this.loadMoreStatus = 'Loading';
            // Get new set of records and append to this.data
            console.log('Inside load more befre countr' +this.countr);
           // this.getTotalRows();
            this.getRecords();

    }
    //on value selection
    onValueSelect(event){
        console.log('entered onValueSelect - Parent');
        this.selectedMultiValues = event.detail;
        console.log('Multiple selected values' +JSON.stringify(this.selectedMultiValues.value));
        if(this.selectedMultiValues.value.length === 0 && !this.selectedMultiValues.selected){
            this.allocToDisplay = this.allocList;
            this.budgetList=this.allbudgets;
            this.programList=this.allprograms;
            console.log('Inside unchecked values');
        }
        else if(this.selectedMultiValues.value.includes(all)){
            console.log('If All is selected' +JSON.stringify(this.selectedMultiValues));
            this.allocToDisplay = this.allocList;
            console.log('Size of records' +JSON.stringify(this.allocToDisplay.length));
        }
        else if(!this.selectedMultiValues.value.includes(all)){
            console.log('Other than all value');
            this.filterRecords();
        }
    }
    filterRecords(){
        if(this.selectedMultiValues.value!=null && this.selectedMultiValues.value!= '' && this.selectedMultiValues.value != 'undefined'){
            console.log('Inside filter method');
           // this.allocToDisplay = this.allocList;
            if(this.allocList!=null && this.allocList!='' && this.allocList!= 'undefined'){
                console.log('Inside allocList not null');
                let recs=[];
                let programs=[];
                let budgets=[];
                let budgList=[];
                let progList=[];
                for(var index = 0; index< this.allocList.length; index++){
                    console.log('Inside for loop-filter method');
                    if (this.selectedMultiValues.value.includes(this.allocList[index].budgetType)) {
                        console.log('Inside select budget types');
                        recs.push(this.allocList[index]);
                        if(!programs.includes(this.allocList[index].programName)){
                            programs.push(this.allocList[index].programName);
                            /*progList =[...progList,{label:this.allocList[index].programName,value:this.allocList[index].programName,selected:false}];
                            */console.log('Inside if condition of filter' +JSON.stringify(programs));
                        }
                    }
                    else if(this.selectedMultiValues.value.includes(this.allocList[index].programName)){
                        console.log('Inside select programs');
                        recs.push(this.allocList[index]);
                        console.log('Recs inside for loop ' + JSON.stringify( recs ) );
                        if(!budgets.includes(this.allocList[index].budgetType)){
                            console.log('inside budget if condition');
                            budgets.push(this.allocList[index].budgetType);
                           /* budgList =[...budgList,{label:this.allocList[index].budgetType,value:this.allocList[index].budgetType,selected:false}];
                            */console.log('Inside if condition budget' +JSON.stringify(budgets));
                        }
                          }
                }
                console.log( 'Recs are ' + JSON.stringify( recs ) );
               /* if(progList.length>0){
                    this.programList=[...progList]; 
                    console.log('Inside assignment of prog' +JSON.stringify(this.programList));
                }
                if(this.budgList.length>0){
                    this.budgetList =[...budgList];
                    console.log('Budget values in filter method' +JSON.stringify(this.budgetList));

                }*/
                if(budgets.length>0){
                    for(var i=0; i<budgets.length;i++){
                        budgList=[...budgList,{label:budgets[i],value:budgets[i],selected:false}];
                        console.log('budget list in for loop' +JSON.stringify(budgList));
                    }
                this.budgetList=[...budgList];
                }
                if(programs.length>0){
                    for(var j=0; j<programs.length;j++){
                        progList=[...progList,{label:programs[j],value:programs[j],selected:false}];
                        console.log('program list in for loop' +JSON.stringify(progList));
                    }
                this.programList=[...progList];
                }
               /* if(programs.length>0 && programs!='' && programs!='undefined'){
                    this.programList=[...programs];
                    console.log('Program values in filter method' +JSON.stringify(this.programList));
                }
                if(budgets.length>0 && budgets!='' && budgets!='undefined'){
                    this.budgetList =[...budgets];
                    console.log('Budget values in filter method' +JSON.stringify(this.budgetList));
                }*/
                this.allocToDisplay = recs;
                console.log('length of records to be displayed' +this.allocToDisplay.length);
            }
        }
    }
   //Export functionality
    handleSelectedExport(event){
        // retrieve the selected item's value
        /*getTotalAllocations()
        .then(result => {
            this.allocToExport = result;
            this.error = undefined;
            console.log('result'+result);
        })
        .catch(error => {
            this.error = error;
            console.log('error : ' + JSON.stringify(this.error));
        }); */ 
        
        
    const selectedItemValue = event.detail.value;
    console.log('selectedItemValue'+selectedItemValue);
    console.log('this.allocToExport+++++++++'+this.allocToExport);
    if(selectedItemValue=="ExportToExcel"){
        console.log('in if');
        this.exportToExcel();
    }
    else if(selectedItemValue=="ExportToCsv"){
        this.exportToCSV();
    }

    }
    getRecords() {
        getAllocationDetails({offsetCount : this.countr , sortField : this.sortBy , direction : this.sortDirection})
            .then(result => {
                // Returned result if from sobject and can't be extended so objectifying the result to make it extensible
                //use concate method 
                let currentData=[];
                currentData=[...this.allocToDisplay];
                this.allocToDisplay = currentData.concat(result);
                //this.allocToDisplay =[...this.allocToDisplay, ...result];
                this.error = undefined;
                this.loadMoreStatus = '';
                console.log('Inside get resutts' +this.allocToDisplay.length);
                console.log('this.totalNumberOfRows'+this.totalNumberOfRows);
                
               // if (this.targetDatatable && this.allocToDisplay.length >= this.totalNumberOfRows) {
               if( this.targetDatatable  && result.length<5) {
               //stop Infinite Loading when threshold is reached
                    this.targetDatatable.enableInfiniteLoading = false;
                    //Display "No more data to load" when threshold is reached
                    this.loadMoreStatus = 'No more data to load';
                }
                //Disable a spinner to signal that data has been loaded
                if (this.targetDatatable) this.targetDatatable.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.allocToDisplay = undefined;
                console.log('error : ' + JSON.stringify(this.error));
            });
    }
    exportToCSV() {  
        let columnHeader = [Program, accountNode,budgetType,startDate,endDate,Amount,activityReservedAmount,activityAvailableAmount,claimReservedAmount,claimAvailableAmount ];  // This array holds the Column headers to be displayd
        let jsonKeys = ["programName", "accountURL","budgetType","startDate","endDate","amount","totalActivityAllocAmount","unallocatedActAmount","totalApprovedFundClaims","unallocatedClaimAmount" ];// This array holds the keys in the json data  
        var jsonRecordsData = this.allocToExport;  
        let csvIterativeData;  
        let csvSeperator  
        let newLineCharacter;  
        csvSeperator = ",";  
        newLineCharacter = "\n";  
        csvIterativeData = "";  
        csvIterativeData += columnHeader.join(csvSeperator);  
        csvIterativeData += newLineCharacter;  
        for (let i = 0; i < jsonRecordsData.length; i++) {  
          let counter = 0;  
          for (let iteratorObj in jsonKeys) {  
            let dataKey = jsonKeys[iteratorObj];  
            if (counter > 0) {  csvIterativeData += csvSeperator;  }  
            if (  jsonRecordsData[i][dataKey] !== null &&  
              jsonRecordsData[i][dataKey] !== undefined  
            ) {  csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';  
            } else {  csvIterativeData += '""';  
            }  
            counter++;  
          }  
          csvIterativeData += newLineCharacter;  
        }  
        console.log("csvIterativeData", csvIterativeData);  
        //this.hrefData = "data:text/csv;charset=utf-8," + encodeURI(csvIterativeData);
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvIterativeData);
        hiddenElement.target = '_self';  
        hiddenElement.download ='Allocations.csv';  
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
        }  
        exportToExcel()
        {
            console.log('in exportToExcel');
            var jsonRecordsData = this.allocList;
            var finalExcelData = "<table border='1px'>";
            finalExcelData += "<tr>"+"<td>" +"Name" +"</td>"+"<td>"+ "Budget Partner"+"</td>"+"<td>"+"Program"+"</td>"+"<td>"+"Budget Type"+"</td>"+"<td>"+"Amount"+"</td>"+"<td>"+"Available Allocation Amount" + "</td>"+"</tr>";
            for (let i = 0; i < jsonRecordsData.length; i++) { 
                finalExcelData += "<tr>"+"<td>" +jsonRecordsData[i].Title +"</td>"+"<td>"+jsonRecordsData[i].AccountName +"</td>"+"<td>"+jsonRecordsData[i].ProgramName+"</td>"+"<td>"+jsonRecordsData[i].BudgetType+"</td>"+"<td>"+jsonRecordsData[i].Amount+"</td>"+"<td>"+jsonRecordsData[i].AllocationAmount + "</td>"+"</tr>";
            }
            finalExcelData=finalExcelData+"</table>";
            //this.hrefData = "data:application/vnd.ms-excel," + encodeURI(finalExcelData);
            var hiddenElement = document.createElement('a');
            hiddenElement.href = 'data:application/vnd.ms-excel,' + encodeURIComponent(finalExcelData);
            hiddenElement.target = '_self';  
            hiddenElement.download ='Allocations.xls';  
            document.body.appendChild(hiddenElement);
            hiddenElement.click();
        }
        
 }