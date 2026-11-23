import { LightningElement,api,track,wire } from 'lwc';
import getApproverList from '@salesforce/apex/PSG_ApprovalBusinessLogic.getApprovalList';

export default class Psg_ApprovalListView extends LightningElement {
    //Property for enable/disable spinner
    @track spinnerOn=false;
    //Property to store Approvel list data
    @track quoteLineList = [];
    @track sortBy;
    @track sortDirection;
    //Datatable columns
    @track columns = [
        { 
            label: 'Quote',
            fieldName: 'QuoteLink',
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'QuoteName'
                },
                target: '_self'
            },
            sortable: true
        },
        { 
            label: 'Assigned To',
            fieldName: 'AssignedToName',
            type: 'text',
            sortable: true
        },
        { 
            label: 'Approver',
            fieldName: 'ApproverName',
            type: 'text',
            sortable: true
        },

        {label:'Status',fieldName:'sbaa__Status__c',editable: false,sortable: true},
        {label:'Quote Type',fieldName:'core_cpq_quote_type_nm__c',editable: false,sortable: true},
        {label:'End Customer',fieldName:'core_cpq_end_customer_disty_view_nm__c',editable: false,sortable: true},
        {label:'Quote Name',fieldName:'core_cpq_name_nm__c',editable: false,sortable: true},
        {label:'Quote Submitted Date',fieldName:'SubmittedDate__c',editable: false,sortable: true},
        {label:'Quote Submitter Name',fieldName:'QuoteSubmitterName',type: 'text',sortable: true}
    ];
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldName, direction) {
        let parseData = JSON.parse(JSON.stringify(this.quoteLineList));
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
        this.quoteLineList = parseData;
    }
    //Connected Callback which will execute on component load.
    async connectedCallback(){
        this.spinnerOn=true;
        this.getApprovalRecords();
    }

    //Function get called onclick of Refresh button
    onRefreshClick(){
        this.spinnerOn=true;
        this.getApprovalRecords();
    }

    //Function that calls getApprovalList apex method and stores the return result
    getApprovalRecords(){
        getApproverList()
        .then(result => {
            this.quoteLineList=JSON.parse(JSON.stringify(result));
            this.quoteLineList.forEach(element => {
                if(element.sbaa__Approver__r != undefined){
                    element.ApproverName= element.sbaa__Approver__r.Name;
                }
                if(element.Quote__c != undefined){
                    element.QuoteLink='/'+ element.Quote__c;
                }
                if(element.Quote__r != undefined){
                    element.QuoteName= element.Quote__r.Name;
                }
                if(element.sbaa__AssignedTo__r != undefined){
                    element.AssignedToName= element.sbaa__AssignedTo__r.Name;
                }
                if(element.Quote__r.core_cpq_quote_type_nm__c != undefined){
                    element.core_cpq_quote_type_nm__c= element.Quote__r.core_cpq_quote_type_nm__c;
                }
                if(element.Quote__r.core_cpq_end_customer_disty_view_nm__c != undefined){
                    element.core_cpq_end_customer_disty_view_nm__c= element.Quote__r.core_cpq_end_customer_disty_view_nm__c;
                }
                if(element.Quote__r.core_cpq_name_nm__c != undefined){
                    element.core_cpq_name_nm__c= element.Quote__r.core_cpq_name_nm__c;
                }
                if(element.Quote__r.SubmittedDate__c != undefined){
                    element.SubmittedDate__c= element.Quote__r.SubmittedDate__c;
                }
                if(element.Quote__r.SubmittedUser__r!= undefined){
                    element.QuoteSubmitterName= element.Quote__r.SubmittedUser__r.Name;
                }
            });
            this.spinnerOn=false;
        })
        .catch(error => {
            console.log(error);
            alert('error while loading approval list.');
            this.spinnerOn=false;
        });
    }

    get dataPresent(){
        return this.quoteLineList.length>0;
    }
}