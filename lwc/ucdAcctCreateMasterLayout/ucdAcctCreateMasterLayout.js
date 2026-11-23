import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

export default class UcdAcctCreateMasterLayout extends LightningElement {
    acctDetails = {};
    stepnum = "step-1";

    acctCreateStep = true;
    acctDuplicateInfoStep = false;
    acctConfirmationStep = false;

    acctCreateNextClickHandler(event) {
        this.acctDetails = event.detail;
        this.stepnum = "step-2";
        this.acctDuplicateInfoStep = true;
        this.acctCreateStep = false;
        this.acctFinalSubmnStep = false;
    }

    acctDupInfoPrevClick(event) {
        this.stepnum = "step-1";
        this.acctDuplicateInfoStep = false;
        this.acctCreateStep = true;
        this.acctConfirmationStep = false;
    }
    acctDupInfoNextClick(event) {
        this.stepnum = "step-3";
        this.acctDuplicateInfoStep = false;
        this.acctCreateStep = false;
        this.acctFinalSubmnStep = true;
    }
    acctConfPrevClick(event) {
        this.stepnum = "step-2";
        this.acctDuplicateInfoStep = true;
        this.acctCreateStep = false;
        this.acctFinalSubmnStep = false;
    }
}