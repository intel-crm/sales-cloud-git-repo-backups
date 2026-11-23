import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue,getRecordNotifyChange } from 'lightning/uiRecordApi';
import checkMandatoryFields from '@salesforce/apex/CRM_ExecutiveMeetingBrief_Utility.checkMandatoryFields';
import fetchExecutiveMeetingBriefDetails from '@salesforce/apex/CRM_EMB_AI_Integration_Outbound.fetchExecutiveMeetingBriefDetails';
import updateExecutiveBriefStatus from '@salesforce/apex/CRM_EMB_AI_Integration_Outbound.updateExecutiveBriefStatus';

 
import AGENTIC_BRIEF_STATUS_FIELD from '@salesforce/schema/Executive_Meeting_Brief__c.CRM_Agentic_Drafting_Status__c';

export default class crm_Executive_Meeting_Brief_Agentic extends LightningElement {

    @api recordId;
    @track isLoading = false;
    @track showProceedDialog = true;

    // Wire service to get record data
    @wire(getRecord, { recordId: '$recordId', fields: [AGENTIC_BRIEF_STATUS_FIELD] })
    recordData;

    get agenticStatus() {
        return getFieldValue(this.recordData.data, AGENTIC_BRIEF_STATUS_FIELD);
    }

    get isGenerationInProgress() {
        return this.agenticStatus === 'In Progress';
    }

    async handleNext() {
        // Check if generation is already in progress
        if (this.isGenerationInProgress) {
            this.showInProgressToast();
            this.dispatchEvent(new CloseActionScreenEvent());
            return;
        }

        try {
            this.isLoading = true;
            
            // Check mandatory fields
            const result = await checkMandatoryFields({ recordId: this.recordId });
            
            if (result !== 'SUCCESS' && result.length > 0) {
                const missingFields = result.replace(/.*fields:/, '');
                this.showValidationToast(`Please fill out the mandatory fields before proceeding: ${missingFields}`);
                this.isLoading = false;
                return;
            } 
            else {
                const briefRecIds = [this.recordId];
                const briefStatusUpdate = await updateExecutiveBriefStatus({ 
                    briefIds: briefRecIds 
                });
                await getRecordNotifyChange([{recordId: this.recordId}]);

                await this.agenticBriefGeneration();
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Agentic Brief Generation started successfully!',
                        variant: 'success'
                    })
                );
                
                this.dispatchEvent(new CloseActionScreenEvent());

                
            }
            
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An error occurred: ' + (error.body?.message || error.message),
                    variant: 'error'
                })
            );
            this.dispatchEvent(new CloseActionScreenEvent());
        } finally {
            this.isLoading = false;
        }
    }

    showInProgressToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Generation In Progress',
                message: 'Agentic brief generation is already in progress for this record. Please wait for it to complete.',
                variant: 'warning'
            })
        );
        
      this.dispatchEvent(new CloseActionScreenEvent());
    }

    showValidationToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Required Fields Missing',
                message: message,
                variant: 'error'
            })
        );
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async agenticBriefGeneration() {
        try {
            const briefRecordIds = [this.recordId];
            
            const briefDetails = await fetchExecutiveMeetingBriefDetails({ 
                briefRecordIds: briefRecordIds 
            });
            
            
        } catch (error) {
            throw error;
        }
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}