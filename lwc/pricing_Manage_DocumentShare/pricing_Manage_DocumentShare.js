import { LightningElement, api, track } from 'lwc';
import getDocumentShare from '@salesforce/apex/Pricing_DocumentShare_Controller.getDocumentShare';
import { NavigationMixin } from 'lightning/navigation';

export default class Pricing_Manage_DocumentShare extends NavigationMixin(LightningElement) {
    @api recordId;
    @track recordName;
    @track noOfAttachments;
    @track docId;

    connectedCallback() {
        getDocumentShare({ quoteId: this.recordId })
            .then(result => {
                console.log('this.result connected callback--'+JSON.stringify(result));
                this.recordName = result.name;
                this.noOfAttachments = result.noOfAttachment;
                this.docId = result.recordId;
            })
    }

    navigateToRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.docId,
                objectApiName: 'Pricing_Document__c',
                actionName: 'view'
            }
        });
    }
}