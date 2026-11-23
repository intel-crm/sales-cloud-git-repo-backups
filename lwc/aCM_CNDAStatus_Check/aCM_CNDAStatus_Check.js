import { LightningElement,api } from 'lwc';
import getCNDAStatus from '@salesforce/apex/ACM_CNDA_SearchAndSelect.FetchCNDAStatus';

export default class ACM_CNDAStatus_Check extends LightningElement {
    @api recordId; // Record ID of the page

    connectedCallback() {
        this.invokeApiCall();
    }

    invokeApiCall() {
        console.log('ACM_CNDAStatus_Check - Record ID : '+this.recordId);
        getCNDAStatus({ AcctID: this.recordId })
            .then(() => {
                console.log('API call successful');
            })
            .catch(error => {
                console.error('API call failed:', error.body.message);
            });
    }


}