import { LightningElement, api, track, wire } from 'lwc';
import getUsers from '@salesforce/apex/CRM_MultiUserSelectionController.getUsers';
import saveUserIds from '@salesforce/apex/CRM_MultiUserSelectionController.saveUserIds';

export default class CRM_MultiUserSelection extends LightningElement {
    @api recordId; // The ID of the Executive_Meeting_Brief__c record
    @track userOptions = [];
    @track selectedUsers = [];

    @wire(getUsers)
    wiredUsers({ error, data }) {
        if (data) {
            this.userOptions = data.map(user => ({
                label: user.Name,
                value: user.Id
            }));
        } else if (error) {
            console.error('Error fetching users:', error);
        }
    }

    handleUserChange(event) {
        this.selectedUsers = event.detail.value;
    }

    handleSave() {
        saveUserIds({ 
            recordId: this.recordId, 
            userIds: this.selectedUsers.join(',') // Convert array to comma-separated string
        })
        .then(() => {
            // Handle success (e.g., show a toast message)
            console.log('Users saved successfully');
        })
        .catch(error => {
            // Handle error
            console.error('Error saving users:', error);
        });
    }
}