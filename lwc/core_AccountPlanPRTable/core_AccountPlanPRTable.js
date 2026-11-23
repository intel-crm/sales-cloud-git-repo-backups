import { LightningElement, api, track, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import ACCOUNT_PLAN_OBJECT from '@salesforce/schema/CRM_Intel_Account_Plan_Rev__c';
import YEAR_FIELD from '@salesforce/schema/CRM_Intel_Account_Plan_Rev__c.CRM_Year__c';
import BU_FIELD from '@salesforce/schema/CRM_Intel_Account_Plan_Rev__c.CRM_BU__c';
import AMOUNT_FIELD from '@salesforce/schema/CRM_Intel_Account_Plan_Rev__c.CRM_Account_Potential_Revenue__c';
import ACCOUNT_FIELD from '@salesforce/schema/CRM_Intel_Account_Plan_Rev__c.CRM_Account_Plan__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getAccountPlans from '@salesforce/apex/core_AccountPlanRevenueController.getAccountPlans';
import { deleteRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
export default class CoreIntelAccountPlan extends LightningElement {
    @api recordId; // Account Id
    @track accountPlans = [];
    @track isExpanded = false;
    @track isLoading = false;
    isLoading = false;
    @track yearOptions = [];
    @track buOptions = [];
    wiredAccountPlansResult;

    get toggleIconName() {
        return this.isExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    toggleSection() {
        this.isExpanded = !this.isExpanded;
    }
    @wire(getObjectInfo, { objectApiName: ACCOUNT_PLAN_OBJECT })
    objectInfo;
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: YEAR_FIELD
    })
    wiredYearPicklist({ data, error }) {
        if (data) {
            // Sort values descending by label (assuming year format like '2025')
            this.yearOptions = [...data.values].sort((a, b) => parseInt(a.label) - parseInt(b.label));
        } else if (error) {
            console.error('Error loading Year picklist values:', error);
        }
    }
    
   /* @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: BU_FIELD
    })
    wiredBUPicklist({ data, error }) {
        if (data) {
            this.buOptions = data.values;
        } else if (error) {
            console.error('Error loading BU picklist values:', error);
        }
    }*/
    // Fetch existing Account Plan records
    @wire(getAccountPlans, { accountplanId: '$recordId' })
    wiredAccountPlans(result) {
        this.wiredAccountPlansResult = result;
        if (result.data) {
            this.accountPlans = result.data.map(plan => ({
                id: plan.Id,
                year: plan.CRM_Year__c,
                bu: plan.CRM_BU__c,
                amount: plan.CRM_Account_Potential_Revenue__c
            })).sort((a, b) => parseInt(a.year) - parseInt(b.year));
        } else if (result.error) {
            this.showToast('Error', 'Failed to load Account Plans', 'error');
            console.error(result.error);
        }

        // If no rows exist, add a dummy row with placeholders
        if (this.accountPlans.length === 0) {
            this.accountPlans = [
                {
                    id: 'dummy_' + Date.now(),
                    year: '',
                    bu: '',
                    amount: ''
                }
            ];
        }
    }

    handleAddRow() {
        // Add a new row with placeholder data
        this.accountPlans = [
            ...this.accountPlans,
            {
                id: 'new_' + Date.now(),
                year: '',
                bu: '',
                amount: ''
            }
        ];
    }
    handleRemoveRow(event) {
        const index = event.target.dataset.index;
        const plan = this.accountPlans[index];
        const planId = plan.id;
    
        // Always remove from UI first
        this.accountPlans = this.accountPlans.filter((_, i) => i !== index);
    
        // If it's a dummy row, no server call needed
        if (planId && planId.startsWith('dummy_')) {
            console.log('Removed dummy row at index:', index);
            return;
        }
    
        // If it's a valid Salesforce record, delete it
        if (planId && planId.length === 18) {
            this.isLoading = true;
            deleteRecord(planId)
                .then(() => {
                    this.showToast('Success', 'Account Plan deleted', 'success');
                    return refreshApex(this.wiredAccountPlansResult);
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to delete Account Plan', 'error');
                    console.error('Error deleting record:', error);
                })
                .finally(() => {
                    this.isLoading = false;
                });
        }
    }
    

    handleInputChange(event) {
        const index = event.target.dataset.index;
        const fieldName = event.target.name;
        const value = event.target.value;
    
        const updatedPlans = [...this.accountPlans];
        updatedPlans[index] = { ...updatedPlans[index], [fieldName]: value };
        this.accountPlans = updatedPlans;
    // Sort after update
    this.sortAccountPlans();
    }
    
    sortAccountPlans() {
        this.accountPlans = [...this.accountPlans].sort((a, b) => parseInt(a.year) - parseInt(b.year));
    }
    async handleSave() {
        
        if (!this.recordId) {
            this.showToast('Error', 'Account Id is missing', 'error');
            return;
        }

        // Check for required fields before saving
        const invalidData = this.accountPlans.some(plan => !plan.year || !plan.bu || !plan.amount);
        if (invalidData) {
            this.showToast('Error', 'Please fill in all fields before saving', 'error');
            return;
        }

        this.isLoading = true;

        const promises = this.accountPlans.map(plan => {
            const fields = {
                [YEAR_FIELD.fieldApiName]: plan.year,
                [BU_FIELD.fieldApiName]: plan.bu,
                [AMOUNT_FIELD.fieldApiName]: plan.amount,
                [ACCOUNT_FIELD.fieldApiName]: this.recordId
            };
        
            if (plan.id && plan.id.length === 18) {
                fields['Id'] = plan.id; 
                return updateRecord({ fields });
            } else {
                return createRecord({ apiName: ACCOUNT_PLAN_OBJECT.objectApiName, fields });
            }
        });

        try {
            await Promise.all(promises);
            this.showToast('Success', 'Account Plans saved successfully!', 'success');
            await refreshApex(this.wiredAccountPlansResult);
            window.location.reload();
        } catch (error) {
            this.showToast('Error', 'Failed to save Account Plans', 'error');
            console.error(error);
        } finally {
            this.isLoading = false;
        }

      
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}