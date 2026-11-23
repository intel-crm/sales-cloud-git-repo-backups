import { LightningElement,api,wire } from 'lwc';
//import CASE_RECORDTYPE_FIELD from '@salesforce/schema/Case.RecordTypeId';
import PRIORITY from '@salesforce/schema/Case.Status';
import PRIORITYREASON from '@salesforce/schema/Case.Core_Sub_Status__c';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class TestCaseLwc extends LightningElement {
    @api recordId;
    siteURL;
   /* recordType;
    @wire(getRecord, { recordId: '$recordId', fields: CASE_RECORDTYPE_FIELD })
    wiredRecord({ data, error }) {
        if (data) {
            this.recordType = data.fields.RecordTypeId.value;
            this.error = undefined;
        } else if (error) {
          this.error = error;
        }
    }*/
    
    
    fields = [PRIORITY,PRIORITYREASON];
    

   /* handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        if(fields.Status == 'Closed'){
            this.showErrorToast();
            
        }else{
        this.template.querySelector('lightning-record-form').submit(fields);
        //window.location.reload();
        }
    }*/

showErrorToast() {
    const evt = new ShowToastEvent({
        title: 'Error',
        message: 'You can not save case as Closed ',
        variant: 'error',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}

}