import { LightningElement, api, track } from 'lwc';
import getDocumentShare from '@salesforce/apex/Pricing_CommentsController.getDocumentShare';
import { NavigationMixin } from 'lightning/navigation';
export default class Pricing_ManageDocumentShare extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @track recordName;
    @track noOfAttachments;
    @track docId;

    connectedCallback() {
        getDocumentShare({ quoteId: this.recordId })
            .then(result => {
                this.recordName = result.name;
                this.noOfAttachments = result.noOfAttachment;
                this.docId = result.recordId;
            });
    }
    
    navigateToRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.docId,
                objectApiName: 'Pricing_Document__c',
                actionName: 'view',
            },
        });
    }
}