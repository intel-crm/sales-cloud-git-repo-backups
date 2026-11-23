import { LightningElement, api, track } from 'lwc';
import getApprovalFlowData from '@salesforce/apex/Core_MDF_ApprovalHistoryController.getApprovalFlowData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Core_MDF_Display_Approver_Details extends LightningElement {
    @api recordId;
    @track showApprovalFlow = false;
    @track approvalFlowData = {};
    @track completedStepGroups = [];
    @track currentStepName = '';
    @track hasCurrentStep = false;
    @track isLoading = false;

    handleShowAllApprovers() {
        this.showApprovalFlow = true;
        this.loadApprovalFlowData();
    }

    loadApprovalFlowData() {
        this.isLoading = true;
        
        getApprovalFlowData({ recordId: this.recordId })
            .then(result => {
                this.approvalFlowData = result;
                this.processApprovalData();
            })
            .catch(error => {
                console.error('Error loading approval flow data:', error);
                this.showToast('Error', 'Failed to load approval flow data: ' + (error.body?.message || error.message), 'error');
                this.closeModal(); // Close modal on error
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    processApprovalData() {
        // Group completed steps by step name
        const stepGroups = {};
        
        if (this.approvalFlowData.completedSteps) {
            this.approvalFlowData.completedSteps.forEach(step => {
                const stepName = step.ProcessNode?.Name || 'Approval Step';
                
                if (!stepGroups[stepName]) {
                    stepGroups[stepName] = {
                        stepName: stepName,
                        groupName: this.getGroupName(stepName),
                        approvers: []
                    };
                }
                
                const approverName = step.Actor?.Name || 'Unknown Approver';
                if (!stepGroups[stepName].approvers.includes(approverName)) {
                    stepGroups[stepName].approvers.push(approverName);
                }
            });
        }

        this.completedStepGroups = Object.values(stepGroups);
        
        // Set current step info
        if (this.approvalFlowData.currentStepApprovers && 
            this.approvalFlowData.currentStepApprovers.length > 0) {
            this.hasCurrentStep = true;
            this.currentStepName = 'Second Level Approver'; // You can make this dynamic
        }
    }

    getGroupName(stepName) {
        // Map step names to group names based on your approval process
        const stepGroupMap = {
            'Approver': 'Approver-SFDC Co-MarketingL2 Approvers',
            'Second Level Approver': 'Approver-Co-Marketing-Salesforce-MDF Budget Manager CCF-Approvers'
        };
        
        return stepGroupMap[stepName] || stepName;
    }

    closeModal() {
        this.showApprovalFlow = false;
        this.isLoading = false;
        // Reset data when closing
        this.approvalFlowData = {};
        this.completedStepGroups = [];
        this.hasCurrentStep = false;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}