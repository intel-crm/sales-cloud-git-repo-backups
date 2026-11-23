import { LightningElement,api } from 'lwc';
import CURRENTUSERID from '@salesforce/user/Id';

export default class currentRecordId extends LightningElement {

 
    userId = CURRENTUSERID;
 
    @api recordId;
    @api objectApiName;
 
}