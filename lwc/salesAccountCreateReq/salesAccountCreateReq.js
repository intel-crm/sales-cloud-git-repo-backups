import { LightningElement,track,wire } from 'lwc';
import getAcctRequests from "@salesforce/apex/UCD_GenericAcctSearch_SBR.getAcctRequests";

export default class SalesAccountCreateReq extends LightningElement {
    columns = [
        {label: 'Account Create Request Id', 
        fieldName: 'recordUrl', 
        type :'url',
        typeAttributes: {label: {fieldName: 'recId'},
        target: '_blank'}},
        { label: 'Account Name', fieldName: 'accName'},
        { label: 'Requested Account', type: 'reqAccName' },
        { label: 'Customer Process Engagement', fieldName: 'cpe'},
        { label: 'Country/Region', fieldName: 'country'},
        { label: 'Status', fieldName: 'status'},
        { label: 'Request Flow Status', fieldName: 'reqFlowStatus'},
        { label: 'Rejected Reason', fieldName: 'rejReason'},
        { label: 'Owner', fieldName: 'ownerName'},
        { label: 'CreatedDate', fieldName: 'createdDate',type:'Date'},
    ];

    @track showDataTable = true;
    selectedPickListValue = 'All';
    tableData;
    allData;
    @wire (getAcctRequests) accountRequest({data,error}){
        if (data) {
        console.log('-->',data); 
        this.allData = data;
        this.tableData = data;
        } else if (error) {
        console.log('-->',error);
        }
   }

    handleOnselect(event) {
        this.selectedPickListValue = event.detail.value;
        if(this.selectedPickListValue != 'All'){
            var updatedData = [];
            for(var i=0;i<this.allData.length;i++){
                if(this.allData[i].Request_Flow_Status__c == this.selectedPickListValue){
                    updatedData[i] = this.allData[i];
                }
            }
            console.log('updatedData--> ',updatedData);
            this.tableData =  updatedData;
        }else{
            this.tableData = this.allData;
        }
    }
}