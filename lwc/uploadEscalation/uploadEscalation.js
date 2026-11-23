import { LightningElement,wire, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//import readCSV from '@salesforce/apex/Core_MDF_UploadBulkEscalation.readCSVFile';
import saveFile from '@salesforce/apex/Core_MDF_UploadBulkEscalation.saveFile';
//import releatedFiles from '@salesforce/apex/Core_MDF_UploadBulkEscalation.releatedFiles';


// importing to get the object info 
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
// importing Account shcema
import ESCALATION_OBJECT from '@salesforce/schema/Core_MDF_Escalation__c';



const columns = [
    { label: 'Escalation Name', fieldName: 'Escalation Name' }, 
    { label: 'Root Cause', fieldName: 'Root Cause' }
    //{ label: 'Total Dollar Impac', fieldName: 'Total Dollar Impact'} 
    //{ label: 'Activity Name', fieldName: 'Activity Name'}
];

export default class ReadCSVFileInLWC extends LightningElement {

    @track selectedValue;
    @track options = [];

    @track error;

    @api recordId;
    @track columns = columns;
    @track data;
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;


    // connectedCallback() {
    //     this.getRelatedFiles();
    // }

    // getting file 
    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.detail.files;
            this.fileName = event.target.files[0].name;
        }
    }

    handleSave() {
        if(this.filesUploaded.length > 0) {
            this.uploadHelper();
        }
        else {
            this.fileName = 'Please select file to upload!!';
        }
    }


    uploadHelper() {
        // Get the list of uploaded files
        const uploadedFiles = this.filesUploaded;

        // calling apex class
        saveFile({idContentDocument : uploadedFiles[0].documentId})
        .then(result => {
            window.console.log('result ===> '+result);
            this.data = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Accounts are created based CSV file!!!',
                    variant: 'success',
                }),
            );
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

    // uploadHelper() {
    //     this.file = this.filesUploaded[0];
    //    if (this.file.size > this.MAX_FILE_SIZE) {
    //         window.console.log('File Size is to long');
    //         return ;
    //     }
    //     this.showLoadingSpinner = true;
    //     // create a FileReader object 
    //     this.fileReader= new FileReader();
    //     // set onload function of FileReader object  
    //     this.fileReader.onloadend = (() => {
    //         this.fileContents = this.fileReader.result;
    //         let base64 = 'base64,';
    //         this.content = this.fileContents.indexOf(base64) + base64.length;
    //         this.fileContents = this.fileContents.substring(this.content);
            
    //         // call the uploadProcess method 
    //         this.saveToFile();
    //     });
    
    //     this.fileReader.readAsDataURL(this.file);
    // }

    // // Calling apex class to insert the file
    // saveToFile() {
    //     saveFile({idContentDocument : this.file.documentId})
    //     .then(result => {//
    //         window.console.log('result ====> ' +result);
    //         // refreshing the datatable
    //         //this.getRelatedFiles();

    //         this.fileName = this.fileName + ' - Uploaded Successfully';
    //         this.UploadFile = 'File Uploaded Successfully';
    //         this.isTrue = true;
    //         this.showLoadingSpinner = false;

    //         // Showing Success message after file insert
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Success!!',
    //                 message: this.file.name + ' - Uploaded Successfully!!!',
    //                 variant: 'success',
    //             }),
    //         );

    //     })
    //     .catch(error => {
    //         // Showing errors if any while inserting the files
    //         window.console.log(error);
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error while uploading File',
    //                 message: error.message,
    //                 variant: 'error',
    //             }),
    //         );
    //     });
    // }
    
 






    // Getting releated files of the current record
    // getRelatedFiles() {
    //     releatedFiles({idParent: this.recordId})
    //     .then(data => {
    //         this.data = data;
    //     })
    //     .catch(error => {
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error!!',
    //                 message: error.message,
    //                 variant: 'error',
    //             }),
    //         );
    //     });
    // }

    // Getting selected rows to perform any action
    getSelectedRecords(event) {
        let conDocIds;
        const selectedRows = event.detail.selectedRows;
        conDocIds = new Set();
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            conDocIds.add(selectedRows[i].ContentDocumentId);
        }

        this.selectedRecords = Array.from(conDocIds).join(',');

        window.console.log('selectedRecords =====> '+this.selectedRecords);
    }



    // object info using wire service
    @wire(getObjectInfo, { objectApiName: ESCALATION_OBJECT })
    accObjectInfo({data, error}) {
        if(data) {
            let optionsValues = [];
            // map of record type Info
            const rtInfos = data.recordTypeInfos;

            // getting map values
            let rtValues = Object.values(rtInfos);

            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].name !== 'Master') {
                    optionsValues.push({
                        label: rtValues[i].name,
                        value: rtValues[i].recordTypeId
                    })
                }
            }

            this.options = optionsValues;
        }
        else if(error) {
            window.console.log('Error ===> '+JSON.stringify(error));
        }
    }
     
    // Handling on change value
    handleChange(event) {
        this.selectedValue = event.detail.value;
    }

    // // accepted parameters
    // get acceptedFormats() {
    //     return ['.csv'];
    // }
    
 
}