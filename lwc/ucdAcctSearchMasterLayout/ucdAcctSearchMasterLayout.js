import { LightningElement,api,wire,track } from 'lwc';

export default class UcdAcctSearchMasterLayout extends LightningElement {
    acctDetails = {};
    acctSearchStep = true;
    acctCreateStep = false;

    acctCreateBackClickHandler(event) {
        console.log('inside prev click');
        this.acctDetails = event.detail;
        this.acctCreateStep = false;
        this.acctSearchStep = true;
    }
}