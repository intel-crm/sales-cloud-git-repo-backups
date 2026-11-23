import { LightningElement,api,track,wire} from 'lwc';
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


export default class Core_MDF_RecoveryClaimsHtmlTable extends LightningElement {
    error;
    @track hasData = false;
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
    @api resultList;
    err=0;

    @track claimList;

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
        this.calledFromGetData=true;

        console.log('this.mode'+this.mode);
        
        getClaimsBasedOnConditionsForUI({program: this.progValue, account: this.acctValue, quarter: this.quarterVal}) 
        .then((data) => {
            console.log('data'+ JSON.stringify(data));
                if(data != null && data != undefined){
                    if( Object.hasOwn(data,'rows')){
                        if(data.rows.length > 0){
                            
                            if(this.mode == 'read'){
                                this.isDisabled=true;
                            }
                            else{
                                this.isDisabled=false;
                            }
                            
                            this.hasData = true;     
                            this.exportData = data.rows;           
                            this.resultList = JSON.parse(JSON.stringify(data.rows));
                            this.tempClaims = [];
                            for(let i = 0; i < this.resultList.length; i++) {
                                this.resultList[i].accountId = this.acctValue;
                                this.resultList[i].program = this.progValue;
                                this.resultList[i].quarter = this.quarterVal;
                                if(this.resultList[i].selected ==true){
                                    this.tempClaims.push(this.resultList[i]);
                                }
                                 
                            }
                            console.log('this.tempClaims' + JSON.stringify(this.tempClaims));
                            var selectedRec={data: this.tempClaims,errors:null};
                            const custEvent1 = new CustomEvent(
                                    'saveclaimsforrecovery', {
                                        detail: selectedRec
                                    });
                            this.dispatchEvent(custEvent1);
                            console.log('selectedRec-->' + JSON.stringify(selectedRec));
                            this.error = undefined;
                            this.loading = false;
                            const custEvent = new CustomEvent(
                                'callloading', {
                                    detail: this.loading
                                });
                            this.dispatchEvent(custEvent);
                    }
                    
                    }
                    else{
                        console.log('here');
                        this.loading = false;
                        var selectedRec = { data: null, errors: null };
                                const custEvent1 = new CustomEvent(
                                    'saveclaimsforrecovery', {
                                    detail: selectedRec
                                });
                                this.dispatchEvent(custEvent1);
                    
                                const custEvent = new CustomEvent(
                                    'callloading', {
                                        detail: this.loading
                                    });
                                this.dispatchEvent(custEvent);
                    }
                }
                else{
                    console.log('here');
                    this.loading = false;
                    var selectedRec = { data: null, errors: null };
                            const custEvent1 = new CustomEvent(
                                'saveclaimsforrecovery', {
                                detail: selectedRec
                            });
                            this.dispatchEvent(custEvent1);
                
                            const custEvent = new CustomEvent(
                                'callloading', {
                                    detail: this.loading
                                });
                            this.dispatchEvent(custEvent);
                }
        })
        .catch(error => {
            var selectedRec = { data: null, errors: null };
            this.loading = false;
            const custEvent1 = new CustomEvent('saveclaimsforrecovery', {
                                detail: selectedRec
                            });
            this.dispatchEvent(custEvent1);
            const custEvent = new CustomEvent(
                'callloading', {
                    detail: this.loading
                });
            this.dispatchEvent(custEvent);
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
        let tempClaims = this.resultList; 
        let selectedClaims = [];
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
                for(let i = 0; i < tempClaims.length; i++) {
                    var inputCmp = this.template.querySelectorAll('.recoveryCmp');
                    var tr = this.template.querySelectorAll('.tableRows');
                if(tempClaims[i].recoveryAmount == '' && event.target.checked == true){
                    tr[i].classList.add('row-color'); 
                    inputCmp[i].setCustomValidity('Rework your recovery');
                    this.err++;
                    selectedClaims.push(tempClaims[i]);

                }
                else if(event.target.checked == false){
                    tempClaims[i].recoveryAmount = '';
                    tempClaims[i].comments = '';  
                    tr[i].classList.remove('row-color'); 
                    inputCmp[i].setCustomValidity('');
                    this.err--;
                }
                inputCmp[i].reportValidity();
            }
            }
        }
        this.resultList = tempClaims;

        var selectedRec={data: selectedClaims,errors:this.err};
                const custEvent2 = new CustomEvent(
                        'saveclaimsforrecovery', {
                            detail: selectedRec
                        });
                    this.dispatchEvent(custEvent2);
    }

    //recoveryInputActions
    recoveryInputActions(event) {

        let key = event.target.dataset.id;
        let value = event.target.value;
        let selectedRows = this.template.querySelectorAll('lightning-input');
        let selectedClaims = [];
        console.log('Key ==> ' + key);
        //Checking and unchecking the checkbox 
        let tempClaims = this.resultList; 
        for(let i = 0; i < tempClaims.length; i++) {
            if(tempClaims[i].Id == key){
                tempClaims[i].recoveryAmount = value;
                tempClaims[i].balanceAmt = (tempClaims[i].claimAmt - tempClaims[i].recoveryAmount).toFixed(2);
                console.log('tempClaims[i].recoveryAmount'+ tempClaims[i].recoveryAmount);
                console.log('tempClaims[i].balanceAmt'+ tempClaims[i].balanceAmt);
                var inputCmp = this.template.querySelectorAll('.recoveryCmp');
                for(let i = 0; i < selectedRows.length; i++) {
                    if(selectedRows[i].type === 'checkbox' && selectedRows[i].dataset.id == key) {
                        selectedRows[i].checked = true;
                        break;
                    }
                }
                if(tempClaims[i].balanceAmt < 0 || tempClaims[i].recoveryAmount == '' ){
                    console.log('here');
                    const tr = event.target.closest("tr");
                    tr.classList.add('row-color');
                    inputCmp[i].setCustomValidity('Enter a valid amount less than or equal to the claim amount.');
                    this.err++;
                    inputCmp[i].reportValidity();
                    tempClaims[i].selected =true;
                    break;
                }
                else if(tempClaims[i].balanceAmt >= 0){
                    const tr = event.target.closest("tr");
                    tr.classList.remove('row-color');
                    inputCmp[i].setCustomValidity('');
                    this.err--;
                    inputCmp[i].reportValidity();
                    tempClaims[i].selected =true;
                }
                
            }  
        }
        this.resultList = tempClaims;

        for(let i = 0; i < this.resultList.length; i++) {
            
            if(this.resultList[i].selected ==true){
                selectedClaims.push(this.resultList[i]);
            }
             
        }
        var selectedRec={data: selectedClaims,errors:this.err};
                const custEvent3 = new CustomEvent(
                        'saveclaimsforrecovery', {
                            detail: selectedRec
                        });
                    this.dispatchEvent(custEvent3);

    }

    //Checkbox Actions
    checkboxActions(event) {
        let key = event.target.dataset.id;
        let selection = event.target.checked;
        let tempClaims = this.resultList; 
        let selectedClaims = [];
        for(let i = 0; i < tempClaims.length; i++) {
            var inputCmp = this.template.querySelectorAll('.recoveryCmp');
                    const tr = event.target.closest("tr");
                if(tempClaims[i].Id == key){
                    
                    if((tempClaims[i].recoveryAmount == '' || tempClaims[i].recoveryAmount > tempClaims[i].claimAmt) && selection == true){
                        tempClaims[i].selected =true;
                    tr.classList.add('row-color');
                    inputCmp[i].setCustomValidity('Rework your recovery');
                    this.err++;
                    inputCmp[i].reportValidity();
                    break;
                }
                else if(selection == false){
                    tempClaims[i].selected =false;
                    tempClaims[i].recoveryAmount = '';
                    tempClaims[i].comments = '';  
                    tr.classList.remove('row-color');
                    inputCmp[i].setCustomValidity('');
                    this.err--;
                    inputCmp[i].reportValidity();
                }
                
                }
                
        }
        this.resultList = tempClaims;

        for(let i = 0; i < this.resultList.length; i++) {
            
            if(this.resultList[i].selected ==true){
                selectedClaims.push(this.resultList[i]);
            }
             
        }
        var selectedRec={data: selectedClaims,errors:this.err};
                const custEvent4 = new CustomEvent(
                        'saveclaimsforrecovery', {
                            detail: selectedRec
                        });
                    this.dispatchEvent(custEvent4);
    }

    //Comment Actions
    commentActions(event) {
        let key = event.target.dataset.id;
        let tempClaims = this.resultList; 
        let selectedClaims = [];
        console.log('comments'+ event.target.value);
        for(let i = 0; i < tempClaims.length; i++) {
            if(tempClaims[i].Id == key){
                tempClaims[i].comments = event.target.value;    
            }   
        }
        for(let i = 0; i < this.resultList.length; i++) {     
            if(this.resultList[i].selected ==true){
                selectedClaims.push(this.resultList[i]);
            }
             
        }
        this.resultList = tempClaims;
        console.log('this.err'+this.err);
        var selectedRec={data: selectedClaims,errors:this.err};
                const custEvent5 = new CustomEvent(
                        'saveclaimsforrecovery', {
                            detail: selectedRec
                        });
                    this.dispatchEvent(custEvent5);

    }
}