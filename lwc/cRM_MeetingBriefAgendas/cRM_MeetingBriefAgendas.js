import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import updateMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.updateMeetingBriefData';
import searchUsers from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchUsers';
import getAgendaItems from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getAgendaItems';
import saveAgendaItems from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.saveAgendaItems';
import getUserDetails from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getUserDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import avatarUrl from '@salesforce/resourceUrl/avatarImg';

export default class CRM_MeetingBriefAgendas extends NavigationMixin(LightningElement) {
    @api recordId;
    @track agendaItems = [];
    @track error;
    @track avatarImg = avatarUrl;

    connectedCallback() {
        this.fetchCurrentData();
    }

    fetchCurrentData() {
        getAgendaItems({ executiveMeetingId: this.recordId })
            .then(result => {
                this.agendaItems = result;
                if (this.agendaItems.length === 0) {
                    this.handleAddAgenda();
                }
                this.error = undefined;
                //this.populateFormFields(this.executiveBriefData);
            })
            .catch(error => {
                this.error = error;
                this.executiveBriefData = undefined;
            });
    }

    /*populateFormFields(data) {
        this.agendaItems = this.parseAgendaItems(data.CRM_StartTime_DetailField__c, data.CRM_EndTime_DetailField__c, data.CRM_Meeting_Agenda_Items__c, data.CRM_PresentersConversationLeadNames__c, data.CRM_Presenters_Conversation_Lead_Id__c);
        if (this.agendaItems.length === 0) {
            this.handleAddAgenda();
        }
    }

    parseAgendaItems(startTimeString, endTimeString, agendaItemsString, presentersLeadString, presentersLeadIdString) {
        const startTimes = startTimeString ? startTimeString.split(';') : [];
        const endTimes = endTimeString ? endTimeString.split(';') : [];
        const agendaItems = agendaItemsString ? agendaItemsString.split(';') : [];
        const presentersLeads = presentersLeadString ? presentersLeadString.split(';') : [];
        const presentersLeadIds = presentersLeadIdString ? presentersLeadIdString.split(';') : [];

        const agendaList = [];
        const maxLength = Math.max(startTimes.length, endTimes.length, agendaItems.length, presentersLeads.length);

        for (let i = 0; i < maxLength; i++) {
            const agenda = {
                id: Date.now().toString() + i,
                startTime: startTimes[i] ? startTimes[i].trim() : '',
                endTime: endTimes[i] ? endTimes[i].trim() : '',
                agendaItems: agendaItems[i] ? agendaItems[i].trim() : '',
                presentersLeadName: presentersLeads[i] ? presentersLeads[i].trim() : '',
                presentersLead: presentersLeadIds[i] ? presentersLeadIds[i].trim() : '',
                showUserDropdown: false,
                userOptions: [],
                isEditing: false,
                showHoverCard: false,
                userDetails: {}
            };
            agendaList.push(agenda);
        }
        return agendaList;
    }*/

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

    handleSearchUsers3(event) {
        const agendaId = event.target.dataset.id;
        const searchTerm = event.target.value;
        if (searchTerm.length > 2) {
            searchUsers({ searchTerm })
                .then(data => {
                    this.agendaItems = this.agendaItems.map(agenda => {
                        if (agenda.id === agendaId) {
                            return {
                                ...agenda,
                                userOptions: data.map(user => ({ label: user.Name, value: user.Id, email: user.Email })),
                                showUserDropdown: data.length > 0
                            };
                        }
                        return agenda;
                    });
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
            this.agendaItems = this.agendaItems.map(agenda => {
                if (agenda.id === agendaId) {
                    return { ...agenda, showUserDropdown: false };
                }
                return agenda;
            });
        }
    }

    handleUserSelect3(event) {
        const agendaId = event.currentTarget.dataset.id;
        const userId = event.currentTarget.dataset.value;
        const userName = event.currentTarget.dataset.name;
        console.log('USERNAME IS:' + userName);

        this.agendaItems = this.agendaItems.map(agenda => {
            if (agenda.id === agendaId) {
                return { ...agenda, presentersLead: userId, presentersLeadName: userName, showUserDropdown: false };
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
            presentersLead: '',
            presentersLeadName: '',
            showUserDropdown: false,
            userOptions: [],
            isEditing: true,
            showHoverCard: false,
            userDetails: {}
        };
        this.agendaItems = [...this.agendaItems, newAgenda];
    }

    handleRemoveAgenda(event) {
        const agendaId = event.target.dataset.id;
        this.agendaItems = this.agendaItems.filter(agenda => agenda.id !== agendaId);
    }

    handleEditAgenda(event) {
        const agendaId = event.target.dataset.id;
        this.agendaItems = this.agendaItems.map(agenda => {
            if (agenda.id === agendaId) {
                return { ...agenda, isEditing: !agenda.isEditing };
            }
            return agenda;
        });
    }

    handleCancel() {
        this.fetchCurrentData();
    }

    handleNavigateToUser(event) {
        const agendaId = event.currentTarget.dataset.id;
        const agenda = this.agendaItems.find(item => item.id === agendaId);
        if (agenda && agenda.presentersLead) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: agenda.presentersLead,
                    objectApiName: 'User',
                    actionName: 'view'
                }
            });
        }
    }

    handleMouseOver(event) {
        const agendaId = event.currentTarget.dataset.id;
        const agenda = this.agendaItems.find(item => item.id === agendaId);
        if (agenda && agenda.presentersLead) {
            getUserDetails({ userId: agenda.presentersLead })
                .then(userDetails => {
                    this.agendaItems = this.agendaItems.map(item => {
                        if (item.id === agendaId) {
                            return { ...item, showHoverCard: true, userDetails };
                        }
                        return item;
                    });
                })
                .catch(error => {
                    console.error('Error fetching user details:', error);
                });
        }
    }

    handleMouseOut(event) {
        const agendaId = event.currentTarget.dataset.id;
        this.agendaItems = this.agendaItems.map(item => {
            if (item.id === agendaId) {
                return { ...item, showHoverCard: false };
            }
            return item;
        });
    }

    handleSave() {
       /* const meetingBriefData = {
            CRM_Start_Time__c: this.agendaItems.map(a => a.startTime).join('; '),
            CRM_StartTime_DetailField__c: this.agendaItems.map(a => a.startTime).join(';\r\n'),
            CRM_End_Time__c: this.agendaItems.map(a => a.endTime).join('; '),
            CRM_EndTime_DetailField__c: this.agendaItems.map(a => a.endTime).join(';\r\n'),
            CRM_Meeting_Agenda_Items__c: this.agendaItems.map(a => a.agendaItems).join('; '),
            CRM_Presenters_Conversation_Lead__c: this.agendaItems.map(a => a.presentersLead).join('; '),
            CRM_PresentersConversationLeadNames__c: this.agendaItems.map(a => a.presentersLeadName).join(';\r\n'),
            CRM_Presenters_Conversation_Lead_Id__c: this.agendaItems.map(a => a.presentersLead).join(';')
        };*/

        saveAgendaItems({ agendaItems: this.agendaItems, executiveMeetingId: this.recordId })
            .then(result => {
                this.agendaItems = this.agendaItems.map(agenda => {
                    return { ...agenda, isEditing: false };
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
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}