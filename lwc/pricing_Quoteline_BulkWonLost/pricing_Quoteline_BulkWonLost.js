import { LightningElement, track, api, wire } from 'lwc';
import getUploadMetaData from '@salesforce/apex/Pricing_IQR_UploadFile.getUploadMetaData';
import getBulkUploadDescriptions from '@salesforce/apex/Pricing_IQR_UploadFile.getBulkUploadDescriptions';
import saveFile from '@salesforce/apex/Pricing_QuoteLine_BulkWonLost.processWonLost';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLostReasonValue from '@salesforce/apex/Pricing_QuoteLineController.getLostReasonValue';

export default class Pricing_Quoteline_BulkWonLost extends LightningElement {

    @track fileName = '';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    @api picklistlabel = 'Select Bulk Upload Type';
    @track noteSection = '';
    @track error = undefined;
    @track selectedValue = 'bulkWonLost';
    @track disableValidateButton = true;
    clickedButtonLabel;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    MAX_FILE_SIZE = 1500000;
    @track uploadMetaData = {};
    @track lostReasonValues = [];

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
                if (item.Name === this.selectedValue) {
                    this.noteSection = item.LabelDescription__c;
                }
            });
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getLostReasonValue)
    getReasonValues({ error, data }) {
        if (data) {
            this.lostReasonValues = Object.values(data);
        } else if (error) {
            this.error = error;
        }
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

    fetchObjectTemplateCSV(dataToExtract, bulkUploadType) {
        var jsonObj = [];

        for (var key of Object.keys(dataToExtract)) {
            if (dataToExtract[key].Pricing_Object_Name__c == bulkUploadType) {
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

        rowData.add('');
        rowData.add(null);
        rowData.add('Lost Reason Picklist Values');
        rowData = Array.from(rowData);
        csvString += rowData.join(',');
        csvString += rowEnd;
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
        console.log(JSON.stringify((this.fileContents).split("\n")));
        var lines = ((this.fileContents).split("\n")).length;
        console.log('Length: '+lines);
        if ((lines - 2) > 1000) {
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
                    console.log(error);
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