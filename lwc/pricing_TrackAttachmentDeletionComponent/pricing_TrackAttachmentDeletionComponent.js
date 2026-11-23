import { LightningElement,api,wire,track } from 'lwc';

import getDeletionLogs from '@salesforce/apex/Pricing_TrackAttachmentDeletionHandler.getDeletetedLogs';
export default class Pricing_TrackAttachmentDeletionComponent extends LightningElement {
    @api recordId; // Quote record ID passed from parent

    @track deletionLogs;

    @wire(getDeletionLogs, { quoteId: '$recordId' })
    wiredDeletionLogs({ error, data }) {
        if (data) {
            this.deletionLogs = data;
        } else if (error) {
            console.error('Error retrieving deletion logs:', error);
            this.deletionLogs = null;
        }
    }
}