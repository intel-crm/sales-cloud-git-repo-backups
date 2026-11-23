import { LightningElement, track, wire } from 'lwc';
import searchUsers from '@salesforce/apex/CRM_UserPillContainerController.searchUsers';

export default class UserPillContainer extends LightningElement {
    @track items = [];
    @track userOptions = [];
    searchTerm = '';

    @wire(searchUsers, { searchTerm: '$searchTerm' })
    wiredUsers({ error, data }) {
        if (data) {
            // Filter out users that are already selected
            const selectedUserIds = new Set(this.items.map(item => item.name));
            this.userOptions = data
                .filter(user => !selectedUserIds.has(user.Id))
                .map(user => ({
                    label: user.Name,
                    value: user.Id
                }));
        } else if (error) {
            console.error('Error fetching users:', error);
        }
    }

    handleInputChange(event) {
        this.searchTerm = event.target.value;
    }

    handleUserSelect(event) {
        const userId = event.currentTarget.dataset.id;
        const user = this.userOptions.find(user => user.value === userId);
        if (user) {
            const newItem = {
                label: user.label,
                name: user.value
            };
            this.items = [...this.items, newItem];
            // Clear the search term to refresh the options
            this.searchTerm = '';
            this.userOptions = [];
        }
    }

    handleItemRemove(event) {
        const name = event.detail.item.name;
        alert(name + ' pill was removed!');
        this.items = this.items.filter(item => item.name !== name);
    }
}