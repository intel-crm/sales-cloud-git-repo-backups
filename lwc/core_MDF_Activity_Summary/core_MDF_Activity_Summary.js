import { LightningElement, api, track } from 'lwc';
import getRecordDetails from '@salesforce/apex/Core_MDF_Activity_Summary.getActivityDetails';

export default class Core_MDF_Activity_Summary extends LightningElement {
    @api recordId;
    @track activityDetails;
    error;

    connectedCallback() {
        this.getActivityDetails();
    }

    getActivityDetails() {

        getRecordDetails({ recordId : this.recordId })
        .then(result => {
            this.activityDetails = result;
            console.log(JSON.stringify(this.activityDetails));
        })
        .catch(error => {
            this.error = error;
        });
    }
}