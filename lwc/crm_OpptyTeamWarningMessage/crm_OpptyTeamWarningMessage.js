import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Replace 'Opty_Team_100_Percent_Roles' with your Custom Label API Name in Setup -> Custom Labels:
import TEAM_MEMBER_ROLES_LABEL from '@salesforce/label/c.CRM_commissionEligibleRoles';
import WARNING_MESSAGE_LABEL from '@salesforce/label/c.CRM_maxCommissionEligibleWarning';

const BASE_FIELDS = ['Opportunity.LastModifiedDate'];

export default class Crm_OpptyTeamWarningMessage extends LightningElement {
    _recordId;

    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        if (this._recordId !== value) {
            this._recordId = value;
            this.resetState();
        }
    }

    // Specify the Opportunity field API name updated by the Approval Process
    // (e.g. 'Core_Approval_Status__c' or 'StageName').
    @api statusFieldApiName = 'Core_Approval_Status__c';
    @api approvedValue = 'Approved';

    // OpportunityTeamMember Role field and full role names to count (from Custom Label or App Builder)
    @api teamMemberFieldApiName = 'TeamMemberRole';
    @api teamMemberFieldValues = TEAM_MEMBER_ROLES_LABEL;

    @api maxTeamMembers = 4;
    @api warningTitle = 'Warning!';
    @api warningMessage = WARNING_MESSAGE_LABEL;

    teamMemberCount;
    isInitialized = false;
    previousModifiedDate;
    previousStatus;
    pendingWarningEvaluation = false;
    showWarningBanner = false;

    resetState() {
        this.teamMemberCount = undefined;
        this.isInitialized = false;
        this.previousModifiedDate = undefined;
        this.previousStatus = undefined;
        this.pendingWarningEvaluation = false;
        this.showWarningBanner = false;
    }

    get normalizedFieldName() {
        if (!this.statusFieldApiName) {
            return '';
        }
        const trimmed = this.statusFieldApiName.trim();
        return trimmed.startsWith('Opportunity.')
            ? trimmed.slice('Opportunity.'.length)
            : trimmed;
    }

    get optionalFields() {
        const fieldName = this.normalizedFieldName;
        return fieldName ? [`Opportunity.${fieldName}`] : [];
    }

    get normalizedTeamMemberFieldName() {
        if (!this.teamMemberFieldApiName) {
            return '';
        }
        const trimmed = this.teamMemberFieldApiName.trim();
        return trimmed.startsWith('OpportunityTeamMember.')
            ? trimmed.slice('OpportunityTeamMember.'.length)
            : trimmed;
    }

    get teamMemberFields() {
        const fields = ['OpportunityTeamMember.Id'];
        const fieldName = this.normalizedTeamMemberFieldName;
        if (fieldName) {
            fields.push(`OpportunityTeamMember.${fieldName}`);
        }
        return fields;
    }

    get allowedTeamMemberValues() {
        // Uses Custom Label by default, or App Builder override if specified
        const rawValues = this.teamMemberFieldValues || TEAM_MEMBER_ROLES_LABEL || '';
        return rawValues
            .split(/[,;\n]+/)
            .map((val) => val.trim().toLowerCase())
            .filter(Boolean);
    }

    get computedWarningMessage() {
        const countText = this.teamMemberCount !== undefined ? this.teamMemberCount : '';
        return (this.warningMessage || '').replace('{count}', countText);
    }

    // 1. Fetch Opportunity Team Members and count matching records (no Apex needed)
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'OpportunityTeamMembers',
        fields: '$teamMemberFields',
        pageSize: 200
    })
    wiredTeamMemberRecords({ data, error }) {
        if (data) {
            const records = data.records || [];
            const fieldName = this.normalizedTeamMemberFieldName;
            const targetValues = this.allowedTeamMemberValues;

            if (fieldName && targetValues.length > 0) {
                const matchingRecords = records.filter((rec) => {
                    const fieldData = rec.fields?.[fieldName];
                    const rawVal = String(fieldData?.value ?? '').trim().toLowerCase();
                    const displayVal = String(fieldData?.displayValue ?? '').trim().toLowerCase();
                    return targetValues.includes(rawVal) || targetValues.includes(displayVal);
                });
                this.teamMemberCount = matchingRecords.length;
            } else {
                this.teamMemberCount = records.length;
            }

            if (this.pendingWarningEvaluation) {
                this.pendingWarningEvaluation = false;
                this.evaluateAndShowWarning();
            }
        } else if (error) {
            console.error('Error loading OpportunityTeamMembers:', JSON.stringify(error));
        }
    }

    // 2. Watch Opportunity status field updates and trigger only when status transitions to Approved
    @wire(getRecord, {
        recordId: '$recordId',
        fields: BASE_FIELDS,
        optionalFields: '$optionalFields'
    })
    wiredOpportunity({ data, error }) {
        if (data) {
            const fieldName = this.normalizedFieldName;
            if (!fieldName || data.fields?.[fieldName] === undefined) {
                return;
            }

            const currentModifiedDate = data.fields?.LastModifiedDate?.value;
            const currentStatus = data.fields[fieldName]?.value;

            // Capture initial record state when the record first loads
            if (!this.isInitialized) {
                this.isInitialized = true;
                this.previousModifiedDate = currentModifiedDate;
                this.previousStatus = currentStatus;
                return;
            }

            const recordUpdated =
                Boolean(currentModifiedDate && this.previousModifiedDate) &&
                currentModifiedDate !== this.previousModifiedDate;

            const targetApproved = (this.approvedValue || 'Approved').trim().toLowerCase();
            const prevNormalized = String(this.previousStatus ?? '').trim().toLowerCase();
            const currNormalized = String(currentStatus ?? '').trim().toLowerCase();

            const statusChangedToApproved =
                recordUpdated &&
                prevNormalized !== currNormalized &&
                currNormalized === targetApproved;

            if (recordUpdated && currNormalized !== targetApproved) {
                this.showWarningBanner = false;
            }

            this.previousModifiedDate = currentModifiedDate;
            this.previousStatus = currentStatus;

            if (statusChangedToApproved) {
                if (this.teamMemberCount !== undefined) {
                    this.evaluateAndShowWarning();
                } else {
                    this.pendingWarningEvaluation = true;
                }
            }
        } else if (error) {
            console.error('Error loading Opportunity record:', JSON.stringify(error));
        }
    }

    evaluateAndShowWarning() {
        const threshold = Number(this.maxTeamMembers) || 4;
        if (this.teamMemberCount > threshold) {
            this.showWarningBanner = true;
            this.showWarningToast();
        }
    }

    showWarningToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.warningTitle,
                message: this.computedWarningMessage,
                variant: 'warning',
                mode: 'sticky'
            })
        );
    }

    handleDismissBanner() {
        this.showWarningBanner = false;
    }
}