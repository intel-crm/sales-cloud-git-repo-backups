import { LightningElement, api, track, wire } from 'lwc';
import getAccountNodes from '@salesforce/apex/Core_MDF_PartnerFundClaim.getAccountNodes';
import fetchBankRecordsForAccounts from '@salesforce/apex/Core_MDF_PartnerFundClaim.fetchBankRecordsForAccounts';
import getSubClaims from '@salesforce/apex/Core_MDF_PartnerFundClaim.getSubClaims';
import checkProgramLEForVatOptIn from '@salesforce/apex/Core_MDF_PartnerFundClaim.ckeckProgramLEForVatOptIn';
import CREDIT_BASED_LABEL from '@salesforce/label/c.Core_MDF_CreditBased_BankNotApplicable';
import REIMBURSEMENT_REQUEST_LABEL from '@salesforce/label/c.Core_MDF_nonTranslate_Reimbursement_Request_for_3rd_party_payment';
import SERVICE_INVOICE_LABEL from '@salesforce/label/c.Core_MDF_nonTranslate_Service_Invoice_to_Intel';
import paymentTypesToHideBank from '@salesforce/label/c.Core_MDF_IPA_PaymentTypes_to_hideBank';
import FUNDING_RESOURCES from '@salesforce/label/c.Core_MDF_Funding_Resources';
import ACCOUNT_NODE from '@salesforce/label/c.Core_MDF_Account_Node';
import NODE_AMOUNT from '@salesforce/label/c.Core_MDF_Node_Amount';
import STATUS from '@salesforce/label/c.Core_MDF_Status';
import BANK from '@salesforce/label/c.Core_MDF_Bank';
import INVOICE_TYPE from '@salesforce/label/c.Core_MDF_Invoice_Type';
import SELECT from '@salesforce/label/c.Core_MDF_Select';
import Core_MDF_AccountBankMapping_Error from '@salesforce/label/c.Core_MDF_AccountBankMapping_Error';
import Core_MDF_CompleteThisField_ErrorMessage from '@salesforce/label/c.Core_MDF_CompleteThisField_ErrorMessage';
import Core_MDF_EditClaimStatusValues from '@salesforce/label/c.Core_MDF_EditClaimStatusValues';
const editableStatuses = Core_MDF_EditClaimStatusValues.split(';');

export default class SubClaimItemCreation extends LightningElement {
    @track accountNodes = [];
    @track subClaims = [];
    _superActivityId;
    firstRun=true;
    isInitialAmountLoad = true;
    _totalRequestedAmount;
    _totalCostNotReimbursable;
    userSelections = {};
    vatOptions = [];
    @api technicalProgName;
    @api claimCountry;  //Sub claim VAT Sync
    @api isEditorClone;
    @api recordId;
    @api clonedEditClaimId;
    vatConfigCache = {};
    @api isClaimEditable;
    @api isCloneClaim;
    abmErrorByNode = {};
    @track CREDIT_BASED_LABEL = CREDIT_BASED_LABEL;
    @track REIMBURSEMENT_REQUEST_LABEL = REIMBURSEMENT_REQUEST_LABEL;
    @track SERVICE_INVOICE_LABEL = SERVICE_INVOICE_LABEL;
    @track FUNDING_RESOURCES = FUNDING_RESOURCES;
    @track ACCOUNT_NODE = ACCOUNT_NODE;
    @track NODE_AMOUNT = NODE_AMOUNT;
    @track STATUS = STATUS;
    @track BANK = BANK;
    @track INVOICE_TYPE = INVOICE_TYPE;
    @track SELECT = SELECT;
    @track Core_MDF_AccountBankMapping_Error = Core_MDF_AccountBankMapping_Error;
    @track Core_MDF_CompleteThisField_ErrorMessage = Core_MDF_CompleteThisField_ErrorMessage;
    @api claimStatus;
    
    @api
    set superActivityId(value) {
        this._superActivityId = value;
        if (value) {
            //Sub claim VAT Sync
            Promise.resolve().then(() => {
                !this.isEditorClone ? this.fetchAccountNodes() : this.fetchSubClaims();
            });
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
        if (!value) return;
        if (this.accountNodes?.length > 0 || (this.isEditorClone && this.subClaims?.length)) {
            this.recalculateNodeAmounts();
        }
    }
    get totalRequestedAmount() {
        return this._totalRequestedAmount;
    }

    @api
    set totalCostNotReimbursable(value) {
        this._totalCostNotReimbursable = value;
        if(!value) return;
        if (this.accountNodes?.length > 0 || (this.isEditorClone && this.subClaims?.length)) {
            this.recalculateOtherCostNotReimbursable();
        }
    }
    get totalCostNotReimbursable() {
        return this._totalCostNotReimbursable;
    }

    get hiddenPaymentTypes() {
        return paymentTypesToHideBank ? paymentTypesToHideBank.split(',').map(v => v.trim()) : [];
    }

    async fetchAccountNodes() {
    try {
        const [nodes, bankMap, existingClaims] = await Promise.all([
            getAccountNodes({ superActivityId: this.superActivityId }),
            getAccountNodes({ superActivityId: this.superActivityId })
                .then(n => fetchBankRecordsForAccounts({ accountIds: n.map(x => x.accountId) }))
        ]);

        this.nodesRaw = nodes || [];
        this.bankMapRaw = bankMap || {};

        this.userSelections = {};
        existingClaims?.forEach(sc => {
            this.userSelections[sc.ChannelPartnerId] = {
                selectedBank: sc.Core_MDF_Bank__c,
                vatValue: sc.Core_MDF_VAT_Opt_In__c
            };
        });

        this.buildNodesOnce();
        this.evaluateVatForExistingNodesOptimized();

    } catch (e) {
        console.error(e);
    }
}

buildNodesOnce() {
    this.accountNodes = this.nodesRaw.map(node => {
        const nodeId = node.accountId;
        const saved = this.userSelections[nodeId] || {};
        const paymentType = node.paymentType; 
        const isBankApplicable = !this.hiddenPaymentTypes.includes(paymentType);
        let banks = [];
        let selectedBank = saved.selectedBank;
        let vatValue = saved.vatValue ?? null;
        let vatDisabled = saved.vatDisabled ?? (!saved.selectedBank || saved.selectedBank === CREDIT_BASED_LABEL);
        let disableBankField = false;
        
        if (!isBankApplicable) {
            banks = [{ label: CREDIT_BASED_LABEL, value: CREDIT_BASED_LABEL }];
            selectedBank = CREDIT_BASED_LABEL;
            disableBankField = true;
            vatDisabled = true;
        } 
        else {
            banks = (this.bankMapRaw[nodeId] || []).map(b => ({
                label: `${b.bankName} - ${b.bankAlias} - ${b.bankStatus}`,
                value: b.bankId,
                //Sub claim VAT Sync
                companyCode: b.companyCode,
                supplierCountryCode: b.supplierCountryCode,
                bankRegion: b.bankRegion
            }));
            disableBankField = false;
            this.abmErrorByNode[nodeId] = banks.length === 0;
            if (!selectedBank && banks.length === 1) {
                selectedBank = banks[0].value;
            }
        }

        const pct = node.percentage || 0;
        const pctDec = pct / 100;
        const vatPercentage = this.calculateVatPercentage(vatValue, selectedBank, banks);
        this.userSelections[nodeId] = { selectedBank, vatValue, vatDisabled, vatPercentage };

        return {
            accountNodeId: nodeId,
            accountNodeName: node.accountName,
            percentage: pct,
            nodeAmount: this.truncate(((this.totalRequestedAmount || 0) * pctDec)),
            reimbursableAmount: this.truncate(((this.totalCostNotReimbursable || 0) * pctDec)),
            banks,
            selectedBank,
            disableBankField,
            vatOptions: [
                { label: SERVICE_INVOICE_LABEL, value: SERVICE_INVOICE_LABEL},
                { label: REIMBURSEMENT_REQUEST_LABEL, value: REIMBURSEMENT_REQUEST_LABEL}
            ],
            vatValue,
            vatDisabled,
            isVatRequired: !vatDisabled,
            requestId: node.activityId,
            Title: node.activityTitle,
            paymentType: node.paymentType,
            vatPercentage
        };
    });
}

async handleBankChange(event) {
    const nodeId = event.target.dataset.nodeId;
    event.target.setCustomValidity('');
    event.target.reportValidity();
    const selectedBank = event.target.value;

    let node;
	if(this.isEditorClone){
    node = this.subClaims.find(n => n.claimId === nodeId);
	} else {
	node = this.accountNodes.find(n => n.accountNodeId === nodeId);
	}
    const bank = node?.banks.find(b => b.value === selectedBank);

    this.userSelections[nodeId] = {
        ...this.userSelections[nodeId],
        selectedBank,
        vatValue: null,
        vatDisabled: true,
        isVatRequired: false
    };

    this.clearVatValidity(nodeId);
    if (selectedBank === CREDIT_BASED_LABEL || !bank?.companyCode) {
        this.isEditorClone ? this.buildClaimsOnce() : this.buildNodesOnce();
        this.emitSubClaimChange();
        return;
    }

    const vatConfig = await this.getVatConfig(bank.companyCode);
    const vatState = this.resolveVatState(vatConfig, bank);  //Sub claim VAT Sync

    this.userSelections[nodeId] = {
        ...this.userSelections[nodeId],
        ...vatState
    };

    this.isEditorClone ? this.buildClaimsOnce() : this.buildNodesOnce();
    this.emitSubClaimChange();
}

clearVatValidity(nodeId) {
    const vatField = this.template.querySelector(
        `lightning-combobox[data-vat][data-vat-node-id="${nodeId}"]`
    );
    if (vatField) {
        vatField.value = null;
        vatField.setCustomValidity('');
        vatField.reportValidity();
    }
}

async getVatConfig(companyCode) {
    if (!this.vatConfigCache[companyCode]) {
        this.vatConfigCache[companyCode] =
            await checkProgramLEForVatOptIn({
                legalEntity: companyCode,
                channelProgram: this.technicalProgName
            });
    }
    return this.vatConfigCache[companyCode];
}


handleVatChange(event) {
    const nodeId = event.target.dataset.nodeId;
    event.target.setCustomValidity('');
    event.target.reportValidity();
    const value = event.target.value;

    this.userSelections[nodeId] = {
        ...this.userSelections[nodeId],
        vatValue: value
    };
    this.isEditorClone ? this.buildClaimsOnce() : this.buildNodesOnce();
    this.emitSubClaimChange();
}

calculateVatPercentage(vatValue, selectedBank, banks) {
    if (vatValue !== this.SERVICE_INVOICE_LABEL) {
        return '0';
    }
    const bank = banks?.find(b => b.value === selectedBank);
    return bank?.companyCode === '420' ? '20' : bank?.companyCode === '650' ? '10' : '0';
}

async evaluateVatForExistingNodesOptimized() {
    const tasks = this.accountNodes.map(async node => {
        const saved = this.userSelections[node.accountNodeId];
        if (!saved?.selectedBank || saved.selectedBank === CREDIT_BASED_LABEL) return;

        const bank = node.banks.find(b => b.value === saved.selectedBank);
        if (!bank?.companyCode) return;

        const res = await this.getVatConfig(bank.companyCode);

        if (saved.vatValue !== undefined && saved.vatValue !== null) {
            //Sub claim VAT Sync
            saved.vatDisabled = this.resolveVatDisabled(res, bank);
            if (saved.vatDisabled && !res?.Core_MDF_VAT_Mandatory__c) {
                saved.vatValue = null;
            }
        } else {
            this.applyVatRules(node.accountNodeId, res, bank);
        }
});

    await Promise.all(tasks);
    this.buildNodesOnce();
}

//Sub claim VAT Sync
resolveVatDisabled(res, bank) {
    if (!res) return true;
    if (res.Core_MDF_VAT_Mandatory__c) return true;
    if (res.Core_MDF_VAT_Opt_in_Option_Required__c) return !this.isOptionalVatAvailable(bank);  //Sub claim VAT Sync
    return true;
}

//Sub claim VAT Sync
applyVatRules(nodeId, res, bank) {
    let vatDisabled = true;
    let vatValue = null;

    if (res) {
        if (res.Core_MDF_VAT_Mandatory__c) {
            vatValue = SERVICE_INVOICE_LABEL;
        } else if (res.Core_MDF_VAT_Opt_in_Option_Required__c) {

        //Sub claim VAT Sync
        vatDisabled = !this.isOptionalVatAvailable(bank);
            vatValue = null;
        }
    }

    this.userSelections[nodeId] = {
        ...this.userSelections[nodeId],
        vatValue,
        vatDisabled
    };
}

//Sub claim VAT Sync
resolveVatState(vatConfig, bank) {
    let vatDisabled = true;
    let vatValue = null;

    if (!vatConfig) {
        return { vatDisabled: true, vatValue: null };
    }

    if (vatConfig.Core_MDF_VAT_Mandatory__c) {
        vatDisabled = true;
        vatValue = SERVICE_INVOICE_LABEL;
    } else if (vatConfig.Core_MDF_VAT_Opt_in_Option_Required__c) {

        //Sub claim VAT Sync
        vatDisabled = !this.isOptionalVatAvailable(bank);
        vatValue = null;
    }

    return { vatDisabled, vatValue };
}

    //Sub claim VAT Sync
    isOptionalVatAvailable(bank) {
        if (!bank?.companyCode) return false;
        if (bank.companyCode !== '420') return true;
        return bank.bankRegion === 'EMEA' && (bank.supplierCountryCode === 'GB' || this.claimCountry === 'UNITED KINGDOM');
    }

    recalculateNodeAmounts() {
        if (this.isEditorClone) {
        this.subClaims = this.subClaims.map(node => ({
            ...node,
            nodeAmount: this.calculateNodeAmount(node.percentage / 100)
        }));
        } else {
        this.accountNodes = this.accountNodes.map(node => ({
            ...node,
            nodeAmount: this.calculateNodeAmount(node.percentage / 100)
        }));
        }
        this.emitSubClaimChange();
    }

    calculateNodeAmount(percentageDecimal) {
        return this.truncate((this.totalRequestedAmount || 0) * percentageDecimal);
    }

    recalculateOtherCostNotReimbursable() {
        if (this.isEditorClone) {
        this.subClaims = this.subClaims.map(node => ({
            ...node,
            reimbursableAmount: this.calculateOtherCostNotReimbursable(node.percentage / 100)
        }));
        } else{
        this.accountNodes = this.accountNodes.map(node => ({
            ...node,
            reimbursableAmount: this.calculateOtherCostNotReimbursable(node.percentage / 100)
        }));
        }
        this.emitSubClaimChange();
    }

    calculateOtherCostNotReimbursable(percentageDecimal) {
        return this.truncate((this.totalCostNotReimbursable || 0) * percentageDecimal);
    }

    emitSubClaimChange() {
        let claimList;
        claimList = this.isEditorClone ? this.subClaims : this.accountNodes; 
        const subClaimEvent = new CustomEvent('subclaimchange', {
            detail: { subClaims: claimList } 
        });
        this.dispatchEvent(subClaimEvent);
    }

    @api validate() {
    let isValid = true;
    this.template.querySelectorAll('lightning-combobox')
        .forEach(cmb => {
            if (cmb.disabled) {
                cmb.setCustomValidity('');
                cmb.reportValidity();
                return;
            }
            if (!cmb.value) {
                const nodeId = cmb.dataset.nodeId;
                const isBank = cmb.dataset.field === 'bank';
                const nodeAccId = cmb.dataset.nodeaccId;
                const hasAbmError = (nodeId && this.abmErrorByNode?.[nodeId]) || (nodeAccId && this.abmErrorByNode?.[nodeAccId]);
                if (isBank && hasAbmError) {
                    cmb.setCustomValidity(Core_MDF_AccountBankMapping_Error);
                } else {
                    cmb.setCustomValidity(Core_MDF_CompleteThisField_ErrorMessage);
                }
                cmb.reportValidity();
                isValid = false;
            } else {
                cmb.setCustomValidity('');
                cmb.reportValidity();
            }
        });
        return isValid;
    }
    async fetchSubClaims() {
    try {
        const [existingClaims, bankMap] = await Promise.all([
            getSubClaims({ recordId: this.clonedEditClaimId }),
            getSubClaims({ recordId: this.clonedEditClaimId })
                .then(n => fetchBankRecordsForAccounts({ accountIds: n.map(x => x.accountId) }))
        ]);

        this.nodesRaw = existingClaims || [];
        this.bankMapRaw = bankMap || {};
        existingClaims?.forEach(sc => {
            this.userSelections[sc.recordId] = {
                selectedBank: sc.bankName,
                vatValue: sc.invoiceType,
                nodeAmount: this.truncate(sc.nodeAmount),  
                reimbursableAmount: this.truncate(sc.reimbursableAmount)
            };
        });
        this.buildClaimsOnce();
        this.emitSubClaimChange();
        this.firstRun = false;
        this.isInitialAmountLoad = false; 
    } catch (e) {
        console.error(e);
    }
}
buildClaimsOnce() {
    this.subClaims = this.nodesRaw.map(node => {
        const nodeId = node.recordId;
        const nodeaccId = node.accountId;
        const saved = this.userSelections[nodeId] || {};
        const paymentType = node.paymentType; 
        const claimPaymentType = node.claimPaymentType;  
        const isBankApplicable = this.isCloneClaim ? !this.hiddenPaymentTypes.includes(paymentType) : !this.hiddenPaymentTypes.includes(claimPaymentType);          
        let banks = [];
        let selectedBank = saved.selectedBank;
        let vatValue = saved.vatValue;
        let vatDisabled = saved.vatDisabled ?? false;
        let disableBankField = false;
        if(!vatValue && this.firstRun){
            vatDisabled = true;
        }
        vatValue = (this.isCloneClaim && this.firstRun) ? '' : vatValue;

        if (!isBankApplicable) {
            banks = [{ label: CREDIT_BASED_LABEL, value: CREDIT_BASED_LABEL }];
            selectedBank = CREDIT_BASED_LABEL;
            disableBankField = true;
            vatDisabled = true;
        } 
        else {
            banks = (this.bankMapRaw[nodeaccId] || []).map(b => ({
                label: `${b.bankName} - ${b.bankAlias} - ${b.bankStatus}`,
                value: b.bankId,
                //Sub claim VAT Sync
                companyCode: b.companyCode,
                supplierCountryCode: b.supplierCountryCode,
                bankRegion: b.bankRegion
            }));
            disableBankField = false;
            const isSelectedBankValid = selectedBank && banks.some(b => b.value === selectedBank);
            const becameEligibleOnClone = this.isCloneClaim && this.hiddenPaymentTypes.includes(claimPaymentType) && !this.hiddenPaymentTypes.includes(paymentType);
            this.abmErrorByNode[nodeId] = banks.length === 0 || (!isSelectedBankValid && !(becameEligibleOnClone && !selectedBank));
			if (!isSelectedBankValid) {
                selectedBank = null;
            }
            if (!selectedBank && banks.length === 1) {
                selectedBank = banks[0].value;
            }
        }
        const pct = node.percentage || 0;
        const pctDec = pct / 100;
        const nodeAmount = this.truncate(this.isInitialAmountLoad && saved.nodeAmount != null ? saved.nodeAmount : (this.totalRequestedAmount || 0) * pctDec);
        const reimbursableAmount = this.truncate(this.isInitialAmountLoad && saved.reimbursableAmount != null ? saved.reimbursableAmount : (this.totalCostNotReimbursable || 0) * pctDec);
        const vatPercentage = this.calculateVatPercentage(vatValue, selectedBank, banks);
        this.userSelections[nodeId] = { selectedBank, vatValue, vatDisabled, vatPercentage };
        this.claimStatus = !this.isCloneClaim ? node.status : '';
        return {
            claimId: nodeId,
            accountNodeName: node.accountName,
            status: !this.isCloneClaim ? node.status : '',
            percentage: pct,
            nodeAmount: nodeAmount,
            reimbursableAmount: reimbursableAmount,
            banks,
            selectedBank,
            disableBankField: this.isBankDisabled(disableBankField),
            vatOptions: [
                { label: SERVICE_INVOICE_LABEL, value: SERVICE_INVOICE_LABEL},
                { label: REIMBURSEMENT_REQUEST_LABEL, value: REIMBURSEMENT_REQUEST_LABEL}
            ],
            vatValue,
            vatDisabled: this.isVatDisabled(vatDisabled),
            isVatRequired: this.isClaimEditable && !vatDisabled,
            requestId: node.activityId,
            Title: node.activityTitle,
            accountId: node.accountId,
            paymentType: this.isCloneClaim ? paymentType : claimPaymentType,
            vatPercentage
        };
    });
}
isBankDisabled(existingRule) {
    let result = false; 
        //result = (this.isClaimEditable || this.isCloneClaim) ? existingRule : !this.isClaimEditable;
        if (!this.isCloneClaim) {
            if (existingRule) {
                result = true;
            }
            else if (!editableStatuses.includes(this.claimStatus)) {
                result = true;
            }
            else {
                result = false;
            }
        }
        else {
            if (this.isClaimEditable || this.isCloneClaim) {
                result = existingRule;
            }
            else {
                result = !this.isClaimEditable;
            }
        }
    return result;
}
isVatDisabled(existingRule) {
    let result = false; 
        //result = (this.isClaimEditable || this.isCloneClaim) ? existingRule : !this.isClaimEditable;
        if (!this.isCloneClaim) {
            if (existingRule) {
                result = true;
            }
            else if (!editableStatuses.includes(this.claimStatus)) {
                result = true;
            }
            else {
                result = false;
            }
        }
        else {
            if (this.isClaimEditable || this.isCloneClaim) {
                result = existingRule;
            }
            else {
                result = !this.isClaimEditable;
            }
        }
    return result;
}
handleBankBlur(event) {
    const nodeId = event.target.dataset.nodeId;
    const nodeAccId = event.target.dataset.nodeaccId; 
    if (!event.target.value) {
        if (this.abmErrorByNode[nodeId] || this.abmErrorByNode[nodeAccId]) {
            event.target.setCustomValidity(Core_MDF_AccountBankMapping_Error);
        } else {
            event.target.setCustomValidity(Core_MDF_CompleteThisField_ErrorMessage);
        }
    } else {
        event.target.setCustomValidity('');
    }
    event.target.reportValidity();
}

handleBankFocus(event) {
    const nodeId = event.target.dataset.nodeId;
    const nodeAccId = event.target.dataset.nodeaccId; 
    if (!event.target.value) {
        if (this.abmErrorByNode[nodeId] || this.abmErrorByNode[nodeAccId]) {
            event.target.setCustomValidity(Core_MDF_AccountBankMapping_Error);
            event.target.reportValidity();
        }
    } else {
        event.target.setCustomValidity('');
    }
}

    truncate(value) {
        const num = Number(value);
        if (isNaN(num)) return 0;
        return Math.trunc(num * 100) / 100;
    }

}