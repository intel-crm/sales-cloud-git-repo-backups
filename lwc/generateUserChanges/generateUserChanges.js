import { LightningElement, track } from 'lwc';
import getUserAuditTrail from '@salesforce/apex/generateUserChanges.getUserAuditTrail';

export default class GenerateUserChanges extends LightningElement {
    @track username = '';
    @track auditTrails;
    @track error;

    columns = [
        { label: 'Action', fieldName: 'action'},
        { label: 'Section', fieldName: 'section'},
        { label: 'Display', fieldName: 'display'},
        { label: 'Date', fieldName: 'createdDate', type: 'date'},
        { label: 'User', fieldName: 'createdBy'}
    ];

    handleUsernameChange(event){
        this.username = event.target.value;
    }

    handleSearch(){
        getUserAuditTrail({ username: this.username })
            .then(result => {
                const uniqueData = this.getUniqueRecord(result, 'section');
                this.auditTrails = uniqueData;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error.body.message;
                this.auditTrails = undefined;
            });
    }

    getUniqueRecord(data, field){
        const uniqueValues = new Set();
        return data.filter(item => {
            if(!uniqueValues.has(item[field])) {
                uniqueValues.add(item[field]);
                return true;
            }
            return false;
        });
    }
    
    handleDownload(){
        if(this.auditTrails && this.auditTrails.length > 0){
            this.exportToCSV();
        }
        else{
            this.error = 'No data available to download.';
        }
    }

    exportToCSV(){
        const columnHeaders = ['Action', 'Section', 'Display', 'Date', 'User'];
        const jsonKeys = ['action', 'section', 'display', 'createdDate', 'createdBy'];

        const csvString = [
            columnHeaders.join(','),
            ...this.auditTrails.map(row => jsonKeys.map(key => row[key]).join(','))
        ].join('\n');

        const hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        hiddenElement.target = '_self';
        hiddenElement.download = 'GeneratedUserChanges.csv';
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
        document.body.removeChild(hiddenElement);
    }

}