import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import searchAccounts from '@salesforce/apex/Core_MDF_Outcome_Acc_Based_Activity.searchAccounts';
import getStoredAccountAllocations from '@salesforce/apex/Core_MDF_Outcome_Acc_Based_Activity.getStoredAccountAllocations';
import validateAllAllocations from '@salesforce/apex/Core_MDF_Outcome_Acc_Based_Activity.validateAllAllocations';
import Account from '@salesforce/label/c.Core_MDF_Account_Label';
import Percentage from '@salesforce/label/c.Core_MDF_Percentage';
import AllocatedAmt from '@salesforce/label/c.Core_MDF_Allocated_Amount';
import Account_Percentage_Allocation from '@salesforce/label/c.Core_MDF_Account_Percentage_Allocation';
import SelectAccount from '@salesforce/label/c.Core_MDF_Select_Account';
import DuplicateAccount from '@salesforce/label/c.Core_MDF_Duplicate_Account';
import NoAllocation from '@salesforce/label/c.Core_MDF_No_Allocation_Label';
import AmountExceeds from '@salesforce/label/c.Core_MDF_Amount_Exceeds';
import NoAvialbleAllocation from '@salesforce/label/c.Core_MDF_No_Avalable_Allocation';
import PercentageRequired from '@salesforce/label/c.Core_MDF_Percentage_Required';
import PercentageEqualHundred from '@salesforce/label/c.Core_MDF_Pecentage_Equal_100';
import AmountRequired from '@salesforce/label/c.Core_MDF_AmountRequired';
import AmountEqualHundred from '@salesforce/label/c.Core_MDF_TotalAmountEqual100';
import AddAccountPercentage from '@salesforce/label/c.Core_MDF_AddAccountPercentage';

export default class AccountPercentageList extends NavigationMixin(LightningElement) {

    @api parentAccountId;
    @api recordId;
    @api mode;
    @api isReadOnly = false;
    @api editable;
    
    @track rows = [
        { 
            id: 1,
            accountId: null,
            accountName: '',
            percent: 0,
            amount: 0,
            formattedPercent: '0.00%',
            formattedAmount: '$0.00',
            errorAccount: false,
            errorPercent: false,
            errorAmount: false,
            errorDuplicate: false,
            errorOverPercent: false,
            errorOverAmount: false,
            errorTotalPercent: false,
            errorTotalAmount: false,
            errorNoAllocation: false,
            errorExceedsAvailable: false,
            errorZeroAmount: false,
            rowClass: '',
            searchResults: [],
            showDropdown: false,
            availableAmount: 0,
            originalAllocatedAmount: 0,
            isOriginalAccount: false
        }
    ];

    @track originalRows = [];
    @track isEditMode = false;
    @track originalAllocatedAmounts = new Map();
    @track Account = Account;
    @track Percentage = Percentage;
    @track AllocatedAmt = AllocatedAmt;
    @track Account_Percentage_Allocation = Account_Percentage_Allocation;
    @track SelectAccountError = SelectAccount;
    @track DuplicateAccountError = DuplicateAccount;
    @track NoAllocationError = NoAllocation;
    @track AmountExceedsError = AmountExceeds;
    @track NoAvialbleAllocationError = NoAvialbleAllocation;
    @track PercentageRequiredError = PercentageRequired;
    @track PercentageEqualHundredError = PercentageEqualHundred;
    @track AmountRequiredError = AmountRequired;
    @track AmountEqualHundredError = AmountEqualHundred;
    @track AddAccountPercentageLabel = AddAccountPercentage;
    rowId = 1;
    totalPercentage = 0;
    calculatedTotalAmount = 0;
    isAddButtonDisabled = false;
    duplicateAccounts = new Set();
    _totalAmount = 0;
    _budgetId;
    isInitialLoad = true;

    @api
    set totalAmount(value) {
        this._totalAmount = value;
        this.updateCalculatedValues();
    }
    get totalAmount() {
        return this._totalAmount;
    }

    @api
    set budgetId(value) {
        const oldBudgetId = this._budgetId;
        this._budgetId = value;
        
        // If budgetId changed and we have existing account selections, validate them
        if (oldBudgetId !== value && value && this.rows && this.rows.length > 0) {
            const hasAccountSelections = this.rows.some(row => row.accountId);
            if (hasAccountSelections) {
                this.validateAllAllocationsInBackground();
            }
        }
    }
    get budgetId() {
        return this._budgetId;
    }

    @api isAccountAllocationModified() {
        if (!this.originalRows || this.originalRows.length !== this.rows.length) {
            return true;
        }

        for (let i = 0; i < this.rows.length; i++) {
            const current = this.rows[i];
            const original = this.originalRows[i];

            if (!current || !original) {
                return true;
            }

            if (current.accountId !== original.accountId ||
                this.normalizeValue(current.percent) !== this.normalizeValue(original.percent) ||
                this.normalizeValue(current.amount) !== this.normalizeValue(original.amount)) {
                return true;
            }
        }

        return false;
    }

    // Helper method to normalize values for comparison
    normalizeValue(value) {
        if (value === null || value === undefined || value === '') {
            return 0;
        }
        const num = parseFloat(value);
        return isNaN(num) ? 0 : this.roundToTwoDecimals(num);
    }

    // Utility method for rounding to 2 decimal places
    roundToTwoDecimals(value) {
        if (value === null || value === undefined || isNaN(value)) {
            return 0;
        }
        return Math.round((value + Number.EPSILON) * 100) / 100;
    }

    // Safe number conversion
    safeParseFloat(value) {
        if (value === null || value === undefined || value === '') {
            return 0;
        }
        const parsed = parseFloat(value);
        return isNaN(parsed) ? 0 : parsed;
    }

    // Formatted values for read-only display
    get formattedTotalPercentage() {
        return this.roundToTwoDecimals(this.totalPercentage).toFixed(2);
    }

    get formattedTotalAmount() {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(this.calculatedTotalAmount);
    }

    get isDeleteDisabled() {
        return this.rows.length === 1;
    }

    connectedCallback() {
        if (['edit', 'clone', ''].includes(this.mode)) {
            this.isReadOnly = false;
            this.isEditMode = this.mode === 'edit';
        }

        let shouldLoadData = false;    
        if (this.recordId) {
            switch(this.mode) {
                case 'edit':
                    shouldLoadData = true;
                    break;
                case 'clone':
                    shouldLoadData = false;
                    break;
                case '':
                    shouldLoadData = false;
                    break;
                default:
                    shouldLoadData = this.isReadOnly;
            }
        }
        if (shouldLoadData) {
            this.loadStoredAllocations();
        } else {
            this.originalRows = JSON.parse(JSON.stringify(this.rows));
        }
        this.isInitialLoad = true;
    }

    @api handleEdit(editable) {
        if(this.mode == 'edit' && editable){
            this.isReadOnly = true;
        }
    }

    // Validate all allocations in background
    validateAllAllocationsInBackground() {
        const accountIds = this.rows
            .filter(row => row.accountId)
            .map(row => row.accountId);

        if (accountIds.length > 0 && this.budgetId) {
            validateAllAllocations({
                budgetId: this.budgetId,
                accountIds: accountIds
            })
            .then(results => {
                this.updateRowsWithValidationResults(results);
            })
            .catch(error => {
                console.error('Error in background validation:', error);
            });
        }
    }

    // Update rows with validation results
    updateRowsWithValidationResults(validationResults) {
        let hasChanges = false;
        
        this.rows = this.rows.map(row => {
            if (row.accountId && validationResults[row.accountId]) {
                const result = validationResults[row.accountId];
                const oldErrorNoAllocation = row.errorNoAllocation;
                const oldErrorExceedsAvailable = row.errorExceedsAvailable;
                const oldErrorZeroAmount = row.errorZeroAmount;
                const oldAvailableAmount = row.availableAmount;

                // Check if allocation exists
                row.errorNoAllocation = !result.allocationExists;
                row.availableAmount = result.availableAmount || 0;
                
                // Enhanced logic for edit mode
                if (this.isEditMode && row.isOriginalAccount) {
                    // For original accounts in edit mode
                    const originalAmount = this.originalAllocatedAmounts.get(row.accountId) || 0;
                    
                    // Don't show zero amount error if there was an original allocation
                    row.errorZeroAmount = row.availableAmount === 0 && originalAmount === 0;
                    
                    // Calculate effective available amount (current + original)
                    const effectiveAvailableAmount = row.availableAmount + originalAmount;
                    
                    // Check if current amount exceeds effective available amount
                    if (effectiveAvailableAmount > 0 && row.amount > effectiveAvailableAmount) {
                        row.errorExceedsAvailable = true;
                    } else {
                        row.errorExceedsAvailable = false;
                    }
                } else if (this.isEditMode && !row.isOriginalAccount) {
                    // For new accounts added in edit mode - use normal validation
                    row.errorZeroAmount = row.availableAmount === 0;
                    
                    if (row.availableAmount > 0 && row.amount > row.availableAmount) {
                        row.errorExceedsAvailable = true;
                    } else {
                        row.errorExceedsAvailable = false;
                    }
                } else {
                    // For create/clone mode - use normal validation
                    row.errorZeroAmount = row.availableAmount === 0;
                    
                    if (row.availableAmount > 0 && row.amount > row.availableAmount) {
                        row.errorExceedsAvailable = true;
                    } else {
                        row.errorExceedsAvailable = false;
                    }
                }

                // Check if there were any changes
                if (oldErrorNoAllocation !== row.errorNoAllocation || 
                    oldErrorExceedsAvailable !== row.errorExceedsAvailable ||
                    oldErrorZeroAmount !== row.errorZeroAmount ||
                    oldAvailableAmount !== row.availableAmount) {
                    hasChanges = true;
                }
            }
            return row;
        });

        if (hasChanges) {
            this.updateRowClasses();
            this.rows = [...this.rows];
        }
    }

    // Manual refresh method that can be called from parent component
    @api
    refreshAllocations() {
        this.validateAllAllocationsInBackground();
    }

    handleInputFocus(event) {
        // Close other dropdowns when focusing on a new input
        const currentIndex = parseInt(event.target.dataset.index);
        this.rows = this.rows.map((row, index) => ({
            ...row,
            searchResults: index === currentIndex ? row.searchResults : [],
            showDropdown: index === currentIndex ? row.showDropdown : false
        }));
    }

    handleInputBlur(event) {
        // Use a timeout to allow clicking on dropdown items
        setTimeout(() => {
            const index = parseInt(event.target.dataset.index);
            if (this.rows[index]) {
                this.rows[index].searchResults = [];
                this.rows[index].showDropdown = false;
                this.rows = [...this.rows];
            }
        }, 150);
    }

    updateCalculatedValues() {
        // When totalAmount changes, recalculate all row amounts to maintain percentage distribution
        if (this._totalAmount && this._totalAmount > 0) {
            this.rows = this.rows.map(row => {
                // Skip rows with no percentage or no account
                if (row.percent === null || row.percent === undefined || row.percent <= 0) {
                    return row;
                }
                
                // Calculate new amount based on percentage and new total
                const newAmount = this.roundToTwoDecimals((row.percent / 100) * this._totalAmount);
                
                // Update the row with new amount and formatted values
                return {
                    ...row,
                    amount: newAmount,
                    formattedAmount: new Intl.NumberFormat('en-US', {
                        style: 'currency',
                        currency: 'USD'
                    }).format(newAmount)
                };
            });
        } else {
            // If total amount is 0 or invalid, reset all amounts to 0
            this.rows = this.rows.map(row => {
                return {
                    ...row,
                    amount: 0,
                    formattedAmount: '$0.00'
                };
            });
        }
        
        // Recalculate totals
        this.calculateTotals();
        this.updateRowClasses();
        this.updateFormattedValues();
    }

    loadStoredAllocations() {
        if (!this.recordId) return;

        getStoredAccountAllocations({ activityId: this.recordId })
            .then(result => {
                if (!result || result.length === 0) return;

                // Store original allocated amounts for edit mode
                if (this.isEditMode) {
                    result.forEach(rec => {
                        if (rec.accountId && rec.amount) {
                            this.originalAllocatedAmounts.set(rec.accountId, this.safeParseFloat(rec.amount));
                        }
                    });
                }

                this.rows = result.map((rec, idx) => {
                    const p = this.safeParseFloat(rec.percent);
                    const a = this.safeParseFloat(rec.amount);
                    return {
                        id: idx + 1,
                        accountId: rec.accountId,
                        accountName: rec.accountName,
                        percent: this.roundToTwoDecimals(p),
                        amount: this.roundToTwoDecimals(a),
                        formattedPercent: `${this.roundToTwoDecimals(p).toFixed(2)}%`,
                        formattedAmount: new Intl.NumberFormat('en-US', {
                            style: 'currency',
                            currency: 'USD'
                        }).format(a),
                        errorAccount: false,
                        errorPercent: false,
                        errorAmount: false,
                        errorDuplicate: false,
                        errorOverPercent: false,
                        errorOverAmount: false,
                        errorTotalPercent: false,
                        errorTotalAmount: false,
                        errorNoAllocation: false,
                        errorExceedsAvailable: false,
                        errorZeroAmount: false,
                        rowClass: '',
                        searchResults: [],
                        showDropdown: false,
                        availableAmount: 0,
                        originalAllocatedAmount: a, // Store original amount in row
                        isOriginalAccount: true // Flag to identify original accounts
                    };
                });

                this.originalRows = JSON.parse(JSON.stringify(this.rows));

                this.rowId = this.rows.length;
                this.calculateTotals();
                this.checkForDuplicates();
                
                // Validate all loaded allocations
                this.validateAllAllocationsInBackground();
                
                this.updateRowClasses();
                this.isInitialLoad = false;
            })
            .catch(error => console.error('Error loading account allocations:', error));
    }

    navigateToAccount(event) {
        const accountId = event.target.dataset.accountId;
        
        if (accountId) {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: accountId,
                    objectApiName: 'Account',
                    actionName: 'view'
                }
            }).then(url => {
                window.open(url, '_blank');
            }).catch(error => {
                console.error('Error generating URL:', error);
            });
        }
    }

    addRow() {
        this.rowId++;
        const newRow = { 
            id: this.rowId,
            accountId: null,
            accountName: '',
            percent: 0,
            amount: 0,
            formattedPercent: '0.00%',
            formattedAmount: '$0.00',
            errorAccount: false,
            errorPercent: false,
            errorAmount: false,
            errorDuplicate: false,
            errorOverPercent: false,
            errorOverAmount: false,
            errorTotalPercent: false,
            errorTotalAmount: false,
            errorNoAllocation: false,
            errorExceedsAvailable: false,
            errorZeroAmount: false,
            rowClass: '',
            searchResults: [],
            showDropdown: false,
            availableAmount: 0,
            originalAllocatedAmount: 0,
            isOriginalAccount: false // New rows are not original accounts
        };
        
        this.rows = [...this.rows, newRow];
        this.calculateTotals();
    }

    removeRow(event) {
        if (this.rows.length === 1) return;

        const index = event.currentTarget.dataset.index;
        this.rows.splice(index, 1);
        this.rows = [...this.rows];

        this.calculateTotals();
        this.checkForDuplicates();
        this.updateRowClasses();
        this.updateFormattedValues();
    }

    handleAccountSearch(event) {
        const index = parseInt(event.target.dataset.index);
        const searchTerm = event.target.value;

        // Close other dropdowns first
        this.rows = this.rows.map((row, i) => ({
            ...row,
            searchResults: i === index ? row.searchResults : [],
            showDropdown: i === index ? row.showDropdown : false
        }));

        // Update the account name in the current row
        this.rows[index].accountName = searchTerm;
        this.rows[index].accountId = null; // Clear selection when typing

        if (searchTerm.length > 1) {
            const selectedIds = this.rows
                .filter((r, i) => r.accountId && i !== index)
                .map(r => r.accountId);

            searchAccounts({
                parentAccountId: this.parentAccountId,
                searchKey: searchTerm,
                excludeIds: selectedIds
            })
            .then(result => {
                this.rows[index].searchResults = result || [];
                this.rows[index].showDropdown = (result && result.length > 0);
                this.rows = [...this.rows];
            })
            .catch(error => {
                console.error("Error in account search", error);
                this.rows[index].searchResults = [];
                this.rows[index].showDropdown = false;
                this.rows = [...this.rows];
            });
        } else {
            this.rows[index].searchResults = [];
            this.rows[index].showDropdown = false;
            this.rows = [...this.rows];
        }
    }

    selectAccount(event) {
        const index = parseInt(event.target.dataset.index);
        const accountId = event.target.dataset.id;
        const accountName = event.target.label;

        this.rows[index].accountId = accountId;
        this.rows[index].accountName = accountName;
        this.rows[index].searchResults = [];
        this.rows[index].showDropdown = false;

        // Check allocation exists for this account using validateAllAllocations
        this.checkAllocationForAccount(index, accountId);

        this.checkForDuplicates();
        this.rows = [...this.rows];
        this.calculateTotals();
        this.updateRowClasses();
    }

    // Updated method to use validateAllAllocations instead of checkAllocationExists
    checkAllocationForAccount(index, accountId) {
        if (this.budgetId && accountId) {
            validateAllAllocations({
                budgetId: this.budgetId,
                accountIds: [accountId]
            })
            .then(results => {
                if (results && results[accountId]) {
                    const result = results[accountId];
                    this.rows[index].errorNoAllocation = !result.allocationExists;
                    this.rows[index].availableAmount = result.availableAmount || 0;
                    
                    // Enhanced logic for edit mode
                    if (this.isEditMode) {
                        const originalAmount = this.originalAllocatedAmounts.get(accountId) || 0;
                        
                        // If this is an original account, don't show zero amount error
                        if (originalAmount > 0) {
                            this.rows[index].errorZeroAmount = false;
                            this.rows[index].isOriginalAccount = true;
                            this.rows[index].originalAllocatedAmount = originalAmount;
                        } else {
                            // New account in edit mode
                            this.rows[index].errorZeroAmount = this.rows[index].availableAmount === 0;
                            this.rows[index].isOriginalAccount = false;
                            this.rows[index].originalAllocatedAmount = 0;
                        }
                    } else {
                        // Create/clone mode
                        this.rows[index].errorZeroAmount = this.rows[index].availableAmount === 0;
                        this.rows[index].isOriginalAccount = false;
                        this.rows[index].originalAllocatedAmount = 0;
                    }
                } else {
                    this.rows[index].errorNoAllocation = true;
                    this.rows[index].availableAmount = 0;
                    this.rows[index].originalAllocatedAmount = 0;
                    
                    // In edit mode, don't show zero amount error for accounts that might have been allocated before
                    if (this.isEditMode) {
                        const originalAmount = this.originalAllocatedAmounts.get(accountId) || 0;
                        this.rows[index].errorZeroAmount = originalAmount === 0;
                        this.rows[index].isOriginalAccount = originalAmount > 0;
                    } else {
                        this.rows[index].errorZeroAmount = true;
                        this.rows[index].isOriginalAccount = false;
                    }
                }
                this.rows = [...this.rows];
                this.updateRowClasses();
            })
            .catch(error => {
                console.error('Error checking allocation:', error);
                this.rows[index].errorNoAllocation = true;
                this.rows[index].availableAmount = 0;
                this.rows[index].originalAllocatedAmount = 0;
                
                if (this.isEditMode) {
                    const originalAmount = this.originalAllocatedAmounts.get(accountId) || 0;
                    this.rows[index].errorZeroAmount = originalAmount === 0;
                    this.rows[index].isOriginalAccount = originalAmount > 0;
                } else {
                    this.rows[index].errorZeroAmount = true;
                    this.rows[index].isOriginalAccount = false;
                }
                this.rows = [...this.rows];
                this.updateRowClasses();
            });
        }
    }

    handlePercentChange(event) {
        const index = parseInt(event.target.dataset.index);
        const inputValue = event.target.value;
        
        // Handle empty or invalid input
        if (inputValue === '' || inputValue === null || inputValue === undefined) {
            this.rows[index].percent = 0;
            this.rows[index].amount = 0;
        } else {
            const newPercent = this.safeParseFloat(inputValue);
            this.rows[index].percent = this.roundToTwoDecimals(newPercent);
            
            if (this._totalAmount && this._totalAmount > 0) {
                this.rows[index].amount = this.roundToTwoDecimals((this.rows[index].percent / 100) * this._totalAmount);
            } else {
                this.rows[index].amount = 0;
            }
        }

        // Check if amount exceeds available allocation
        this.checkAmountExceedsAvailable(index);

        this.updateFormattedValues(index);
        this.calculateTotals();
        this.rows = [...this.rows];
        this.updateRowClasses();
    }

    handleAmountChange(event) {
        const index = parseInt(event.target.dataset.index);
        const inputValue = event.target.value;
        
        // Handle empty or invalid input
        if (inputValue === '' || inputValue === null || inputValue === undefined) {
            this.rows[index].amount = 0;
            this.rows[index].percent = 0;
        } else {
            const newAmount = this.safeParseFloat(inputValue);
            this.rows[index].amount = this.roundToTwoDecimals(newAmount);
            
            if (this._totalAmount && this._totalAmount > 0) {
                const calculatedPercent = (this.rows[index].amount / this._totalAmount) * 100;
                this.rows[index].percent = this.roundToTwoDecimals(calculatedPercent);
            } else {
                this.rows[index].percent = 0;
            }
        }

        // Check if amount exceeds available allocation
        this.checkAmountExceedsAvailable(index);

        this.updateFormattedValues(index);
        this.calculateTotals();
        this.rows = [...this.rows];
        this.updateRowClasses();
    }

    checkAmountExceedsAvailable(index) {
        const row = this.rows[index];
        
        if (this.isEditMode && row.isOriginalAccount) {
            // For original accounts in edit mode
            const originalAmount = this.originalAllocatedAmounts.get(row.accountId) || 0;
            const effectiveAvailableAmount = row.availableAmount + originalAmount;
            
            if (effectiveAvailableAmount > 0 && row.amount > effectiveAvailableAmount) {
                row.errorExceedsAvailable = true;
            } else {
                row.errorExceedsAvailable = false;
            }
            
            // Don't show zero amount error if there was an original allocation
            if (originalAmount > 0) {
                row.errorZeroAmount = false;
            }
        } else {
            // Normal validation for create/clone mode or new accounts in edit mode
            if (row.availableAmount > 0 && row.amount > row.availableAmount) {
                row.errorExceedsAvailable = true;
            } else {
                row.errorExceedsAvailable = false;
            }
        }
    }

    updateFormattedValues(index = null) {
        if (index !== null) {
            const row = this.rows[index];
            const percent = this.safeParseFloat(row.percent);
            const amount = this.safeParseFloat(row.amount);
            
            row.formattedPercent = `${this.roundToTwoDecimals(percent).toFixed(2)}%`;
            row.formattedAmount = new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD'
            }).format(amount);
        } else {
            this.rows = this.rows.map(row => {
                const percent = this.safeParseFloat(row.percent);
                const amount = this.safeParseFloat(row.amount);
                
                return {
                    ...row,
                    formattedPercent: `${this.roundToTwoDecimals(percent).toFixed(2)}%`,
                    formattedAmount: new Intl.NumberFormat('en-US', {
                        style: 'currency',
                        currency: 'USD'
                    }).format(amount)
                };
            });
        }
    }

    checkForDuplicates() {
        this.duplicateAccounts.clear();
        this.rows.forEach(row => row.errorDuplicate = false);

        this.rows.forEach(row => {
            if (row.accountId) {
                if (this.duplicateAccounts.has(row.accountId)) {
                    row.errorDuplicate = true;
                } else {
                    this.duplicateAccounts.add(row.accountId);
                }
            }
        });
    }

    calculateTotals() {
        let totalPercent = 0;
        let totalAmount = 0;
        
        for (let row of this.rows) {
            totalPercent += this.safeParseFloat(row.percent);
            totalAmount += this.safeParseFloat(row.amount);
        }
        
        // Round totals to avoid floating point precision issues
        this.totalPercentage = this.roundToTwoDecimals(totalPercent);
        this.calculatedTotalAmount = this.roundToTwoDecimals(totalAmount);
        
    }

    @api
    getAllAccountAllocationDetails() {
        return this.rows.map(row => ({
            accountId: row.accountId || null,
            percent: this.safeParseFloat(row.percent),
            amount: this.safeParseFloat(row.amount),
        }));
    }

    @api
    validate() {
        // First, refresh allocations to get latest data
        this.validateAllAllocationsInBackground();
        
        let allValid = true;
        // Round total percentage for comparison to avoid floating point issues
        const roundedTotalPercentage = this.roundToTwoDecimals(this.totalPercentage);
        
        // Use tolerance for percentage comparison (allow 0.02% difference to handle floating point)
        const totalPercentageError = Math.abs(roundedTotalPercentage - 100) > 0.02;
        const totalAmountError = Math.abs(this.calculatedTotalAmount - this._totalAmount) > 0.02;

        this.rows = this.rows.map((row, index) => {
            row.errorAccount = !row.accountId || row.accountId === null || row.accountId === '';
            
            const percent = this.safeParseFloat(row.percent);
            const amount = this.safeParseFloat(row.amount);
            
            row.errorPercent = percent <= 0;
            row.errorAmount = amount <= 0;
            
            row.errorOverPercent = roundedTotalPercentage > 100.02; // Use tolerance here too
            row.errorOverAmount = this.calculatedTotalAmount > this._totalAmount + 0.02; // Use tolerance here too
            
            // Check if this row has any individual errors
            const hasIndividualErrors = row.errorAccount || 
                row.errorPercent || 
                row.errorAmount ||
                row.errorDuplicate || 
                row.errorOverPercent ||
                row.errorOverAmount ||
                row.errorNoAllocation ||
                row.errorExceedsAvailable ||
                row.errorZeroAmount;

            // Only show total errors on the last row and only if no individual errors exist
            const isLastRow = index === this.rows.length - 1;
            
            row.errorTotalPercent = totalPercentageError && isLastRow && !hasIndividualErrors;
            row.errorTotalAmount = totalAmountError && isLastRow && !hasIndividualErrors;

            if (
                row.errorAccount ||
                row.errorPercent ||
                row.errorAmount ||
                row.errorDuplicate ||
                row.errorOverPercent ||
                row.errorOverAmount ||
                row.errorNoAllocation ||
                row.errorExceedsAvailable ||
                row.errorZeroAmount ||
                row.errorTotalPercent ||
                row.errorTotalAmount
            ) {
                allValid = false;
            }
            
            return row;
        });

        this.updateRowClasses();
        this.rows = [...this.rows];
        
        return allValid;
    }

    updateRowClasses() {
        this.rows = this.rows.map(row => ({
            ...row,
            rowClass:
                row.errorAccount ||
                row.errorPercent ||
                row.errorAmount ||
                row.errorDuplicate ||
                row.errorOverPercent ||
                row.errorOverAmount ||
                row.errorTotalPercent ||
                row.errorTotalAmount ||
                row.errorNoAllocation ||
                row.errorExceedsAvailable ||
                row.errorZeroAmount
                    ? 'row-error'
                    : ''
        }));
    }
}