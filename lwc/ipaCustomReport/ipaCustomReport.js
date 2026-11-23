import { LightningElement, wire, api, track} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getMPIList from '@salesforce/apex/PMP_CustomReportController.getCompanyRecords';

const columns = [{
        label: 'Partner Id',
        fieldName: 'PartnerURL',
        type: 'url',
        typeAttributes: {label: { fieldName: 'PartnerId' }, target: '_blank'}
    },
    {
        label: 'Partner Name',
        fieldName: 'Name',
        sortable: true
    },
    {
        label: 'Partner Tier',
        fieldName: 'PMP_IPA_Badge_Tier_Txt__c',
        sortable: true
    },
    {
        label: 'Partner Benefit',
        fieldName: 'PMP_Partner_Benefit_Type__c',
        sortable: true
    },
    {
        label: 'Partner Program',
        fieldName: 'PMP_Partner_Program_nm__c',
        sortable: true
    },
    {
        label: 'Partner Segment',
        fieldName: 'PMP_Partner_Segment_Nm__c',
        sortable: true
    },
    {
        label: 'Created Date',
        fieldName: 'CreatedDate',
        sortable: true
    },
    {
        label: 'Last Modified Date',
        fieldName: 'LastModifiedDate',
        sortable: true
    }
];

export default class IpaCustomReport extends LightningElement {
    @track error;
    @track data;
    @api sortedDirection = 'asc';
    @api sortedBy = 'CreatedDate';
    @api searchKey = '';
    recordSpinner = true;
    result;
    @api chartType;
    selectedPageSize = '10';
    @api selectedYear= '2022';
    @track allSelectedRows = [];
    @track page = 1; 
    @track items = []; 
    @track data = []; 
    @track columns; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize=10;
    @track totalRecountCount = 0;
    @track totalPage = 0;
    isPageChanged = false;
    initialLoad = true;
    columnHeader = ['ID', 'Name' , 'CreatedDate' ];
    

    @wire(getMPIList, {searchKey: '$searchKey', sortBy: '$sortedBy', sortDirection: '$sortedDirection' , year : '$selectedYear'})
    wiredAccounts({ error, data }) {
        if (data) {
            console.log('data--->'+data);
            this.recordSpinner = false;
            this.processRecords(data);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
    
    processRecords(data){
        var tempMPIList = [];  
        for (var i = 0; i < data.length; i++) {  
            let tempRecord = Object.assign({}, data[i]); //cloning object  
            tempRecord.PartnerId = tempRecord.Id;  
            tempRecord.PartnerURL = "/" + tempRecord.Id;  
            tempMPIList.push(tempRecord); 
         }
        this.items = tempMPIList;
            this.totalRecountCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            
            this.data = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;
            this.columns = columns;
    }
    //clicking on previous button this method will be called
    previousHandler() {
        this.isPageChanged = true;
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
          var selectedIds = [];
          for(var i=0; i<this.allSelectedRows.length;i++){
            selectedIds.push(this.allSelectedRows[i].Id);
          }
        this.template.querySelector(
            '[data-id="table"]'
          ).selectedRows = selectedIds;
    }

    //clicking on next button this method will be called
    nextHandler() {
        this.isPageChanged = true;
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }
          var selectedIds = [];
          for(var i=0; i<this.allSelectedRows.length;i++){
            selectedIds.push(this.allSelectedRows[i].Id);
          }
        this.template.querySelector(
            '[data-id="table"]'
          ).selectedRows = selectedIds;
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }    
    
    sortColumns( event ) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        return refreshApex(this.result);
        
    }

    handleKeyChange( event ) {
        this.searchKey = event.target.value;
        var data = [];
        for(var i=0; i<this.items.length;i++){
            if(this.items[i]!= undefined && this.items[i].Name.includes(this.searchKey)){
                data.push(this.items[i]);
            }
        }
        this.processRecords(data);
    }

    exportData(){
        // Prepare a html table
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';          
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        this.columnHeader.forEach(element => {            
            doc += '<th>'+ element +'</th>'           
        });
        doc += '</tr>';
        // Add the data rows
        this.items.forEach(record => {
            doc += '<tr>';
            doc += '<th>'+record.Id+'</th>'; 
            doc += '<th>'+record.Name+'</th>'; 
            doc += '<th>'+record.CreatedDate+'</th>';
            doc += '</tr>';
        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'MPI Data.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    get pageSizeOptions() {
        return [
            { label: '10', value: '10' },
            { label: '20', value: '20' },
            { label: '50', value: '50' },
        ];
    }
    get yearOptions() {
        return [
            { label: '2022', value: '2022' },
            { label: '2021', value: '2021' },
            { label: '2020', value: '2020' },
            { label: '2019', value: '2019' }
        ];
    }

    handleRowChange(event) {
        this.selectedPageSize = event.detail.value;
        this.pageSize = event.detail.value;
        this.processRecords(this.items);
    }

    handleYearChange(event) {
        this.recordSpinner = true;
        this.selectedYear = event.detail.value;
        this.processRecords(this.items);
    }
}