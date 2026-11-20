import { LightningElement,api, track, wire } from 'lwc';
import getUploadMetaData from '@salesforce/apex/Pricing_IQR_UploadFile.getUploadMetaData';
import saveFile from '@salesforce/apex/Pricing_ApprovalPriceRulesTriggerHandler.processRecords';
import isloggedinUserhasRPMAccess from '@salesforce/apex/Pricing_QuoteLineController.hasPricingManagerAccess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class Pricing_BulkInsertUpdateProductFloorPrice extends LightningElement {
    @api recordId;
    @track data;
    @track fileName = '';
    @track disableValidateButton = false;
    @track disableTemplateButton = false;
    @track disableUploadFile = false;
    @track isRPMUser = true;
    msg = 'Only RPM can do this action';
    clickedButtonLabel;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    MAX_FILE_SIZE = 1500000;
    @track uploadMetaData = {};



    connectedCallback(){
        isloggedinUserhasRPMAccess()
        .then((result) => {
           this.isRPMUser = result;
        })
        .catch((error) => {
            // handle errors
        });
    }


   @wire(getUploadMetaData)
    loadUploadMetaData(response) {
        if (response && response.data) {
            this.uploadMetaData = response.data;
        }
    }

    
   handleFilesChange(event) {
        console.log('handleFilesChange:');
        console.log('file length:',JSON.stringify(event.target.files.length));
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
           // this.disableValidateButton = true;
        }
    }

    handleDownloadClick(event) {

        this.clickedButtonLabel = event.target.label;
        if (this.clickedButtonLabel == 'Download Template') {
            this.fetchObjectTemplateCSV(this.uploadMetaData, 'BulkProductFloorPrice');
        }
    }

    closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
    }

    fetchObjectTemplateCSV(dataToExtract, bulkUploadType) {
        var map = new Map();
        var jsonObj = [];
        map.set('GroupId', '');
        map.set('Object', '');
        for (var key of Object.keys(dataToExtract)) {
            console.log('dataToExtract11'+JSON.stringify(dataToExtract));
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
               
        rowData = Array.from(rowData);
        csvString += Array.from(rowData).join(',');
        csvString += rowEnd;
        

        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        downloadElement.download = 'BulkProductFloorPrice' + '.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }



    handleSave() {
        console.log('this.filesUploaded.length:', JSON.stringify(this.filesUploaded.length));
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
        console.log('this.filesUploaded.length:', JSON.stringify(this.filesUploaded.length));
        this.fileReader = new FileReader();
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            this.saveToFile();
        });
        this.fileReader.readAsText(this.file, "ascii");
    }

    saveToFile() {
            var inp = this.template.querySelectorAll("lightning-combobox");
            console.log('recordId:'+this.recordId);
                var lines = ((this.fileContents).split("\n")).length;
                console.log('lines: '+lines);
                if ((lines - 1) > 1000) {
                    console.log('inside lines');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'More than 1000 rows',
                            message: 'File you are trying to upload has more than 1000 rows. Request you to perform Bulk Upload in batches of 1000 rows',
                            variant: 'error',
                        }),
                    );
                }
                else {
                   // this.disableValidateButton = true;
                        saveFile({ base64Data: JSON.stringify(this.fileContents), objectName: 'BulkProductFloorPrice' ,recordId: this.recordId})
                            .then(result => {
                                if (result == 'Operation Completed') {
                                    
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Success!!',
                                            message: 'Bulk Product Floor Price file has uploaded successfully. Please see the email notification to review the results of the upload.',
                                            variant: 'success',
                                            mode: 'sticky',
                                        }),
                                    );
                                    this.disableTemplateButton = false;
                                    this.closeAction();
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
                            })
                            .catch(error => {
                                window.console.log('error:'+error.message);
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error while uploading File - ' + error.body.message,
                                        message: error.message,
                                        variant: 'error',
                                    }),
                                );
                            });
    
                }
        }
}