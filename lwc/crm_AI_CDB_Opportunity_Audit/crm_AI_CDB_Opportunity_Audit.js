import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue,getRecordNotifyChange } from 'lightning/uiRecordApi';
//import checkMandatoryFields from '@salesforce/apex/CRM_ExecutiveMeetingaudit_Utility.checkMandatoryFields';
import fetchExecutiveMeetingBriefDetails from '@salesforce/apex/CRM_EMB_AI_Integration_Outbound.fetchExecutiveMeetingBriefDetails';
import updateOpportunityAIStatus from '@salesforce/apex/CRM_AI_Opportunity_Integration.updateOpportunityAIStatus';

 
import AGENTIC_AUDIT_STATUS_FIELD from '@salesforce/schema/Opportunity.CRM_AI_Status__c';

export default class Crm_AI_CDB_Opportunity_Audit extends LightningElement {

    @api recordId;
    @track isLoading = false;
    @track showProceedDialog = true;

    // Wire service to get record data
    @wire(getRecord, { recordId: '$recordId', fields: [AGENTIC_AUDIT_STATUS_FIELD] })
    recordData;

    get agenticStatus() {
        return getFieldValue(this.recordData.data, AGENTIC_AUDIT_STATUS_FIELD);
    }

    get isGenerationInProgress() {
        return this.agenticStatus === 'In Progress';
    }

    async handleNext() {

        try {
            this.isLoading = true;
            
            // Check mandatory fields
            /*const result = await checkMandatoryFields({ recordId: this.recordId });
            
            if (result !== 'SUCCESS' && result.length > 0) {
                const missingFields = result.replace(/.*fields:/, '');
                this.showValidationToast(`Please fill out the mandatory fields before proceeding: ${missingFields}`);
                this.isLoading = false;
                return;
            } 
            else {*/
                const oppRecIds = [this.recordId];
                const auditStatusUpdate = await updateOpportunityAIStatus({ 
                    oppyIds: oppRecIds 
                });
                await getRecordNotifyChange([{recordId: this.recordId}]);

                await this.agenticauditGeneration();
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'AI Audit started successfully!',
                        variant: 'success'
                    })
                );
                
                this.dispatchEvent(new CloseActionScreenEvent());

                
            //}
            
        } catch (error) {
            console.error('Error:', error);
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
                title: 'AI Audit In Progress',
                message: 'AI Audit is already in progress for this record. Please wait for it to complete.',
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

    async agenticauditGeneration() {
        try {
            const auditRecordIds = [this.recordId];
            
            const auditDetails = await fetchExecutiveMeetingBriefDetails({ 
                auditRecordIds: auditRecordIds 
            });
            
            
        } catch (error) {
            console.error('Error fetching audit details:', error);
            throw error;
        }
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}