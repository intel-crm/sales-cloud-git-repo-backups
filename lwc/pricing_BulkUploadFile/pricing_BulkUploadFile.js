import { LightningElement, track, api, wire } from 'lwc';
import getUploadMetaData from '@salesforce/apex/Pricing_IQR_UploadFile.getUploadMetaData';
import getBulkUploadDescriptions from '@salesforce/apex/Pricing_IQR_UploadFile.getBulkUploadDescriptions';
import saveFile from '@salesforce/apex/Pricing_IQR_UploadFile.processRecords';
import saveFileWonLost from '@salesforce/apex/Pricing_QuoteLine_BulkWonLost.processWonLost';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLostReasonValue from '@salesforce/apex/Pricing_QuoteLineController.getLostReasonValue';
import saveFileCompProductPrice from '@salesforce/apex/Pricing_IQR_UploadFile.processCompetitorProductPrice';
import isDPMUser from '@salesforce/apex/Pricing_IQR_UploadFile.isDPMUser';


export default class Pricing_BulkUploadFile extends LightningElement {
    @api recordId;
    @track columns;
    @track data;
    @track fileName = '';
    @track UploadFile = 'Upload Data';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    @api picklistlabel = 'Select Bulk Upload Type';

    @track objLabelMap = {};
    @track picklistvalueselectedRPM = [
        { "label": "None", "value": "None" },
        { "label": "Create Change Request", "value": "ChangeRequest" },
        { "label": "Bulk won/lost", "value": "bulkWonLost" }
    ];
    @track picklistvalueselectedDPM = [
        { "label": "None", "value": "None" },
        { "label": "Create Competitor Product Price Records", "value": "createCompetitorProductPrice" }
    ];
    @track synchronousprocess;
    @track batchJobId;
    @track nullObjectError = '';
    @track objectSelectionNullError = 'Please select the Bulk Upload Type, as it is Mandatory for Bulk Upload';
    @track selectObjectDevName = "";
    @track error = undefined;
    @track requiredflds;
    @track selectedValue;
    @track disableValidateButton = true;
    @track disableTemplateButton = true;
    @track disableUploadFile = true;
    clickedButtonLabel;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;
    @track uploadMetaData = {};
    @track objMetadataValues = {};
    @track validateBtnLabel = 'Validate';
    @track showOptions = false;

    @track lostReasonValues = [];

    connectedCallback() {
        isDPMUser()
        .then((result) => {
            this.showOptions = result;
        })
        .catch((error) => {
            console.error('Error: ', error.body.message);
        });
    }

    @wire(getUploadMetaData)
    loadUploadMetaData(response) {
        if (response && response.data) {
            this.uploadMetaData = response.data;
        }
    }

    @wire(getBulkUploadDescriptions)
    getDescriptions({ error, data }) {
        if (data) {
            data.forEach((item) => {
                this.objLabelMap[item.Name] = item.LabelDescription__c;
            });
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getLostReasonValue) // lostReasonValues
    getReasonValues({ error, data }) {
        if (data) {
            this.lostReasonValues = Object.values(data);
        } else if (error) {
            this.error = error;
        }
    }

    handleSearchOptionChange(event) {
        event.preventDefault();
        this.selectObjectDevName = event.detail.value;
        this.getRequiredFieldsFromApex(this.selectObjectDevName);
    }

    get objectDescription() {
        return this.objLabelMap[this.selectedValue];
    }

    getRequiredFieldsFromApex(objectName) {
        getAllRequiredFileds({ objName: objectName }).then(result => {
            if (result.length > 0) {
                this.requiredflds = result;
            } else {
                this.requiredflds = null;
            }
        })
            .catch(error => {
                this.error = error;
            });
    }

    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.disableValidateButton = false;
        }
    }

    handleDownloadClick(event) {
        this.clickedButtonLabel = event.target.label;
        if (this.clickedButtonLabel == 'Download Template') {
            this.fetchObjectTemplateCSV(this.uploadMetaData, this.selectedValue);
        }
    }

    handlePickListValueChange(event) {
        this.selectedValue = event.target.value;
        if (this.selectedValue != "None") {
            this.disableUploadFile = false;
            this.disableTemplateButton = false;
            if (this.selectedValue == 'ChangeRequest') {
                this.validateBtnLabel = 'Validate And Create Bulk CR';
            }
            if (this.selectedValue == 'bulkWonLost') {
                this.validateBtnLabel = 'Update Status';
            }
            if (this.selectedValue == 'createCompetitorProductPrice') {
                this.validateBtnLabel = 'Validate And Create Competitor Product Price Records';
            }
        } else {
            this.validateBtnLabel = 'Validate';
            this.disableValidateButton = true;
            this.disableUploadFile = true;
            this.disableTemplateButton = true;
        }
        this.fileName = '';
        this.data = null;
        this.columns = null;
    }

    fetchObjectTemplateCSV(dataToExtract, bulkUploadType) {
        var map = new Map();
        var jsonObj = [];
        map.set('GroupId', '');
        map.set('Object', '');
        for (var key of Object.keys(dataToExtract)) {
            
            if (dataToExtract[key].Pricing_Object_Name__c == bulkUploadType) {
                map.set(dataToExtract[key].Pricing_Field_Name__c, '');
                let fieldKey = dataToExtract[key].Pricing_Field_Name__c;
                let item = {};
                item[fieldKey] = '';
                jsonObj.push(item);
            }
        }
        this.downloadCSVFile(jsonObj);
    }

    downloadCSVFile(csvData) {
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();

        csvData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });
        if (this.selectedValue == 'bulkWonLost') {
            rowData.add('');
            rowData.add(null);
            rowData.add('Lost Reason Picklist Values');
        }        
        rowData = Array.from(rowData);
        csvString += Array.from(rowData).join(',');
        csvString += rowEnd;
        if (this.selectedValue == 'bulkWonLost') {
            for (let i = 0; i < this.lostReasonValues.length; i++) {
                let newRow = new Set();
                for (let index = 0; index < 9; index++) {
                    
                    if (index == 8) {
                        newRow.add(this.lostReasonValues[i]);
                    } else {
                        newRow.add([" "]);                      
                    }
                    
                }
                csvString += Array.from(newRow).join(',');
                csvString += rowEnd;
            }
        }

        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        downloadElement.download = this.selectedValue + '.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    handleSave() {
        if (this.filesUploaded.length > 0) {
            this.uploadHelper();
        } else {
            this.fileName = 'Please upload the correct Bulk Upload Template';
        }
    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            window.console.log('File Size is too large');
            return;
        }
        this.showLoadingSpinner = true;
        this.fileReader = new FileReader();
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            this.showLoadingSpinner = true;
            this.saveToFile();
        });
        this.fileReader.readAsText(this.file, "ascii");
    }

    saveToFile() {
        var inp = this.template.querySelectorAll("lightning-combobox");
        inp.forEach(function (element) {
            if (element.name == this.picklistlabel && !element.value) {
                this.nullObjectError = this.objectSelectionNullError;
            }
        }, this)
        if (this.nullObjectError != this.objectSelectionNullError) {
            var lines = ((this.fileContents).split("\n")).length;
            if ((lines - 1) > 1000) {
                this.showLoadingSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'More than 1000 rows',
                        message: 'File you are trying to upload has more than 1000 rows. Request you to perform Bulk Upload in batches of 1000 rows',
                        variant: 'error',
                    }),
                );
            }
            else {
                this.disableValidateButton = true;
                if (this.selectedValue == 'ChangeRequest') {
                    saveFile({ base64Data: JSON.stringify(this.fileContents), objectName: this.selectedValue })
                        .then(result => {
                            if (result == 'Operation Completed') {
                                this.showLoadingSpinner = false;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success!!',
                                        message: 'Validation Started, Soon you will get email notification with the result',
                                        variant: 'success',
                                        mode: 'sticky',
                                    }),
                                );
                                this.disableTemplateButton = false;
                                this.isTrue = false;
                                this.showLoadingSpinner = false;
                            }
                            else {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error while uploading File',
                                        message: result,
                                        variant: 'error',
                                        mode: 'sticky',
                                    }),
                                );
                            }
                            this.showLoadingSpinner = false;
                        })
                        .catch(error => {
                            this.showLoadingSpinner = false;
                            window.console.log(error);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error while uploading File - ' + error.body.message,
                                    message: error.message,
                                    variant: 'error',
                                }),
                            );
                            this.showLoadingSpinner = false;
                        });
                }
                if (this.selectedValue == 'bulkWonLost') {
                    saveFileWonLost({ base64Data: JSON.stringify(this.fileContents), objectName: this.selectedValue })
                        .then(result => {
                            if (result == 'Operation Completed') {
                                this.showLoadingSpinner = false;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success!!',
                                        message: 'Validation Started, Soon you will get email notification with the result',
                                        variant: 'success',
                                        mode: 'sticky',
                                    }),
                                );
                                this.disableTemplateButton = false;
                                this.isTrue = false;
                                this.showLoadingSpinner = false;
                            }
                            else {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error while uploading File',
                                        message: result,
                                        variant: 'error',
                                        mode: 'sticky',
                                    }),
                                );
                            }
                            this.showLoadingSpinner = false;
                        })
                        .catch(error => {
                            this.showLoadingSpinner = false;
                            window.console.log(error);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error while uploading File - ' + error.body.message,
                                    message: error.message,
                                    variant: 'error',
                                }),
                            );
                            this.showLoadingSpinner = false;
                        });
                }
                if (this.selectedValue == 'createCompetitorProductPrice') {
                    saveFileCompProductPrice({ base64Data: JSON.stringify(this.fileContents), objectName: this.selectedValue })
                        .then(result => {
                            if (result == 'Operation Completed') {
                                this.showLoadingSpinner = false;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success!!',
                                        message: 'Validation Started, Soon you will get email notification with the result',
                                        variant: 'success',
                                        mode: 'sticky',
                                    }),
                                );
                                this.disableTemplateButton = false;
                                this.isTrue = false;
                                this.showLoadingSpinner = false;
                            }
                            else {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error while uploading File',
                                        message: result,
                                        variant: 'error',
                                        mode: 'sticky',
                                    }),
                                );
                            }
                            this.showLoadingSpinner = false;
                        })
                        .catch(error => {
                            this.showLoadingSpinner = false;
                            window.console.log(error);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error while uploading File - ' + error.body.message,
                                    message: error.message,
                                    variant: 'error',
                                }),
                            );
                            this.showLoadingSpinner = false;
                        });
                }

            }
        }
    }

}