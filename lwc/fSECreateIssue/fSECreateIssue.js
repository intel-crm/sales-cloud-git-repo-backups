import { LightningElement ,track ,api } from 'lwc';
import testFSEUser from '@salesforce/apex/QuoteBusinessLogic.testFSEUser';

export default class FSECreateIssue extends LightningElement {
    @api recordId;
    @track Records = [] ;
    connectedCallback() {
        testFSEUser()
        .then(result => {
            console.log('FSE--->' +JSON.stringify(result));
            this.Records.push(JSON.stringify(result));
            //this.Records = result;
            console.log('FSE12--->' +this.Records);
        })
        .catch(error => {
            console.log('Error --> ' + JSON.stringify(error));

        });
    }
}