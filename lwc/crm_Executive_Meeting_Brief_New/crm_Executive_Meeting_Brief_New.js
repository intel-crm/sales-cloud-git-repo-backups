import { LightningElement, track, wire, api } from 'lwc';
import saveMeetingBrief from '@salesforce/apex/CRM_ExecutiveMeetingBrief_Controller.createMeetingBrief';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from 'lightning/actions';
import {CurrentPageReference} from 'lightning/navigation';

export default class Crm_Executive_Meeting_Brief_New extends NavigationMixin(LightningElement)  {
    @api recordId;
    @track crmExecutiveMeetingBriefName = '';
    @track crmScheduledStartTime = '';
    @track crmScheduledEndTime = '';
    @track accountID;

    @track showModal = true;

    connectedCallback(){
        console.log('Inside LWC connectedCallback:'+this.recordId);
        this.accountID = this.recordId;
        
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

    handleSave(event) {
        const buttonLabel = event.target.dataset.action;
        console.log('Inside handle save'+buttonLabel);
        const meetingBriefData = {
            Core_Executive_Meeting_Brief_Name__c: this.crmExecutiveMeetingBriefName,
            CRM_Scheduled_Start_Time__c: this.crmScheduledStartTime,
            CRM_Scheduled_End_Time__c: this.crmScheduledEndTime,
            Account__c: this.accountID
        };
        saveMeetingBrief({ meetingBriefData: meetingBriefData })
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
                    this.showModal = false;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            objectApiName: 'Executive_Meeting_Brief__c',
                            actionName: 'view'
                        }
                    });
                    eval("$A.get('e.force:refreshView').fire();");
                }

               if (buttonLabel === 'Save') {
                    // Close modal and navigate to the created record
                    this.showModal = false;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            objectApiName: 'Executive_Meeting_Brief__c',
                            actionName: 'view'
                        }
                    });
                    eval("$A.get('e.force:refreshView').fire();");
                    
                } else if (buttonLabel === 'Save and New') {
                    // Reset form for new record but keep modal open
                    this.resetForm();
                }
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

    // Reset form method
    resetForm() {
        this.crmExecutiveMeetingBriefName = '';
        this.crmScheduledStartTime = '';
        this.crmScheduledEndTime = '';
        // Keep accountID if it was passed from parent, otherwise reset it
        if (!this.recordId) {
            this.accountID = '';
        }
    }


    handleCancel() {
    console.log('Form cancelled');
    this.showModal = false;
    
    // Navigate to Executive Meeting Brief list view
    this[NavigationMixin.Navigate]({
        type: 'standard__objectPage',
        attributes: {
            objectApiName: 'Executive_Meeting_Brief__c',    
            actionName: 'list'
        },
        state: {
            filterName: 'All' // Optional: you can specify a specific list view
        }
    });
    
    const cancelEvent = new CustomEvent('modalclose');
    this.dispatchEvent(cancelEvent);
    eval("$A.get('e.force:refreshView').fire();");
}

}