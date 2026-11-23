import { LightningElement, track, api } from 'lwc';

const columns = [
    { label: 'Date', fieldName: 'CreatedDate', hideDefaultActions :true},
    { label: 'Assigned To', fieldName: 'OriginalActorName',hideDefaultActions :true},
    { label: 'Assigned To Alias	', fieldName: 'OriginalActorAlias',hideDefaultActions :true,},
    { label: 'Assigned To Last Name	', fieldName: 'OriginalActorLastName',hideDefaultActions :true},
    { label: 'Status', fieldName: 'StepStatus',hideDefaultActions :true},
    { label: 'Comments', fieldName: 'Comments', hideDefaultActions :true},
    { label: 'Actual Approver', fieldName: 'ActorName',hideDefaultActions :true},
    { label: 'Actual Approver Alias', fieldName: 'ActorAlias',hideDefaultActions :true},
    { label: 'Actual Approver Last Name', fieldName: 'ActorLastName',hideDefaultActions :true,}	
  ];

export default class Core_MDF_ViewAllApprovalHistory extends LightningElement {
    @track columns = columns;
    @api allData;
}