import { LightningElement, api } from 'lwc';

export default class PRM_AdminRegistrationUCDDuplicateAcc extends LightningElement {

    @api redDetMap;

    connectedCallback() {
        console.log('Received Map Data in LWC:', JSON.stringify(this.redDetMap));
    }


}