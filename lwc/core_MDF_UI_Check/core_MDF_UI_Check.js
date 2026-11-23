import { LightningElement, track, api } from 'lwc';
import searchAccounts from '@salesforce/apex/Core_MDF_Outcome_Acc_Based_Activity.searchAccounts';

export default class AccountPercentageList extends LightningElement {

    @api parentAccountId;
    @api recordId;

    @track rows = [
        { 
            id: 1,
            accountId: null,
            accountName: '',
            percent: null,
            percentFormatted: '0.00',
            calculatedAmount: 0,
            errorMessage: '',
            searchResults: []
        }
    ];

    rowId = 1;
    totalPercentage = 0;

    isAddButtonDisabled = false;
    isPercentOver = false;      // total > 100
    isPercentUnder = false;     // total < 100
    isTotal100Percent = false;  // total == 100

    duplicateAccounts = new Set();
    _totalAmount = 0;

    /*─────────────────────────────────────────────
     * Update totals when parent passes new amount
     *─────────────────────────────────────────────*/
    @api
    set totalAmount(value) {
        this._totalAmount = value;

        this.rows = this.rows.map(row => {
            const p = row.percent || 0;
            return {
                ...row,
                calculatedAmount: (p / 100) * value
            };
        });
    }
    get totalAmount() {
        return this._totalAmount;
    }

    /*─────────────────────────────────────────────
     * Add Row
     *─────────────────────────────────────────────*/
    addRow() {
        if (this.totalPercentage < 100) {
            this.rowId++;
            this.rows = [
                ...this.rows,
                { 
                    id: this.rowId,
                    accountId: null,
                    accountName: '',
                    percent: null,
                    percentFormatted: '0.00',
                    calculatedAmount: 0,
                    errorMessage: '',
                    searchResults: []
                }
            ];
            this.calculateTotalPercentage();
        }
    }

    /*─────────────────────────────────────────────
     * Remove Row
     *─────────────────────────────────────────────*/
    removeRow(event) {
        const index = event.target.dataset.index;
        this.rows.splice(index, 1);
        this.rows = [...this.rows];

        this.calculateTotalPercentage();
        this.checkForDuplicates();
    }

    /*─────────────────────────────────────────────
     * Account Search
     *─────────────────────────────────────────────*/
    handleAccountSearch(event) {
        const index = event.target.dataset.index;
        const searchTerm = event.target.value;

        if (searchTerm.length > 2) { 
            this.rows[index].searchResults = [];
            searchAccounts({ parentAccountId: this.parentAccountId, searchKey: searchTerm })
                .then(result => {
                    this.rows[index].searchResults = result;
                })
                .catch(error => console.error("Error in account search", error));
        } else {
            this.rows[index].searchResults = [];
        }

        this.rows[index].errorMessage = '';
        this.rows = [...this.rows];
    }

    /*─────────────────────────────────────────────
     * Select Account
     *─────────────────────────────────────────────*/
    selectAccount(event) {
        const index = event.target.dataset.index;
        const accountId = event.target.dataset.id;
        const accountName = event.target.label;

        this.rows[index].accountId = accountId;
        this.rows[index].accountName = accountName;
        this.rows[index].searchResults = [];

        this.checkForDuplicates();
        this.rows = [...this.rows];
        this.calculateTotalPercentage();
    }

    /*─────────────────────────────────────────────
     * Percent Change
     *─────────────────────────────────────────────*/
    handlePercentChange(event) {
        const index = event.target.dataset.index;
        const newPercent = parseFloat(event.target.value);

        this.rows[index].percentFormatted = isNaN(newPercent) ? '0.00' : newPercent.toFixed(2);
        this.rows[index].percent = isNaN(newPercent) ? 0 : newPercent;

        this.rows[index].calculatedAmount =
            isNaN(newPercent) ? 0 : (newPercent / 100) * (this._totalAmount || 0);

        this.calculateTotalPercentage();
        this.rows = [...this.rows];
    }

    /*─────────────────────────────────────────────
     * Check Duplicate Accounts
     *─────────────────────────────────────────────*/
    checkForDuplicates() {
        this.duplicateAccounts.clear();
        let hasDuplicate = false;

        this.rows.forEach(row => {
            row.errorMessage = '';

            if (row.accountId) {
                if (this.duplicateAccounts.has(row.accountId)) {
                    row.errorMessage = 'Duplicate account selected!';
                    hasDuplicate = true;
                } else {
                    this.duplicateAccounts.add(row.accountId);
                }
            }
        });

        this.isAddButtonDisabled = hasDuplicate || this.totalPercentage >= 100;
    }

    /*─────────────────────────────────────────────
     * Total Percentage Calculation
     *─────────────────────────────────────────────*/
    calculateTotalPercentage() {
        this.totalPercentage = this.rows.reduce((sum, row) => sum + (row.percent || 0), 0);

        // reset flags
        this.isPercentUnder = false;
        this.isPercentOver = false;
        this.isTotal100Percent = false;

        if (this.totalPercentage > 100) {
            this.isPercentOver = true;
            this.isAddButtonDisabled = true;
        }
        else if (this.totalPercentage === 100) {
            this.isTotal100Percent = true;
            this.isAddButtonDisabled = true;
        }
        else {
            // less than 100
            this.isAddButtonDisabled = false;
        }
    }

    /*─────────────────────────────────────────────
     * Return Details to Aura Parent
     *─────────────────────────────────────────────*/
    @api
    getAllAccountAllocationDetails() {
        return this.rows.map(row => ({
            accountId: row.accountId || null,
            accountName: row.accountName || '',
            percent: row.percent || 0,
            percentFormatted: row.percentFormatted || '0.00',
            calculatedAmount: row.calculatedAmount || 0
        }));
    }

    /*─────────────────────────────────────────────
     * VALIDATION for Aura Save
     *─────────────────────────────────────────────*/
    @api
    validate() {
        let allValid = true;

        // Reset flags
        this.isPercentOver = false;
        this.isPercentUnder = false;

        // 1️⃣ Duplicate accounts
        const duplicateExists = [...this.rows].some(row => row.errorMessage === 'Duplicate account selected!');
        if (duplicateExists) allValid = false;

        // 2️⃣ Total must be 100%
        if (this.totalPercentage < 100) {
            this.isPercentUnder = true;
            allValid = false;
        }
        if (this.totalPercentage > 100) {
            this.isPercentOver = true;
            allValid = false;
        }

        // 3️⃣ Account Required
        this.rows.forEach((row, index) => {
            if (!row.accountId) {
                allValid = false;
                const input = this.template.querySelector(
                    `lightning-input[data-index="${index}"][type="search"]`
                );
                if (input) {
                    input.setCustomValidity("Please select an account.");
                    input.reportValidity();
                }
            }
        });

        // 4️⃣ Percent Required
        this.rows.forEach((row, index) => {
            const input = this.template.querySelector(
                `lightning-input[data-index="${index}"][type="number"]`
            );
            if (!input) return;

            input.setCustomValidity("");

            if (row.percent === null || row.percent === "" || isNaN(row.percent)) {
                input.setCustomValidity("Percentage is required.");
                allValid = false;
            }
            input.reportValidity();
        });

        return allValid;
    }
    get hasDuplicate() {
    return [...this.rows].some(r => r.errorMessage === 'Duplicate account selected!');
    }

    get hasErrors() {
        return this.isPercentOver || this.isPercentUnder || this.hasDuplicate;
    }

}