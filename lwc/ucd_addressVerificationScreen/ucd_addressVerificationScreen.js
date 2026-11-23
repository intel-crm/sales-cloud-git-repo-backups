import { LightningElement, api } from 'lwc';

export default class Ucd_addressVerificationScreen extends LightningElement {
    @api invoke(){
        console.log('Action called');
    }
}