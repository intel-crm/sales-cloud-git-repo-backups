import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import loadData from "@salesforce/apex/Core_MDF_ApprovalHistoryController.loadData";
//16852 starts
import getApprovalFlowData from '@salesforce/apex/Core_MDF_ApprovalHistoryController.getApprovalFlowData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import USER_TYPE_FIELD from '@salesforce/schema/User.UserType';
import STANDARD_USER_TYPE from '@salesforce/label/c.Core_MDF_ReleaseHold_StandardUserType';
import SHOW_ALL_APPROVERS from '@salesforce/label/c.Core_MDF_ShowAllApprovers';
import APPROVAL_FLOW from '@salesforce/label/c.Core_MDF_ApprovalFlow';
import START from '@salesforce/label/c.Core_MDF_Start_ApprovalStep';
import PENDING from '@salesforce/label/c.Core_MDF_PendingStatus';
import CLOSE from '@salesforce/label/c.Core_MDF_Close';
//16852 ends
  
    
export default class Core_MDF_ApprovalHistoryViewAll extends NavigationMixin(LightningElement) {
      //@track columns = columns;
      @api recordId;
      @track haserror;
      @api identifierTextField1='';
      @api identifierTextField2='';
      @api identifierCheckboxField1='';
      @api identifierCheckboxField2='';
      @track dataLength=0;
      @track dataLoaded=false;
      fullDataSet = [];
      @track columns = [];
      historyHeaderData;
      columnsWithWrapping = [];

    //16852 starts
    @track showApprovalFlow = false;
    @track approvalFlowData = {};
    @track completedStepGroups = [];
    @track currentStepName = '';
    @track hasCurrentStep = false;
    @track isLoading = false;
    labels = {SHOW_ALL_APPROVERS,APPROVAL_FLOW,START,PENDING,CLOSE};
    //16852 ends

      @wire(loadData, {recordId: "$recordId", identifierTextField1:"$identifierTextField1", identifierTextField2:"$identifierTextField2", identifierCheckboxField1:"$identifierCheckboxField1", identifierCheckboxField2:"$identifierCheckboxField2"})
      wiredApprovalHistoryData({data,error}) {
        if (data) {
              this.fullDataSet = data.records;
              this.dataLength = data.records.length;
              this.columns = data.lstDataTableColumns;
              this.columns = this.columns.map(eachrow => ({
                ...eachrow,
                wrapText: true,
                hideDefaultActions : true
              }))
              this.historyHeaderData = data.TableTitle;
              this.dataLoaded=data.MDFound;
            this.isApprovalProcessComplete = data.isApprovalProcessComplete; //16852
              this.haserror=false;
          } else if (error) {
              this.haserror=true;
              this.data=undefined;
        }
     }    

    //This function controls the height of the datatable based on the number of records.
    get setDatatableHeight() {
      if(this.dataLength > 10){
        return 'height:27rem;border-bottom: 1px solid;';
      }
      return '';
  }

    //16852 starts
    handleShowAllApprovers() {
        this.showApprovalFlow = true;
        this.loadApprovalFlowData();
    }
    loadApprovalFlowData() {
        this.isLoading = true;
        getApprovalFlowData({ recordId: this.recordId })
            .then(result => {
                this.approvalFlowData = result;
                if (result.eligibleApprovers) {
                    Object.keys(result.eligibleApprovers).forEach(key => {
                        console.log('Stage "${key}": ', result.eligibleApprovers[key]);
                    });
                } else {
                    console.log('No eligible approvers found in result');
                }
                this.processApprovalData();
            })
            .catch(error => {
                this.showToast('Error', 'Failed to load approval flow data: ' + (error.body?.message || error.message), 'error');
                this.closeModal();
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    processApprovalData() {
        const stepGroups = {};
        if (this.approvalFlowData.completedSteps) {
            this.approvalFlowData.completedSteps.forEach(step => {
                const stepKey = step.stepName;
                if (!stepGroups[stepKey]) {
                    stepGroups[stepKey] = {
                        stepName: step.stepName,
                        stepStatus: step.status,
                        stepNumber: step.stepNumber,
                        approvers: [],
                        queueMembers: [],
                        eligibleApprovers: [],
                        stepType: 'completed'
                    };
                }
                const approverName = step.actualApprover;
                const assignedApprover = step.assignedApprover;
                const approverKey = assignedApprover + '-' + approverName;
                const existingApprover = stepGroups[stepKey].approvers.find(app => app.key === approverKey);
                if (!existingApprover) {
                    stepGroups[stepKey].approvers.push({
                        assignedApprover: assignedApprover,
                        actualApprover: approverName,
                        key: approverKey
                    });
                }
            });
        }
        this.completedStepGroups = Object.values(stepGroups)
        .sort((a, b) => a.stepNumber - b.stepNumber)
        .map(group => {
            return {
                ...group,
                uniqueKey: `${group.stepName}-${group.stepNumber}`,
                hasQueueMembers: group.queueMembers.length > 0,
                hasEligibleApprovers: false
            };
        });
        if (this.approvalFlowData.currentSteps && this.approvalFlowData.currentSteps.length > 0) {
            this.hasCurrentStep = true;
            const currentStep = this.approvalFlowData.currentSteps[0];
            this.currentStepName = currentStep.stepName;
            this.approvalFlowData.currentStepApprovers = this.approvalFlowData.currentSteps.map(step => {
            if (this.recordId && this.recordId.startsWith('0RJ') && (!step.eligibleApprovers || step.eligibleApprovers.length === 0) && step.stepName === 'Level 1 Approval' && this.approvalFlowData.eligibleApprovers && this.approvalFlowData.eligibleApprovers['L1 Approval']) {
                step.eligibleApprovers = this.approvalFlowData.eligibleApprovers['L1 Approval'];
            }

            if (this.recordId && this.recordId.startsWith('0RJ') && (!step.eligibleApprovers || step.eligibleApprovers.length === 0) && step.stepName === 'L2 Marketing' && this.approvalFlowData.eligibleApprovers && this.approvalFlowData.eligibleApprovers['L2 Regional Marketing']) {
                step.eligibleApprovers = this.approvalFlowData.eligibleApprovers['L2 Regional Marketing'];
            }

            if (this.recordId && this.recordId.startsWith('0RJ') && (!step.eligibleApprovers || step.eligibleApprovers.length === 0) && step.stepName === 'L2 Sales' && this.approvalFlowData.eligibleApprovers && this.approvalFlowData.eligibleApprovers['L2 Regional Sales']) {
                step.eligibleApprovers = this.approvalFlowData.eligibleApprovers['L2 Regional Sales'];
            }
                const uniqueEligibleApprovers = [...new Set(step.eligibleApprovers || [])];
                return {
                    name: step.assignedApprover || step.actualApprover,
                    stepName: step.stepName,
                    stepStatus: step.status,
                    isQueue: step.isQueue,
                    queueMembers: step.queueMembers || [],
                    eligibleApprovers: uniqueEligibleApprovers,
                    hasEligibleApprovers: uniqueEligibleApprovers.length > 0
                };
            });
        }
        else {
            this.hasCurrentStep = false;
        }
    }
    closeModal() {
        this.showApprovalFlow = false;
        this.isLoading = false;
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
    @wire(getRecord, { recordId: USER_ID, fields: [USER_TYPE_FIELD] })
    userRecord;
    get isInternalUser() {
        if (this.userRecord && this.userRecord.data) {
            const userType = this.userRecord.data.fields.UserType.value;
            return userType === STANDARD_USER_TYPE;
        }
        return false;
    }
    get shouldShowAllApproversButton() {
        return this.dataLoaded && !this.isApprovalProcessComplete && this.isInternalUser;
    }
    //16852 ends
}