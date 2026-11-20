import { LightningElement, api, track } from 'lwc';
import getRelatedFilesByRecordId from '@salesforce/apex/core_S2S_FileDownloadCaseController.getRelatedFilesByRecordId'; // Importing Apex method to fetch related files
import getContentVersion from '@salesforce/apex/core_S2S_FileDownloadCaseController.getContentVersion'; // Importing Apex method to get content version
import { refreshApex } from '@salesforce/apex'; // Importing Apex method to refresh data
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Importing Lightning Web Component event for showing toast messages
import { subscribe, createMessageContext } from 'lightning/messageService'; // Importing Lightning Message Service functions
import fileMessage from "@salesforce/messageChannel/UploadFileMessageChannel__c"; // Importing message channel for file upload notifications

export default class Core_FileDownloadCase extends LightningElement {
    @api recordId // Public property to hold the record Id
    @track filesList = []; // Track variable for storing related files
    isFiles = false; // Flag to check if files are available
    subscription = null; // Subscription object for Lightning Message Service
    context = createMessageContext(); // Create message context for Lightning Message Service
    receivedMessage; // Variable to hold received message
    @track downloadUrl; // Track variable for download URL
    @track extension; // Track variable for file extension
    @track downloadLabel; // Track variable for download label
    @track downloadElement; // Track variable for download element
    isPriview = false; // Flag to check if preview is active

    connectedCallback() {
        this.initFiles(); // Initialize related files on component connect
    }

    renderedCallback() {
        this.subscribeMC(); // Subscribe to message channel on component render
        if (this.isPriview) {
            const showPreview = this.template.querySelector("c-core_previewfilemodal");
            showPreview.show();
        }
    }

    // Method to fetch related files
    initFiles() {
        getRelatedFilesByRecordId({ recordId: this.recordId }).
            then((data, error) => {
                if (data) {
                    this.filesList = Object.keys(data).map(item => ({
                        "label": data[item].Title__c,
                        "value": data[item].VersionData__c.split('/')[6],
                        "type": data[item].ContentDocumentId__r.FileType__c
                    }))

                    if (this.filesList.length > 0) {
                        this.isFiles = true;
                    }
                }
                if(error){
                    this.showToast('Error!!', error.body.message, 'error', 'dismissable');
                }
            })
    }

    // Method to handle preview
    previewHandler(event) {
        var contentVersionId = event.target.dataset.id;
        var contentVersionType = event.target.dataset.type;
        var contentVersionFileName = event.target.dataset.filename;
        this.downloadUrl = '';

        getContentVersion({ recordId: contentVersionId })
            .then((data, error) => {
                if (data) {
                    var previewElement;
                    this.downloadUrl = 'previewElement.src';
                    this.extension = contentVersionType;

                    if (contentVersionType === 'PNG' || contentVersionType === 'JPG') {
                        previewElement = document.createElement('img');
                        previewElement.src = 'data:image/' + contentVersionType + ';base64,' + data;
                        this.downloadUrl = previewElement.src;

                    } else if (contentVersionType === 'PDF') {
                        previewElement = document.createElement('iframe');
                        previewElement.href = 'data:text/html;base64,' + data;
                        previewElement.src = previewElement.href;
                        this.downloadUrl = previewElement.src;
                    }

                    let downloadElement = document.createElement('a');
                    downloadElement.download = contentVersionFileName;
                    downloadElement.href = 'data:application/octet-stream;base64,' + data;
                    this.downloadElement = downloadElement;
                    this.downloadLabel = contentVersionFileName;
                    this.isPriview = true;
                } 
                if(error){
                    this.showToast('Error!!', error.body.message, 'error', 'dismissable');
                }
            });

    }

    // Method to handle preview modal visibility change
    hanldeProgressValueChange(event) {
        this.isPriview = event.detail;
    }

    // Method to subscribe to message channel
    subscribeMC() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.context, fileMessage, (message) => {
            this.displayMessage(message);
        });
    }

    // Method to handle received messages
    displayMessage(message) {
        if (message.message === 'handleRefresh') {
            this.initFiles();
            refreshApex(this.filesList);
            this.isFiles = false;
        }
    }

    // Method to show toast message
    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}