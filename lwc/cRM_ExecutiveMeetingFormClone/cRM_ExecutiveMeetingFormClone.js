import { LightningElement, track, wire, api } from 'lwc';
import saveMeetingBrief from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.saveMeetingBriefClone';
import getUsers from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getUsers';
import searchUsers from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchUsers';
import searchAttendees from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchAttendees';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getExecutiveMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getExecutiveMeetingBriefData';

export default class CRM_ExecutiveMeetingFormClone extends NavigationMixin(LightningElement) {
    @api recordId;
    @track crmIntelsMeetingObjectives = '';
    @track crmOtherPartysMeetingObjectives = '';
    @track crmMostCriticalMessages = '';
    @track crmPreparedBy = '';
    @track crmReviewedBy = '';
    @track crmLocation = '';
    @track crmDressCode = '';
    @track crmMeetingOwnerContact = '';
    @track attendees = [];
    @track agendaItems = [];
    @track backgroundItems = [];
    @track crmAdditionalInformation = '';
    @track crmAdditionalLegalGuidance = '';
    @track crmAttendeeBios = '';
    @track userOptions = [];
    @track crmStartTime = '';
    @track crmEndTime = '';
    @track crmMeetingAgendaItems = '';
    @track presentersConversationLead = '';
    @track searchTerm = '';
    @track contacts = [];
    @track showDropdown = true;
    @track crmReviewedByNames = ''; // Store user names

    @track isLocationModalOpen = false;
    @track crmLocationStreet = '';
    @track crmLocationCity = '';
    @track crmLocationPostalCode = '';
    @track crmLocationLongitude = null;
    @track crmLocationCountryCode = '';
    @track crmLocationStateCode = '';
    @track showIntelDropdown = false;
    @track showExternalDropdown = false;
    @track intelUserOptions = [];
    @track externalUserOptions = [];
    @track attendees = [];

    @track crmEventEngagementName = '';
    @track crmScheduledStartTime = '';
    @track crmScheduledEndTime = '';
    @track countryOptions=[];
    @track stateOptions=[];
    @track editMode = false;
    @track executiveBriefData;

    @wire(getUsers)
    wiredUsers({ error, data }) {
        if (data) {
            this.userOptions = data.map(user => {
                return { label: user.Name, value: user.Id };
            });
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading users',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }
    //test changes
    connectedCallback() {
        console.log('Inside connectedcallback'+this.recordId);
        this.initializeData();
    }
    initializeData(){
        console.log('Inside initializeData'+this.recordId);
         if(this.recordId!=null){
            this.editMode = true;
            console.log('Inside if editmode true check'+ this.editMode);
        }
         if(this.editMode == true){
            this.fetchCurrentData();
        }
    }
    //test changes
    fetchCurrentData(){
        console.log('Inside fetchCurrentData method:');
        getExecutiveMeetingBriefData({executiveMeetingId: this.recordId})
            .then(result => {
                this.executiveBriefData = result;
                console.log('ExecutiveBriefData is:'+JSON.stringify(this.executiveBriefData));
                this.error = undefined;
                this.populateFormFields(this.executiveBriefData);
            })
            .catch(error => {
                this.error = error;
                this.executiveBriefData = undefined;
                console.log('Oops error:'+this.error);
            })


        }
        populateFormFields(data) {
            console.log('Inside populate form fields'+this.executiveBriefData);
            this.crmEventEngagementName = data.CRM_Event_Engagement_Name__c;
            this.crmScheduledStartTime = data.CRM_Scheduled_Start_Time__c;
            this.crmScheduledEndTime = data.CRM_Scheduled_End_Time__c;
            this.crmIntelsMeetingObjectives = data.CRM_Intels_Meeting_Objectives__c;
            this.crmOtherPartysMeetingObjectives = data.CRM_Other_Partys_Meeting_Objectives__c;
            this.crmMostCriticalMessages = data.CRM_Most_Critical_Messages_to_Get_Across__c;
            this.crmPreparedBy = data.CRM_PreparedBy__c;
            this.crmReviewedBy = data.CRM_Reviewed_by__c;
            this.crmLocationStreet = data.CRM_Location__Street__s;
            this.crmLocationCity = data.CRM_Location__City__s;
            this.crmLocationPostalCode = data.CRM_Location__PostalCode__s;
            this.crmLocationCountryCode = data.CRM_Location__CountryCode__s;
            this.crmLocationStateCode = data.CRM_Location__StateCode__s;
            this.crmDressCode = data.CRM_Dress_Code__c;
            this.crmMeetingOwnerContact = data.CRM_MeetingOwnerContact__c;
            //this.attendees = this.parseAttendees(data.CRM_IntelAttendees__c, data.CRM_ExternalAttendees__c);
            //this.agendaItems = this.parseAgendaItems(data.CRM_Start_Time__c, data.CRM_End_Time__c, data.CRM_Meeting_Agenda_Items__c, data.Presenters_Conversation_Lead__c);
            //this.backgroundItems = this.parseBackgroundItems(data.CRM_Background_Objective1__c, data.CRM_Proactive_Talking_Points__c, data.CRM_Reactive_Talking_Points__c);
            this.crmAdditionalInformation = data.CRM_Additional_Information__c;
            this.crmAdditionalLegalGuidance = data.CRM_Additional_Legal_Guidance__c;
            this.crmAttendeeBios = data.CRM_Attendee_Bio_s__c;
    }
            
    //test changes end
    handleInputChange(event) {
        const { id } = event.target.dataset;
        const { value } = event.target;
        if (id) {
            this[id] = value;
        }
    }
 

    /*handleInputChange(event) {
        debugger;
        console.log('inside handleInputChange', event);
        const field = event.target.dataset.id;
        this[field] = event.target.value;
         console.log('inside handleInputChange this[field]:', this[field]);
    }*/
    /* handleSearch(event) {
        const searchTerm = event.target.value;
        const userType = event.target.dataset.type === 'CRM_Intel_Attendees__c' ? 'Internal User' : 'External User';

        console.log('Search Term:', searchTerm);
        console.log('User Type:', userType);

        if (searchTerm.length > 2) {
            searchAttendees({ userType, searchTerm })
                .then(data => {
                    const options = data.map(user => ({ label: user.Name, value: user.Id }));
                    if (userType === 'Internal User') {
                        this.intelUserOptions = options;
                    } else if (userType === 'External User') {
                        this.externalUserOptions = options;
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
        }
    }    

    handleAttendeeSelect(event) {
        const userId = event.target.dataset.id;
        const field = event.target.dataset.field;
        const userName = event.target.textContent;

        const newAttendee = {
            id: Date.now().toString(),
            intelAttendee: field === 'intelAttendee' ? userId : '',
            externalAttendee: field === 'externalAttendee' ? userId : '',
            intelAttendeeName: field === 'intelAttendee' ? userName : '',
            externalAttendeeName: field === 'externalAttendee' ? userName : ''
        };

        this.attendees = [...this.attendees, newAttendee];
        console.log('Attendees after selection:', this.attendees);
    }*/

    handleAddAttendee() {
        const newAttendee = {
            id: Date.now().toString(),
            intelAttendee: '',
            externalAttendee: '',
            showIntelDropdown: false,
            showExternalDropdown: false,
        };
        this.attendees = [...this.attendees, newAttendee];
         console.log('Attendees after adding:', this.attendees);
    }

    handleRemoveAttendee(event) {
        const attendeeId = event.target.dataset.id;
        this.attendees = this.attendees.filter(attendee => attendee.id !== attendeeId);
    }

    handleAgendaChange(event) {
        const agendaId = event.target.dataset.id;
        const field = event.target.dataset.field;
        const value = event.target.value;

        this.agendaItems = this.agendaItems.map(agenda => {
            if (agenda.id === agendaId) {
                return { ...agenda, [field]: value };
            }
            return agenda;
        });
    }

    handleAddAgenda() {
        const newAgenda = {
            id: Date.now().toString(),
            startTime: '',
            endTime: '',
            agendaItems: '',
            presentersLead: ''
        };
        this.agendaItems = [...this.agendaItems, newAgenda];
    }

    handleRemoveAgenda(event) {
        const agendaId = event.target.dataset.id;
        this.agendaItems = this.agendaItems.filter(agenda => agenda.id !== agendaId);
    }

    handleSearchUsers(event) {
        const searchTerm = event.target.value;
        console.log('Search Term:', searchTerm);
        if (searchTerm.length > 2) {
            searchUsers({ searchTerm })
                .then(data => {
                    this.userOptions = data.map(user => ({ label: user.Name, value: user.Id }));
                    this.showUserDropdown = this.userOptions.length > 0;
                    this.userOptions = [...this.userOptions];
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error loading users',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
        } else {
            this.showUserDropdown = false;
        }
    }

    handleUserSelect1(event) {
        const agendaId = event.currentTarget.dataset.id;
        const userId = event.currentTarget.dataset.value;
        const userName = event.currentTarget.textContent;

        this.agendaItems = this.agendaItems.map(agenda => {
            if (agenda.id === agendaId) {
                return { ...agenda, presentersLead: userId, presentersLeadName: userName };
            }
            return agenda;
        });
        this.showUserDropdown = false;
    }

    

    handleBackgroundChange(event) {
        const backgroundId = event.target.dataset.id;
        const field = event.target.dataset.field;
        const value = event.target.value;

        this.backgroundItems = this.backgroundItems.map((background, index) => {
            if (background.id === backgroundId) {
                return { ...background, [field]: value };
            }
            background.label = `Objectives ${(index + 1)}`;
            return background;
        });
    }

    handleAddBackground() {
        const newBackground = {
            id: Date.now().toString(),
            backgroundObjective1: '',
            proactiveTalkingPoints: '',
            reactiveTalkingPoints: '',
            backgroundObjective2: '',
            proactiveTalkingPointsObjective2: '',
            reactiveTalkingPointsObjective2: ''
        };
        this.backgroundItems = [...this.backgroundItems, newBackground];
        // Update labels
        this.updateBackgroundLabels();
    }

    updateBackgroundLabels() {
        this.backgroundItems = this.backgroundItems.map((background, index) => {
            background.label = `Objectives ${(index + 1)}`;
            return background;
        });
    }

    handleRemoveBackground(event) {
        const backgroundId = event.target.dataset.id;
        this.backgroundItems = this.backgroundItems.filter(background => background.id !== backgroundId);
        // Update labels
        this.updateBackgroundLabels();
    }

    handleSave() {
        debugger;
        const meetingBriefData = {
            CRM_Event_Engagement_Name__c: this.crmEventEngagementName,
            CRM_Scheduled_Start_Time__c: this.crmScheduledStartTime,
            CRM_Scheduled_End_Time__c: this.crmScheduledEndTime,

            Account__c: '0012D00000aYhYGQA0',
            CRM_Intels_Meeting_Objectives__c: this.crmIntelsMeetingObjectives,
            CRM_Other_Partys_Meeting_Objectives__c: this.crmOtherPartysMeetingObjectives,
            CRM_Most_Critical_Messages_to_Get_Across__c: this.crmMostCriticalMessages,
            CRM_Additional_Information__c: this.crmAdditionalInformation,
            CRM_Additional_Legal_Guidance__c: this.crmAdditionalLegalGuidance,
            CRM_Attendee_Bio_s__c: this.crmAttendeeBios,
            CRM_PreparedBy__c: this.crmPreparedBy,
            CRM_MeetingOwnerContact__c: this.crmMeetingOwnerContact,
            CRM_Reviewed_By_Names__c: this.crmReviewedByNames,
            CRM_Background_Objective1__c: this.backgroundItems.map(b => b.backgroundObjective1).join(';\r\n'),
            CRM_Proactive_Talking_Points__c: this.backgroundItems.map(b => b.proactiveTalkingPoints).join(';\r\n'),
            CRM_Reactive_Talking_Points__c: this.backgroundItems.map(b => b.reactiveTalkingPoints).join(';\r\n'),
    
            CRM_Location__Street__s: this.crmLocationStreet,
            CRM_Location__City__s: this.crmLocationCity,
            CRM_Location__PostalCode__s: this.crmLocationPostalCode,
            CRM_Location__Longitude__s: this.crmLocationLongitude,
            CRM_Location__CountryCode__s: this.crmLocationCountryCode,
            CRM_Location__StateCode__s: this.crmLocationStateCode,

            CRM_Dress_Code__c: this.crmDressCode,

            CRM_IntelAttendees__c: this.attendees.map(a => a.intelAttendee).toString(),
            CRM_ExternalAttendees__c: this.attendees.map(a => a.externalAttendee).toString(),
            
            CRM_Start_Time__c: this.agendaItems.map(a => a.startTime).join('; '),
            CRM_End_Time__c: this.agendaItems.map(a => a.endTime).join('; '),
            CRM_Meeting_Agenda_Items__c: this.agendaItems.map(a => a.agendaItems).join('; '),
            CRM_Presenters_Conversation_Lead__c: this.agendaItems.map(a => a.presentersLead).join('; ')

            //CRM_Reviewed_by__c: this.crmReviewedBy
            /*CRM_Location__c: this.crmLocation,
            
           
            CRM_Intel_Attendees__c: JSON.stringify(this.attendees.map(a => a.intelAttendee)),
            CRM_External_Attendees__c: JSON.stringify(this.attendees.map(a => a.externalAttendee)),           
            
            Presenters_Conversation_Lead__c: this.presentersConversationLead,
            */
        };
        console.log('Meeting Brief Data:', meetingBriefData);
        debugger;
        saveMeetingBrief({meetingBriefData: meetingBriefData, editMode:this.editMode, recordId:this.recordId })
            .then(result => {
                console.log('SAVE RESULT IS:'+result);
                if(!this.editMode){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Executive Meeting Brief created successfully',
                            variant: 'success'
                        })
                    );
                }
                if(this.editMode){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Executive Meeting Brief updated successfully',
                            variant: 'success'
                        })
                    );
                }

                // Navigate to the newly created record
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'Executive_Meeting_Brief__c',
                        actionName: 'view'
                    }
                });
            })
            .catch(error => {
                console.log('SAVE RESULT ERROR IS:'+error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    handleCancel() {
        // Implement cancel logic here
        console.log('Form cancelled');
    }
    handlePreparedBySelect(event) {
        this.crmPreparedBy = event.detail.contactId;
        console.log('Selected crmPreparedBy ID:', this.crmPreparedBy);
    }

    handleMeetingOwnerSelect(event) {
        this.crmMeetingOwnerContact = event.detail.contactId;
        console.log('Selected crmMeetingOwnerContact ID:', this.crmMeetingOwnerContact);
    }

    /*handleUserSelect(event) {
        debugger;
        const selectedUsers = event.detail.selectedUsers;
        if (selectedUsers) {
            this.crmReviewedBy = selectedUsers.map(user => user.Id).join(';');
            console.log('Selected crmReviewedBy IDs:', this.crmReviewedBy);
        } else {
            this.crmReviewedBy = '';
        }
    }*/
    handleUserSelect(event) {
        const selectedUsers = event.detail.selectedUsers;
        if (selectedUsers) {
            this.crmReviewedBy = selectedUsers.map(user => user.Id).join(';');
            this.crmReviewedByNames = selectedUsers.map(user => user.Name).join('; ');
            console.log('Selected crmReviewedBy IDs:', this.crmReviewedBy);
            console.log('Selected crmReviewedBy Names:', this.crmReviewedByNames);
        } else {
            this.crmReviewedBy = '';
            this.crmReviewedByNames = '';
        }
    }

    openLocationModal() {
        this.isLocationModalOpen = true;
    }

    closeLocationModal() {
        this.isLocationModalOpen = false;
    }

    saveLocation() {
        // Logic to save location details
        this.closeLocationModal();
    }
    handleSearch(event) {
        const userId = event.currentTarget.dataset.id;
        const searchTerm = event.target.value;
        const userType = event.target.dataset.type === 'CRM_Intel_Attendees__c' ? 'Internal User' : 'External User';

        if (searchTerm.length > 2) {
            searchAttendees({ userType, searchTerm })
                .then(data => {
                    const options = data.map(user => ({ label: user.Name, value: user.Id }));
                    if (userType === 'Internal User') {
                        this.intelUserOptions = options;
                        // this.showIntelDropdown = options.length > 0;
                        if (options.length) {
                            this.attendees.forEach((a) => {
                                if (a.id === userId) {
                                    a.showIntelDropdown = true;
                                }
                            });
                        }
                    } else if (userType === 'External User') {
                        this.externalUserOptions = options;
                        // this.showExternalDropdown = options.length > 0;
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
        console.log(event);
        const userId = event.currentTarget.dataset.id;
        const field = event.currentTarget.dataset.field;
        const userName = event.currentTarget.textContent;

        console.log(userId);
        console.log(JSON.parse(JSON.stringify(this.attendees)));
        const attendee = this.attendees.findIndex((a) => a.id == userId);
        if (attendee !== -1) {
            const newAttendee = {
                ...this.attendees.find((a) => a.id == userId)
            };
            if (field === 'externalAttendee') {
                newAttendee.externalAttendee = userName;
            } else if (field === 'intelAttendee') {
                newAttendee.intelAttendee = userName;
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
    }

    handleAddressChange(event) {
        const { street, city, postalCode, country, state, latitude, longitude } = event.detail;
        this.crmLocationStreet = street;
        this.crmLocationCity = city;
        this.crmLocationPostalCode = postalCode;
        this.crmLocationCountryCode = country;
        this.crmLocationStateCode = state;
        this.crmLocationLatitude = latitude;
        this.crmLocationLongitude = longitude;
    }
}