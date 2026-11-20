import { LightningElement, track } from 'lwc';
import searchAccounts from '@salesforce/apex/Core_MDF_AccountSearchController.searchAccounts';
import getRecordTypeIdByProgram from '@salesforce/apex/Core_MDF_AccountSearchController.getRecordTypeIdByProgram';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

import PFR_DETAIL_LINK from '@salesforce/label/c.Core_MDF_PFRDetailLink';

export default class AccountSearchScreen extends NavigationMixin(LightningElement) {

    @track accountData;
    @track accounts = [];
    @track programOptions = [];
    @track vcProgramTableData = [];
    showVcTable = false;

    selectedProgram;
    selectedRecordTypeId;
    selectedAccountId;

    isLoading = false;
    showProgramDropdown = false;
    showTable = false;
    hideRequestBtn = false; 

    disableOnboard = true;

    columns = [
        { label: 'Account Name', fieldName: 'accountUrl',type: 'url',typeAttributes: {label: { fieldName: 'name' },target: '_blank'} },
        { label: 'Country', fieldName: 'billingCountry' },
        { label: 'State', fieldName: 'billingState' },
        { label: 'Zip Code', fieldName: 'billingPostalCode' },
        { label: 'Unified Global Customer BPID', fieldName: 'unifiedBPId' },
        { label: 'Co-Marketing Active', fieldName: 'comarketingActive', type: 'boolean' },
        { label: 'CoMarketing Agency', fieldName: 'comarketingAgency', type: 'boolean' },
        { label: 'IPA Account', fieldName: 'ipaAccount', type: 'boolean' },
        { 
            label: 'Onboarded Programs', 
            fieldName: 'onboardedPrograms', 
            type: 'text', 
            wrapText: true 
        },
        {
            type: 'button',
            typeAttributes: {
                label: 'Onboard',
                name: 'onboard',
                variant: 'brand',
                disabled: { fieldName: 'disableOnboard' }
            }
        }
    ];

    vcColumns = [
        { label: 'Program', fieldName: 'program' },
        { label: 'Virtual Corp Name', fieldName: 'vcName' }
    ];

    get accountQueryFilter() {
        return "RecordType.DeveloperName = 'Mastered_Account'";
    }

    async handleRefresh() {
        if (!this.selectedAccountId) return;

        this.isLoading = true;

        try {
            const result = await searchAccounts({ accountId: this.selectedAccountId });

            if (!result) {
                this.resetUI();
                return;
            }

            this.accountData = result;

            this.programOptions = (result.programOptions || []).map(p => ({
                label: p,
                value: p
            }));

            this.showProgramDropdown = this.programOptions.length > 0;
            this.hideRequestBtn = true;

            // rebuild tables if program already selected
            if (this.selectedProgram) {
                this.handleProgramChange({
                    detail: { value: this.selectedProgram }
                });
            }

        } catch (error) {
            console.error('Refresh Error:', error);
        } finally {
            this.isLoading = false;
        }
    }
    
    async handleAccountFilterChange(event) {

        this.selectedAccountId = event.detail;

        if (!this.selectedAccountId) {
            this.resetUI();
            return;
        }
        this.isLoading = true;

        try {
            const result = await searchAccounts({ accountId: this.selectedAccountId });

            if (!result) {
                this.resetUI();
                return;
            }

            this.accountData = result;

            this.programOptions = (result.programOptions || []).map(p => ({
                label: p,
                value: p
            }));

            this.showProgramDropdown = this.programOptions.length > 0;
            this.hideRequestBtn = true;
            //this.showTable = false;
            //this.showVcTable = false;

            this.disableOnboard = true;

            // Build table immediately
            this.accounts = [{
                ...this.accountData,
                accountUrl: '/lightning/r/Account/' + this.accountData.Id + '/view',
                disableOnboard: true
            }];

            this.showTable = true;

            if (this.accountData?.onboardedPrograms) {

                const mapData = this.accountData?.pgmNameToVCMap || {};

                this.vcProgramTableData = Object.keys(mapData).map(program => ({
                    program: program,
                    vcName: mapData[program]
                }));

                this.showVcTable = this.vcProgramTableData.length > 0;

            } else {
                this.vcProgramTableData = [];
                this.showVcTable = false;
            }                        

        } catch (error) {
            console.error('Error:', error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleProgramChange(event) {

        this.selectedProgram = event.detail.value;

        this.selectedRecordTypeId = await getRecordTypeIdByProgram({
            programName: this.selectedProgram
        });

        const onboarded = this.accountData?.onboardedPrograms || '';

        this.disableOnboard = onboarded.includes(this.selectedProgram);

        this.accounts = [{
            ...this.accountData,
            accountUrl: '/lightning/r/Account/' + this.accountData.Id + '/view',
            disableOnboard: this.disableOnboard
        }];

        /*this.showTable = true;

        if (this.accountData?.onboardedPrograms) {

            const mapData = this.accountData?.pgmNameToVCMap || {};

            this.vcProgramTableData = Object.keys(mapData).map(program  => ({
                program: program,
                vcName: mapData[program]
            }));

            this.showVcTable = this.vcProgramTableData.length > 0;

        } else {
            this.vcProgramTableData = [];
            this.showVcTable = false;
        }*/
    }

    handleRowAction(event) {
        if (event.detail.action.name === 'onboard' && !this.disableOnboard) {
            this.navigateToOnboarding(event.detail.row.Id);
        }
    }

    navigateToOnboarding(accountId) {

        const defaultValues = encodeDefaultFieldValues({
            Core_MDF_Account__c: accountId
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Core_MDF_Account_Onboarding__c',
                actionName: 'new'
            },
            state: {
                recordTypeId: this.selectedRecordTypeId,
                defaultFieldValues: defaultValues
            }
        });
    }

    handleAccountRequest() {
        window.open(PFR_DETAIL_LINK + 'lightning/n/New_Account_SBR', '_blank');
    }

    resetUI() {
        this.accountData = null;
        this.programOptions = [];
        this.accounts = [];
        this.selectedProgram = null;
        this.selectedRecordTypeId = null;
        this.selectedAccountId = null;
        this.showProgramDropdown = false;
        this.showTable = false;
        this.showVcTable = false;
        this.hideRequestBtn = false;
        this.disableOnboard = true;
    }

    get showRequestButton() {
        return !this.hideRequestBtn;
    }
}