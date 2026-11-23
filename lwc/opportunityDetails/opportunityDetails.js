import { LightningElement,api } from 'lwc';

export default class OpportunityDetails extends LightningElement {
    @api recordId;
    @api objectApiName;

    constructor(){
        console.log('Record Id'+this.recordId);
        console.log('Object Api Name'+this.objectApiName);
    }
}