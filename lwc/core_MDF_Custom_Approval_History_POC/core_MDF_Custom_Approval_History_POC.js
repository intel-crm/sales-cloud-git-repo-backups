import {LightningElement, api, track} from 'lwc';
import process from '@salesforce/apex/Core_MDF_Custom_Approval_Hist.process';
import getProcessItemData from '@salesforce/apex/Core_MDF_Custom_Approval_Hist.getProcessItemData';

export default class Core_MDF_Custom_Approval_History_POC extends LightningElement {
    

    @api actorId;
    @api contextObjectType;
    @api fieldNames; //field names provided by called to be rendered as columns
    @api disableReassignment;
    rowData;
    columns;
    fieldDescribes;
    columns = [
        { label: 'Step Name', fieldName: 'name' },
        { label: 'Date', fieldName: 'Date', type: 'date' },
        { label: 'Status', fieldName: 'Status', type: 'name' },
        { label: 'Assigned To Approver', fieldName: 'Approver', type: 'name' },
        { label: 'Actual Approver', fieldName: 'Actual Approver', type: 'name' },
    ];
   

}