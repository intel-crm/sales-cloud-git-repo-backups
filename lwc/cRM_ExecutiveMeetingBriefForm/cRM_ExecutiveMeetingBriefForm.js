import { LightningElement, track, wire, api } from 'lwc';
import saveMeetingBrief from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.saveMeetingBrief';
//import getUsers from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getUsers'; // delete it
//import searchUsers from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchUsers'; /// delete it
//import searchAttendees from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.searchAttendees'; // detele it
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getExecutiveMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getExecutiveMeetingBriefData';
import { CloseActionScreenEvent } from 'lightning/actions';
import {CurrentPageReference} from 'lightning/navigation';

export default class Crm_ExecutiveMeetingBriefEdit extends NavigationMixin(LightningElement) { 
    @api recordId;
    @track crmIntelsMeetingObjectives = '';
    @track crmOtherPartysMeetingObjectives = '';
    @track crmMostCriticalMessages = '';
    @track crmEventEngagementName = '';
    @track crmScheduledStartTime = '';
    @track crmScheduledEndTime = '';
    @track accountID;

    @track showModal = true;
    @track editMode = false;
    @track uploadedFiles;

    connectedCallback(){

        this.accountID = this.recordId;
        console.log('Inside connectedCallback:'+this.recordId);
    }

    /*@wire(CurrentPageReference)
    getStateParameters(currentPageReference){
        if(currentPageReference){
            this.accountID = currentPageReference.state.c__accountId;
        }
    }*/

    /*connectedCallback(){
        this.getAccountIdFromUrl();
    }
   
    getAccountIdFromUrl(){
            this.accountID = this.CurrentPageReference.state.c__accountId;
            console.log(this.accountID);
        
    }*/


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

    handleAccountChange(event){
        console.log('INSIDE HANDLE ACC CHANGE:::'+event.target.dataset);
        this.accountID = event.detail.recordId;
        console.log('INSIDE HANDLE ACC CHANGE ACC ID:'+this.accountID);
    }

    get acceptedFormats() {
        return ['.pdf', '.doc', '.docx'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
         this.uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + this.uploadedFiles.length);
    }

    handleSave() {
        debugger;
        const meetingBriefData = {
            CRM_Event_Engagement_Name__c: this.crmEventEngagementName,
            CRM_Scheduled_Start_Time__c: this.crmScheduledStartTime,
            CRM_Scheduled_End_Time__c: this.crmScheduledEndTime,
            Account__c: this.accountID,
            CRM_Intels_Meeting_Objectives__c: this.crmIntelsMeetingObjectives,
            CRM_Other_Partys_Meeting_Objectives__c: this.crmOtherPartysMeetingObjectives,
            CRM_Most_Critical_Messages_to_Get_Across__c: this.crmMostCriticalMessages,
            CRM_Additional_Information__c: this.crmAdditionalInformation
        };
        console.log('Meeting Brief Data:', meetingBriefData);      
         console.log('Meeting Brief UPLOAD FILES:', this.uploadedFiles);
        saveMeetingBrief({ meetingBriefData: meetingBriefData, editMode: this.editMode, recordId: this.recordId, uploadedFiles: this.uploadedFiles })
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
        const cancelEvent = new CustomEvent('modalclose');
        this.dispatchEvent(cancelEvent);
        eval("$A.get('e.force:refreshView').fire();");
        /*this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'Executive_Meeting_Brief__c',
            actionName: 'view'
        },
    });*/
    }

}