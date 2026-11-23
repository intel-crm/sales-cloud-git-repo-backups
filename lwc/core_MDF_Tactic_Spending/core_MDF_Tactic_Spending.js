import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTacticSpending from '@salesforce/apex/Core_MDF_Tactics_Controller.getTacticSpending';
import TACTIC_SPENDING_TEXT from '@salesforce/label/c.Core_MDF_Tactic_Spending';
import TACTIC_TEXT from '@salesforce/label/c.Core_MDF_Tactic';
import TOTAL_PLANNED_SPEND_TEXT from '@salesforce/label/c.Core_MDF_Total_Planned_Spend';
import PREVIOUS_PERIOD_SPENDS_TEXT from '@salesforce/label/c.Core_MDF_Previous_Period_Spends';
import REMAINING_SPEND_TEXT from '@salesforce/label/c.Core_MDF_Remaining_Spend';
import SPEND_THIS_PERIOD_TEXT from '@salesforce/label/c.Core_MDF_Spend_this_Period';
import INTEL_CONTRIBUTION_TEXT from '@salesforce/label/c.Core_MDF_Intel_Contribution_this_Period';
import reimbursementRateLabel from '@salesforce/label/c.Core_MDF_Reimbursement_Rate_Label';
import SPEND_THIS_PERIOD_HELPTEXT from '@salesforce/label/c.Core_MDF_Spend_this_Period_HelpText';
import TOTAL_AMOUNT_USD from '@salesforce/label/c.Core_MDF_Total_Amount_USD';
import TOTAL_LABEL from '@salesforce/label/c.Core_MDF_Total';
import totalSpendError1 from '@salesforce/label/c.Core_MDF_Total_Spend';
import totalSpendError2 from '@salesforce/label/c.Core_MDF_Total_Spend_Error';
import intelContributionError1 from '@salesforce/label/c.Core_MDF_Intel_Contribution_Error1';
import intelContributionError2 from '@salesforce/label/c.Core_MDF_Intel_Contribution_Error2';
import totalPlannedSpendError from '@salesforce/label/c.Core_MDF_Total_Planned_Spend_error';
import CURRENCY_CONVERTER_TITLE from '@salesforce/label/c.Core_MDF_Currency_Converter_Title';
import total_planned_spend_help_text from '@salesforce/label/c.Core_MDF_total_planned_spend_help_text';
import previous_period_spends_help_text from '@salesforce/label/c.Core_MDF_previous_period_spends_help_text';
import remaining_spend_help_text from '@salesforce/label/c.Core_MDF_remaining_spend_help_text';
import Intel_contribution_this_period_help_text from '@salesforce/label/c.Core_MDF_Intel_contribution_this_period_help_text';
import Core_MDF_Error from '@salesforce/label/c.Core_MDF_Error';
import APPLICATION_ERROR from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';


export default class Core_MDF_Tactic_Spending extends LightningElement {
    @api editable = false;
    @api activityId;
    @api recordId; //Claim Id
    @api reimbursableAmountUsd;
    @api reimbursementRate;
    @api editCmp = false;
    @track showTacticSpending = false;
        @track showCurrencyConverter = false;

    //Custom Labels
    tacticSpendingText = TACTIC_SPENDING_TEXT;
    currencyConverterHeader = CURRENCY_CONVERTER_TITLE;
    tacticText = TACTIC_TEXT;
    totalPlannedSpendText = TOTAL_PLANNED_SPEND_TEXT;
    previousPeriodSpendsText = PREVIOUS_PERIOD_SPENDS_TEXT;
    ramainingSpendText = REMAINING_SPEND_TEXT;
    spendThisPeriodText = SPEND_THIS_PERIOD_TEXT;
    intelContributionText = INTEL_CONTRIBUTION_TEXT;
    reimbursementRateLabel = reimbursementRateLabel;
    spendThisPeriodHelpText = SPEND_THIS_PERIOD_HELPTEXT;
    totalAmountUsdLabel = TOTAL_AMOUNT_USD;
    totalLabel = TOTAL_LABEL;
    
    totalSpendError1 = totalSpendError1;
    totalSpendError2 = totalSpendError2;
    intelContributionError1 = intelContributionError1;
    intelContributionError2 = intelContributionError2;
    totalPlannedSpendError = totalPlannedSpendError;
    errorLabel = Core_MDF_Error;
    applicationError = APPLICATION_ERROR;
    
    @track total_planned_spend_help_text = total_planned_spend_help_text;
    @track previous_period_spends_help_text = previous_period_spends_help_text;
    @track remaining_spend_help_text = remaining_spend_help_text;
    @track Intel_contribution_this_period_help_text = Intel_contribution_this_period_help_text;

    @track tactics = [];

    connectedCallback() {
        this.loadTacticSpendingDetails();
    }
    openCurrencyConverter() {
        this.showCurrencyConverter = true;
    }

    closeCurrencyConverter() {
        this.showCurrencyConverter = false;
    }

    loadTacticSpendingDetails(){
        getTacticSpending({ 
            editable: this.editable, 
            claimId: this.recordId, 
            activityId: this.activityId 
        })
        .then(result => {
            if(result && result.length > 0){
                const rows = result.map(r => ({
                    ...r,
                    isTotal: false,
                    className: ''
                }));

                const totalRow = this.getTotalRow(rows);
                totalRow.isTotal = true;
                totalRow.className = 'total-row';

                this.tactics = [...rows, totalRow];

            this.showTacticSpending = result[0].ipaOutcomeBased;
            this.reimbursementRate = result[0].reimbursementRate;
            }
        })
        .catch(error => {
            this.handleServerExceptions();
        });
    }

    handleServerExceptions(){
        this.showToast(this.errorLabel, this.applicationError, 'error', 'dismissable');
    }

    getTotalRow(rows) {
        const sum = (key) => rows.reduce((acc, r) => acc + (parseFloat(r[key]) || 0), 0);
    
        return {
            tactic: 'TOTAL',
            tacticLabel: this.totalLabel,
            totalPlannedSpend: sum('totalPlannedSpend').toFixed(2),
            previousSpend: sum('previousSpend').toFixed(2),
            remainingSpend: (sum('totalPlannedSpend') - sum('previousSpend')).toFixed(2),
            spendThisPeriod: sum('spendThisPeriod').toFixed(2),
            intelContribution: sum('intelContribution').toFixed(2),
            editable: false,
            isTotal: true,
            className: 'total-row'
        };
    }
    

    handleSpendChange(event) {
        const index = event.target.dataset.index;
        const input = event.target;
        /*let value1 = event.target.value;
        if (value1.includes('.')) {
            let [intPart, decPart] = value1.split('.');
            if (decPart.length > 2) {
                event.target.value = parseFloat(intPart + '.' + decPart.substring(0, 2));
            }
        }*/
        const value = parseFloat(input.value);
        //const value = input.value;

        const row = this.tactics[index];
        if (row.isTotal) return;

        this.tactics[index].spendThisPeriod = isNaN(value) ? 0 : value;//0 Assignment
        //this.tactics[index].spendThisPeriod = value;//0 Assignment

        // Validate single input
        const isValid = this.validateInput(input, index, true);

        if (isValid) {
            const row = this.tactics[index];
            const contribution = ((row.spendThisPeriod || 0) * (row.reimbursementRate)) / 100;
            row.intelContribution = contribution ? parseFloat(contribution.toFixed(2)) : '';
        } else {
            this.tactics[index].intelContribution = '';
        }
        this.updateTotalRow();
    }

    updateTotalRow() {
        const dataRows = this.tactics.filter(r => !r.isTotal);
        const totalRow = this.getTotalRow(dataRows);
        this.tactics = [...dataRows, totalRow];
    }
    

    @api validate() {
        const allInputs = this.template.querySelectorAll('lightning-input');
        let allValid = true;

        allInputs.forEach(input => {
            const index = input.dataset.index;

            const row = this.tactics[index];
            if (row?.isTotal) return;

            if (!input.reportValidity()) {
                allValid = false;
            }

            const valid = this.validateInput(input, index, false);
            if (!valid) allValid = false;
        });

        const dataRows = this.tactics.filter(row => !row.isTotal);
        const totalSpend = dataRows.reduce((sum, r) => sum + (r.spendThisPeriod || 0), 0);
        //const totalRemaining = dataRows.reduce((sum, r) => sum + (r.totalPlannedSpend - r.previousSpend), 0);
        const totalRemaining = dataRows.reduce((sum, r) => sum + (r.totalPlannedSpend), 0);
        //const totalSpend = this.getTotalSpend();
        //const totalRemaining = this.getTotalRemaining();

        if (Number(totalSpend.toFixed(2)) > Number(totalRemaining.toFixed(2))) {
            this.showToast(
                this.errorLabel,
                `${totalSpendError1} ($${totalSpend.toFixed(2)}) ${totalSpendError2} ($${totalRemaining.toFixed(2)})`,
                'error'
            );
            allValid = false;
        }
        //`Total Spend ($${totalSpend}) exceeds Total Planned Spend ($${totalRemaining})`,
        //Total Spend $10 should match with Total Planned Spend $100

        if (!allValid) return allValid;

        const totalIntel = dataRows.reduce((sum, row) => {
            const contribution = (row.spendThisPeriod || 0);
            return sum + contribution;
        }, 0);

        console.log('Por debug', {totalspendthisperiod: totalIntel,
        reimbursableamountusd: this.reimbursableAmountUsd,
        reimbusesableamounttype: typeof this.reimbursableAmountUsd,
        numreimbursableamount: Number(this.reimbursableAmountUsd),
        validationFailed: Number(totalIntel.toFixed(2)) != this.reimbursableAmountUsd});
    
        if (Number(totalIntel.toFixed(2)) != this.reimbursableAmountUsd) {
            this.showToast(
                this.errorLabel,
                `${intelContributionError1} ($${totalIntel.toFixed(2)}) ${intelContributionError2} ($${this.reimbursableAmountUsd}).`,
                'error'
            );
            allValid = false;
        }

        return allValid;
    }

    @api prepareClaimAttributes() {
        const claimAttributes = [];
        const dataRows = this.tactics.filter(row => !row.isTotal);

        dataRows.forEach(row => {
            const totalPlannedSpend = {
                Core_MDF_Type_nm__c: 'Total Planned Spend',
                Core_MDF_Field_Value_nbr__c: row.totalPlannedSpend,
                Core_MDF_Tactics_nm__c: row.tactic,
                Core_MDF_Is_Active_Ind__c : true
            }

            if(row.totalPlannedSpendRecordId){
                totalPlannedSpend.Id = row.totalPlannedSpendRecordId;
            }
            claimAttributes.push(totalPlannedSpend);

            const previousPeriodSpend = {
                Core_MDF_Type_nm__c: 'Previous Period Spends',
                Core_MDF_Field_Value_nbr__c: row.previousSpend,
                Core_MDF_Tactics_nm__c: row.tactic,
                Core_MDF_Is_Active_Ind__c : true
            }

            if(row.previousSpendRecordId){
                previousPeriodSpend.Id = row.previousSpendRecordId;
            }
            claimAttributes.push(previousPeriodSpend);

            const spendThisPeriod = {
                Core_MDF_Type_nm__c: 'Spend This Period',
                Core_MDF_Field_Value_nbr__c: row.spendThisPeriod,
                Core_MDF_Tactics_nm__c: row.tactic,
                Core_MDF_Is_Active_Ind__c : true
            }

            if(row.spendThisPeriodRecordId){
                spendThisPeriod.Id = row.spendThisPeriodRecordId;
            }
            claimAttributes.push(spendThisPeriod);
        });

        return claimAttributes;
    }


    validateInput(input, index, showTotalError) {
        const row = this.tactics[index];
        if (row.isTotal) return true;

        const value = parseFloat(input.value);
        const safeValue = isNaN(value) ? 0 : value;
        //const remaining = row.totalPlannedSpend - row.previousSpend;
        const remaining = row.totalPlannedSpend;
        let limit = (remaining * 1.1) - row.previousSpend;
        limit = (limit < 0) ? 0 : limit;

        input.setCustomValidity('');

        if (safeValue > limit) {
            input.setCustomValidity(`${totalPlannedSpendError} ($${limit.toFixed(2)}).`);
            input.reportValidity();
            return false;
        }

        if (showTotalError) {
            const totalSpend = this.getTotalSpend();
            const totalRemaining = this.getTotalRemaining();

            if (totalSpend > totalRemaining) {
                input.setCustomValidity(`${totalSpendError1} ($${totalSpend}) ${totalSpendError2} ($${totalRemaining})`);
                input.reportValidity();
                return false;
            }
        }

        // Intel Contribution limit check
        /*const clonedTactics = this.tactics.filter(r => !r.isTotal).map((r, i) => {
            return i == index ? { ...r, spendThisPeriod: safeValue } : r;
        });

        const totalIntel = clonedTactics.reduce((sum, row) => {
            return sum + ((row.spendThisPeriod) * (row.reimbursementRate) / 100);
        }, 0);
        
        if (totalIntel > this.reimbursableAmountUsd) {
            input.setCustomValidity(`Intel Contribution ($${totalIntel.toFixed(2)}) should match with Claim Reimbursement Amount ($${this.reimbursableAmountUsd}).`);
            input.reportValidity();
            return false;
        }*/

        input.reportValidity();
        return true;
    }

    getTotalSpend() {
        //return this.tactics.reduce((sum, r) => sum + (r.spendThisPeriod || 0), 0);
        return this.tactics.reduce((sum, r) => sum + (r.isTotal ? 0 : (r.spendThisPeriod || 0)),0);
    }

    getTotalRemaining() {
        //return this.tactics.reduce((sum, r) => sum + (r.totalPlannedSpend - r.previousSpend), 0);
        //return this.tactics.reduce((sum, r) => sum + (r.totalPlannedSpend), 0);
        return this.tactics.reduce((sum, r) => sum + (r.isTotal ? 0 : (r.totalPlannedSpend || 0)),0);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}