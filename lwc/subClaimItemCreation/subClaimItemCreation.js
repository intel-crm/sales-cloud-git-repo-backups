import { LightningElement, api, track, wire } from 'lwc';
import getAccountNodes from '@salesforce/apex/Core_MDF_PartnerFundClaim.getAccountNodes';
import fetchBankRecordsForAccounts from '@salesforce/apex/Core_MDF_PartnerFundClaim.fetchBankRecordsForAccounts';
import CREDIT_BASED_LABEL from '@salesforce/label/c.Core_MDF_CreditBased_BankNotApplicable';
import REIMBURSEMENT_REQUEST_LABEL from '@salesforce/label/c.Core_MDF_nonTranslate_Reimbursement_Request_for_3rd_party_payment';
import SERVICE_INVOICE_LABEL from '@salesforce/label/c.Core_MDF_nonTranslate_Service_Invoice_to_Intel';

export default class SubClaimItemCreation extends LightningElement {
    @track accountNodes = [];
    _superActivityId;
    _totalRequestedAmount;
    _totalCostNotReimbursable;
    userSelections = {};
    invoiceTypeOptions = [];

    @api
    set superActivityId(value) {
        this._superActivityId = value;
        if (value) {
            console.log('superActivityId received:', value);
            this.fetchAccountNodes();
        } else {
            console.warn('superActivityId not provided yet.');
        }
    }
    get superActivityId() {
        return this._superActivityId;
    }

    @api
    set totalRequestedAmount(value) {
        this._totalRequestedAmount = value;
        if (this.accountNodes?.length > 0 && value) {
            console.log('totalRequestedAmount updated:', value);
            this.recalculateNodeAmounts();
        }
    }
    get totalRequestedAmount() {
        return this._totalRequestedAmount;
    }

    @api
    set totalCostNotReimbursable(value) {
        this._totalCostNotReimbursable = value;
        if (this.accountNodes?.length > 0 && value) {
            console.log('totalCostNotReimbursable updated:', value);
            this.recalculateOtherCostNotReimbursable();
        }
    }
    get totalCostNotReimbursable() {
        return this._totalCostNotReimbursable;
    }

    async fetchAccountNodes() {
        const nodes = await getAccountNodes({ superActivityId: this.superActivityId }) || [];
        console.log('@@Nodes',nodes);
        //const accountIds = nodes.map(n => n.ChannelPartnerId);
        const accountIds = nodes.map(n => n.accountId);
        const bankMap = await fetchBankRecordsForAccounts({ accountIds }) || {};

        this.nodesRaw = nodes;
        this.bankMapRaw = bankMap;

        this.rebuildNodes();
    }

    rebuildNodes() {
    this.accountNodes = this.nodesRaw.map(node => {
        //const nodeId = node.ChannelPartnerId;
        const nodeId = node.accountId;
        let banks = (this.bankMapRaw[nodeId] || []).map(b => ({
            label: `${b.bankName} - ${b.bankAlias} - ${b.bankStatus}`,
            value: b.bankId,
            companyCode: b.companyCode
        }));

        const saved = this.userSelections[nodeId] || {};

        let selectedBank = saved.selectedBank;
        let disableBankField = false;
        let vatValue = saved.vatValue ?? null;
        let vatDisabled = saved.vatDisabled ?? true;

        if(banks.length === 0){
            banks = [
                {label: CREDIT_BASED_LABEL, value: CREDIT_BASED_LABEL}
            ];
            selectedBank = CREDIT_BASED_LABEL;
            vatValue = 'No';
            vatDisabled = true;
            disableBankField = true;
        }

        if (!selectedBank && banks.length === 1) {
            selectedBank = banks[0].value;
        }

        const isCreditBased = selectedBank === CREDIT_BASED_LABEL;

        if (!saved.vatValue && selectedBank && !isCreditBased) {
            const bank = banks.find(b => b.value === selectedBank);
            const isVatEligible = bank?.companyCode == 420 || bank?.companyCode == 650;

            vatValue = isVatEligible ? null : REIMBURSEMENT_REQUEST_LABEL;
            vatDisabled = !isVatEligible;
        }

        this.userSelections[nodeId] = { selectedBank, vatValue, vatDisabled };

        /*return {
            accountNodeId: nodeId,
            accountNodeName: node.ChannelPartner?.Name,
            percentage: node.Core_MDF_Amount_Percentage__c,
            nodeAmount: this.calculateNodeAmount(node.Core_MDF_Amount_Percentage__c / 100),
            reimbursableAmount: this.calculateOtherCostNotReimbursable(node.Core_MDF_Amount_Percentage__c / 100),
            percentage: node.percentage || 0,
            nodeAmount: this.calculateNodeAmount((node.percentage || 0) / 100),
            reimbursableAmount: this.calculateOtherCostNotReimbursable((node.percentage || 0) / 100),
            banks,
            selectedBank,
            disableBankField,
            vatOptions: [
                { label: SERVICE_INVOICE_LABEL, value: SERVICE_INVOICE_LABEL},
                { label: REIMBURSEMENT_REQUEST_LABEL, value: REIMBURSEMENT_REQUEST_LABEL}
            ],
            vatValue,
            vatDisabled,
            requestId: node.Id,
            Title: node.Title
        };*/
        return {
            accountNodeId: node.accountId,
            accountNodeName: node.accountName,
            percentage: node.percentage || 0,
            nodeAmount: this.calculateNodeAmount((node.percentage || 0) / 100),
            reimbursableAmount: this.calculateOtherCostNotReimbursable((node.percentage || 0) / 100),
            banks,
            selectedBank,
            disableBankField,
            vatOptions: [
                { label: SERVICE_INVOICE_LABEL, value: SERVICE_INVOICE_LABEL },
                { label: REIMBURSEMENT_REQUEST_LABEL, value: REIMBURSEMENT_REQUEST_LABEL }
            ],
            vatValue,
            vatDisabled,
            requestId: node.activityId,
            Title: node.activityTitle
        };
    });
    console.log('✅ Final UI nodes:', JSON.stringify(this.accountNodes));
}

    handleBankChange(event) {
        const nodeId = event.target.dataset.nodeId;
        const selectedBank = event.target.value;

        const bank = this.accountNodes.find(n => n.accountNodeId === nodeId)
                         .banks.find(b => b.value === selectedBank);
        const isVatEligible = bank?.companyCode == 420 || bank?.companyCode == 650;
        this.userSelections[nodeId] = {
            ...this.userSelections[nodeId],
            selectedBank,
            vatValue: isVatEligible ? null : REIMBURSEMENT_REQUEST_LABEL,
            vatDisabled: !isVatEligible
        };

        this.rebuildNodes();
        this.emitSubClaimChange();
    }

    handleVatChange(event) {
        const nodeId = event.target.dataset.nodeId;
        const vatValue = event.target.value;
        this.userSelections[nodeId] = {
            ...this.userSelections[nodeId],
            vatValue
        };

        this.rebuildNodes();
        this.emitSubClaimChange();
    }

    getPreviousSelection(nodeId) {
        const existing = this.accountNodes?.find(n => n.accountNodeId === nodeId);
        return existing ? existing.selectedBank : null;
    }

    recalculateNodeAmounts() {
        this.accountNodes = this.accountNodes.map(node => ({
            ...node,
            nodeAmount: this.calculateNodeAmount(node.percentage / 100)
        }));
        this.emitSubClaimChange();
    }

    calculateNodeAmount(percentageDecimal) {
        console.log('@totalRequestedAmount',this.totalRequestedAmount);
        console.log('@percentageDecimal',percentageDecimal);
        return this.totalRequestedAmount ? this.totalRequestedAmount * percentageDecimal : 0;
    }

    recalculateOtherCostNotReimbursable() {
        this.accountNodes = this.accountNodes.map(node => ({
            ...node,
            reimbursableAmount: this.calculateOtherCostNotReimbursable(node.percentage / 100)
        }));
        this.emitSubClaimChange();
    }

    calculateOtherCostNotReimbursable(percentageDecimal) {
        return this.totalCostNotReimbursable ? this.totalCostNotReimbursable * percentageDecimal : 0;
    }

    emitSubClaimChange() {
        console.log('Dispatching subclaimchange:', JSON.stringify(this.accountNodes));
        const subClaimEvent = new CustomEvent('subclaimchange', {
            detail: { subClaims: this.accountNodes } 
        });
        this.dispatchEvent(subClaimEvent);
    }

    @api validateBanks() {
        let isValid = true;
        this.template.querySelectorAll('lightning-combobox').forEach(cmb => {
            if (!cmb.reportValidity()) {
                isValid = false;
            }
        });
        return isValid;
    }
}