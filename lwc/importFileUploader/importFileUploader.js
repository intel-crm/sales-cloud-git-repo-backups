import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class ImportFileUploader extends LightningElement {
    
    @api recordId = '';
    @api contentVersionId  = '';
    @api contentDocumentId = '';
    @api fileName          = '';
    
    @track isUploaded = false;

    handleUploadFinished(event) {
        const files = event.detail.files;
        
        if (files && files.length > 0) {
            const file = files[0];
            
            this.contentVersionId  = file.contentVersionId;
            this.contentDocumentId = file.documentId;
            this.fileName          = file.name;
            this.isUploaded        = true;

            // This is what actually passes 
            // values back to Flow
            this.dispatchEvent(
                new FlowAttributeChangeEvent(
                    'contentVersionId', 
                    file.contentVersionId
                )
            );
            this.dispatchEvent(
                new FlowAttributeChangeEvent(
                    'contentDocumentId', 
                    file.documentId
                )
            );
            this.dispatchEvent(
                new FlowAttributeChangeEvent(
                    'fileName', 
                    file.name
                )
            );
        }
    }

    handleReset() {
        this.contentVersionId  = '';
        this.contentDocumentId = '';
        this.fileName          = '';
        this.isUploaded        = false;

        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'contentVersionId', ''
            )
        );
        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'contentDocumentId', ''
            )
        );
        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'fileName', ''
            )
        );
    }

    @api
    validate() {
        if (!this.contentVersionId) {
            return {
                isValid: false,
                errorMessage: 
                    'Please upload a CSV file before continuing.'
            };
        }
        return { isValid: true };
    }
}