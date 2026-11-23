import { LightningElement, track, api } from 'lwc';
import getExecutiveMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getExecutiveMeetingBriefData';
import updateMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.updateMeetingBriefData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Crm_ExecutiveMeetingBrief_Background extends LightningElement {
    @api recordId;
    formats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'align',
        'link',
        'image',
        'clean',
        'table',
        'header',
        'color',
    ];

    @track backgroundItems = [
        {
            id: Date.now().toString(),
            backgroundObjective1: '',
            agendaTopic: '',
            proactiveTalkingPoints: '',
            reactiveTalkingPoints: '',
            isEditing: true
        }
    ];
    @track EMBBackgroundedit = false;
    connectedCallback() {
        this.fetchCurrentData();
    }

    fetchCurrentData() {
        getExecutiveMeetingBriefData({ executiveMeetingId: this.recordId })
            .then(result => {
                this.executiveBriefData = result;
                this.error = undefined;
                this.populateFormFields(this.executiveBriefData);
            })
            .catch(error => {
                this.error = error;
                this.executiveBriefData = undefined;
            });
    }

    populateFormFields(data) {
        //this.backgroundItems = this.parseBackgroundItems(data.CRM_Background_Objective1__c, data.CRM_Proactive_Talking_Points__c, data.CRM_Reactive_Talking_Points__c, data.CRM_Agenda_Topic_backendField__c);
        const items = this.parseBackgroundItems(data.CRM_Background_Objective1__c, data.CRM_Proactive_Talking_Points__c, data.CRM_Reactive_Talking_Points__c, data.CRM_Agenda_Topic_backendField__c);
        if (items.length === 0) {
            items.push({
                id: Date.now().toString(),
                backgroundObjective1: '',
                agendaTopic: '',
                proactiveTalkingPoints: '',
                reactiveTalkingPoints: '',
                label: 'Objective 1',
                isEditing: false
            });
        }
        this.backgroundItems = items;
    }

    parseBackgroundItems(objectiveString, proactivePointsString, reactivePointsString, agendaTopicString) {
        const objectives = objectiveString ? objectiveString.split(';\n') : [];
        console.log('objectives:: ', objectives);
        const proactivePoints = proactivePointsString ? proactivePointsString.split(';\n') : [];
        const reactivePoints = reactivePointsString ? reactivePointsString.split(';\n') : [];
        const agendaTopics = agendaTopicString ? agendaTopicString.split(';') : [];

        const backgroundList = [];
        const maxLength = Math.max(objectives.length, proactivePoints.length, reactivePoints.length);
        this.EMBBackgroundedit = false;
        for (let i = 0; i < maxLength; i++) {
            const background = {
                id: Date.now().toString() + i,
                backgroundObjective1: objectives[i] ? objectives[i].trim() : '',
                agendaTopic: agendaTopics[i] ? agendaTopics[i].trim() : '',
                proactiveTalkingPoints: proactivePoints[i] ? proactivePoints[i].trim() : '',
                reactiveTalkingPoints: reactivePoints[i] ? reactivePoints[i].trim() : '',
                label: `Objectives ${i + 1}`,
                isEditing: false
            };
            backgroundList.push(background);
        }
        return backgroundList;
    }

    handleInputChange(event) {
        const backgroundId = event.target.dataset.id;
        const field = event.target.dataset.field;
        const value = event.target.value;

        this.backgroundItems = this.backgroundItems.map(background => {
            if (background.id === backgroundId) {
                return { ...background, [field]: value };
            }
            return background;
        });
    }

    handleEdit(event) {
        const backgroundId = event.target.dataset.id;
        this.EMBBackgroundedit = !this.EMBBackgroundedit;
        this.backgroundItems = this.backgroundItems.map(background => {
            if (background.id === backgroundId) {
                background.isEditing = !background.isEditing;
            }
            return background;
        });
    }

    handleAddRow() {
        const newBackground = {
            id: Date.now().toString(),
            backgroundObjective1: '',
            agendaTopic: '',
            proactiveTalkingPoints: '',
            reactiveTalkingPoints: '',
            isEditing: false
        };
        this.EMBBackgroundedit = false;
        this.backgroundItems = [...this.backgroundItems, newBackground];
        this.updateBackgroundLabels();
    }

    updateBackgroundLabels() {
        this.backgroundItems = this.backgroundItems.map((background, index) => {
            background.label = `Objectives ${(index + 1)}`;
            return background;
        });
    }

    handleDeleteRow(event) {
        const backgroundId = event.target.dataset.id;
        this.backgroundItems = this.backgroundItems.filter(background => background.id !== backgroundId);
        this.EMBBackgroundedit = false;
        this.updateBackgroundLabels();
    }

    handleCancel() {
        // Reset the editing state
        this.EMBBackgroundedit = false;

        // Refetch the current data to reset the form to its original state
        this.fetchCurrentData();
    }

    handleSave() {

        const meetingBriefData = {
            CRM_Background_Objective1__c: this.backgroundItems.map(b => b.backgroundObjective1).join(';\r\n'),
            CRM_Proactive_Talking_Points__c: this.backgroundItems.map(b => b.proactiveTalkingPoints).join(';\r\n'),
            CRM_Reactive_Talking_Points__c: this.backgroundItems.map(b => b.reactiveTalkingPoints).join(';\r\n'),
            CRM_Agenda_Topic_backendField__c: this.backgroundItems.map(b => b.agendaTopic).join(';\r\n'),
        };
        updateMeetingBriefData({ meetingBriefData: meetingBriefData, executiveMeetingId: this.recordId, fieldUpdated: 'Background' })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Executive Meeting Brief updated successfully',
                        variant: 'success'
                    })
                );
                this.backgroundItems = this.backgroundItems.map(background => {
                    background.isEditing = false;
                    return background;
                });
                this.EMBBackgroundedit = false;
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