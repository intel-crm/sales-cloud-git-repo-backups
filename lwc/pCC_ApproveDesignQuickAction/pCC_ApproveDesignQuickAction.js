import { LightningElement, api, wire } from 'lwc';
import approveQuicAction from '@salesforce/apex/PCC_QuickActionController.approveQuickAction';
import { CurrentPageReference } from 'lightning/navigation';


export default class PCC_ApproveDesignQuickAction extends LightningElement {

    // get the record id for the current page
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    // call server to get data
    @api recordId;
    connectedCallback() {
        console.log('Record Id -->', this.recordId);
        approveQuicAction({ recordId: this.recordId }).then(result => {
            console.log('result -->', result.registrationIsApproved);
        }).catch(error => {
            console.log('Error -->', error);
        });
    }


}