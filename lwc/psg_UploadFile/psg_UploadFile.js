import { LightningElement } from 'lwc';
//import saveFile from '@salesforce/apex/PSG_UploadFile.saveFile';
//import getUploadMetaData from '@salesforce/apex/PSG_UploadFile.getUploadData';
//import getBatchJobStatus from '@salesforce/apex/PSG_UploadFile.getBatchJobStatus';
//import validatingAccess from '@salesforce/apex/PSG_UploadFile.validatingAccess';
//import getQuoteType from '@salesforce/apex/PSG_UploadFile.getQuoteType';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import PRICEBOOKNAMES from '@salesforce/label/c.PSG_PriceBooks_Names';
//import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
//import getAllObjects from '@salesforce/apex/PSG_UploadFile.getAllObjects';
//import getAllRequiredFileds from '@salesforce/apex/PSG_UploadFile.getAllRequiredFileds';

//import { getRecord } from 'lightning/uiRecordApi';
//const FIELDS = [
//'PSG_Upload_File_Mapping__mdt.PSG_Field_Name__c',
//'PSG_Upload_File_Mapping__mdt.PSG_Field_API_Name__c',
//'PSG_Upload_File_Mapping__mdt.PSG_Object_Name__c',
//'PSG_Upload_File_Mapping__mdt.PSG_Object_API_Name__c',
//];

/*
const columns = [
{ label: 'Name', fieldName: 'Name' },
{ label: 'Site', fieldName: 'Site', type: 'url' },
{ label: 'Account Source', fieldName: 'AccountSource' }
];

const FIELDS1 = ['SBQQ__Quote__c.core_cpq_quote_type_nm__c'];*/
export default class LwcCSVUploader extends LightningElement {
    
/*@api recordId;
@track columns;
@track data;
@track fileName = '';
@track UploadFile = 'Upload Data';
@track showLoadingSpinner = false;
@track isTrue = false;
@api picklistlabel = 'Select Object Name';
@api priceBookPickListLabel = 'Select Price Book';
@track groupsAssociated = [];
@track priceBookPickListValues = [{label : "All", value : "All"}];
/*
@track priceBookPickListValues = [
    { "label": "APJ", "value": "APJ" }, 
    { "label": "EMEA", "value": "EMEA" },
    { "label": "ASMO", "value": "ASMO" },
    { "label": "PRC", "value": "PRC" },
    { "label": "OEM", "value": "OEM" },
    { "label": "All", "value": "All"}
];
@api objectList = [];
@track picklistvalueselected = [];/*[
    { "label": "None", "value": "None" }, 
    { "label": "Quote Line", "value": "Quote Line" },
    { "label": "Product Details", "value": "Product Details" },
    { "label": "MSVP", "value": "MSVP"},
    { "label": "Distributor Margin", "value": "Distributor Margin"},
    { "label": "Forward Cost", "value": "Forward Cost"},
    { "label": "Tools SW Price Book", "value": "Tools SW Price Book"},
    { "label": "Tools IP/Devkit Price Book", "value": "Tools IP/Devkit Price Book"},
    { "label": "Components Price Book", "value": "Components Price Book"},
    //{ "label": "Quote", "value": "Quote" },
   // { "label": "Quote and QuoteLine", "value": "Quote and QuoteLine" },
    //{ "label": "Contracted Price", "value": "Contracted Price"},
    //{ "label": "SW Tool List Price", "value": "PSG Component List Price -- Price Book Entry"},
];

//@track picklistvalueselectedtemp = [];
@track options = [];
@track progress = 0;
@track processStatus = 'In Progress';
@track synchronousprocess;
@track batchJobId;
@track processedPercent = 0;
@track nullObjectError = '';
@track objectSelectionNullError = 'Please fill the Object as it is Mandatory for Bulk Upload';
//@track picklistvalueselected = [];
//-----------
@track selectObjectDevName = "";
@track error = undefined;
@track searchOptions;
@track requiredflds;
@track selectedValue;
@track selectedPriceBookValue;
@track disableUploadButton = true;
@track disableTemplateButton = true;
@track disableResultButton = true;
@track disableObjectSelection = false;
@track disableUploadFile = false;
@track enablePriceBookSelection = false;
@api horizontalAlign = 'space';
@track quoteObjRec;
@track showProgressBar = false;
//-----------
clickedButtonLabel;
selectedRecords;
filesUploaded = [];
file;
fileContents;
fileReader;
content;
MAX_FILE_SIZE = 1500000;
@track uploadMetaData = {};
/*
@wire(getRecord, { recordId: '$recordId', fields: FIELDS1 })
    wiredRecord({ error, data }) {
        if(data){
            this.quoteObjRec = data; 
            console.log('quote rec '+JSON.stringify(data)); 
        }
    }
@api
get picklistvalueselected() {
    /*
    var objectData = new Set();
    var picklistvalues = [];
    console.log('connected call back');
    getUploadMetaData()
    .then(result => {
    this.uploadMetaData = result;
    this.showLoadingSpinner = false;
    picklistvalues.push({ label: '--None--', value: '--None--'});
    for (var key of Object.keys(this.uploadMetaData)){
        objectData.add(this.uploadMetaData[key].PSG_Object_Name__c);
        console.log('objectData1 '+JSON.stringify(this.uploadMetaData[key].PSG_Object_Name__c));
    }
    for (var key of objectData){
        picklistvalues.push({ label: key, value: key});
    }
    console.log('this.picklistvalueselected '+JSON.stringify(picklistvalues));
    return picklistvalues;
})
.catch(error => {
    this.showLoadingSpinner = false;
    console.log(error);
    window.console.log(error);
        this.dispatchEvent(
        new ShowToastEvent({
                title: 'Error while uploading File',
                message: error.message,
                variant: 'error',
            }),
        );
    });
    return this._picklistvalueselected;
}

set picklistvalueselected(val) {
    var objectData = new Set();
    var picklistvalues = [];
    console.log('connected call back');
    getUploadMetaData()
        .then(result => {
            this.uploadMetaData = result;
            this.showLoadingSpinner = false;
            picklistvalues.push({ label: '--None--', value: '--None--' });
            for (var key of Object.keys(this.uploadMetaData)) {
                objectData.add(this.uploadMetaData[key].PSG_Object_Name__c);
                console.log('objectData1 ' + JSON.stringify(this.uploadMetaData[key].PSG_Object_Name__c));
            }
            for (var key of objectData) {
                picklistvalues.push({ label: key, value: key });
            }
            console.log('this.picklistvalueselected ' + JSON.stringify(picklistvalues));
            this._picklistvalueselected = picklistvalues;
        })
        .catch(error => {
            this.showLoadingSpinner = false;
            console.log(error);
            window.console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while uploading File',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
}
@wire(getUploadMetaData)
loadUploadMetaData(response) {
    console.log('meta data ' + JSON.stringify(response.data));
    var objectData = new Set();
    if (response && response.data) {
        this.uploadMetaData = response.data;
    }
}

/*
// wire method to get all object names
@wire(getAllObjects)
objectNames({ error, data }) {
    if (data) {
        console.log('>> return map' + JSON.stringify(data));
        this.searchOptions = data.map((type) => {
            return {
                label: type.objectName,
                value: type.objectAPI
            };
        });
        this.searchOptions.unshift({ label: "-- Select --", value: "" });
    } else if (error) {
        console.log('>>' + JSON.stringify(error));
        this.searchOptions = undefined;
        this.error = error;
    }
}

handleSearchOptionChange(event) {
    event.preventDefault();
    this.selectObjectDevName = event.detail.value;
    console.log('>>' + this.selectObjectDevName);
    this.getRequiredFieldsFromApex(this.selectObjectDevName);

}
getRequiredFieldsFromApex(objectName) {
    getAllRequiredFileds({ objName: objectName }).then(result => {
        if(result.length>0){
            this.requiredflds = result;
        }else{
            this.requiredflds = null;
        }
    })
        .catch(error => {
            this.error = error;
        });
}

connectedCallback(){
    console.log('connectedCallback '+this.recordId);
    var objectList = [];
        PRICEBOOKNAMES.split(',').forEach((pbName)=>{
            this.priceBookPickListValues.push({label : pbName,value : pbName});
        });
    if(this.recordId != undefined){
        this.disableObjectSelection = true;
        this.showLoadingSpinner = true;
        getQuoteType({ recordId:  this.recordId})
        .then((result) => {
            console.log('connectedCallback1 '+result);
            this.disableTemplateButton = false;
            console.log('connectedCallback2 '+JSON.stringify(this.quoteObjRec));
            if(result == 'Contract Pricing'){
                console.log('test1');
                objectList.push({ "label": "Quote Line CP", "value": "Quote Line CP" });
                this.selectedValue = 'Quote Line CP';
            }else{
                console.log('test2');
                objectList.push({ "label": "Quote Line", "value": "Quote Line" });
                this.selectedValue = 'Quote Line';
            } 
            this.picklistvalueselected = objectList;
            this.showLoadingSpinner = false;
        })
        .catch((error) => {
            this.error = error;
            this.showLoadingSpinner = false;
        });
        
    }else{
        this.disableUploadFile = true;
    }

    if(this.recordId == undefined || this.recordId == null){
        validatingAccess()
        .then(result => {
            var pickListAdded = [];
            objectList.push({ "label": "None", "value": "None" });
            result.forEach(function(element){
                console.log('groups associated '+element);
                console.log('groups associated '+element);
                if(element == 'ags_internal_pms'){
                    objectList.push({ "label": "Product Details", "value": "Product Details" });
                    objectList.push({ "label": "Forward Cost", "value": "Forward Cost"});
                    objectList.push({ "label": "Tools SW Price Book", "value": "Tools SW Price Book"});
                    objectList.push({ "label": "Tools IP/Devkit Price Book", "value": "Tools IP/Devkit Price Book"});
                    objectList.push({ "label": "Components Price Book", "value": "Components Price Book"});
                    pickListAdded.push("Product Details");
                    pickListAdded.push("Forward Cost");
                    pickListAdded.push("Tools SW Price Book");
                    pickListAdded.push("Tools IP/Devkit Price Book");
                    pickListAdded.push("Components Price Book");
                }
                if(element == 'ags_manage_disti_margin'){
                    if(!pickListAdded.includes("Product Details")){
                        objectList.push({"label": "Product Details", "value": "Product Details" });
                        pickListAdded.push("Product Details");
                    }
                    if(!pickListAdded.includes("Distributor Margin")){
                        objectList.push({ "label": "Distributor Margin", "value": "Distributor Margin"});
                        pickListAdded.push("Distributor Margin");
                    }
                }
                if(element == 'ags_manage_msvp'){
                    if(!pickListAdded.includes("Product Details")){
                        objectList.push({"label": "Product Details", "value": "Product Details" });
                        pickListAdded.push("Product Details");
                    }
                    if(!pickListAdded.includes("MSVP")){
                        objectList.push({"label": "MSVP", "value": "MSVP"});
                        pickListAdded.push("MSVP");
                    }
                }            
            });
            this.picklistvalueselected = objectList;
        })
        .catch(error => {
            this.error = error;
            console.log('inside error '+error);
        });
    }
    console.log('connectedCallback3');
    /*
    var objectData = new Set();
    console.log('connected call back');
    getUploadMetaData()
    .then(result => {
    this.uploadMetaData = result;
    this.showLoadingSpinner = false;
    this.picklistvalueselected.push({ label: '--None--', value: '--None--'});
    for (var key of Object.keys(this.uploadMetaData)){
        objectData.add(this.uploadMetaData[key].PSG_Object_Name__c);
        console.log('objectData1 '+JSON.stringify(this.uploadMetaData[key].PSG_Object_Name__c));
    }
    for (var key of objectData){
        this.picklistvalueselected.push({ label: key, value: key});
    }
    console.log('this.picklistvalueselected '+JSON.stringify(this.picklistvalueselected));
})
.catch(error => {
    this.showLoadingSpinner = false;
    console.log(error);
    window.console.log(error);
        this.dispatchEvent(
        new ShowToastEvent({
                title: 'Error while uploading File',
                message: error.message,
                variant: 'error',
            }),
        );
    });
}
handleFilesChange(event) {
    if (event.target.files.length > 0) {
        this.filesUploaded = event.target.files;
        this.fileName = event.target.files[0].name;
        this.disableUploadButton = false;
    }
}
handleSave() {
    if (this.filesUploaded.length > 0) {
        if((this.selectedValue == 'Tools SW Price Book' || this.selectedValue == 'Tools IP/Devkit Price Book' 
        || this.selectedValue == 'Components Price Book') && this.selectedPriceBookValue == null){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Price Book Missing',
                    message: 'Please Select a Price Book',
                    variant: 'error',
                }),
            );
        }else if((this.selectedValue == 'Tools SW Price Book') && (this.selectedPriceBookValue+'_SW.csv') != this.fileName){
                    console.log('file name '+(this.selectedPriceBookValue+'_SW.csv')+ ' '+this.fileName);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'File Invalid',
                            message: 'Please upload a valid file',
                            variant: 'error',
                        }),
                    );
        }else if((this.selectedValue == 'Tools IP/Devkit Price Book') && (this.selectedPriceBookValue+'_IP.csv') != this.fileName){
            console.log('file name '+(this.selectedPriceBookValue+'_IP.csv')+ ' '+this.fileName);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'File Invalid',
                    message: 'Please upload a valid file',
                    variant: 'error',
                }),
            );
        }else if((this.selectedValue == 'Components Price Book') && (this.selectedPriceBookValue+'_COMP.csv') != this.fileName){
            console.log('file name '+(this.selectedPriceBookValue+'_COMP.csv')+ ' '+this.fileName);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'File Invalid',
                    message: 'Please upload a valid file',
                    variant: 'error',
                }),
            );
        }else {
            this.uploadHelper();
        }
    } else {
        this.fileName = 'Please upload the Bulk Upload Template';
    }     
}

uploadHelper() {
    this.file = this.filesUploaded[0];
    if (this.file.size > this.MAX_FILE_SIZE) {
        window.console.log('File Size is to long');
        return;
    }
    this.showLoadingSpinner = true;
    this.fileReader = new FileReader();
    this.fileReader.onloadend = (() => {
        this.fileContents = this.fileReader.result;
        this.showLoadingSpinner = true;
        this.saveToFile();
    });
    this.fileReader.readAsText(this.file,"ascii");
}

saveToFile(){
    var inp = this.template.querySelectorAll("lightning-combobox");
    inp.forEach(function (element) {
        if (element.name == this.picklistlabel && !element.value) {
            this.nullObjectError = this.objectSelectionNullError;
        }
    }, this)
    if (this.nullObjectError != this.objectSelectionNullError) {
        console.log('one22 '+this.selectedValue);
        console.log(JSON.stringify(this.fileContents));
        var lines= ((this.fileContents).split("\n")).length;
        console.log('Lines '+lines);
        if((lines-1) > 4000){
            this.showLoadingSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'More than 4000 rows',
                    message: 'File you are trying to upload has more than 4000 rows. Request you to perform Bulk Upload in batches of 4000 rows',
                    variant: 'error',
                }),
            );
        }
        else{
        saveFile({ base64Data: JSON.stringify(this.fileContents), objectName: this.selectedValue,recordId: this.recordId,priceBookName: this.selectedPriceBookValue})
            .then(result => {
                this.disableUploadButton = false;
                this.disableTemplateButton = false;
                this.disableResultButton = false;
                this.showLoadingSpinner = false;
                window.console.log('result ====> ');
                window.console.log(result);
                this.data = JSON.parse(result).csvDataMapList;
                //this.fileName = this.fileName + ' - Uploaded Successfully';
                console.log('file name 20 ' + JSON.parse(result));
                this.fileName = JSON.parse(result).errorCount;
                this.columns = JSON.parse(result).columns;
                this.synchronousprocess = JSON.parse(result).synchronousProcess;
                this.batchJobId = JSON.parse(result).batchJobId
                this.isTrue = false;
                this.showLoadingSpinner = false;
                if(JSON.parse(result).batchJobId != null &&JSON.parse(result).batchJobId != ''){
                    this.showProgressBar = true;
                    this.disableResultButton = true;
                    this.disableUploadButton = true;
                }
                this.progressBar();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        //message: this.file.name + ' - Uploaded Successfully!!! ',
                        message: this.fileName,
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.showLoadingSpinner = false;
                console.log(error);
                window.console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while uploading File',
                        message: error.message,
                        variant: 'error',
                    }),
                );
            });
    }
    }
    //this.showLoadingSpinner = false;
}
progressBar() {
    console.log('progressBar1');
    if (this.synchronousprocess == false) {
        console.log('progressBar2 '+this.batchJobId);
                this._interval = setInterval(() => {
                    //add method
                    getBatchJobStatus({ jobID: this.batchJobId })
                    .then(result => {
                        console.log('progressBar10 ' + JSON.stringify(result));
                        console.log('progressBar20 ' + result.JobItemsProcessed + ' '+result.TotalJobItems);
                        if(result.Status == 'Processing'){
                            this.processedPercent = Math.round((result.JobItemsProcessed / result.TotalJobItems) * 100);
                            this.progress = this.processedPercent;
                            this.processStatus = 'Processing => ' + this.progress + ' %';
                        }else if(result.Status == 'Completed'){
                            this.processedPercent = 100;
                            this.progress = this.processedPercent;
                            this.processStatus = 'Completed';
                            clearInterval(this._interval);
                        }else{
                            this.processStatus= 'In Progress';
                        }
                    })
                    .catch(error => {
                        this.showLoadingSpinner = false;
                        console.log(error);
                        window.console.log(error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error while getting Status',
                                message: error.message,
                                variant: 'error',
                            }),
                        );
                    });
                    //add method
                }, 3000);
    }
}
fetchObjectTemplateCSV(dataToExtract, objectName) {
    let rowData = new Set();
    var map = new Map();
    var jsonObj = [];
    map.set('GroupId', '');
    map.set('Object', '');
    //rowData.add('GroupId');
    //rowData.add('Object');
    var optionsMap = [];
    dataToExtract.forEach(function (record) {
        //console.log('counting');
        Object.values(record).forEach(function (key) {
            //console.log('counting '+key);
            if (key.PSG_Object_Name__c == objectName) {
                // rowData.add(key.PSG_Field_Name__c);
                //console.log('counting '+key.PSG_Field_Name__c);
            }
        });
    });
    if(this.selectedValue == 'Quote and QuoteLine'){
        let item2 = {};
        item2['GroupId'] = '';
        jsonObj.push(item2);
        item2['Object'] = '';
        jsonObj.push(item2);
    }
    for (var key of Object.keys(dataToExtract)) {
        console.log('enter for loop');
        console.log(JSON.stringify(key) + " -> " + JSON.stringify(dataToExtract[key])+' '+objectName)
        if (dataToExtract[key].PSG_Object_Name__c == objectName) {
            map.set(dataToExtract[key].PSG_Field_Name__c, '');
            let fieldKey = dataToExtract[key].PSG_Field_Name__c;
            let item = {};
            item[fieldKey] = '';
            jsonObj.push(item);
            console.log(fieldKey + " checkhere2 " + dataToExtract[key].PSG_Field_Name__c+' 4444'+JSON.stringify(item));
        }
        /*
        for (var key2 in dataToExtract[key]) {
            if (dataToExtract[key].hasOwnProperty(key2)) {
                //var key = dataToExtract[key];
                var value = (dataToExtract[key])[key2];
                console.log(key2 + " checkhere55555 " + value);
                //do something with value;
                console.log(key + " checkhere " + dataToExtract[key].PSG_Field_Name__c);
                if(key2 == "PSG_Object_Name__c" && value == objectName){
                    map.set(((dataToExtract["PSG_Field_Name__c"])[key2]).PSG_Field_Name__c, '');
                    var item = {};
                    item [((dataToExtract[key])[key2]).PSG_Field_Name__c] = '';
                    jsonObj.push(item);
                    console.log(key + " checkhere22 " + dataToExtract[key].PSG_Field_Name__c);
                }
            }
        }
        */
        //if(dataToExtract[key].PSG_Object_Name__c == objectName){
        //    console.log(key + " -> " + dataToExtract[key].PSG_Field_Name__c)
        //    map.set(dataToExtract[key].PSG_Field_Name__c);
        //}
    //}

    //rowData.add('Result');
    //rowData.add('Reason');
    //map.set('Result', '');
    //map.set('Reason', '');
    /*let item3 = {};
    item3['Result'] = '';
    jsonObj.push(item3);
    item3['Reason'] = '';
    jsonObj.push(item3);
    
    console.log('final map  ' + JSON.stringify(jsonObj));
    this.downloadCSVFile(jsonObj, false);
    //this.downloadCSVFile([{"Active":""}]);
}
handleDownloadClick(event) {
    this.clickedButtonLabel = event.target.label;
    if (this.clickedButtonLabel == 'Download Result') {
        this.downloadCSVFile(this.data, true);
    } else if (this.clickedButtonLabel == 'Download Template') {
        this.fetchObjectTemplateCSV(this.uploadMetaData, this.selectedValue);
    }
}
handlePriceBookValueChange(event) {
    this.selectedPriceBookValue = event.target.value;
}
handlePickListValueChange(event) {
    console.log('one '+event.target.value);
    console.log('one '+event.detail.value);
    this.selectedValue = event.target.value;
    if(this.selectedValue != "None"){
        this.disableUploadFile = false;
    }
    if(this.selectedValue == 'Tools SW Price Book' || this.selectedValue == 'Tools IP/Devkit Price Book' 
    || this.selectedValue == 'Components Price Book'){
        this.disableUploadFile = false;
        this.enablePriceBookSelection = true;
    }else{
        this.enablePriceBookSelection = false;
    }
    this.disableTemplateButton = false;
    this.disableResultButton = true;
    this.fileName = '';
    this.data = null;
    this.columns = null;
}

// this method validates the data and creates the csv file to download
downloadCSVFile(csvData, downloadValues){
    let rowEnd = '\n';
    let csvString = '';
    let rowData = new Set();
    /*
    this.columns.forEach(function (record) {
        Object.values(record).forEach(function (key) {
            rowData.add(key);
        });
    });
    
    // this set elminates the duplicates if have any duplicate keys
    console.log('data2222222222222222 ' + JSON.stringify(this.data));
    // getting keys from data
    if (downloadValues == true) {
        csvData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });
        rowData = Array.from(rowData);
        rowData = rowData.reverse();
    } else {
        csvData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
                console.log('key ' + key);
            });
        });
        rowData = Array.from(rowData);
    }
    // Array.from() method returns an Array object from any object with a length property or an iterable object.
    //rowData = Array.from(rowData);
    //rowData = rowData.reverse();
    // splitting using ','
    csvString += rowData.join(',');
    csvString += rowEnd;
    console.log('csvString ' + JSON.stringify(csvString));
    // main for loop to get the data based on key value
    for (let i = 0; i < csvData.length; i++) {
        let colValue = 0;
        // validating keys in data
        for (let key in rowData) {
            console.log('key forloop ' + key);
            if (rowData.hasOwnProperty(key)) {
                // Key value 
                // Ex: Id, Name
                let rowKey = rowData[key];
                // add , after every value except the first.
                if (colValue > 0) {
                    csvString += ',';
                }
                // If the column is undefined, it as blank in the CSV file.
                let value = csvData[i][rowKey] === undefined ? '' : csvData[i][rowKey];
                csvString += '"' + value + '"';
                console.log('key forloop2 ' + csvString);
                colValue++;
            }
        }
        csvString += rowEnd;
    }
    console.log('csvString2 ' + JSON.stringify(csvString));
    // Creating anchor element to download
    let downloadElement = document.createElement('a');

    // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
    downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
    downloadElement.target = '_self';
    // CSV File Name
    downloadElement.download = this.selectedValue+'.csv';
    // below statement is required if you are using firefox browser
    document.body.appendChild(downloadElement);
    // click() Javascript function to download CSV file
    downloadElement.click();
}*/
}