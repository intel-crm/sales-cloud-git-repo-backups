import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import loadData from "@salesforce/apex/Core_MDF_ApprovalHistoryController.loadData";
//16852 starts
//import loadAllApprovers from "@salesforce/apex/Core_MDF_ApprovalHistoryController.loadAllApprovers";
import getApprovalFlowData from '@salesforce/apex/Core_MDF_ApprovalHistoryController.getApprovalFlowData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEligibleApproversForRecord from '@salesforce/apex/Core_MDF_CampaignPFR_Controller.getEligibleApproversForRecord';
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
    @api identifierTextField1 = '';
    @api identifierTextField2 = '';
    @api identifierCheckboxField1 = '';
    @api identifierCheckboxField2 = '';
    @track dataLength = 0;
    @track dataLoaded = false;
    fullDataSet = [];
    @track columns = [];
    historyHeaderData;
    columnsWithWrapping = [];

    //16852 starts
    /*@track showAllApprovers = false;
    @track allApproversData = [];
    @track allApproversColumns = [];
    @track hasApprovers = false;*/
    @track showApprovalFlow = false;
    @track approvalFlowData = {};
    @track completedStepGroups = [];
    @track currentStepName = '';
    @track hasCurrentStep = false;
    @track isLoading = false;
    //@track shouldShowEndStep = false;
    labels = {SHOW_ALL_APPROVERS,APPROVAL_FLOW,START,PENDING,CLOSE};
    //16852 ends

    @wire(loadData, { recordId: "$recordId", identifierTextField1: "$identifierTextField1", identifierTextField2: "$identifierTextField2", identifierCheckboxField1: "$identifierCheckboxField1", identifierCheckboxField2: "$identifierCheckboxField2" })
    wiredApprovalHistoryData({ data, error }) {
        if (data) {
            this.fullDataSet = data.records;
            this.dataLength = data.records.length;
            this.columns = data.lstDataTableColumns;
            this.columns = this.columns.map(eachrow => ({
                ...eachrow,
                wrapText: true,
                hideDefaultActions: true
            }))
            this.historyHeaderData = data.TableTitle;
            this.dataLoaded = data.MDFound;
            this.isApprovalProcessComplete = data.isApprovalProcessComplete; //16852
            this.haserror = false;
        } else if (error) {
            this.haserror = true;
            this.data = undefined;
        }
    }

    //This function controls the height of the datatable based on the number of records.
    get setDatatableHeight() {
        if (this.dataLength > 10) {
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
                    console.log('Eligible approvers map: ', result.eligibleApprovers);
                    Object.keys(result.eligibleApprovers).forEach(key => {
                        console.log('Stage "${key}": ', result.eligibleApprovers[key]);
                    });
                } else {
                    console.log('No eligible approvers found in result');
                }
                this.processApprovalData();
            })
            .catch(error => {
                console.error('Error loading approval flow data:', error);
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
                    
                /*if (step.isQueue && step.queueMembers && step.queueMembers.length > 0) {
                    step.queueMembers.forEach(member => {
                        if (!stepGroups[stepKey].queueMembers.includes(member)) {
                            stepGroups[stepKey].queueMembers.push(member);
                        }
                    });
                }
                if (step.eligibleApprovers && step.eligibleApprovers.length > 0) {
                    const currentEligible = stepGroups[stepKey].eligibleApprovers || [];
                    console.log('currentEligible: ',currentEligible);
                    const mergedEligible = [...new Set([...currentEligible, ...step.eligibleApprovers])];
                    stepGroups[stepKey].eligibleApprovers = mergedEligible;
                }*/
            });
        }

        // Sort the steps by step number to maintain order
        this.completedStepGroups = Object.values(stepGroups)
        .sort((a, b) => a.stepNumber - b.stepNumber)
        .map(group => {
            //const uniqueEligibleApprovers = [...new Set(group.eligibleApprovers || [])];
            //const hasEligibleApprovers = group.eligibleApprovers && group.eligibleApprovers.length > 0;
            return {
                ...group,
                //eligibleApprovers: uniqueEligibleApprovers,
                uniqueKey: `${group.stepName}-${group.stepNumber}`,
                hasQueueMembers: group.queueMembers.length > 0,
                hasEligibleApprovers: false
            };
        });

        if (this.approvalFlowData.currentSteps && this.approvalFlowData.currentSteps.length > 0) {
            console.log('Test1: ', this.approvalFlowData.currentSteps);
            this.hasCurrentStep = true;
            const currentStep = this.approvalFlowData.currentSteps[0];
            console.log('Test2: ', currentStep);
            this.currentStepName = currentStep.stepName;
            this.approvalFlowData.currentStepApprovers = this.approvalFlowData.currentSteps.map(step => {
                console.log('step.eligibleApprovers: ',step.eligibleApprovers);
                const uniqueEligibleApprovers = [...new Set(step.eligibleApprovers || [])];
                console.log('uniqueEligibleApprovers: ', uniqueEligibleApprovers);
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

        //this.shouldShowEndStep = this.approvalFlowData.processStatus === 'Approved' || this.approvalFlowData.processStatus === 'Rejected';
    }

    closeModal() {
        this.showApprovalFlow = false;
        this.isLoading = false;
        this.approvalFlowData = {};
        this.completedStepGroups = [];
        this.hasCurrentStep = false;
        //this.shouldShowEndStep = false;
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
            // Standard users are internal, others (Partner, CustomerSuccess, etc.) are external
            return userType === STANDARD_USER_TYPE;
        }
        return false;
    }

    get shouldShowAllApproversButton() {
        console.log('shouldShowAllApproversButton1: ', this.dataLoaded);
        console.log('shouldShowAllApproversButton2: ', !this.isApprovalProcessComplete);
        console.log('shouldShowAllApproversButton3: ', this.isInternalUser);
        return this.dataLoaded && !this.isApprovalProcessComplete && this.isInternalUser;
    }
    //16852 ends
}