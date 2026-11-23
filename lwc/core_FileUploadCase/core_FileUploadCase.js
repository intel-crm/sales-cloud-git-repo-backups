import { LightningElement, track, api } from 'lwc';
import uploadFiles from '@salesforce/apex/core_S2S_FileUploadCaseCtrl.uploadFiles'; // Importing Apex method for file upload
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Importing Lightning Web Component event for showing toast messages
import { publish, createMessageContext } from 'lightning/messageService'; // Importing Lightning Message Service functions
import fileMessage from "@salesforce/messageChannel/UploadFileMessageChannel__c"; // Importing message channel for file upload notifications

const MAX_FILE_SIZE =  2621440; // Maximum file size allowed for upload in bytes

export default class Core_FileUploadCase extends LightningElement {
    @track showSpinner = false; // Tracking variable for spinner visibility
    @api recordId; // Public property to hold the record Id
    context = createMessageContext(); // Create message context for Lightning Message Service
    @track filesData = []; // Track variable for storing uploaded files data

    // Method to handle file change event
    handleFileChange(event) {
        if (event.target.files.length > 0) {
            for (var i = 0; i < event.target.files.length; i++) {
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.ShowToast('Error!!', 'File size exceeded the upload size limit 2.5MB.', 'error', 'dismissable');
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({ 'indexNumber': i, 'fileName': file.name, 'fileContent': fileContents });
                };
                reader.readAsDataURL(file);
            }
        }
    }

    // Method to remove file from the list
    removeFile(event) {
        var index = event.target.dataset.index;
        this.filesData.pop(index);
    }

    // Method to publish message for file upload
    publishMC() {
        const message = {
            message: "handleRefresh"
        };
        publish(this.context, fileMessage, message);
    }

    // Method to handle file upload
    uploadFile() {
        this.handleSpinner();
        if (this.filesData == [] || this.filesData.length == 0) {
            this.ShowToast('Information', 'Please select files first', 'info', 'dismissable');
            this.handleSpinner();
            return;
        } else {
            uploadFiles({ recordId: this.recordId, filedata: JSON.stringify(this.filesData) }).
                then(result => {
                    console.log(result);
                    if (result && result == 'success') {
                        this.filesData = [];
                        this.ShowToast('Success','Success', 'success', 'Files Uploaded successfully.');
                    } else {
                        this.ShowToast('Error!!', result, 'error', 'dismissable');
                    }
                }).catch(error => {
                    if (error && error.body && error.body.message) {
                        this.ShowToast('Error!!', error.body.message, 'error', 'dismissable');
                    }
                }).finally(() => {
                    this.handleSpinner();
                    this.publishMC();
                });
        }
    }

    // Method to handle spinner visibility
    handleSpinner() {
        this.showSpinner = !this.showSpinner;
    }

    // Method to show toast message
    ShowToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}