import { LightningElement,api,track,wire} from 'lwc';
import getcolumnsForClaimsEligibleForRecovery from 
    '@salesforce/apex/Core_MDF_RecoveryClaimReportViewCtrl.getcolumnsForClaimsEligibleForRecovery';
import getClaimsBasedOnConditionsForUI from 
    '@salesforce/apex/Core_MDF_Recovery_Helper.getClaimsBasedOnConditionsForUI';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const columnsTest = [
    { label: 'Claim #', fieldName: 'claimID' , type: 'text'},
    { label: 'Budget Type', fieldName: 'budgetType' , type: 'text'}, 
    { label: 'Geo', fieldName: 'geo' , type: 'text'},
    { label: 'Country', fieldName: 'country' , type: 'text'},
    { label: 'Claim Status', fieldName: 'clmStatus' , type: 'text'}, 
    { label: 'Activity Category', fieldName: 'actCategory' , type: 'text'},
    { label: 'Activity Type', fieldName: 'actType' , type: 'text'},
    { label: 'Claim Amount', fieldName: 'claimAmt' , type: 'currency', typeAttributes: {minimumFractionDigits: 2, maximumFractionDigits: 2 }}, 
    { label: 'Recovery Amount', fieldName: 'recoveryAmount' , type: 'currency', typeAttributes: {minimumFractionDigits: 2, maximumFractionDigits: 2 }},
    { label: 'Balance Amount', fieldName: 'balanceAmt' , type: 'currency', typeAttributes: {minimumFractionDigits: 2, maximumFractionDigits: 2 }},
    { label: 'Comments', fieldName: 'comments' , type: 'text'}
];


export default class Test_RecoveryClaims extends LightningElement {
    error;
    @track preSelectedRows=[];
    @track hasData = false;
    my_ids =[]; 
    @api progValue;
    @api acctValue;
    @api quarter;
    @api mode;
    @api loading;
    @track data = [];
    @track columns = [];
    @track errors;
    @track data;
    draftValues=[];
    @track claimList = [];
    @track selectedRows =[];

    e=[];
    errorRows =[];

    @track claimList;
    //**************Pagination*************/
    @track currentPageNumber;
    @track totalPages;
    @track totalNoOfRecords;
    @track recordsPerPage = 100;
    @track iterationStarting;
    @track iterationEnding;
    //**************Pagination*************/

    // in order to refresh your data, execute this function:
    refreshData() {
        let temp = [];let p=[];
        
        for(let i=0;i<this.data.length;i++){
            temp.push(this.data[i]);
           }
        
           for(let j=0;j<this.preSelectedRows.length;j++){
            p.push(this.preSelectedRows[j]);
           }
        
        this.data = temp;

        this.preSelectedRows = p;
    }


    checkCellValue(event) {
       
            this.changedCell = event.detail.draftValues;
            this.arr = [];
            let errors = {};
            errors.rows = [];
            if(this.errors != undefined && Object.keys(this.errors).length > 0 ){
                errors = this.errors;
            }

            if(this.e == undefined && this.e.length == 0 ){
                this.e = [];
            }
    
            this.row = this.changedCell[0];
            this.tableData = this.data;
            let rowId = [];
            this.tableData.forEach( item => {
                if(item.Id == this.row.Id){
                    let it = {};
                    Object.assign(it,item);
                    if(Object.hasOwn(this.row,'recoveryAmount')){
                        it.recoveryAmount = parseFloat(this.row.recoveryAmount);
                        if(it.recoveryAmount > it.claimAmt){
                            errors.rows[this.row.Id] = { title: 'We found an error', messages: [ 'Enter a valid amount less than or equal to the claim amount.' ], fields: [ 'recoveryAmount'] };
                        this.e.push(this.row.Id);
                        }
                        else if(isNaN(it.recoveryAmount) || it.recoveryAmount<0){
                            errors.rows[this.row.Id] = { title: 'We found an error', messages: [ 'Enter a valid amount.' ], fields: [ 'recoveryAmount'] };
                        this.e.push(this.row.Id);
                        }
                        else if(it.recoveryAmount == '' || it.recoveryAmount == 0){
                            errors.rows[this.row.Id] = { title: 'We found an error', messages: [ 'Recovery Amount is required.' ], fields: [ 'recoveryAmount'] };
                            this.e.push(this.row.Id);
                        }
                        else{
                            errors.rows[this.row.Id] = {};
                            this.e=[];
                        }
                        it.balanceAmt = parseFloat(it.claimAmt) - it.recoveryAmount;
                        it.balanceAmt = it.balanceAmt.toFixed(2);
                        if(!this.preSelectedRows.includes(this.row.Id)){
                            rowId.push(this.row.Id);
                        }
                        //this.preSelectedRows;
                    }else if(Object.hasOwn(this.row,'comments')) {
                        it.comments = this.row.comments;
                    }              
                    this.arr.push(it);
                }else{
                    this.arr.push(item);
                }
            });
    
            var p = [];
            for(var f=0;f<rowId.length;f++){
                this.preSelectedRows.push(rowId[f]);
            }
    
            for(var i=0;i<this.preSelectedRows.length;i++){
                p.push(this.preSelectedRows[i]);
            }
    
            this.preSelectedRows = p;
            this.data = this.arr;
            this.errors = errors;
    
            var dataForSave =[];
            for(var i=0;i<this.preSelectedRows.length;i++){
                if(this.data.find(x=>x.Id==this.preSelectedRows[i])){
                    dataForSave.push(this.data.find(x=>x.Id==this.preSelectedRows[i]));              
                }
                else{
                    dataForSave.push(this.data.find(x=>x.Id==this.preSelectedRows[i]));
                }
               
               
            }
    
            var dataToBePassedForSave ={data:dataForSave,errors: this.e.length};
            const custEvent = new CustomEvent(
                'saveclaimsforrecovery', {
                    detail: dataToBePassedForSave
                });
            this.dispatchEvent(custEvent);
        
        
    }

    getSelectedRows(event){
        /*if(this.disableRowSelection){
            this.disableRowSelection=false;
            return;
        }
        else{ */      
            this.selRowIds = [];
            var dataForSave =[];
            var unCheckedRow = [];
    
            let errors = {};
            errors.rows = [];
            if(this.errors != undefined && Object.keys(this.errors).length > 0 ){
                errors = this.errors;
            }
            var e=[];
            
            let tableData = [];
            this.oldSelRows = this.preSelectedRows;
            
            if(this.data.length > 0){
                this.selRows = event.detail.selectedRows;
    
                this.selRows.forEach(item => { this.selRowIds.push(item.Id)});
                if(this.mode=='read'){
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Info',
                            message: 'Row action is not allowed', 
                            variant: 'info'
                        })
                    );
                    this.refreshData();
                }else{

                    this.preSelectedRows = [];

                    this.preSelectedRows = this.selRowIds;

                    this.oldSelRows.forEach(item =>{
                        if(!this.preSelectedRows.includes(item)){
                            unCheckedRow.push(item);
                        }
                    });
                    
                    
                    this.data.forEach(item =>{
                        if(unCheckedRow.includes(item.Id)){
                            let it = {};
                            Object.assign(it,item);
                            if(Object.hasOwn(it,'recoveryAmount')){
                                this.template.querySelector("lightning-datatable").draftValues = [];
                                it.recoveryAmount = "0";
                                it.balanceAmt = it.claimAmt;
                                tableData.push(it);
                                errors.rows[item.Id]={};
                                if(e.find(x=>x==item.Id)){
                                    e=e.filter(x=>x!=item.Id);
                                }
                                
                            }
                        }else{
                            errors.rows[item.Id]={};
                                if(e.find(x=>x==item.Id)){
                                    e=e.filter(x=>x!=item.Id);
                                }
                            tableData.push(item);
                        }
                    });
        
                    this.selRows.forEach(item =>{
                        let it = {};
                        Object.assign(it,item);
                        if(Object.hasOwn(it,'recoveryAmount')){
                            if(it.recoveryAmount == '' || it.recoveryAmount == 0){
                                errors.rows[item.Id] = { title: 'We found an error', messages: [ 'Recovery Amount is required.' ], fields: [ 'recoveryAmount'] };
                                e.push(item.Id);
                            }
                        }
                    });
                    
                    
                    this.data = tableData;
                    this.errors = errors;
            
                    for(var i=0;i<this.preSelectedRows.length;i++){
                        if(this.data.find(x=>x.Id==this.preSelectedRows[i])){
                            dataForSave.push(this.data.find(x=>x.Id==this.preSelectedRows[i]));
                        }
                        else{
                            dataForSave.push(this.data.find(x=>x.Id==this.preSelectedRows[i]));
                        }
                        
                    }
            
                    var dataToBePassedForSave ={data: dataForSave,errors:e.length};
                    const custEvent = new CustomEvent(
                        'saveclaimsforrecovery', {
                            detail: dataToBePassedForSave
                        });
                    this.dispatchEvent(custEvent);
                   }
            }
            
        
        
            //}
        
    }


    @api reloadWire(){
        this.getClaimsBasedOnConditionsForUI(this.progValue,this.acctValue,this.quarterVal,this.mode);
        this.errors = {};
    }

   

    @api getClaimsBasedOnConditionsForUI(progValue,acctValue,quarterVal,mode){
        this.errors = {};
         

        this.hasData = false;
        this.progValue = progValue;
        this.acctValue = acctValue;
        this.quarterVal = quarterVal;
        this.mode = mode;

        this.data =[];
        //this.disableRowSelection=false;
        this.calledFromGetData=true;
        
        getClaimsBasedOnConditionsForUI({program: this.progValue, account: this.acctValue, quarter: this.quarterVal}) 
        .then((data) => {
        if (data) {
                this.preSelectedRows = [];
                this.my_ids =[];
                this.hasData = true;     
                this.exportData = data.rows;           
                this.resultList = JSON.parse(JSON.stringify(data.rows));
                console.log('Total Data1-->' + this.resultList);
                
                this.claimList = [];
                this.iterationStarting = 0;
                this.iterationEnding = this.recordsPerPage;
                for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                    if (this.resultList[i] !== undefined) {
                        this.claimList.push(this.resultList[i]);
                    }
                }
                this.currentPageNumber = 1;
                this.totalNoOfRecords = this.resultList.length;
                this.totalPages = Math.ceil(this.resultList.length / this.recordsPerPage);
                this.isSpinner = false;
                if(this.mode == 'edit'){
                    this.columns = JSON.parse(JSON.stringify(this.columns));
                    this.columns[8].editable = true;
                    this.columns[8].type = 'number';
                    this.columns[10].editable = true;
                    this.columns = [...this.columns];
                }
                else{
                    this.columns = JSON.parse(JSON.stringify(this.columns));
                    this.columns[8].editable = false;
                    this.columns[8].type = 'number';
                    this.columns[10].editable = false;
                    this.columns = [...this.columns];
                }
                console.log('Total Data2-->' + JSON.stringify(this.claimList));
                
                if(data.selectedIdSet != null && data.selectedIdSet != undefined){
                    for(let i=0;i<data.selectedIdSet.length;i++){
                        this.my_ids.push(data.selectedIdSet[i]);
                    }
                }
              

                this.preSelectedRows = this.my_ids;
                       var selectedRec=[];
                       for(var i=0;i<this.preSelectedRows.length;i++){
                        selectedRec.push(data.rows.find(x=>x.Id == this.preSelectedRows[i]));
                       }

                var selectedRec={data: selectedRec,errors:null};
                const custEvent1 = new CustomEvent(
                        'saveclaimsforrecovery', {
                            detail: selectedRec
                        });
                    this.dispatchEvent(custEvent1);

                console.log('selectedIdSet-->' + this.preSelectedRows);
                console.log('selectedRec-->' + selectedRec);
                this.error = undefined;
                this.loading = false;
                const custEvent = new CustomEvent(
                    'callloading', {
                        detail: this.loading
                    });
                this.dispatchEvent(custEvent);
        } else if (error) {
            this.error = error;
            this.loading = false;
            console.log('###Inside Error###');
        }
           
        })
        .catch(error => {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Application Error! Please try again later.',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(event);
            });
         
    }

    connectedCallback() {
        this.columns = columnsTest; 
    }

    

    getColumns() {
        getcolumnsForClaimsEligibleForRecovery() 
            .then(result => {
                console.log('columns:',JSON.stringify(result));
                this.columns = [...this.columns, ...result];
                
                //this.columns = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                
            }); 
    }

    exportToCSV() {  
        let columnHeader =[];let jsonKeys =[];
        for(let x=0;x<this.columns.length;x++){
            columnHeader.push(this.columns[x].label);
            jsonKeys.push(this.columns[x].fieldName);
        }

          // This array holds the Column headers to be displayd
        // This array holds the keys in the json data  
        var jsonRecordsData = this.exportData;  
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
        
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(csvIterativeData);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Recovery.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();

        //this.hrefdata = "data:text/csv;charset=utf-8," + encodeURI(csvIterativeData);  
      }

    

      // Select the all rows
    allSelected(event) {
        let selectedRows = this.template.querySelectorAll('lightning-input');
        
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
            }
        }
    }
    //**************Pagination*************/
    onPrevious() {
        if (this.iterationStarting > 0) {
            this.currentPageNumber = this.currentPageNumber - 1;
            this.iterationStarting = this.iterationStarting - this.recordsPerPage;
            this.iterationEnding = this.iterationEnding - this.recordsPerPage;
            this.claimList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList[i] !== undefined) {
                    this.claimList.push(this.resultList[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }
    }

    onNext() {
        if (this.currentPageNumber < this.totalPages) {
            this.currentPageNumber = this.currentPageNumber + 1;
            this.iterationStarting = this.iterationStarting + this.recordsPerPage;
            this.iterationEnding = this.iterationEnding + this.recordsPerPage;
            this.claimList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList[i] !== undefined) {
                    this.claimList.push(this.resultList[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }
    }

    get disablePreviousButtom() {
        return (this.iterationStarting === 0);
    }
    get disableNextButtom() {
        return (this.currentPageNumber === this.totalPages) || (this.currentPageNumber > this.totalPages);
    }

    get hasRecords() {
        return (this.totalNoOfRecords !== 0);
    }

    onLast() {
        if (this.currentPageNumber < this.totalPages) {
            this.currentPageNumber = this.totalPages;
            this.iterationStarting = (this.recordsPerPage * this.totalPages) - this.recordsPerPage;
            this.iterationEnding = this.recordsPerPage * this.totalPages;
            this.claimList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList[i] !== undefined) {

                    this.claimList.push(this.resultList[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }

    }

    onFirst() {
        if (this.iterationStarting > 0) {
            this.currentPageNumber = 1;
            this.iterationStarting = 0;
            this.iterationEnding = this.recordsPerPage;
            this.claimList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList[i] !== undefined) {
                    this.claimList.push(this.resultList[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }
    }
    //**************Pagination*************/
}