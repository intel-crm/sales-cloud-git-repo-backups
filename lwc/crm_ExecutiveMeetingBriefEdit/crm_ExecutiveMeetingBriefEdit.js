import { LightningElement, track, wire, api } from 'lwc';
import saveMeetingBrief from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.saveMeetingBrief';
import getUsers from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getUsers';
import searchUsers from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchUsers';
import searchAttendees from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchAttendees';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getExecutiveMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getExecutiveMeetingBriefData';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class Crm_ExecutiveMeetingBriefEdit extends NavigationMixin(LightningElement) {
    @api recordId;
    @track crmIntelsMeetingObjectives = '';
    @track crmOtherPartysMeetingObjectives = '';
    @track crmMostCriticalMessages = '';
    @track crmPreparedBy = '';
    @track crmPreparedByName = '';
    @track crmReviewedBy = '';
    @track crmLocation = '';
    @track crmDressCode = '';
    @track crmMeetingOwnerContact = '';
    @track crmMeetingOwnerContactName = '';
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
    @track crmLocationCountry = '';
    @track crmLocationStateCode = '';
    @track showIntelDropdown = false;
    @track showExternalDropdown = false;
    @track intelUserOptions = [];
    @track externalUserOptions = [];
    @track attendees = [];

    @track crmEventEngagementName = '';
    @track crmScheduledStartTime = '';
    @track crmScheduledEndTime = '';
    @track countryOptions = [];
    @track stateOptions = [];
    @track editMode = false;
    @track executiveBriefData;
    showUserDropdown1 = false;
    showUserDropdown2 = false;
    showUserDropdown3 = false;
    @track showForm;
     @track filteredUsers5 = [];
     @track selectedUsers5 = [];
     @track showDropdown5 = false;
     @track searchTerm5 = '';
    activeSections = ['eventDetails', 'objectives', 'logistics', 'attendees', 'agenda', 'background', 'additionalInfo'];
    @track showModal = true;

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
        console.log('Inside connectedcallback' + this.recordId);
        this.showForm = true;
        this.initializeData();
    }
    initializeData() {
        console.log('Inside initializeData' + this.recordId);
        if (this.recordId != null) {
            this.editMode = true;
            console.log('Inside if editmode true check' + this.editMode);
        }
        if (this.editMode == true) {
            this.fetchCurrentData();
        }
    }
    //test changes
    fetchCurrentData() {
        console.log('Inside fetchCurrentData method:');
        getExecutiveMeetingBriefData({ executiveMeetingId: this.recordId })
            .then(result => {
                this.executiveBriefData = result;
                console.log('ExecutiveBriefData is:' + JSON.stringify(this.executiveBriefData));
                this.error = undefined;
                this.populateFormFields(this.executiveBriefData);
            })
            .catch(error => {
                this.error = error;
                this.executiveBriefData = undefined;
                console.log('Oops error:' + this.error);
            })


    }

       handleSearchChange5(event) {
        debugger;
        this.searchTerm5 = event.target.value;
        if (this.searchTerm5.length > 2) {
            searchUsers({ searchTerm: this.searchTerm5 })
                .then(result => {
                    this.filteredUsers5 = result;
                    console.log('filteredUsers5 :' , this.filteredUsers5);
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
        const user = this.filteredUsers5.find(u => u.Id === userId );
        if (user && !this.selectedUsers5.some(u => u.Id === userId || u.Name.trim() === name.trim())) {
            this.selectedUsers5 = [...this.selectedUsers5, user];
            console.log('inside if line 144', JSON.stringify(this.selectedUsers5));
            this.crmReviewedBy = this.selectedUsers5.map(user => user.Id).join(';');
             this.crmReviewedByNames = this.selectedUsers5.map(user => user.Name).join('; ');
           console.log('Selected crmReviewedBy IDs:', this.crmReviewedBy);
            console.log('Selected crmReviewedBy Names:', this.crmReviewedByNames);          
            this.searchTerm5 = '';
        }
        this.showDropdown5 = false;
       
    }

    handleRemoveUser5(event) {
        const userId = event.currentTarget.dataset.id;
        this.selectedUsers5 = this.selectedUsers5.filter(user => user.Id !== userId);        
    }

    // handleUserSelect5(event) {
    //     const selectedUsers = event.detail.selectedUsers;
    //     if (selectedUsers) {
    //         this.crmReviewedBy = selectedUsers.map(user => user.Id).join(';');
    //         this.crmReviewedByNames = selectedUsers.map(user => user.Name).join('; ');
    //         console.log('Selected crmReviewedBy IDs:', this.crmReviewedBy);
    //         console.log('Selected crmReviewedBy Names:', this.crmReviewedByNames);
    //     } else {
    //         this.crmReviewedBy = '';
    //         this.crmReviewedByNames = '';
    //     }
    // }

    populateFormFields(data) {
        console.log('Inside populate form fields' + JSON.stringify(this.executiveBriefData));
        this.crmEventEngagementName = data.CRM_Event_Engagement_Name__c;
        this.crmScheduledStartTime = data.CRM_Scheduled_Start_Time__c;
        this.crmScheduledEndTime = data.CRM_Scheduled_End_Time__c;
        this.crmIntelsMeetingObjectives = data.CRM_Intels_Meeting_Objectives__c;
        this.crmOtherPartysMeetingObjectives = data.CRM_Other_Partys_Meeting_Objectives__c;
        this.crmMostCriticalMessages = data.CRM_Most_Critical_Messages_to_Get_Across__c;
        this.crmPreparedByName = data.CRM_PreparedBy__r.Name;
        this.crmPreparedBy = data.CRM_PreparedBy__c;
        console.log('PREPARED BY NAME:' + data.CRM_PreparedBy__r.Name);
        console.log('PREPARED BY:', this.crmPreparedBy);
        this.crmReviewedByNames = data.CRM_Reviewed_By_Names__c; /// ReviewedByNames
        this.selectedUsers5 = data.CRM_Reviewed_By_Names__c ? data.CRM_Reviewed_By_Names__c.split(';').map((name) => {  return { Name: name, Id: name} }) : [];
        console.log('selected user Reviewed by:', JSON.stringify(this.selectedUsers5));
        
        console.log('Inside populate form location' + JSON.stringify(data.CRM_Location__c));
        this.crmLocationStreet = data.CRM_Location__c.street;
        this.crmLocationCity = data.CRM_Location__c.city;
        this.crmLocationPostalCode = data.CRM_Location__c.postalCode;
        this.crmLocationCountry = data.CRM_Location__c.countrycode;
        this.crmLocationStateCode = data.CRM_Location__c.statecode;
        this.crmDressCode = data.CRM_Dress_Code__c;
        this.crmMeetingOwnerContact = data.CRM_MeetingOwnerContact__c;
        this.crmMeetingOwnerContactName = data.CRM_MeetingOwnerContact__r.Name;
        this.attendees = this.parseAttendees(data.CRM_IntelAttendees__c, data.CRM_ExternalAttendees__c);
        console.log('ATTENDEES' + JSON.stringify(this.attendees));
        console.log('AGENDA START TIME:'+data.CRM_StartTime_DetailField__c);
         console.log('AGENDA END TIME:'+data.CRM_EndTime_DetailField__c);
        this.agendaItems = this.parseAgendaItems(data.CRM_StartTime_DetailField__c, data.CRM_EndTime_DetailField__c, data.CRM_Meeting_Agenda_Items__c, data.CRM_PresentersConversationLeadNames__c);
        this.backgroundItems = this.parseBackgroundItems(data.CRM_Background_Objective1__c, data.CRM_Proactive_Talking_Points__c, data.CRM_Reactive_Talking_Points__c);
        this.crmAdditionalInformation = data.CRM_Additional_Information__c;
        this.crmAdditionalLegalGuidance = data.CRM_Additional_Legal_Guidance__c;
        this.crmAttendeeBios = data.CRM_Attendee_Bio_s__c;
    }
    parseAttendees(intelAttendeesString, externalAttendeesString) {
        // Split the attendee strings into arrays
        const intelAttendees = intelAttendeesString ? intelAttendeesString.split(',') : [];
        const externalAttendees = externalAttendeesString ? externalAttendeesString.split(',') : [];

        console.log('INTEL ATTENDEES:' + intelAttendees);
        console.log('EXTERNAL ATTENDEES:' + externalAttendees);

        // Create a combined list of attendees with unique IDs
        const attendees = [];
        const maxLength = Math.max(intelAttendees.length, externalAttendees.length);

        for (let i = 0; i < maxLength; i++) {
            const attendee = {
                id: Date.now().toString() + i, // Generate a unique ID for each attendee
                intelAttendee: intelAttendees[i] || '', // Use empty string if no attendee
                externalAttendee: externalAttendees[i] || '', // Use empty string if no attendee
                showIntelDropdown: false,
                showExternalDropdown: false,
            };
            attendees.push(attendee);
        }

        return attendees;
    }
    parseAgendaItems(startTimeString, endTimeString, agendaItemsString, presentersLeadString) {
        console.log('START TIME STRING: ' + startTimeString);
        console.log('END TIME STRING: ' + endTimeString);
        console.log('PRSENTERS LEAD STRING: ' + presentersLeadString);
        // Split the input strings into arrays
        const startTimes = startTimeString ? startTimeString.split(';') : [];
        const endTimes = endTimeString ? endTimeString.split(';') : [];
        const agendaItems = agendaItemsString ? agendaItemsString.split(';') : [];
        const presentersLeads = presentersLeadString ? presentersLeadString.split(';') : [];

        console.log('START TIMES:' + startTimes);
        console.log('END TIMES:' + endTimes);

        // Create a combined list of agenda items
        const agendaList = [];
        const maxLength = Math.max(startTimes.length, endTimes.length, agendaItems.length, presentersLeads.length);

        for (let i = 0; i < maxLength; i++) {
            const agenda = {
                id: Date.now().toString() + i, // Generate a unique ID for each agenda item
                startTime: startTimes[i] ? startTimes[i].trim() : '', // Use empty string if no start time
                endTime: endTimes[i] ? endTimes[i].trim() : '', // Use empty string if no end time
                agendaItems: agendaItems[i] ? agendaItems[i].trim() : '', // Use empty string if no agenda item
                //presentersLead: presentersLeads[i] ? presentersLeads[i].trim() : '', // Use empty string if no presenter lead
                presentersLeadName: presentersLeads[i] ? presentersLeads[i].trim() : '' // Placeholder for presenter lead name, if needed
            };
            agendaList.push(agenda);
        }
        console.log('AGENDA LIST IS:' + JSON.stringify(agendaList));
        return agendaList;
    }
    parseBackgroundItems(objectiveString, proactivePointsString, reactivePointsString) {
        // Split the input strings into arrays
        const objectives = objectiveString ? objectiveString.split(';') : [];
        const proactivePoints = proactivePointsString ? proactivePointsString.split(';') : [];
        const reactivePoints = reactivePointsString ? reactivePointsString.split(';') : [];

        console.log('OBJECTIVES' + objectives);
        console.log('PROACTIVE:' + proactivePoints);
        console.log('REACTIVE' + reactivePoints);

        // Create a combined list of background items
        const backgroundList = [];
        const maxLength = Math.max(objectives.length, proactivePoints.length, reactivePoints.length);

        for (let i = 0; i < maxLength; i++) {
            const background = {
                id: Date.now().toString() + i, // Generate a unique ID for each background item
                backgroundObjective1: objectives[i] ? objectives[i].trim() : '', // Use empty string if no objective
                proactiveTalkingPoints: proactivePoints[i] ? proactivePoints[i].trim() : '', // Use empty string if no proactive point
                reactiveTalkingPoints: reactivePoints[i] ? reactivePoints[i].trim() : '', // Use empty string if no reactive point
                label: `Objectives ${i + 1}` // Label for the section
            };
            backgroundList.push(background);
        }
        console.log('Backgorund list is:' + backgroundList);
        return backgroundList;
    }


    //test changes end
    handleInputChange(event) {
        const { id } = event.target.dataset;
        const { value } = event.target;
        console.log('INPUT ID:' + id);
        console.log('INPUT VALUE:' + value);
        if (id) {
            this[id] = value;
        }
    }

    @track attendees = [
        {
            id: Date.now().toString(),
            intelAttendee: '',
            externalAttendee: '',
            showIntelDropdown: false,
            showExternalDropdown: false,
        }
    ];

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

    handleRemoveLastAgenda() {
        if (this.agendaItems.length > 0) {
            this.agendaItems = this.agendaItems.slice(0, -1);
            console.log('Agenda items after removal:', this.agendaItems);
        }
    }

    handleRemoveLastAttendee() {
        if (this.attendees.length > 0) {
            this.attendees = this.attendees.slice(0, -1);
            console.log('Attendees after removal:', this.attendees);
        }
    }

    @track agendaItems = [
        {
            id: Date.now().toString(),
            startTime: '',
            endTime: '',
            agendaItems: '',
            presentersLeadName: '',
            showUserDropdown3: false
        }
    ];

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

    handleSearchUsers1(event) {
        const searchTerm = event.target.value;
        console.log('Search Term:', searchTerm);
        if (searchTerm.length > 2) {
            searchUsers({ searchTerm })
                .then(data => {
                    this.userOptions = data.map(user => ({ label: user.Name, value: user.Id }));
                    this.showUserDropdown1 = this.userOptions.length > 0;
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
            this.showUserDropdown1 = false;
        }

    }

    //  const contactId = event.currentTarget.dataset.id;
    //     const selectedContact = this.contacts.find(contact => contact.Id === contactId);
    //     console.log('Selected Contact:', selectedContact);
    //     const selectEvent = new CustomEvent('contactselect', {
    //         detail: { contactId, contactName: selectedContact.Name }
    //     });
    //     this.dispatchEvent(selectEvent);
    //     this.searchTerm = selectedContact.Name;
    //     this.showDropdown = false;

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
        this.showUserDropdown1 = false;
    }

    handleSearchUsers2(event) {
        const searchTerm = event.target.value;
        console.log('Search Term:', searchTerm);
        if (searchTerm.length > 2) {
            searchUsers({ searchTerm })
                .then(data => {
                    this.userOptions = data.map(user => ({ label: user.Name, value: user.Id }));
                    this.showUserDropdown2 = this.userOptions.length > 0;
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
            this.showUserDropdown2 = false;
        }
    }

    handleUserSelect2(event) {
        const agendaId = event.currentTarget.dataset.id;
        const userId = event.currentTarget.dataset.value;
        const userName = event.currentTarget.textContent;

        this.agendaItems = this.agendaItems.map(agenda => {
            if (agenda.id === agendaId) {
                return { ...agenda, presentersLead: userId, presentersLeadName: userName };
            }
            return agenda;
        });
        this.showUserDropdown2 = false;
    }

    // handleSelect(event) {
    //     const contactId = event.currentTarget.dataset.id;
    //     const selectedContact = this.contacts.find(contact => contact.Id === contactId);
    //     console.log('Selected Contact:', selectedContact);
    //     const selectEvent = new CustomEvent('contactselect', {
    //         detail: { contactId, contactName: selectedContact.Name }
    //     });
    //     this.dispatchEvent(selectEvent);
    //     this.searchTerm = selectedContact.Name;
    //     this.showDropdown = false;
    // }

    handleSearchUsers3(event) {
        const searchTerm = event.target.value;
        console.log('Search Term:', searchTerm);
        if (searchTerm.length > 2) {
            searchUsers({ searchTerm })
                .then(data => {
                    this.userOptions = data.map(user => ({ label: user.Name, value: user.Id }));
                    this.showUserDropdown3 = this.userOptions.length > 0;
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
            this.showUserDropdown3 = false;
        }
    }

    handleUserSelect3(event) {
        const agendaId = event.currentTarget.dataset.id;
        const userId = event.currentTarget.dataset.value;
        const userName = event.currentTarget.textContent;

        this.agendaItems = this.agendaItems.map(agenda => {
            if (agenda.id === agendaId) {
                return { ...agenda, presentersLead: userId, presentersLeadName: userName };
            }
            return agenda;
        });
        this.showUserDropdown3 = false;
    }

    @track backgroundItems = [
        {
            id: Date.now().toString(),
            backgroundObjective1: '',
            proactiveTalkingPoints: '',
            reactiveTalkingPoints: '',
            label: 'Objective 1'
        }
    ];



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
        console.log('agendaItems : ', JSON.stringify(this.agendaItems));
        console.log('Prepared by::', this.crmPreparedBy);
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
            CRM_Location__CountryCode__s: this.crmLocationCountry,
            CRM_Location__StateCode__s: this.crmLocationStateCode,
            
            CRM_Dress_Code__c: this.crmDressCode,

            CRM_IntelAttendees__c: this.attendees.map(a => a.intelAttendee).toString(),
            CRM_ExternalAttendees__c: this.attendees.map(a => a.externalAttendee).toString(),
            
            CRM_Start_Time__c: this.agendaItems.map(a => a.startTime).join('; '),
            CRM_StartTime_DetailField__c: this.agendaItems.map(a => a.startTime).join(';\r\n'),


            CRM_End_Time__c: this.agendaItems.map(a => a.endTime).join('; '),
            CRM_EndTime_DetailField__c: this.agendaItems.map(a => a.endTime).join(';\r\n'),

            CRM_Meeting_Agenda_Items__c: this.agendaItems.map(a => a.agendaItems).join('; '),

            CRM_Presenters_Conversation_Lead__c: this.agendaItems.map(a => a.presentersLead).join('; '),
            CRM_PresentersConversationLeadNames__c: this.agendaItems.map(a => a.presentersLeadName).join(';\r\n')

            //CRM_Reviewed_by__c: this.crmReviewedBy
            /*CRM_Location__c: this.crmLocation,
            CRM_Location__Longitude__s: this.crmLocationLongitude,
            */
        };
        console.log('Meeting Brief Data:', meetingBriefData);
        console.log('CRM_StartTime_DetailField__c:', meetingBriefData.CRM_StartTime_DetailField__c);
        console.log('CRM_EndTime_DetailField__c:', meetingBriefData.CRM_EndTime_DetailField__c);
        console.log('DRESS CODE:'+this.crmDressCode);
        debugger;
        saveMeetingBrief({ meetingBriefData: meetingBriefData, editMode: this.editMode, recordId: this.recordId })
            .then(result => {
                console.log('SAVE RESULT IS:' + result);
                if (!this.editMode) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Executive Meeting Brief created successfully',
                            variant: 'success'
                        })
                    );
                }
                if (this.editMode) {
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
                }); eval("$A.get('e.force:refreshView').fire();");
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

    handleCancel() {
        // Implement cancel logic here
        console.log('Form cancelled');
        this.showModal = false;
        if(!this.editMode){
            console.log('Inside editMode'+this.editMode);
            this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Executive_Meeting_Brief__c', // Replace with your custom object's API name
                actionName: 'list'
            },
            state: {
                filterName: 'Recent' // You can specify a filter name if needed, e.g., 'Recent'
            }
        });
    }
        else{
            console.log('Inside cancel new mode'+this.editMode);
            this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Executive_Meeting_Brief__c',
                actionName: 'view'
            }

        })
    }
        /*const cancelEvent = new CustomEvent('modalclose');
        this.dispatchEvent(cancelEvent);*/
        /*this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'Executive_Meeting_Brief__c',
            actionName: 'view'
        },
    });*/
    }

    handlePreparedBySelect(event) {
        this.crmPreparedBy = event.currentTarget.dataset.value; //event.currentTarget?.dataset?.label;
        this.crmPreparedByName = event.currentTarget?.dataset?.label;
        console.log('PREPARED BY NAME:', this.crmPreparedByName);
        this.showUserDropdown1 = false;
        console.log('Selected crmPreparedBy ID1:', JSON.stringify(event.currentTarget.dataset.value));
        console.log('Selected crmPreparedBy ID2:', JSON.stringify(event.currentTarget?.dataset?.id));
        console.log('Selected crmPreparedBy ID:', this.crmPreparedBy); // Name , field lookup(user)
    }

    handleMeetingOwnerSelect(event) {
        //this.crmMeetingOwnerContact = event.detail.contactId;
        this.crmMeetingOwnerContact = event.currentTarget.dataset.value; //event.currentTarget?.dataset?.label;
        this.crmMeetingOwnerContactName = event.currentTarget?.dataset?.label;
        this.showUserDropdown2 = false;
        console.log('Selected crmMeetingOwnerContact ID:', this.crmMeetingOwnerContact);
    }

    /*
    const contactId = event.currentTarget.dataset.id;
        const selectedContact = this.contacts.find(contact => contact.Id === contactId);
        console.log('Selected Contact:', selectedContact);
    }*/
    

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
        debugger;
        const userId = event.currentTarget.dataset.id;
        const searchTerm = event.target.value;
        const userType = event.target.dataset.type === 'CRM_Intel_Attendees__c' ? 'Internal User' : 'External User';

        if (searchTerm.length > 2) {
            searchAttendees({ userType, searchTerm })
                .then(data => {
                    const options = data.map(user => ({ label: user.Name, value: user.Id, wwid: user.Core_WWID__c }));
                    console.log('options::: ', options);
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
        this.crmLocationCountry = country;
        this.crmLocationStateCode = state;
        this.crmLocationLatitude = latitude;
        this.crmLocationLongitude = longitude;
    }

    handleSaveAndNew(event){
        this.handleSave();
        
         this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: EXECUTIVE_BRIEF_OBJECT,
                        actionName: 'new'
                    }
                });

    }

}