//import { LightningElement, track, api } from 'lwc'; import searchUsers from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchUsers'; export default class CRMUserPillContainer extends LightningElement { @track searchTerm = ''; @track filteredUsers = []; @track selectedUsers = []; @track showDropdown = false; handleSearchChange(event) { this.searchTerm = event.target.value; if (this.searchTerm.length > 2) { searchUsers({ searchTerm: this.searchTerm }).then(result => { this.filteredUsers = result; this.showDropdown = true; }).catch(error => { console.error('Error searching users:', error); }); } else { this.showDropdown = false; } } handleUserSelect(event) { const userId = event.currentTarget.dataset.id; const user = this.filteredUsers.find(u => u.Id === userId); if (user && !this.selectedUsers.some(u => u.Id === userId)) { this.selectedUsers = [...this.selectedUsers, user]; this.dispatchEvent(new CustomEvent('userselect', { detail: { selectedUsers: this.selectedUsers } })); } this.showDropdown = false; } handleRemoveUser(event) { const userId = event.currentTarget.dataset.id; this.selectedUsers = this.selectedUsers.filter(user => user.Id !== userId); this.dispatchEvent(new CustomEvent('userselect', { detail: { selectedUsers: this.selectedUsers } })); } }

import { LightningElement, track, api } from 'lwc';
import searchUsers from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchUsers';

export default class CRMUserPillContainer extends LightningElement {
    @track searchTerm = '';
    @track filteredUsers = [];
    @track selectedUsers = [];
    @track showDropdown = false;

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
        debugger;
        const userId = event.currentTarget.dataset.id;
        const user = this.filteredUsers.find(u => u.Id === userId);
        if (user && !this.selectedUsers.some(u => u.Id === userId)) {
            this.selectedUsers = [...this.selectedUsers, user];
            this.dispatchEvent(new CustomEvent('userselect', { detail: { selectedUsers: this.selectedUsers } }));
            this.searchTerm = '';
        }
        this.showDropdown = false;
    }

    handleRemoveUser(event) {
        const userId = event.currentTarget.dataset.id;
        this.selectedUsers = this.selectedUsers.filter(user => user.Id !== userId);
        this.dispatchEvent(new CustomEvent('userselect', { detail: { selectedUsers: this.selectedUsers } }));
    }
}