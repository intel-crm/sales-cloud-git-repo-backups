import { LightningElement,api,track,wire } from 'lwc';
import getPRList from '@salesforce/apex/PSG_PortalRequestController.GetPRList';

export default class Psg_PortalRequestListView extends LightningElement {
//Property for enable/disable spinner
@track spinnerOn=false;
//Property to store PR list data
@track PRList = [];
@track sortBy;
@track sortDirection;
//Datatable columns
@track columns = [
    { 
        label: 'PR #',
        fieldName: 'RequestNo',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            target: '_blank'
        },
        sortable: true
    },

    {label:'Status',fieldName:'core_cpq_Status__c',editable: false,sortable: true},
    {label:'Request Type',fieldName:'core_cpq_request_type__c',editable: false,sortable: true},
    {label:'Object',fieldName:'core_cpq_bot_Object_Name__c',editable: false,sortable: true},
    {label:'Approver',fieldName:'core_cpq_approver__c',editable: false,type: 'Text',sortable: true},
    {label:'Requestor',fieldName:'core_cpq_Requested_By__c',type: 'Text',sortable: true}
];
doSorting(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
}

sortData(fieldName, direction) {
    let parseData = JSON.parse(JSON.stringify(this.PRList));
    // Return the value stored in the field
    let keyValue = (a) => {
        return a[fieldName];
    };
    // cheking reverse direction
    let isReverse = direction === 'asc' ? 1: -1;
    // sorting data
    parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; // handling null values
        y = keyValue(y) ? keyValue(y) : '';
        // sorting values based on direction
        return isReverse * ((x > y) - (y > x));
    });
    this.PRList = parseData;
}
//Connected Callback which will execute on component load.
async connectedCallback(){
    this.spinnerOn=true;
    this.GetPRListRecord();
}

//Function get called onclick of Refresh button
onRefreshClick(){
    this.spinnerOn=true;
    this.GetPRListRecord();
}

//Function that calls getPRList apex method and stores the return result
GetPRListRecord(){
    getPRList()
    .then(result => {
        
        this.PRList=JSON.parse(JSON.stringify(result));
        this.PRList.forEach(element => {

            if(element.Id != undefined){
                element.RequestNo = '/'+ element.Id;
            }
            if(element.core_cpq_Requested_By__c != undefined){
                element.core_cpq_Requested_By__c=element.core_cpq_Requested_By__r.Name;
            }
            if(element.core_cpq_approver__c != undefined){
                element.core_cpq_approver__c=element.core_cpq_approver__r.Name;
            }
            
        });
        this.spinnerOn=false;
    })
    .catch(error => {
        console.log(error);
        alert('error while loading PRlist.');
        this.spinnerOn=false;
    });
}

get dataPresent(){
    return this.PRList.length>0;
}
}