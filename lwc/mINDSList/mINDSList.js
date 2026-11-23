/* eslint-disable no-console */
import {
    LightningElement,
    wire,
    track,
    api
} from 'lwc';

import fetchCaseData from '@salesforce/apex/Core_IPS_MAG_Response_Controller.fetchCaseData';

export default class MINDSList extends LightningElement {
    @api recordId;
    @track response;
    @track error;
    @track isDataAviable = false;
    @track columns = [{
            label: 'GEC Question',
            fieldName: 'question'

        },
        {
            label: 'GEC Answer',
            fieldName: 'answer'
        },
        {
            label: 'Submitted By',
            fieldName: 'lastModifiedBy'
        },
        {
            label: 'Created Date',
            fieldName: 'createdDate'
        },
    ];

    @wire(fetchCaseData, {
        recordID: '$recordId'
    })
    wiredCases({
        data,
        error
    }) {
        if (data) {
            this.response = data;
            this.isDataAviable = true;
            console.log("Data____________________________>>>>", this.response)
            this.errors = undefined;
        }
        if (error) {
            this.response = undefined;
            console.log("Error____________________________>>>>", error)
            this.errors = error;
        }
    }

}