import { LightningElement, api } from 'lwc';

import updateActivityVisibility from '@salesforce/apex/AccountActivityVisibilityController.updateActivityVisibility';

export default class AccountActivityVisibilityUpdater
    extends LightningElement {

    @api recordId;

    connectedCallback() {

        if(this.recordId){

            updateActivityVisibility({
                accountId: this.recordId
            })
            .catch(error => {
                console.error(error);
            });
        }
    }
}