import { LightningElement,api,wire,track } from 'lwc';

export default class UcdAcctSearchMasterLayout extends LightningElement {
    acctDetails = {};
    acctSearchStep = true;
    acctCreateStep = false;

    acctSearchNextClickHandler(event) {
        this.acctDetails = event.detail;
        this.acctCreateStep = true;
        this.acctSearchStep = false;
    }

    acctCreateBackClickHandler(event) {
        console.log('insode prev click');
        this.acctDetails = event.detail;
        this.acctCreateStep = false;
        this.acctSearchStep = true;
    }
}