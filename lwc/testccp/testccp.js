import { LightningElement,wire,track } from 'lwc';
import getSubmittedRecords from '@salesforce/apex/Core_MDF_Approval_Request.getSubmittedRecords';
 
export default class Core_MDF_Items_To_Approve_POC extends LightningElement {
   
    @track columns = [{
        label: 'Id',
        fieldName: 'Id',
        type: 'Id',
        sortable: true
    },
    {
        label: 'TargetObjectId',
        fieldName: 'TargetObjectId',
        type: 'Id',
        sortable: true
    },
    {
        label: 'TargetObject.Name',
        fieldName: 'Name',
        type: 'text',
        sortable: true
    }
    
];
 
@track error;
@track recordsToRender ;
@wire(getSubmittedRecords)
wiredAccounts({
    error,
    data
}) {
    if (data) {
        this.recordsToRender = data;
    } else if (error) {
        this.error = error;
    }
}
}