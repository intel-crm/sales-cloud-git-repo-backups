import { LightningElement, wire, api, track } from 'lwc';
import getExecutiveMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getExecutiveMeetingBriefData';
import updateMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.updateMeetingBriefData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchAttendees from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchAttendees';
import { NavigationMixin } from 'lightning/navigation';
import getUserDetails from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getUserDetails';
import avatarUrl from '@salesforce/resourceUrl/avatarImg';

export default class Crm_MeetingBrief_Attendees extends NavigationMixin(LightningElement) {
    @api recordId;
    @track attendees = [];
    @track intelUserOptions = [];
    @track externalUserOptions = [];
    error;
    @track showIntelDropdown = false;
    @track showExternalDropdown = false;
    @track avatarImg = avatarUrl;

    connectedCallback() {
        this.fetchCurrentData();
    }

    fetchCurrentData() {
        getExecutiveMeetingBriefData({ executiveMeetingId: this.recordId })
            .then(result => {
                console.log('Executive Meeting Brief Data:', result);
                this.attendees = this.parseAttendees(result.CRM_IntelAttendees__c, result.CRM_ExternalAttendees__c, result.CRM_InternalAttendees_Ids__c, result.CRM_ExternalAttendees_Ids__c);
                if (this.attendees.length === 0) {
                    this.handleAddRow();
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.showToast('Error', 'Failed to load Executive Brief Attendees', 'error');
                console.error(error);
            });
    }

    parseAttendees(intelAttendeesString, externalAttendeesString, intelAttendeeIdsString, externalAteendeeIdsString) {
        const intelAttendees = intelAttendeesString ? intelAttendeesString.split(',') : [];
        const externalAttendees = externalAttendeesString ? externalAttendeesString.split(',') : [];
        const intelAttendeesIds = intelAttendeeIdsString ? intelAttendeeIdsString.split(',') : [];
        const externalAttendeesIds = externalAteendeeIdsString ? externalAteendeeIdsString.split(',') : [];

        console.log('INTEL ATTENDEES:' + intelAttendees);
        console.log('EXTERNAL ATTENDEES:' + externalAttendees);

        const attendees = [];
        const maxLength = Math.max(intelAttendees.length, externalAttendees.length);

        for (let i = 0; i < maxLength; i++) {
            const attendee = {
                id: Date.now().toString() + i,
                intelAttendee: intelAttendees[i]?.replace(/\([^()]*\)/g, '') || '',
                externalAttendee: externalAttendees[i]?.replace(/\([^()]*\)/g, '') || '',
                showIntelDropdown: false,
                showExternalDropdown: false,
                isEditing: false,
                intelAttendeeId: intelAttendeesIds[i] || '',
                externalAttendeeId: externalAttendeesIds[i] || '',
            };
            attendees.push(attendee);
        }

        return attendees;
    }

    handleSearch(event) {
        const userId = event.currentTarget.dataset.id;
        const searchTerm = event.target.value;
        const userType = event.target.dataset.type === 'CRM_Intel_Attendees__c' ? 'Internal User' : 'External User';
        console.log('ATT search:' + userId + ' Usertype: ' + userType);
        if (searchTerm.length > 2) {
            searchAttendees({ userType, searchTerm })
                .then(data => {
                    const options = data.map(user => ({ label: user.Name, value: user.Id, wwid: user.Core_WWID__c, Email: user.Email }));
                    console.log('options::: ', options);
                    if (userType === 'Internal User') {
                        this.intelUserOptions = options;
                        if (options.length) {
                            this.attendees.forEach((a) => {
                                if (a.id === userId) {
                                    a.showIntelDropdown = true;
                                }
                            });
                        }
                        console.log('ATT EACH:' + JSON.stringify(this.attendees));
                    } else if (userType === 'External User') {
                        this.externalUserOptions = options;
                        this.attendees.forEach((a) => {
                            if (a.id === userId) {
                                a.showExternalDropdown = true;
                            }
                        });
                    }
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: `Error loading ${userType} attendees`,
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
        } else {
            if (userType === 'Internal User') {
                this.showIntelDropdown = false;
                this.hideInternalAndExeternalDropDowns();
            } else if (userType === 'External User') {
                this.showExternalDropdown = false;
                this.hideInternalAndExeternalDropDowns();
            }
        }
    }

    hideInternalAndExeternalDropDowns() {
        this.attendees = this.attendees.map((a) => {
            return {
                ...a,
                showIntelDropdown: false,
                showExternalDropdown: false,
            };
        });
    }

    handleAttendeeSelect(event) {
        const userId = event.currentTarget.dataset.id;
        const field = event.currentTarget.dataset.field;
        const userName = event.currentTarget.dataset.name;
        console.log('ATTENDEE USERNAME IS:' + userName);
        const intelAttendeeId = event.currentTarget.dataset.intelAttendeeid;
        const externalAttendeeId = event.currentTarget.dataset.externalAttendeeid;

        console.log('ATTENDEE SELECT INTEL' + intelAttendeeId);
        console.log('ATTENDEE SELECT EXTERNAL' + externalAttendeeId);

        const attendee = this.attendees.findIndex((a) => a.id == userId);
        if (attendee !== -1) {
            const newAttendee = {
                ...this.attendees.find((a) => a.id == userId)
            };
            if (field === 'externalAttendee') {
                newAttendee.externalAttendee = userName;
                console.log('USER ID:' + intelAttendeeId);
                newAttendee.externalAttendeeId = externalAttendeeId;
            } else if (field === 'intelAttendee') {
                newAttendee.intelAttendee = userName;
                newAttendee.intelAttendeeId = intelAttendeeId;
            }
            this.attendees[attendee] = {
                ...newAttendee
            };
        }
        this.hideInternalAndExeternalDropDowns();
    }

    handleRemoveAttendee(event) {
        const attendeeId = event.target.dataset.id;
        this.attendees = this.attendees.filter(attendee => attendee.id !== attendeeId);
        console.log('Handle remove attendee:', this.attendees);
    }

    handleAddRow() {
        const newAttendee = {
            id: Date.now().toString(),
            intelAttendee: '',
            externalAttendee: '',
            isEditing: true,
            intelAttendeeId: '',
            externalAttendeeId: '',
        };
        this.attendees = [...this.attendees, newAttendee];
    }

    handleRemoveRow(event) {
        const attendeeId = event.target.dataset.id;
        this.attendees = this.attendees.filter(attendee => attendee.id !== attendeeId);
    }

    handleEditRow(event) {
        const attendeeId = event.target.dataset.id;
        this.attendees = this.attendees.map(attendee => {
            if (attendee.id === attendeeId) {
                return { ...attendee, isEditing: !attendee.isEditing };
            }
            return attendee;
        });
    }

    handleCancel() {
        this.fetchCurrentData();
    }

    handleSave() {
        const meetingBriefData = {
            CRM_IntelAttendees__c: this.attendees.map(a => a.intelAttendee).toString(),
            CRM_ExternalAttendees__c: this.attendees.map(a => a.externalAttendee).toString(),
            CRM_InternalAttendees_Ids__c: this.attendees.map(a => a.intelAttendeeId).toString(),
            CRM_ExternalAttendees_Ids__c: this.attendees.map(a => a.externalAttendeeId).toString()
        }
        updateMeetingBriefData({ meetingBriefData: meetingBriefData, executiveMeetingId: this.recordId, fieldUpdated: 'Attendees' })
            .then(result => {
                console.log('SAVE RESULT IS:' + result);
                this.attendees = this.attendees.map(attendee => {
                    return { ...attendee, isEditing: false };
                });
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Executive Meeting Brief updated successfully',
                        variant: 'success'
                    })
                );
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

    navigateToUserRecord(event) {
        const userId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: userId,
                objectApiName: 'User',
                actionName: 'view'
            }
        });
    }

    handleMouseOver(event) {
        const userId = event.currentTarget.dataset.id;
        const type = event.currentTarget.dataset.type;
        getUserDetails({ userId: userId })
        .then(userDetails => {
            if (type === 'external') {         
                this.attendees = this.attendees.map(item => {
                    item.showHoverCard = false;
                    if (item.externalAttendeeId === userId) {
                            return { ...item, showHoverCard: true, userDetails };
                    }
                    return item;
                });     
                this.attendees = [...this.attendees];                          
            } else {       
                this.attendees = this.attendees.map(item => {     
                    item.showHoverCard = false;   
                    if (item.intelAttendeeId === userId) {
                        return { ...item, showHoverCard: true, userDetails };
                    }
                    return item;
                });    
                this.attendees = [...this.attendees];  
            }
        })
        .catch(error => {
            console.error('Error fetching user details:', error);
        });
    }

    handleMouseOut(event) {
        console.log('Hide hover card');
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
}