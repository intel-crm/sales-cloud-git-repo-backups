import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOutcomeBasedActivities from '@salesforce/apex/Core_MDF_OutcomeBasedCmpgnTab.getOutcomeBasedActivities';
import getStatusPicklistValues from '@salesforce/apex/Core_MDF_OutcomeBasedCmpgnTab.getStatusPicklistValues';
import searchAccounts from '@salesforce/apex/Core_MDF_OutcomeBasedCmpgnTab.searchAccounts';
import { CurrentPageReference } from 'lightning/navigation';
import Status from '@salesforce/label/c.Core_MDF_Status';
import Filters from '@salesforce/label/c.Core_MDF_Filters';
import Account from '@salesforce/label/c.Core_MDF_Account_Label';
import OutcomeBasedCampaigns from '@salesforce/label/c.Core_MDF_OutcomeBased_Campaign_Page_Header';
import Errortext from '@salesforce/label/c.Core_MDF_Error';
import SearchFilter from '@salesforce/label/c.Core_MDF_Search_Filter_HelpText';
import CampaignFilterText from '@salesforce/label/c.Core_MDF_OutcomeBased_ListView_ErrorMessage';
import ClearFilters from '@salesforce/label/c.Core_MDF_Clear_Filters';
import SelectStatus from '@salesforce/label/c.Core_MDF_Select_Status';
import AllStatuses from '@salesforce/label/c.Core_MDF_All_Statuses';
import SearchAccount from '@salesforce/label/c.Core_MDF_Search_Account_Placeholder';
import Search from '@salesforce/label/c.Core_MDF_Search';
import SearchPlaceholder from '@salesforce/label/c.Core_MDF_Search_Filter_Placeholder';
import ListviewName from '@salesforce/label/c.Core_MDF_Activity_Name';
import ListViewCampaignNum from '@salesforce/label/c.Core_MDF_OutcomeBasedCampaign_Number';
import ListViewMaxIntelInvest from '@salesforce/label/c.Core_MDF_Maximum_Intel_Investment';
import ListviewStartEnddate from '@salesforce/label/c.Core_MDF_Start_and_End_Date';
import ListViewOwner from '@salesforce/label/c.Core_MDF_Owner';

export default class OutcomeBasedActivitiesTable extends NavigationMixin(LightningElement) {
    
    // API properties
    @api objectApiName;
    
    // Custom Labels
    @track AllStatuses = AllStatuses;
    @track ListviewName = ListviewName;
    @track ListViewCampaignNum = ListViewCampaignNum;
    @track ListViewMaxIntelInvest = ListViewMaxIntelInvest;
    @track ListviewStartEnddate= ListviewStartEnddate;
    @track ListViewOwner = ListViewOwner;
    @track SearchPlaceholder = SearchPlaceholder;
    @track Search = Search;
    @track SelectStatus = SelectStatus;
    @track SearchAccount = SearchAccount;
    @track ClearFilters = ClearFilters;
    @track Status = Status;
    @track Filters = Filters;
    @track Account = Account;
    @track OutcomeBasedCampaigns = OutcomeBasedCampaigns;
    @track Errortext = Errortext;
    @track SearchFilter = SearchFilter;
    @track CampaignFilterText = CampaignFilterText;
    @track Program = 'Program';
    @track Budget = 'Budget';
    @track AllPrograms = 'All Programs';
    @track AllBudgets = 'All Budgets';
    
    // State management
    @track activities = [];
    @track filteredActivities = [];
    @track displayedActivities = [];
    @track error;
    @track isLoading = false;
    @track statusOptions = [];
    @track totalServerRecords = 0;
    @track hasNextPage = false;
    @track hasPreviousPage = false;
    nextCursorValue;
    nextCursorId;
    previousCursorValue;
    previousCursorId;
    
    // Filter values
    @track selectedStatus = '';
    @track selectedAccountId = '';
    @track selectedAccountName = '';
    @track accountSearchTerm = '';
    @track accountSearchResults = [];
    @track showAccountDropdown = false;
    @track searchKey = '';
    @track showSearchHelp = false;
    @track selectedProgram = '';
    @track selectedBudget = '';

    // Pagination values
    @track currentPage = 1;
    pageSize = 1000;

    // Datatable properties
    @track sortedBy = 'LastModifiedDate';
    @track sortedDirection = 'desc';
    currentObjectApiName;

    // Performance monitoring
    performanceStart;

    // Define columns for the datatable
    get columns() {
    return [
        { 
            label: this.ListviewName, 
            fieldName: 'recordUrl', 
            type: 'url', 
            sortable: true,
            typeAttributes: {
                label: { fieldName: 'Title' },
                tooltip: { fieldName: 'Title' },
                target: '_blank'
            }
        },
        { 
            label: this.ListViewCampaignNum, 
            fieldName: 'Core_MDF_Activity_Number__c', 
            type: 'text', 
            sortable: true 
        },
        {
            label: this.Program,
            fieldName: 'Core_MDF_Program__c',
            type: 'text',
            sortable: false
        },
        {
            label: this.Budget,
            fieldName: 'Core_MDF_Budget_Type_nm__c',
            type: 'text',
            sortable: false
        },
        { 
            label: this.Status, 
            fieldName: 'Core_MDF_Fund_Request_Status__c', 
            type: 'text', 
            sortable: true 
        },
        { 
            label: this.Account, 
            fieldName: 'accountUrl', 
            type: 'url', 
            sortable: true,
            typeAttributes: {
                label: { fieldName: 'AccountName' },
                target: '_blank'
            }
        },
        { 
            label: this.ListViewMaxIntelInvest, 
            fieldName: 'Core_MDF_Maximum_Intel_Investment_amt__c', 
            type: 'currency', 
            typeAttributes: { 
                currencyCode: 'USD' 
            }, 
            cellAttributes: {
                alignment: 'left'
            },
            sortable: true 
        },
        { 
            label: this.ListviewStartEnddate,
            fieldName: 'Core_MDF_Start_Date_End_Date__c', 
            type: 'text', 
            sortable: true 
        },
        { 
            label: this.ListViewOwner, 
            fieldName: 'OwnerName', 
            type: 'text', 
            sortable: false 
        }
    ];
    }

    // Wire method to get status picklist values
    @wire(getStatusPicklistValues)
    wiredStatusValues({ error, data }) {
        if (data) {
            this.statusOptions = [
                { label: this.AllStatuses, value: '' },
                ...data.map(status => ({
                    label: status.label,
                    value: status.value
                }))
            ];
        } else if (error) {
            console.error('Error loading status values:', error);
        }
    }

    connectedCallback() {
        this.isLoading = true;
        this.performanceStart = performance.now();
        this.loadActivities('next', null, null, 1);
    }

   

    @wire(CurrentPageReference)
    getState(pageRef) {
        this.recordId = pageRef?.state?.c__recordId;
        this.currentObjectApiName = pageRef?.attributes?.objectApiName || this.objectApiName;

        // Detect if we're in Experience Cloud or Internal Lightning
        this.isExperienceCloud = pageRef?.type === 'comm__namedPage' || 
                                window.location.href.includes('/s/');
    }

    processActivitiesData(data) {
        this.isLoading = true;

        // Check if we're in Experience Cloud or Internal Lightning
        const isExperienceCloud = this.isExperienceCloud || 
                                 window.location.href.includes('/s/');

        let promises;

        if (isExperienceCloud) {
            // For Experience Cloud users
            promises = data.map(activity => {
                // Generate campaign URL
                const campaignUrlPromise = this[NavigationMixin.GenerateUrl]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'Outcome_based_Campaign_Details__c'
                    },
                    state: {
                        recordId: activity.Id
                    }
                });

                // Generate account URL if account exists
                const accountUrlPromise = activity.ChannelPartnerId ? 
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: activity.ChannelPartnerId,
                            objectApiName: 'Account',
                            actionName: 'view'
                        }
                    }) : Promise.resolve(null);

                return Promise.all([campaignUrlPromise, accountUrlPromise])
                    .then(([campaignUrl, accountUrl]) => ({
                        ...activity,
                        OwnerName: activity.Owner ? activity.Owner.Name : '',
                        AccountName: activity.ChannelPartner ? activity.ChannelPartner.Name : '',
                        recordUrl: campaignUrl,
                        accountUrl: accountUrl || '#'
                    }))
                    .catch(error => {
                        console.error('Error generating Experience Cloud URLs:', error);
                        return {
                            ...activity,
                            OwnerName: activity.Owner ? activity.Owner.Name : '',
                            AccountName: activity.ChannelPartner ? activity.ChannelPartner.Name : '',
                            recordUrl: `/s/outcome-based-campaign-details?recordId=${activity.Id}`,
                            accountUrl: activity.ChannelPartnerId ? `/lightning/r/Account/${activity.ChannelPartnerId}/view` : '#'
                        };
                    });
            });
        } else {
            // For Internal Lightning users
            promises = data.map(activity => {
                // Generate campaign URL
                const campaignUrlPromise = this[NavigationMixin.GenerateUrl]({
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'Core_MDF_Outcome_Based_Campaign_Detail' 
                    },
                    state: {
                        c__recordId: activity.Id
                    }
                });

                // Generate account URL if account exists
                const accountUrlPromise = activity.ChannelPartnerId ? 
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: activity.ChannelPartnerId,
                            objectApiName: 'Account',
                            actionName: 'view'
                        }
                    }) : Promise.resolve(null);

                return Promise.all([campaignUrlPromise, accountUrlPromise])
                    .then(([campaignUrl, accountUrl]) => ({
                        ...activity,
                        OwnerName: activity.Owner ? activity.Owner.Name : '',
                        AccountName: activity.ChannelPartner ? activity.ChannelPartner.Name : '',
                        recordUrl: campaignUrl,
                        accountUrl: accountUrl || '#'
                    }))
                    .catch(error => {
                        console.error('Error generating internal URLs:', error);
                        return {
                            ...activity,
                            OwnerName: activity.Owner ? activity.Owner.Name : '',
                            AccountName: activity.ChannelPartner ? activity.ChannelPartner.Name : '',
                            recordUrl: `/lightning/n/Core_MDF_Outcome_Based_Campaign_Detail/${activity.Id}/view`,
                            accountUrl: activity.ChannelPartnerId ? `/lightning/r/Account/${activity.ChannelPartnerId}/view` : '#'
                        };
                    });
            });
        }

        Promise.all(promises)
            .then(results => {
                console.log('🔹 Generated URLs:', results.map(r => ({ 
                    id: r.Id, 
                    campaignUrl: r.recordUrl, 
                    accountUrl: r.accountUrl 
                })));
                this.activities = results;
                this.filteredActivities = results;
                this.displayedActivities = results;
                this.isLoading = false;
                this.logPerformance('URL generation');
            })
            .catch(error => {
                this.handleError(error, 'processing activities data');
                this.isLoading = false;
            });
    }

    // Handle status filter change
    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
        this.applyFilters();
    }

    handleProgramChange(event) {
        this.selectedProgram = event.detail.value;
        this.applyFilters();
    }

    handleBudgetChange(event) {
        this.selectedBudget = event.detail.value;
        this.applyFilters();
    }

    // Handle account search input
    handleAccountSearch(event) {
        const searchTerm = event.target.value;
        this.accountSearchTerm = searchTerm;
        
        if (searchTerm.length >= 2) {
            this.searchAccountsDebounced(searchTerm);
        } else {
            this.accountSearchResults = [];
            this.showAccountDropdown = false;
        }
    }

    // Debounced search for accounts
    searchAccountsDebounced(searchTerm) {
        // Clear previous timeout
        if (this.searchTimeout) {
            clearTimeout(this.searchTimeout);
        }
        
        // Set new timeout
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchTimeout = setTimeout(() => {
            searchAccounts({ searchTerm: searchTerm })
                .then(result => {
                    this.accountSearchResults = result;
                    this.showAccountDropdown = result.length > 0;
                })
                .catch(error => {
                    console.error('Error searching accounts:', error);
                    this.accountSearchResults = [];
                    this.showAccountDropdown = false;
                });
        }, 300);
    }

    // Handle account selection from dropdown
    handleAccountSelect(event) {
        event.preventDefault();
        
        const selectedAccountId = event.currentTarget.dataset.id;
        const selectedAccountName = event.currentTarget.dataset.name;
        
        
        this.selectedAccountId = selectedAccountId;
        this.selectedAccountName = selectedAccountName;
        this.accountSearchTerm = selectedAccountName;
        this.showAccountDropdown = false;
        this.accountSearchResults = [];
        
        this.applyFilters();
    }

    // Handle account input focus
    handleAccountFocus() {
        if (this.accountSearchResults.length > 0) {
            this.showAccountDropdown = true;
        }
    }

    // Handle account input blur
    handleAccountBlur() {
        // Delay hiding dropdown to allow for selection
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.showAccountDropdown = false;
        }, 300);
    }

   // Clear account selection (called when X icon is clicked)
    handleClearAccount(event) {
        event.preventDefault();
        event.stopPropagation();
        
        
        this.selectedAccountId = '';
        this.selectedAccountName = '';
        this.accountSearchTerm = '';
        this.accountSearchResults = [];
        this.showAccountDropdown = false;
        
        // Clear the input field
        const accountInput = this.template.querySelector('[data-id="accountInput"]');
        if (accountInput) {
            accountInput.value = '';
            accountInput.focus(); 
        }
        
        this.applyFilters();
    }

    // Handle search input change
    handleSearchChange(event) {
        this.searchKey = event.target.value.toLowerCase();
        this.applyFilters();
    }

    // Handle search input focus - show help text
    handleSearchFocus() {
        this.showSearchHelp = true;
    }

    // Handle search input blur - hide help text after delay
    handleSearchBlur() {
        // Add small delay to allow user to see help text
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.showSearchHelp = false;
        }, 200);
    }

    // Apply filters to the activities
    applyFilters() {
        this.loadActivities('next', null, null, 1);
    }

    updateDisplayedActivities() {
        this.displayedActivities = this.filteredActivities;
    }

    handleFirstPage() {
        if (this.currentPage !== 1) {
            this.loadActivities('next', null, null, 1);
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.loadActivities('previous', this.previousCursorValue, this.previousCursorId, this.currentPage - 1);
        }
    }

    handleNextPage() {
        if (this.hasNextPage) {
            this.loadActivities('next', this.nextCursorValue, this.nextCursorId, this.currentPage + 1);
        }
    }

    handleLastPage() {
        if (this.hasNextPage) {
            this.loadActivities('last', null, null, this.totalPages);
        }
    }

    // Handle datatable sorting
    handleSort(event) {
        let sortField = event.detail.fieldName;
        
        // Map display field names to actual field names for sorting
        if (sortField === 'recordUrl') {
            sortField = 'Title';
        } else if (sortField === 'accountUrl') {
            sortField = 'ChannelPartner.Name';
        }
        
        this.sortedBy = sortField;
        this.sortedDirection = event.detail.sortDirection;
        
        return this.loadActivities('next', null, null, 1);
    }

    loadActivities(pageDirection, cursorValue, cursorId, targetPage) {
        this.isLoading = true;
        return getOutcomeBasedActivities({
            sortBy: this.sortedBy,
            sortDirection: this.sortedDirection,
            pageSize: this.pageSize,
            pageDirection: pageDirection,
            cursorValue: cursorValue,
            cursorId: cursorId,
            statusFilter: this.selectedStatus,
            programFilter: this.selectedProgram,
            budgetFilter: this.selectedBudget,
            accountId: this.selectedAccountId,
            searchKey: this.searchKey
        })
            .then(result => {
                this.currentPage = targetPage || 1;
                this.totalServerRecords = result.totalRecords || 0;
                this.hasNextPage = Boolean(result.hasNext);
                this.hasPreviousPage = Boolean(result.hasPrevious);
                this.nextCursorValue = result.nextCursorValue;
                this.nextCursorId = result.nextCursorId;
                this.previousCursorValue = result.previousCursorValue;
                this.previousCursorId = result.previousCursorId;
                this.error = undefined;
                this.processActivitiesData(result.records || []);
            })
            .catch(error => {
                this.error = this.normalizeError(error);
                this.activities = [];
                this.filteredActivities = [];
                this.displayedActivities = [];
                this.totalServerRecords = 0;
                this.hasNextPage = false;
                this.hasPreviousPage = false;
                this.isLoading = false;
            });
    }

    // Enhanced error handling
    handleError(error, operation) {
        console.error(`Error in ${operation}:`, error);
        
        let errorMessage = 'An unexpected error occurred';
        
        if (error.body) {
            if (error.body.message) {
                errorMessage = error.body.message;
            } else if (error.body.pageErrors && error.body.pageErrors.length > 0) {
                errorMessage = error.body.pageErrors[0].message;
            }
        } else if (error.message) {
            errorMessage = error.message;
        }
        
        this.showToast('Error', errorMessage, 'error');
        this.error = errorMessage;
    }

    // Show toast message
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissible'
        });
        this.dispatchEvent(event);
    }

    // Performance monitoring
    logPerformance(operation) {
        if (this.performanceStart) {
            const duration = performance.now() - this.performanceStart;
            console.log(`${operation} completed in ${duration.toFixed(2)}ms`);
        }
    }

    // Clear all filters
    handleClearFilters() {
        
        this.selectedStatus = '';
        this.selectedAccountId = '';
        this.selectedAccountName = '';
        this.accountSearchTerm = '';
        this.accountSearchResults = [];
        this.showAccountDropdown = false;
        this.searchKey = '';
        this.showSearchHelp = false;
        this.selectedProgram = '';
        this.selectedBudget = '';
        
        // Clear input values
        const searchInput = this.template.querySelector('[data-id="searchInput"]');
        if (searchInput) {
            searchInput.value = '';
        }
        
        const accountInput = this.template.querySelector('[data-id="accountInput"]');
        if (accountInput) {
            accountInput.value = '';
        }
        
        // Clear status combobox
        const statusCombobox = this.template.querySelector('lightning-combobox[name="statusFilter"]');
        if (statusCombobox) {
            statusCombobox.value = '';
        }

        const programCombobox = this.template.querySelector('lightning-combobox[name="programFilter"]');
        if (programCombobox) {
            programCombobox.value = '';
        }

        const budgetCombobox = this.template.querySelector('lightning-combobox[name="budgetFilter"]');
        if (budgetCombobox) {
            budgetCombobox.value = '';
        }
        
        this.applyFilters();
    }

    // Normalize error messages
    normalizeError(err) {
        try {
            if (Array.isArray(err?.body)) {
                return err.body.map(e => e.message).join(', ');
            } else if (typeof err?.body?.message === 'string') {
                return err.body.message;
            }
            return err?.message || JSON.stringify(err);
        } catch {
            return 'Unknown error occurred';
        }
    }
    
    // Getters for template
    
    get hasActivities() {
        return this.displayedActivities && this.displayedActivities.length > 0;
    }

    get recordCount() {
        return this.totalServerRecords || 0;
    }

    get totalRecordCount() {
        return this.totalServerRecords || 0;
    }

    get totalPages() {
        return Math.max(Math.ceil(this.recordCount / this.pageSize), 1);
    }

    get paginationSummary() {
        const startRecord = this.recordCount === 0 ? 0 : ((this.currentPage - 1) * this.pageSize) + 1;
        const endRecord = Math.min(startRecord + this.displayedActivities.length - 1, this.recordCount);
        return `Page ${this.currentPage} of ${this.totalPages} - Showing ${startRecord}-${endRecord} of ${this.recordCount}`;
    }

    get isPreviousDisabled() {
        return !this.hasPreviousPage || this.currentPage <= 1;
    }

    get isNextDisabled() {
        return !this.hasNextPage;
    }

    get programOptions() {
        return this.buildFilterOptions(this.activities, 'Core_MDF_Program__c', this.AllPrograms);
    }

    get budgetOptions() {
        return this.buildFilterOptions(this.activities, 'Core_MDF_Budget_Type_nm__c', this.AllBudgets);
    }

    buildFilterOptions(records, fieldName, allLabel) {
        const values = [...new Set((records || [])
            .map(record => record[fieldName])
            .filter(value => value))]
            .sort((firstValue, secondValue) => firstValue.localeCompare(secondValue));

        return [
            { label: allLabel, value: '' },
            ...values.map(value => ({ label: value, value: value }))
        ];
    }

    // Check if any filters are applied
    get hasFiltersApplied() {
        return this.selectedStatus || this.selectedProgram || this.selectedBudget || this.selectedAccountId || this.searchKey;
    }

    // Show clear X icon when account is selected
    get showAccountClearButton() {
        return this.selectedAccountId && this.selectedAccountId.length > 0;
    }
}