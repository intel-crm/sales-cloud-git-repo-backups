import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import ACCOUNT_TYPE from '@salesforce/schema/Account.Type';
import ACCOUNT_OWNER from '@salesforce/schema/Account.OwnerId';

export default class TestLDS extends LightningElement {
@api recordId;

@api objectApiName;

fields = [ACCOUNT_NAME, ACCOUNT_TYPE, ACCOUNT_OWNER];

accName = ACCOUNT_NAME;
accType = ACCOUNT_TYPE;
accOwner = ACCOUNT_OWNER;

handleLoad(){
    alert('Show me');
}

handleSuccess(event) {



    this.toggleEdit = false;

    const evt = new ShowToastEvent({

        title: "Account Updated",

        message: "Record ID: " + event.detail.id,

        variant: "success"

    });

    this.dispatchEvent(evt);



}

}