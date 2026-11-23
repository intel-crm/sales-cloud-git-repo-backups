import { LightningElement, wire } from 'lwc';
import callDocparserAPI from '@salesforce/apex/DocparserAPIHandler.callDocparserAPI';

export default class MyLwcComponent extends LightningElement {
    // Handle button click event
    handleButtonClick() {
        doSomething()
            .then(result => {
                // Handle success
                console.log('Apex method called successfully:', result);
            })
            .catch(error => {
                // Handle error
                console.error('Error calling Apex method:', error);
            });
    }
}