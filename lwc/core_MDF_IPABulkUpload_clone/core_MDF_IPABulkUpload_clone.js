import {
    LightningElement,
    track,
    api
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import readCSV from '@salesforce/apex/Core_MDF_IPABulkCampaignUpload.readCSVFile';
import getUploadMetaData from '@salesforce/apex/Core_MDF_IPABulkCampaignUpload.getUploadData';
import saveFile from '@salesforce/apex/Core_MDF_IPABulkUpload_Clone.saveFile';
import validateAndSave from '@salesforce/apex/Core_MDF_IPABulkUpload_Clone.validateAndSave';
import getChannelProgram from '@salesforce/apex/Core_MDF_IPABulkCampaignUpload.getChannelProgram';
import campaignValidations from '@salesforce/resourceUrl/Core_MDF_BulkUploadUtil';
import * as validations from 'c/validationModules';
import {
    loadScript
} from 'lightning/platformResourceLoader';


export default class Core_MDF_IPABulkUpload_clone extends LightningElement {

    @track activeSections = 'Options';
    //picklists

    @track uploadMetaData = [];
    @track platformValues = [];
    @track progValues = [];
    @track objectValues = [];
    @track objectselected = [];
    @track progselected = [];
    @track platformselected = [];
    @api objectpicklistlabel = 'Select Object';
    @api platformpicklistlabel = 'Select Platform';
    @api programpicklistlabel = 'Select Program';

    @track selectedObjValue;
    @track selectedPlatformValue;
    @track selectedProgramValue;
    @track disableObjectSelection = true;
    @track disablePlatformSelection = true;
    @track disableProgramSelection = true;


    @api camperror;
    @api recordId;
    @track error;
    @track UploadFile = 'Upload Data';

    @track data;
    @track columns = [];

    @track nullObjectError = '';
    @track objectSelectionNullError = 'Please fill the Object as it is Mandatory for Bulk Upload';
    @track synchronousprocess;
    @track bulkUploadBatchId;
    @track fileName = '';
    @track disableUploadButton = true;
    @track disableTemplateButton = true;

    @track disableResultButton = true;



    @track objToProgramFieldApiName = [];


    @track path1selected = false;
    @track path2selected = false;
    @track path3selected = false;
    @api path;

    clickedButtonLabel;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;


    connectedCallback() {
        this.path1selected = true;
        var objectData = new Set();
        var platformData = new Set();
        var programData = new Set();

        getUploadMetaData()
            .then(result => {
                this.uploadMetaData = result;
                console.log('uploadMetaData:  ' + JSON.stringify(this.uploadMetaData));
                this.objectValues.push({
                    label: '--None--',
                    value: '--None--'
                });
                this.platformValues.push({
                    label: '--None--',
                    value: '--None--'
                });
                for (var key of Object.keys(this.uploadMetaData)) {
                    objectData.add(this.uploadMetaData[key].Core_MDF_Object_API_Name__c);
                    platformData.add(this.uploadMetaData[key].Core_MDF_Platform__c);
                }
                for (var key of objectData) {
                    this.objectValues.push({
                        label: key,
                        value: key
                    });
                }
                for (var key of platformData) {
                    this.platformValues.push({
                        label: key,
                        value: key
                    });
                }
                this.objectselected = this.objectValues;
                this.platformselected = this.platformValues;

                this.selectedPlatformValue = 'None';
                this.disablePlatformSelection = false;


            })
            .catch(error => {
                //this.showLoadingSpinner = false;
                console.log(error);

            });

        //get channel program
        getChannelProgram().then(result => {

                for (var key of Object.keys(result)) {
                    programData.add(result[key]);
                }

                for (var key of programData) {
                    this.progValues.push({
                        label: key,
                        value: key
                    });
                }
                this.progselected = this.progValues;


            })
            .catch(error => {
                //this.showLoadingSpinner = false;
                console.log(error);
            });


    }


    renderedCallback() {
        loadScript(this, campaignValidations)
            .then(() =>
                console.log('Loaded campaignValidations')
            )
            .catch(error => console.log(error));
    }

    handlePlatformValueChange(event) {
        this.selectedPlatformValue = event.target.value;
        if (this.selectedPlatformValue != "None") {
            this.disableProgramSelection = false;
        }
    }


    handleProgramValueChange(event) {
        this.selectedProgramValue = event.target.value;
        if (this.selectedProgramValue != "None") {
            this.disableObjectSelection = false;
        }
    }

    handleObjectValueChange(event) {
        this.selectedObjValue = event.target.value;
        if (this.selectedObjValue != "None") {
            this.disableTemplateButton = false;
            this.activeSections = ['Download', 'Upload'];
        }


        //this.disableTemplateButton = false;
        /*this.disableResultButton = true;
        this.fileName = '';
        this.data = null;
        this.columns = null;*/
    }



    handleDownloadClick(event) {
        this.clickedButtonLabel = event.target.label;
        /*if (this.clickedButtonLabel == 'Download Result') {
            this.downloadCSVFile(this.data, true);
        } */
        if (this.clickedButtonLabel == 'Download Template') {
            this.fetchObjectTemplateCSV(this.uploadMetaData, this.selectedObjValue);
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

        for (var key of Object.keys(dataToExtract)) {
            console.log('enter for loop');
            console.log(JSON.stringify(key) + " -> " + JSON.stringify(dataToExtract[key]) + ' ' + objectName)
            if (dataToExtract[key].Core_MDF_Object_API_Name__c == objectName) {
                map.set(dataToExtract[key].Core_MDF_Field_Name__c, '');
                let fieldKey = dataToExtract[key].Core_MDF_Field_Name__c;
                let item = {};
                item[fieldKey] = '';
                jsonObj.push(item);
                console.log(fieldKey + " checkhere2 " + dataToExtract[key].Core_MDF_Field_Name__c + ' 4444' + JSON.stringify(item));
            }

        }

        console.log('final map  ' + JSON.stringify(jsonObj));
        this.downloadCSVFile(jsonObj, false);

    }


    // this method validates the data and creates the csv file to download
    downloadCSVFile(csvData, downloadValues) {
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();
        /*
        this.columns.forEach(function (record) {
            Object.values(record).forEach(function (key) {
                rowData.add(key);
            });
        });
        */
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
        downloadElement.download = this.selectedObjValue + '.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
    }


    onPathSelection(event) {
        this.path = event.detail.path;
        console.log('this.path-->' + this.path);
        if (this.path == 'pat-1') {
            this.path1selected = true;
            this.path2selected = false;
            this.path3selected = false;

        } else if (this.path == 'pat-2') {
            this.path2selected = true;
            this.path1selected = false;
            this.path3selected = false;
        } else if (this.path == 'pat-3') {
            this.path3selected = true;
            this.path1selected = false;
            this.path2selected = false;
        } else {
            this.path1selected = false;
            this.path2selected = false;
            this.path3selected = false;
        }
    }

    // this method validates the data and creates the csv file to download
    /*downloadCSVFile() {   
        let rowEnd = '\n';
        let csvString = '';
        this.data = this.columns;
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data
        this.data.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.data.length; i++){
            let colValue = 0;

            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.data[i][rowKey] === undefined ? '' : this.data[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'IPA Campaign Data.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
    }*/

    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.disableUploadButton = false;
            this.handleSave();
        }
    }

    handleSave() {
        if (this.filesUploaded.length > 0) {
            this.uploadHelper();
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
            console.log('this.fileReader.result' + this.fileReader.result);
            console.log('this.fileContents' + this.fileContents);
            //this.showLoadingSpinner = true;
            this.validateData();
            //this.saveToFile();
        });
        this.fileReader.readAsText(this.file,'latin1');

    }
    handleValidate() {
        this.onlyValidate = true;
        validateAndSave({
                bulkUploadBatch: this.bulkUploadBatchId,
                onlyValidate: this.onlyValidate
            })
            .then(result => {
                this.batSub = result;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Batch submitted',
                        //message: this.file.name + ' - Uploaded Successfully!!! ',
                        message: this.batSub,
                        variant: 'success',
                    }),
                );
            })

    }

    handleBtnSave() {
        this.onlyValidate = false;
        validateAndSave({
                bulkUploadBatch: this.bulkUploadBatchId,
                onlyValidate: this.onlyValidate
            })
            .then(result => {
                this.batSub = result;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Batch submitted',
                        //message: this.file.name + ' - Uploaded Successfully!!! ',
                        message: this.batSub,
                        variant: 'success',
                    }),
                );
            })
    }

    validateDataType(content) {
        var lines = content.split("\\r\\n");

        var result = [];

        var headers = lines[0].split(",");
        console.log('headers..' + JSON.stringify(headers));
        headers[headers.length] = 'Result';
        for (var k = 0; k < headers.length; k++) {
            if (headers[k] == 'Result') {
                this.columns = [...this.columns, {
                    fieldName: headers[k],
                    label: headers[k],
                    wrapText: true,
                    initialWidth: 200,
                    typeAttributes: {
                        tooltip: {
                            fieldName: headers[k]
                        }
                    },
                    cellAttributes: {
                        class: {
                            fieldName: 'dataTypeErrorColor'
                        }
                    },
                }];

            } else {
                this.columns = [...this.columns, {
                    fieldName: headers[k],
                    label: headers[k]
                }];
            }

        }

        var dataTypeMap = [];
        var validationMap = [];
        var validationMethod = [];

        for (var key of Object.keys(this.uploadMetaData)) {
            if (this.uploadMetaData[key].Core_MDF_Object_API_Name__c ==  this.selectedObjValue) {
                dataTypeMap = [...dataTypeMap, {
                    key: this.uploadMetaData[key].Core_MDF_Field_Name__c,
                    value: this.uploadMetaData[key].Core_MDF_Data_Type_nm__c
                }];
                if (this.uploadMetaData[key].Core_MDF_ValidationToBeChecked__c) {
                    validationMap = [...validationMap, {
                        key: this.uploadMetaData[key].Core_MDF_Field_Name__c,
                        value: this.uploadMetaData[key].Core_MDF_ValidationToBeChecked__c
                    }];
                    validationMethod = [...validationMethod, {
                        key: this.uploadMetaData[key].Core_MDF_Field_Name__c,
                        value: this.uploadMetaData[key].Core_MDF_LWCValidationMethodName__c
                    }];
                }

            }
        }
        for (var i = 1; i < lines.length - 1; i++) {

            var obj = {};
            obj['Result'] = '';
            var currentline = lines[i].split(",");

            for (var j = 0; j < headers.length - 1; j++) {
                for (var key in Object.keys(dataTypeMap)) {
                    console.log('dataTypeMap[key].key:' + dataTypeMap[key].key + ' and headers[j]:' + headers[j]);
                    obj[headers[j]] = currentline[j];
                    console.log('typeof ' + currentline[j] + ' is ' + typeof (currentline[j]) + ' and dataTypeMap[key].value=' + dataTypeMap[key].value);
                    //obj['Result'] = 'Success';
                    if (dataTypeMap[key].key == headers[j] && typeof (currentline[j]) != dataTypeMap[key].value) {
                        console.log('matched');
                        let dataTypeErrorColor = "slds-text-color_error";
                        obj['Result'] = obj['Result'] + 'Error for ' + headers[j] + '. Expected datatype ' + dataTypeMap[key].value + ' but received ' + typeof (currentline[j]) + '. ';
                        obj['dataTypeErrorColor'] = dataTypeErrorColor;
                        break;
                    }
                }
                if(headers[j] == 'Start Date'){
                    this.startDate = currentline[j];
                }
                for (var key in Object.keys(validationMap)) {
                    if (validationMap[key].key == headers[j] && validationMap[key].value) {
                        
                        if(headers[j] == 'End Date'){
                            this.methodName = validationMethod[key].value;
                            var valError = validations[this.methodName](this.startDate,currentline[j]);
                        }else{
                            this.methodName = validationMethod[key].value;
                            var valError = validations[this.methodName](currentline[j]);
                        }
                        console.log('valError::' + valError);
                        if (valError != '') {
                            let dataTypeErrorColor = "slds-text-color_error";
                            obj['Result'] = obj['Result'] + valError;
                            obj['dataTypeErrorColor'] = dataTypeErrorColor;
                            break;
                        }
                    }

                }
            }
            result.push(obj);

        }

        this.data = JSON.parse(JSON.stringify(result));

        this.path = 'pat-2';
        this.template.querySelector('c-core_-m-d-f_-path-component').changePath(this.path);
    }

    validateData() {
        this.validateDataType(JSON.stringify(this.fileContents));
    }

    saveToFile() {

        //check data type
        //check format
        //check required fields
        //check validation--

        //build datatable and show basic error


        var inp = this.template.querySelectorAll("lightning-combobox");
        inp.forEach(function (element) {
            if (element.name == this.picklistlabel && !element.value) {
                this.nullObjectError = this.objectSelectionNullError;
            }
        }, this)
        if (this.nullObjectError != this.objectSelectionNullError) {
            console.log(JSON.stringify(this.fileContents));
            saveFile({
                    base64Data: JSON.stringify(this.fileContents),
                    objectName: this.selectedObjValue
                })
                .then(result => {
                    this.disableUploadButton = false;
                    this.disableTemplateButton = false;
                    this.disableResultButton = false;
                    this.disableValidate = false;
                    //this.showLoadingSpinner = false;
                    window.console.log('result ====> ');
                    console.log(result);
                    //this.data = JSON.parse(result).csvDataMapList;
                    //this.fileName = this.fileName + ' - Uploaded Successfully';
                    //console.log('file name 20 ' + JSON.parse(result));
                    //this.fileName = JSON.parse(result).errorCount;
                    //this.columns = JSON.parse(result).columns;
                    //this.synchronousprocess = JSON.parse(result).synchronousProcess;
                    this.bulkUploadBatchId = result;
                    this.isTrue = false;
                    //this.showLoadingSpinner = false;
                    /*if(JSON.parse(result).bulkUploadBatchId != null &&JSON.parse(result).bulkUploadBatchId != ''){
                        this.showProgressBar = true;
                        this.disableResultButton = true;
                        this.disableUploadButton = true;
                    }*/
                    //this.progressBar();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Data is being uploaded',
                            //message: this.file.name + ' - Uploaded Successfully!!! ',
                            message: `Bulk Upload Batch Id is ${this.bulkUploadBatchId}`,
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
        //this.showLoadingSpinner = false;
    }

    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        // calling apex class
        readCSV({
                idContentDocument: uploadedFiles[0].documentId
            })
            .then(result => {
                window.console.log('result ===> ' + result);
                this.data = result;
                if (this.data == null) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: 'Camapigns are not created based on CSV file!!!',
                            variant: 'error',
                        }),
                    );
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!!',
                            message: 'Campaigns are created based on CSV file!!!',
                            variant: 'success',
                        }),
                    );
                }

            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: JSON.stringify(error),
                        variant: 'error',
                    }),
                );
            })

    }
}