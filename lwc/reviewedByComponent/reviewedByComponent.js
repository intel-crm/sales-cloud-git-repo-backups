import { LightningElement, api, track, wire } from 'lwc';
import searchUsers from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchUsers';
import getReviewedByData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getExecutiveMeetingBriefData';

export default class ReviewedByComponent extends LightningElement {
    @api recordId; // Accept recordId as a public property
    @api isEditMode = false;
    @track searchTerm = '';
    @track filteredUsers = [];
    @track selectedUsers = [];
    @track showDropdown = false;

    @wire(getReviewedByData, { recordId: '$recordId' })
    wiredReviewedByData({ error, data }) {
        if (data) {
            this.selectedUsers = data.split(';').map(id => ({ Id: id, Name: id }));
        } else if (error) {
            console.error('Error fetching reviewed by data:', error);
        }
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        if (this.searchTerm.length > 2) {
            searchUsers({ searchTerm: this.searchTerm })
                .then(result => {
                    this.filteredUsers = result;
                    this.showDropdown = true;
                })
                .catch(error => {
                    console.error('Error searching users:', error);
                });
        } else {
            this.showDropdown = false;
        }
    }

    handleUserSelect(event) {
        const userId = event.currentTarget.dataset.id;
        const name = event.currentTarget.dataset.name;
        const user = this.filteredUsers.find(u => u.Id === userId);
        if (user && !this.selectedUsers.some(u => u.Id === userId)) {
            this.selectedUsers = [...this.selectedUsers, user];
            this.searchTerm = '';
        }
        this.showDropdown = false;
    }

    handleRemoveUser(event) {
        const userId = event.currentTarget.dataset.id;
        this.selectedUsers = this.selectedUsers.filter(user => user.Id !== userId);
    }
}