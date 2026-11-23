import { LightningElement, track, api } from 'lwc';
//import Core_IPS_BES_IPassDataSync from '@salesforce/apex/Core_IPS_BES_IPassDataSync';
import { getRecord } from 'lightning/uiRecordApi';
export default class Dynamic_Sync_LWC extends LightningElement {
    @api recordId;
    connectedCallback(){
        console.log(this.recordId);
    } 
}