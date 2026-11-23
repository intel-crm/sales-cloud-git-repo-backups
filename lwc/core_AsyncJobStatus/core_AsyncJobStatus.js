import { LightningElement, wire, track } from 'lwc';
import getAsyncJobs from '@salesforce/apex/Core_AsyncJobStatus.getAsyncJobs';
import { refreshApex } from '@salesforce/apex';

const COLUMNS = [
    { label: 'Class Name', fieldName: 'ClassName', type: 'text' },
    { label: 'Status', fieldName: 'Status', type: 'text', 
        cellAttributes: { class: { fieldName: 'statusColor' } } 
    },
    { label: 'Type', fieldName: 'JobType', type: 'text' },
    { label: 'Items Processed', fieldName: 'JobItemsProcessed', type: 'number' },
    { label: 'Errors', fieldName: 'NumberOfErrors', type: 'number' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', 
        typeAttributes: { year: 'numeric', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' } 
    }
];

export default class Core_AsyncJobStatus extends LightningElement {
    @track jobs = [];
    columns = COLUMNS;
    
    // Filter properties
    statusFilter = '';
    classFilter = '';
    dateFilter = '';
    wiredJobsResult;

    statusOptions = [
        { label: '--All--', value: '' },
        { label: 'Completed', value: 'Completed' },
        { label: 'Failed', value: 'Failed' },
        { label: 'Processing', value: 'Processing' },
        { label: 'Queued', value: 'Queued' }
    ];

    @wire(getAsyncJobs, { 
        status: '$statusFilter', 
        className: '$classFilter', 
        createdDate: '$dateFilter' 
    })
    wiredJobs(result) {
        this.wiredJobsResult = result;
        if (result.data) {
            // Flatten the data to show ApexClass.Name and add CSS classes
            this.jobs = result.data.map(job => ({
                ...job,
                ClassName: job.ApexClass ? job.ApexClass.Name : 'N/A',
                statusColor: job.Status === 'Failed' ? 'slds-text-color_error' : 
                             job.Status === 'Completed' ? 'slds-text-color_success' : ''
            }));
        }
    }

    handleStatusChange(event) { this.statusFilter = event.detail.value; }
    handleClassChange(event) { this.classFilter = event.detail.value; }
    handleDateChange(event) { this.dateFilter = event.detail.value; }

    handleRefresh() {
        return refreshApex(this.wiredJobsResult);
    }
}