import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserDetails from '@salesforce/apex/Core_MDF_DownloadAllDocumentsController.getUserDetails';
import errorText from '@salesforce/label/c.Core_MDF_Error';
import applicationErrorMessage from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import loadingLabel from '@salesforce/label/c.Core_MDF_Loading';
import downloadAllDocumentsLabel from '@salesforce/label/c.Core_MDF_Download_All_Document_Button_Label';
import downloadCaseReviewDocuments from '@salesforce/label/c.Core_MDF_Download_Case_Review_Documents';

export default class Core_MDF_DownloadAllDocuments extends NavigationMixin(LightningElement) {
    @api recordId;
    auditDocumentList = [];
    contentDocumentIds = [];
    sftDocumentUrl = [];
    hasContentDocumentIds = false;
    isClaimCaseReviewerOrManager;
    showSpinner = false;
    displayDownloadAllDocuments = false;
    labels = {
        errorText, applicationErrorMessage,
        loadingLabel, downloadAllDocumentsLabel, downloadCaseReviewDocuments
    };

    connectedCallback() {
        this.checkUserPermissions()
    }

    //This method is to check the user access either to download documents or to submit message
    async checkUserPermissions() {
        await getUserDetails({ caseId: this.recordId })
            .then(response => {
                if (response !== {} && Object.keys(response).length > 0) {
                    this.isClaimCaseReviewerOrManager = response.isClaimCaseReviewerOrManager;
                    this.auditDocumentList = response.auditDocumentList;
                    if (this.isClaimCaseReviewerOrManager) {
                        this.checkAccessToDownloadAllDocuments();
                    } else {
                        this.displayDownloadAllDocuments = false;
                    }
                }
            })
            .catch(error => {
                console.log('Error in checkUserPermissions - Core_MDF_DownloadAllDocuments', error);
                this.fireToastEvent(this.labels.applicationErrorMessage, this.labels.errorText);
            })
    }

    //This method is to display the 'download all documents', only when review documents are available
    checkAccessToDownloadAllDocuments() {
        this.hasAccessToSubmitMessage = false;
        if (this.auditDocumentList.length > 0) {
            this.displayDownloadAllDocuments = true;
            this.getContentDocumentIds();
        } else {
            this.displayDownloadAllDocuments = false;
        }
    }

    //This method is to get all the content document ids of the case review documents
    getContentDocumentIds() {
        this.auditDocumentList.forEach(auditDoc => {
            if(!auditDoc.Core_MDF_SFT_File_Download_Ind__c){
                this.contentDocumentIds.push(auditDoc.Core_MDF_Document_Id__c);
            }else if(auditDoc.Core_MDF_SFT_File_Download_Ind__c){
                this.sftDocumentUrl.push(auditDoc.Core_MDF_SFT_File_Download_URL__c);
            }
        });

    }

    //This method is executed on click of 'Download all documents'
    downloadAllFiles() {
        if (this.contentDocumentIds.length > 0){
            this.contentDocumentIds.forEach(contentDocId => {
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: "/sfc/servlet.shepherd/document/download/" +
                            contentDocId +
                            "?operationContext=S1",
                    }
                }, false
                );
            });
        }
        if (this.sftDocumentUrl.length > 0){
            this.sftDocumentUrl.forEach(DocURL => {
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: DocURL,
                    }
                }, false
                );
                
                
            });
        }
    }


    //common toast event to handle success and error scenarios
    fireToastEvent(message, variant) {
        const toastEvent = new ShowToastEvent({
            message: message,
            duration: "5000",
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }
}