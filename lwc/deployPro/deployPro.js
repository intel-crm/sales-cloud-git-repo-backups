import { LightningElement, track, wire } from 'lwc';
import getUsers from '@salesforce/apex/deploymentChanges.getUsers';
import getAuditTrail from '@salesforce/apex/deploymentChanges.getAuditTrail';

export default class DeploymentChanges extends LightningElement {
    @track userOptions = [];
    @track selectedUserId;
    @track showTable = false;
    @track auditTrailData = [];
    columns = [
        { label: 'File Name', fieldName: 'fileName' },
        { label: 'Edited Date', fieldName: 'createdDate', type: 'date' },
        { label: 'Description', fieldName: 'description' }
    ];

    @wire(getUsers)
    wiredUsers({ error, data }) {
        if (data) {
            this.userOptions = data.map(user => ({
                label: user.Name,
                value: user.Id
            }));
        } else if (error) {
            console.error(error);
        }
    }

    handleUserChange(event) {
        this.selectedUserId = event.detail.value;
    }

    handleDownload() {
        if (this.selectedUserId) {
            getAuditTrail({ userId: this.selectedUserId })
                .then(data => {
                    this.auditTrailData = data;
                    this.showTable = true;
                })
                .catch(error => {
                    console.error(error);
                });
        } else {
            // Optionally handle case where no user is selected
            alert('Please select a user.');
        }
    }
}