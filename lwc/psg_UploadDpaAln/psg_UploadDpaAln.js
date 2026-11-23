import { LightningElement, track, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateRecord from '@salesforce/apex/PSG_UploadDpaAln.validateRecord';
import submitRecToSAP from '@salesforce/apex/PSG_UploadDpaAln.submitRecToSAP';
import validateQuoteRecord from '@salesforce/apex/PSG_UploadDpaAln.validateQuoteRecord';
import hasCustomPermission from '@salesforce/customPermission/PSG_Internal_Biz_Ops';
import validatingUserAccess from '@salesforce/apex/PSG_UploadDpaAln.validatingUserAccess'

export default class Psg_UploadDpaAln extends LightningElement {
    @api picklistlabel = 'Select Type';
    //@track disableUploadFile = true;
    @track disableUpdateButton = true;
    @track enableShipEndDate = false;
    @track enableTA = false;
    @track shipEndDate;
    @track disableResultButton = true;
    @track UpdateFile = 'Update Data';
    @track DpaAlnNo;
    //@track QuoteNo;
    @track data;
    @track dataTableList;
    @track readOnly = false;
    @track readOnlyDate = false;
    @track minDate;
    @track count = '';
    @track note = '';
    @track textAreaLabel = '';
    @track textAreaPlaceholder = '';
    @track columns=[  
        {label:'CIS #',fieldName:'CIS_No', type:'text'},
        {label:'Result',fieldName:'Result'},
        {label:'Reason',fieldName:'Reason', type:'text'},
      ];
    @track selectedValue;
    @track selectedOperationValue;
    @track shipEndDateError = 'Ship End Date should be a future date.';
    @track showLoadingSpinner = false;
    @track picklistvalueselected = [];
    @track enableOperationSelectionDPA = false;
    @track enableOperationSelectionALN = false;
    @track operationPickListValuesDPA = [
        {"label" : "Extend", "value" : "Extend"},
        {"label" : "Expire", "value" : "Expire"}
    ];
    @track operationPickListValuesALN = [
        {"label" : "Extend", "value" : "Extend"},
        {"label" : "Expire", "value" : "Expire"},
        {"label" : "Hold", "value" : "Hold"}
    ];
    @track operationPickListValuesQuote = [
        {"label" : "De-activate", "value" : "De-activate"},
        {"label" : "Revise", "value" : "Revise"}
    ];
    @api operationPickListLabel = 'Select Type of Operation';

    connectedCallback(){
        var objectList = [];
        console.log('connectedCallback123');
        if(hasCustomPermission){
            objectList.push({"label" : "DPA", "value" : "DPA"});
            objectList.push({"label" : "ALN", "value" : "ALN"});
            console.log('added1234='+objectList);
        }
        console.log('added12345='+objectList);
        validatingUserAccess()
        .then(result => {
            console.log('isUserAccess='+result);
            if(result == true){
                objectList.push({"label" : "Quote", "value" : "Quote"});
                console.log('added123='+objectList);
            }
            this.picklistvalueselected = objectList;
        })
        .catch(error => {
            console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Occured',
                        message: error.message,
                        variant: 'error',
                    }),
                );
        });
    }

    handlePickListValueChange(event){
        this.selectedValue = event.target.value;
        this.template.querySelectorAll('lightning-combobox').forEach( each => {
            each.value = null;
            this.selectedOperationValue = null;
        });
        /*this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = null;
        });*/
        if(this.selectedValue == 'DPA' || this.selectedValue == 'ALN' || this.selectedValue == 'Quote'){
            this.enableOperationSelection = true;
        }else{
            this.enableOperationSelection = false;
        }

        if(this.selectedValue != null && (this.selectedOperationValue != null || this.selectedOperationValue != '') && this.DpaAlnNo != null){
            this.disableUpdateButton = false;
        }else{
            this.disableUpdateButton = true;
        }

        this.disableResultButton = true;
        console.log(this.selectedValue);
    }
    
    get operationPicklistValues(){
        if(this.selectedValue == 'DPA'){
            this.enableTA = true;
            this.textAreaLabel = 'DPA No. (Comma Separated)';
            this.textAreaPlaceholder = 'Enter DPA No.';
            return this.operationPickListValuesDPA;
        }else if(this.selectedValue == 'ALN'){
            this.enableTA = true;
            this.textAreaLabel = 'ALN No. (Comma Separated)';
            this.textAreaPlaceholder = 'Enter ALN No.';
            return this.operationPickListValuesALN;
        }else if(this.selectedValue == 'Quote'){
            this.enableTA = true;
            this.textAreaLabel = 'Quote No. (Comma Separated)';
            this.textAreaPlaceholder = 'Enter Quote No. (max 20)';
            return this.operationPickListValuesQuote;
        }
    }

    handleOperationValueChange(event) {
        this.selectedOperationValue = event.target.value;
        let yyyyMmDd = this.calculateDate();
        if(this.selectedOperationValue == 'Extend' || this.selectedOperationValue == 'Expire'){
            this.enableShipEndDate = true;
        }else{
            this.enableShipEndDate = false;
        }

        if(this.selectedOperationValue == 'Expire'){
            this.shipEndDate = yyyyMmDd;
            this.readOnlyDate = true;
        }else{
            this.readOnlyDate = false;
            this.shipEndDate = null;
        }

        if(this.selectedValue != null && (this.selectedOperationValue != null || this.selectedOperationValue != '') && this.DpaAlnNo != null){
            this.disableUpdateButton = false;
        }else{
            this.disableUpdateButton = true;
        }
    }
    
    calculateDate(){
        let rightNow = new Date();
        // Adjust for the user's time zone
        rightNow.setMinutes(
            new Date().getMinutes() - new Date().getTimezoneOffset()
        );
        let yyyyMmDd = rightNow.toISOString().slice(0,10);
        return yyyyMmDd;
    }

    shipEndDateChange(event) {
        this.shipEndDate = event.target.value;
        let rightNow = new Date();
        rightNow.setMinutes(
            new Date().getMinutes() - new Date().getTimezoneOffset()
        );
        rightNow.setDate(rightNow.getDate()+1);
        let yyyyMmDd = rightNow.toISOString().slice(0,10);
        this.minDate = yyyyMmDd;
        console.log(this.shipEndDate+ ' '+yyyyMmDd+' '+this.minDate);
    }
    
    handleChange(event){
        //if(this.selectedValue == 'DPA' || this.selectedValue == 'ALN'){
            this.DpaAlnNo = event.target.value;
            console.log(this.DpaAlnNo);
            if(this.selectedValue != null && (this.selectedOperationValue != null || this.selectedOperationValue != '') && (this.DpaAlnNo != null || this.DpaAlnNo != '')){
                this.disableUpdateButton = false;
                console.log('Entered');
            }else{
                this.disableUpdateButton = true;
            }
        /*}else if(this.selectedValue == 'Quote'){
            this.DpaAlnNo = event.target.value;
            if(this.selectedValue != null && (this.selectedOperationValue != null || this.selectedOperationValue != '') && (this.QuoteNo != null || this.QuoteNo != '')){
                this.disableUpdateButton = false;
                console.log('Entered');
            }else{
                this.disableUpdateButton = true;
            }
        }*/
    }

    isInputValid(){
        let isValid = true;
        this.template.querySelectorAll('.validate').forEach(inputField => {
            console.log('Check valid ='+inputField);
            console.log('Check valid ='+inputField.value);
            if(!inputField.checkValidity()){
                inputField.reportValidity();
                isValid = false;
            }
        } );
        return isValid;
    }

    handleSave(){
        let valid = this.isInputValid();
        console.log('Valid ='+valid + ',selectedValue ='+this.selectedValue);
        if(valid == true && (this.selectedValue == 'DPA' || this.selectedValue == 'ALN')){
            this.validateRec();
        }else if(valid == true && this.selectedValue == 'Quote'){
            this.validateQuoteRec();
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while uploading',
                    message: 'Please correct all the Error',
                    variant: 'error',
                }),
            );
        }
    }
    
    validateRec(){
        this.showLoadingSpinner = true;
        validateRecord({obj : this.selectedValue, cisNo: this.DpaAlnNo, action : this.selectedOperationValue, shipEndDate : this.shipEndDate})
        .then( result => {
            this.showLoadingSpinner = false;
            this.disableResultButton = false;
            this.readOnly = true;
            this.readOnlyDate = true;
            console.log('dpaAlnNoList-->'+JSON.stringify(result.dpaAlnNoList));
            console.log('cisNoToResultMap-->'+JSON.stringify(result.cisNoToResultMap));
            
            let record = JSON.parse(JSON.stringify(result.dpaAlnNoList));
            let recordMap = JSON.parse(JSON.stringify(result.cisNoToResultMap));
            let recordReasonMap = JSON.parse(JSON.stringify(result.cisNoToReasonMap));
            let successCountNo = JSON.parse(JSON.stringify(result.successCount));
            let successList = JSON.parse(JSON.stringify(result.successValues));
            console.log(result);
            console.log(record);
            let dataRecord = [];
            const filterMap = new Map(Object.entries(recordMap));
            const filterReasonMap = new Map(Object.entries(recordReasonMap));
            record.forEach(element => {
                let newLst = {};
                newLst.CIS_No = element;
                if(filterMap.has(element)){
                    newLst.Result = filterMap.get(element);
                } 
                if(filterReasonMap.has(element)){
                    newLst.Reason = filterReasonMap.get(element);
                }           
                dataRecord.push(newLst);
                
            })
            this.disableUpdateButton = true;
            console.log('Table --->'+JSON.stringify(dataRecord));
            this.dataTableList = JSON.parse(JSON.stringify(dataRecord));
            this.count = successCountNo+'/'+record.length+' Records uploaded Successfully';
            if(result.successCount > 0){
                this.note = 'Note: Bulk SAP submission for successful DPA/ALN has been initiated, and result will be sent over an Email.';
            }
            this.sendRequestToSAP(successList);
        })
        
        .catch(error => {
            this.showLoadingSpinner = false;
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while uploading',
                        message: error.message,
                        variant: 'error',
                    }),
                );
        });
        
    }

    handleDownloadClick(event) {
        this.downloadCSVFile(this.dataTableList);
    }

    downloadCSVFile(recList){
        console.log('Entered downloadCSV');
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();
        // getting keys from data
        recList.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });
        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        console.log(rowData);
        
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;
        // main for loop to get the data based on key value
        for(let i=0; i < recList.length; i++){
            let colValue = 0;
            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = recList[i][rowKey] === undefined ? '' : recList[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        downloadElement.download = 'DPA_ALN_Update.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    sendRequestToSAP(successList){
        submitRecToSAP({successLst : successList})
        .then()    
    }

    validateQuoteRec(){
        this.showLoadingSpinner = true;
        validateQuoteRecord({quoteNo: this.DpaAlnNo, action : this.selectedOperationValue})
        .then( result => {
            this.showLoadingSpinner = false;
            this.readOnly = true;
            this.disableUpdateButton = true;
            this.note = 'Note: Bulk Quote De-activation/Revision has been initiated, and result will be sent over an Email.';
        })
        .catch(error => {
            this.showLoadingSpinner = false;
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while uploading',
                        message: error.message,
                        variant: 'error',
                    }),
                );
        });
    }
}