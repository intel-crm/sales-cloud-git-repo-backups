import { LightningElement, wire, track } from 'lwc';
import getLogs from '@salesforce/apex/AccountTransferLogPocController.getLogs';

const columns = [
    { label: 'Name', fieldName: 'Name', type: 'url',
    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank'} },
    { label: 'Budget', fieldName: 'Core_MDF_Partner_Marketing_Budget__c' }
];

export default class AccountTransferLogPOC extends LightningElement {
    columns = columns;
    @track logs;
    @track error;

    @wire(getLogs)
    wiredLogs( { error, data } ) {

        if ( data ) {

            let tempRecs = [];
            data.forEach( ( record ) => {
                let tempRec = Object.assign( {}, record );  
                tempRec.Name = '/' + tempRec.Id;
                tempRecs.push( tempRec );
                
            });
            this.logs = tempRecs;
            this.error = undefined;
            console.log ('logs:- '+logs);

        }

        else if ( error ) {

            this.error = error;
            this.logs = undefined;

        }
}
}