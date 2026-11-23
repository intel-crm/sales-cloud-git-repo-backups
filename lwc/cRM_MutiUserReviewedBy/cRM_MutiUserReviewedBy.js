import { LightningElement, track, api } from 'lwc';
import searchUsers from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchUsers';
import updateMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.updateMeetingBriefData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExecutiveMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getExecutiveMeetingBriefData';
import avatarUrl from '@salesforce/resourceUrl/avatarImg';
import { NavigationMixin } from 'lightning/navigation';
import getUserDetails from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getUserDetails';

export default class cRM_MutiUserReviewedBy extends NavigationMixin(LightningElement) {
    @api recordId;
    @track searchTerm5 = '';
    @track showDropdown5 = false;
    @track filteredUsers5 = [];
    @track selectedUsers5 = [];
    @track crmReviewedByNames = '';
    @track isEditMode = false;
    @track avatarImg = avatarUrl;
    @track showHoverCard = false;
    @track hoverUser = {};
    @track hoverCardStyle = '';

    connectedCallback() {
        this.fetchCurrentData();
    }

    fetchCurrentData() {
        getExecutiveMeetingBriefData({ executiveMeetingId: this.recordId })
            .then(result => {
                this.executiveBriefData = result;
                console.log('Reviewed by executiveBriefData is:' + JSON.stringify(this.executiveBriefData));
                this.error = undefined;
                this.populateFormFields(this.executiveBriefData);
            })
            .catch(error => {
                this.error = error;
                this.executiveBriefData = undefined;
                console.log('Oops error:' + JSON.stringify(this.error));
            });
    }

    populateFormFields(data) {
    this.crmReviewedByNames = data.CRM_Reviewed_By_Names__c;
    this.crmReviewedBy = data.CRM_ReviewedBy__c;

    if (!this.crmReviewedByNames) {
        this.isEditMode = true;
    }

    this.selectedUsers5 = this.parseReviewedBy(this.crmReviewedByNames, this.crmReviewedBy);
    console.log('Inside crmReviewedName:', this.crmReviewedByNames);
    }

    parseReviewedBy(crmReviewedByNames, crmReviewedBy) {
        const namesArray = crmReviewedByNames ? crmReviewedByNames.split(';') : [];
        const idsArray = crmReviewedBy ? crmReviewedBy.split(';') : [];

        const userList = [];
        const maxLength = Math.max(namesArray.length, idsArray.length);

        for (let i = 0; i < maxLength; i++) {
            const user = {
                Name: namesArray[i] ? namesArray[i].trim() : '',
                Id: idsArray[i] ? idsArray[i].trim() : '',
                Email: '', // Assuming you have email data
                Phone: '', // Assuming you have phone data
                userOptions: [],
                isEditing: false,
                showHoverCard: false,
                userDetails: {}
            };
            userList.push(user);
        }
        return userList;
    }
    handleSearchChange5(event) {
        this.searchTerm5 = event.target.value;
        if (this.searchTerm5.length > 2) {
            searchUsers({ searchTerm: this.searchTerm5 })
                .then(result => {
                    this.filteredUsers5 = result;
                    console.log('filteredUsers5 :', this.filteredUsers5);
                    this.showDropdown5 = true;
                })
                .catch(error => {
                    console.error('Error searching users:', error);
                });
        } else {
            this.showDropdown5 = false;
        }
    }

    handleUserSelect5(event) {
        const userId = event.currentTarget.dataset.id;
        const name = event.currentTarget.dataset.name;
        const user = this.filteredUsers5.find(u => u.Id === userId);
        if (user && !this.selectedUsers5.some(u => u.Id === userId && u.Name === name)) {
            this.selectedUsers5 = [...this.selectedUsers5, user];
            this.crmReviewedBy = this.selectedUsers5.map(user => user.Id).join(';');
            console.log('REVIEWBY USERID:'+this.crmReviewedBy);
            this.crmReviewedByNames = this.selectedUsers5.map(user => user.Name).join('; ');
             console.log('REVIEWBY NAME:'+this.crmReviewedByNames);
            this.searchTerm5 = '';
        }
        this.showDropdown5 = false;
    }

    handleRemoveUser5(event) {
        const userId = event.currentTarget.dataset.id;
        this.selectedUsers5 = this.selectedUsers5.filter(user => user.Id !== userId);
        this.crmReviewedByNames = this.selectedUsers5.map(user => user.Name).join('; ');
        console.log('REMOVE USER:' + JSON.stringify(this.crmReviewedByNames));
    }

    handleSave(event) {
        const meetingBriefData = {
            CRM_Reviewed_By_Names__c: this.crmReviewedByNames,
            CRM_ReviewedBy__c : this.crmReviewedBy
        };
        console.log('SAVE REVIEWED BY:' + this.crmReviewedByNames);
        updateMeetingBriefData({ meetingBriefData: meetingBriefData, executiveMeetingId: this.recordId, fieldUpdated: 'ReviewedBy' })
            .then(result => {
                console.log('SAVE RESULT IS:' + result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Executive Meeting Brief updated successfully',
                        variant: 'success'
                    })
                );
                this.isEditMode = false;
            })
            .catch(error => {
                console.log('SAVE RESULT ERROR IS:' + error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    toggleEditMode() {
        this.isEditMode = !this.isEditMode;
    }

    handleNavigateToUser(event) {
        const userId = event.currentTarget.dataset.id;
        console.log('REVIEWED BY USER ID:' + userId);
        const user = this.selectedUsers5.find(u => u.Id === userId);
        console.log('REVIEWED BY USER:' + user);
        if (userId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: userId,
                    objectApiName: 'User',
                    actionName: 'view'
                }
            });
        }
    }

    /*handleMouseOver(event) {
        const userId = event.currentTarget.dataset.id;
        this.hoverUser = this.selectedUsers5.find(user => user.Id === userId);
        this.showHoverCard = true;

        // Get the bounding rectangle of the hovered element
        const rect = event.currentTarget.getBoundingClientRect();
        this.hoverCardStyle = `top: ${rect.top - 100}px; left: ${rect.left}px; position: absolute;`;
    }*/
    handleMouseOver(event) {
        const userId = event.currentTarget.dataset.id;
          const user = this.selectedUsers5.find(u => u.Id === userId);
          console.log('REVIEWEDBY HOVER USERID:'+userId);
        if (userId) {
            getUserDetails({ userId: userId})
                .then(user=>{
                    console.log('REVIEWEDBY INSIDE HOVER IF:'+JSON.stringify(user));
                    this.hoverUser = user;
                    this.showHoverCard= true;
                })
                .catch(error => {
                    console.error('Error fetching user details:', error);
                });
        }
    }
    handleMouseOut() {
        this.showHoverCard = false;
    }
}