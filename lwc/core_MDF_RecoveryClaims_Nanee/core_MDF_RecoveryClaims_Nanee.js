import { LightningElement,api,track,wire} from 'lwc';
import getcolumnsForClaimsEligibleForRecovery from 
    '@salesforce/apex/Core_MDF_RecoveryClaimReportViewCtrl.getcolumnsForClaimsEligibleForRecovery';
import getFilteredDataForClaimsEligibleForRecovery from 
    '@salesforce/apex/Core_MDF_Recovery_Helper.getClaimsBasedOnConditionsForUI';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class Core_MDF_RecoveryClaims_Nanee extends LightningElement {
    error;
    @track preSelectedRows=[];

    my_ids =[]; 
    @api progValue;
    @api acctValue;
    @api quarter;
    @api loading;
    @track data = [];
    @track columns = [];
 
    draftValues=[];
    /*@track items = [];
    @track page = 1;
    @track pageSize = 10; 
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track startingRecord = 1;
    @track endingRecord = 0;*/ 

    @track selectedRows;
    Obj = {
        Id: '',
        recoveryAmount: '',
        balanceAmt: '',
        comments: '',
        claimAmt: ''
    };
    
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
        //return refreshApex();
    }

    checkCellValue(event) {
        var tableInput = [];
        var selectedRowId=[];
        var newUiSel =[];
        var errorRows=[];
        

        tableInput = event.detail.draftValues;
        console.log('onchange--->',JSON.stringify(tableInput));
        if(tableInput.length > 0){
            tableInput.forEach(field => {
                var Obj2 = {
                    Id: '',
                    recoveryAmount: '',
                    balanceAmt: '',
                    comments: '',
                    claimAmt: ''
                };
                if(this.draftValues.find(x=>x.Id == field.Id)){
                    Obj2 = this.Obj;
                }

                if(this.draftValues.length > 0){
                    var idMatchFound = false;
                    this.draftValues.forEach(value => {
                        
                        if(field.Id == value.Id){
                            console.log('Id match');
                            idMatchFound = true;
                            selectedRowId.push(value.Id);
                            Obj2.Id = value.Id;

                            if(value.recoveryAmount != undefined && value.recoveryAmount>Obj2.claimAmt){
                                errorRows.push(value.Id);
                                Obj2.recoveryAmount = value.recoveryAmount;
                            }
                            elseif(value.recoveryAmount != undefined && value.recoveryAmount<=Obj2.claimAmt)
                                {
                                Obj2.balanceAmt = Obj2.claimAmt - value.recoveryAmount;
                                Obj2.recoveryAmount = value.recoveryAmount;
                                errorRows=[];
                            }

                            
                           if(field.comments != undefined){
                                Obj2.comment = value.comments;
                            }
                        }
                        });
                        if(!idMatchFound){
                            console.log('idMatchFound-->',idMatchFound);
                            Obj2.Id = field.Id;
                            Obj2.recoveryAmount = field.recoveryAmount;
                            Obj2.comments = field.comments;}
                }else{
                    Obj2.Id = field.Id;
                    Obj2.recoveryAmount = field.recoveryAmount;
                    Obj2.comments = field.comments;
                    Obj2.claimAmt = this.data.find(x=>x.Id==Obj2.Id).claimAmt;
                    Obj2.balanceAmt = Obj2.claimAmt - Obj2.recoveryAmount;

                    selectedRowId.push(Obj2.Id);
                    if(Obj2.recoveryAmount != undefined && Obj2.recoveryAmount>Obj2.claimAmt){
                                errorRows.push(Obj2.Id);
                            }
                            else{
                                errorRows=[];
                            }

                } 
                if(Obj2.Id != ''){
                    this.draftValues.push(Obj2);
                }
            });
        }
        console.log('Total Count--> (',this.draftValues.length, ') objList-->',JSON.stringify(this.draftValues));
        
        for(let j=0;j<selectedRowId.length;j++){
            newUiSel.push(selectedRowId[j]);
           }
    
           /*var temp=[];
           for(let h=0;h<this.data.length;h++){
            temp.push(this.data[h]);
           }
    
           this.data = temp;*/
            
           this.preSelectedRows = newUiSel;
           console.log('presel rows:'+this.preSelectedRows);
    
           console.log('error rows:'+errorRows);
    
           let errors = {};
           errors.rows = [];
    
           for(var f=0;f<errorRows.length;f++){
            errors.rows[errorRows[f]] = { title: 'We found an error', messages: [ 'Enter a valid amount lesser than claim amount.' ], fields: [ 'recoveryAmount'] };
           
           }
    
           this.errors = errors;
    }

    /*checkCellValue(event){
        var selectedRowId=[];
        var newUiSel =[];

        this.draftValues = [...this.draftValues, ...event.detail.draftValues];
        var errorRows=[];
        for(var i=0;i<this.draftValues.length;i++){
            selectedRowId.push(this.data.find(x=>x.Id==this.draftValues[i].Id).Id);
            if(this.draftValues[i].recoveryAmount>this.data.find(x=>x.Id==this.draftValues[i].Id).claimAmt){
                errorRows.push(this.draftValues[i].Id);
            }
            else{
                //this.data.find(x=>x.Id==this.draftValues[i].Id).balanceAmt = this.data.find(x=>x.Id==this.draftValues[i].Id).claimAmt - this.draftValues[i].recoveryAmount;
                errorRows=[];
            }
        }
       
       for(let j=0;j<selectedRowId.length;j++){
        newUiSel.push(selectedRowId[j]);
       }

       /*var temp=[];
       for(let h=0;h<this.data.length;h++){
        temp.push(this.data[h]);
       }

       this.data = temp;
        
       this.preSelectedRows = newUiSel;
       console.log('presel rows:'+this.preSelectedRows);

       console.log('error rows:'+errorRows);

       let errors = {};
       errors.rows = [];

       for(var f=0;f<errorRows.length;f++){
        errors.rows[errorRows[f]] = { title: 'We found an error', messages: [ 'Enter a valid amount lesser than claim amount.' ], fields: [ 'recoveryAmount'] };
       
       }

       this.errors = errors;

        /*this.errors = {
            rows: {
                errorRows: {
                    title: 'We found error.',
                    messages: [
                        'Enter a valid amount lesser than claim amount.'
                    ],
                    fieldNames: ['recoveryAmount']
                }
            }
        };

    }*/

    getSelectedRec(event) {

        //find current cell id
       
        //event.detail.selectedRows = this.preSelectedRows;

        var s = event.detail.selectedRows;
        var currentcellId;
        var preselectedLength = this.preSelectedRows.length;
        var selectedlength = s.length;
        let i,j;
        var found='';
        
        var uiSelections = [];
        
        for(var d=0;d<this.preSelectedRows.length;d++){
            uiSelections.push(this.preSelectedRows[d]);
        }

        console.log('before any selections value of preselected rows:'+this.preSelectedRows);
        if(preselectedLength == 0){
            for (i = 0; i < s.length; i++) {
            
            currentcellId = this.data.find(x=>x.Id==s[i].Id).Id;
            uiSelections.push(currentcellId);
            }
        }
        else if (preselectedLength<=selectedlength){
            for (i = 0; i < selectedlength; i++) {
                found = uiSelections.find(x=>x==s[i].Id);
                if(typeof(found) === 'undefined'){
                    currentcellId = s[i].Id;
                   }
                  
            }
            uiSelections.push(currentcellId);
        }
        else if (selectedlength<preselectedLength){
            for (i = 0; i < preselectedLength; i++) {
                found = s.find(x=>x.Id==uiSelections[i]);
                console.log('found:'+found);
                if(typeof(found) === 'undefined'){
                    currentcellId = uiSelections[i];
                    console.log('curr:'+currentcellId); 
                   }
            }
            uiSelections = uiSelections.filter(value => value !== currentcellId);
        }


        console.log('ui values: ' + uiSelections);
        

        var y = this.data.find(c=>c.Id == currentcellId).claimID;
        alert('You selected: ' + y);

        var selectedRecords =  

        this.template.querySelector("lightning-datatable").getSelectedRows();  
  
        console.log('selectedRecords are ',selectedRecords);
  
        this.selectedRows = selectedRecords;



console.log('preselections after :'+this.preSelectedRows);
        




       if(this.data[0].mode=='read'){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Info',
                message: 'Row action is not allowed', 
                variant: 'info'
            })
        );

        this.refreshData();
       }

       else{
           this.preSelectedRows = uiSelections;
       }
    

        
        const custEvent = new CustomEvent(
            'saveclaimsforrecovery', {
                detail: this.selectedRows
            });
        this.dispatchEvent(custEvent);
    }


    //clicking on previous button this method will be called
    /*previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.data = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    } */
    @wire(getFilteredDataForClaimsEligibleForRecovery, { program: '$progValue' , account : '$acctValue' , quarter: '$quarter'})
    wiredFilterData({ error, data }) {
        if (data) {
            this.preSelectedRows = [];
            this.my_ids =[];
            //this.items = data;
            console.log('data from filter:'+data);
            this.data = data.rows;

        
           for(let i=0;i<data.selectedIdSet.length;i++){
            this.my_ids.push(data.selectedIdSet[i]);
           }
            
           this.preSelectedRows = this.my_ids;

           console.log('preSelectedRows:' + this.preSelectedRows);

            //this.preSelectedRows = data.selectedIdSet;

            /*this.totalRecountCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            this.data = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;*/

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

            const custEvent = new CustomEvent(
                'callloading', {
                    detail: this.loading
                });
            this.dispatchEvent(custEvent);
        }
    }

    connectedCallback() {
        
        this.getColumns();
       
    }

    getColumns() {
        getcolumnsForClaimsEligibleForRecovery() 
            .then(result => {
                this.columns = [...this.columns, ...result];
                //this.columns = result;
                console.log(this.columns);
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
        var jsonRecordsData = this.data;  
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
        
        // Prepare a html table
        let doc = '<table>';
        // Add styles for the table
        /*doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';          
        doc += '</style>';*/
        // Add all the Table Headers
        doc += '<tr>';
        columnHeader.forEach(element => {            
            doc += '<th>'+ element +'</th>'           
        });
        doc += '</tr>';

        for (let i = 0; i < jsonRecordsData.length; i++) {  
            let counter = 0; 
            doc += '<tr>'; 
            for (let iteratorObj in jsonKeys) {  
              let dataKey = jsonKeys[iteratorObj];  
              if (counter > 0) {  csvIterativeData += csvSeperator;  }  
              if (  jsonRecordsData[i][dataKey] !== null &&  
                jsonRecordsData[i][dataKey] !== undefined  
              ) {  
                doc += '<th>'+jsonRecordsData[i][dataKey]+'</th>'; 
               // csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';  
              } else {  
                doc += '<th></th>'; 
                //csvIterativeData += '""';  
              }  
              counter++;  
            }  
            doc += '</tr>';
            //csvIterativeData += newLineCharacter;  
          }  

        // Add the data rows
        /*jsonRecordsData.forEach(record => {
            doc += '<tr>';
            doc += '<th>'+record.Id+'</th>'; 
            doc += '<th>'+record.FirstName+'</th>'; 
            doc += '<th>'+record.LastName+'</th>';
            doc += '<th>'+record.Email+'</th>'; 
            doc += '</tr>';
        });*/
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Recovery.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();

        //this.hrefdata = "data:text/csv;charset=utf-8," + encodeURI(csvIterativeData);  
      }
}